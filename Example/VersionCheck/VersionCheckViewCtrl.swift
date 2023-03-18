//
//  VersionCheckViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/8/31.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa
import SwiftyJSON

class VersionCheckViewCtrl: UIViewController {

    // MARK: - let property and IBOutlet
    
    @IBOutlet weak private var bundleIDTextField: JudyBaseTextField!
    @IBOutlet weak private var versionTextField: JudyBaseTextField!
    @IBOutlet weak private var infoLabel: UILabel!

    @IBOutlet weak private var queryButton: JudyBaseButton!
    
    private let disposeBag = DisposeBag()


    private var viewModel: VersionCheckViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = VersionCheckViewModel(
            bundleID: bundleIDTextField.rx.text.orEmpty.asObservable(),
            version: versionTextField.rx.text.orEmpty.asObservable(), tapAction: queryButton.rx.tap.asObservable())
        // 模型 -> UI
        viewModel.bundleID.bind(to: bundleIDTextField.rx.text).disposed(by: disposeBag)
        viewModel.version.bind(to: versionTextField.rx.text).disposed(by: disposeBag)
        viewModel.queryResult.bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        // UI -> 模型
        bundleIDTextField.rx.text.orEmpty.bind(to: viewModel.bundleID).disposed(by: disposeBag)
        versionTextField.rx.text.orEmpty.bind(to: viewModel.version).disposed(by: disposeBag)
        
        viewModel.queryButtonValid.bind(to: queryButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 按钮点击事件
        viewModel.appStorePublisher()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (status, appStoreURL) in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                
                if appStoreURL == nil { return }
                logn("拿到AppStore链接:\(appStoreURL!)")
                if status == .older {
                    let alertController = UIAlertController(title: "请更新版本",
                                                            message: nil,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "去更新", style: .destructive) { action -> Void in
                        if let url = URL(string: appStoreURL!) {
                            if UIApplication.shared.canOpenURL(url) {
                                logHappy("正在打开：\(url)")
                                UIApplication.shared.open(url, completionHandler: nil)
                            } else {
                                logWarning("不能打开该 URL")
                            }
                        }
                    }
                    alertController.addAction(okAction)
                    Judy.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
    }

}


struct VersionCheckViewModel {

    let bundleID = BehaviorSubject<String>(value: "com.shengda.whalemall")
    let version = BehaviorSubject<String>(value: Judy.versionShort)
    /// 查询结果的 BehaviorSubject
    let queryResult = BehaviorSubject<String>(value: "点击查询按钮开始查询")

    // 输出
    private let bundleIDValid: Observable<Bool>
    private let versionValid: Observable<Bool>
    let queryButtonValid: Observable<Bool>
    let tapAction: Observable<Void>

    
    init(bundleID: Observable<String>, version: Observable<String>, tapAction: Observable<Void>) {
        // bundleID 是否有效
        bundleIDValid = bundleID
            .map { $0.count >= 5 }
            .share(replay: 1)
        // versionValid 是否有效
        versionValid = version
            .map { $0.count >= 1 }
            .share(replay: 1)
        // 所有输入是否有效 -> 按钮是否可点击
        queryButtonValid = Observable.combineLatest(bundleIDValid, versionValid)
            .map { $0 && $1 }
            .share(replay: 1)
        
        self.tapAction = tapAction
    }
    
    /*
    /// 以 Completable 任务是否完成的方式查询版本是否有强制更新
    func versionCheckCompletable() -> Completable {
        queryResult.onNext("查询中……")
        return Completable.create { [weak self] completable in
            guard let `self` = self  else { return Disposables.create {} }
            _ = Observable.zip(self.getVersionInfo(), self.getVersionForce())
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .observe(on: MainScheduler.instance)
                .subscribe({ event in
                    switch event {
                    case .next((let versionInfo, let force)):
                        log("查询到的 versionStatus：\(versionInfo)")
                        log("查询强制更新响应的 isHot = \(force)")

                        var infoString = "查询结果\n"
                        infoString += "Bundle ID: \(try! self.bundleID.value())\n"
                        infoString += "Version: \(try! self.version.value())\n"
                        infoString += versionInfo.0.rawValue
                        self.queryResult.onNext(infoString)
                    default:
                        self.queryResult.onNext("完成查询\(event)")
                    }
                    completable(.completed)
                })

            return Disposables.create { }
        }
    }
    */

    
    /// 查询当前 App 的版本状态
    func appStorePublisher() -> Observable<(AppVersionStatus, String?)> {
        let values = Observable.combineLatest(bundleID, version)
        return tapAction.throttle(.milliseconds(3000), scheduler: MainScheduler.instance)
            .map {
                queryResult.onNext("查询中……")
            }
            .withLatestFrom(values)  // 取 infos 的最新元素
            .map { (bundle, version) in
                let requestURLStr = "https://itunes.apple.com/cn/lookup?bundleId=\(bundle)"
                let requestURL = URL(string: requestURLStr)!
                let request = URLRequest(url: requestURL, timeoutInterval: 8)
                // request.httpMethod = "POST"
                return (request, version)
            }
            .flatMap { (request, version) in
                return URLSession.shared.rx.json(request: request)
                    .map { JSON($0) }
                    .map { json in
                        sleep(5)// 线程休眠 5 秒
                        guard json["resultCount"].intValue != 0 else {
                            return (AppVersionStatus.notFound, nil)
                        }
                        let info = json["results", 0]
                        // 服务器的版本
                        let versionOnLine: String = info["version"].stringValue
                        
                        let versionStatus = AppVersionStatus.versionCompare(localVersion: version, onLineVersion: versionOnLine)
                        
                        let appStoreUrl: String?
                        if versionStatus == .older {
                            // 将 %9A%E8%8 这样的 string 转成正常的 String
                            appStoreUrl = info["trackViewUrl"].string?.removingPercentEncoding
                            // requestURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        } else {
                            appStoreUrl = nil
                        }
                        return (versionStatus, appStoreUrl)
                    }
            }
            .map { (status: AppVersionStatus, url: String?) in
                queryResult.onNext(status.localizedDescription)
                return (status, url)
            }
            .share(replay: 1)
    }
    
}

/// App 版本状态
enum AppVersionStatus {   
    /// 最新版本
    case latest
    /// 当前使用的为较旧的版本，可以更新到新版本。
    case older
    /// 当前使用的为审核版本
    case review
    /// 当前 App 尚未出现在 AppStore
    case notFound
    
    /// 版本状态比较，通过传入一个线上版本号与当前版本进行比较。
    ///
    /// - Parameter localVersion: 本地版本号
    /// - Parameter onLineVersion: 线上版本号
    /// - Returns: App 版本状态
    static func versionCompare(localVersion: String, onLineVersion: String) -> AppVersionStatus {
        var versionStatus = AppVersionStatus.latest
        
        // 切割字符串并返回数组
        var versionLocalList = localVersion.components(separatedBy: ".")
        var versionOnLineList = onLineVersion.components(separatedBy: ".")
        
        // 当要比较的两个数组长度不一致
        if versionLocalList.count != versionOnLineList.count {
            // 得到差值并补齐使之数组长度相等
            let s = versionLocalList.count - versionOnLineList.count
            for _ in 1...abs(s) {
                if versionLocalList.count > versionOnLineList.count {
                    versionOnLineList.append("0")
                } else {
                    versionLocalList.append("0")
                }
            }
        }
        var verL: Int = 0, verS: Int = 0
        // 比较版本
        for i in 0..<versionLocalList.count {
            guard (Int(versionLocalList[i]) != nil), (Int(versionOnLineList[i]) != nil) else {
                logWarning("版本号中存在非 Int 字符")
                return .latest
            }
            verL = Int(versionLocalList[i])!
            verS = Int(versionOnLineList[i])!
            if verL == verS {
                versionStatus = .latest
                continue
            }
            if verL < verS {
                versionStatus = .older
                break
            }
            if verL > verS {
                versionStatus = .review
                break
            }
        }
        
        return versionStatus
    }

}

// 添加本地化描述，我们可以显示对用户友好的错误信息。
extension AppVersionStatus: LocalizedError {
    
    var localizedDescription: String {
        switch self {
        case .latest:
            return "您使用的是最新版本!"
        case .older:
            return "发现最新版本，请及时更新!"
        case .review:
            return "您当前使用的版本正在审核……"
        case .notFound:
            return "在 AppStore 中没有发现您当前使用的 App"
        }
    }
}
