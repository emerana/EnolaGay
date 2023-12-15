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
            bundleID: bundleIDTextField.rx.text.orEmpty,
            version: versionTextField.rx.text.orEmpty,
            tapAction: queryButton.rx.tap)
        // 模型 -> UI
        viewModel.bundleID.bind(to: bundleIDTextField.rx.text).disposed(by: disposeBag)
        viewModel.version.bind(to: versionTextField.rx.text).disposed(by: disposeBag)
        viewModel.outputInfoBehaviorRelay.bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        // 按钮是否有效
        viewModel.queryButtonValid.drive(queryButton.rx.isEnabled).disposed(by: disposeBag)
        // 输入提示
//        viewModel.inputStatusInfo.drive(infoLabel.rx.text).disposed(by: disposeBag)
        
        // UI -> 模型
        bundleIDTextField.rx.text.orEmpty.bind(to: viewModel.bundleID).disposed(by: disposeBag)
        versionTextField.rx.text.orEmpty.bind(to: viewModel.version).disposed(by: disposeBag)
        
        // 按钮点击事件
        viewModel.appStoreInfoDrive()
            .drive { [weak self] (status, appStoreURL) in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                
                guard let appStoreURL = appStoreURL else { return }
                Logger.info("拿到AppStore链接:\(appStoreURL)")
                if status == .older {
                    self.showAlert(appStoreUrl: appStoreURL)
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// 弹出更新提示窗口
    private func showAlert(appStoreUrl: String) {
        let alertController = UIAlertController(title: "发现新版本",
                                                message: "点击跳转到 AppStore 以更新",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "去更新", style: .destructive) { action -> Void in
            if let url = URL(string: appStoreUrl) {
                if UIApplication.shared.canOpenURL(url) {
                    Logger.happy("正在打开：\(url)")
                    UIApplication.shared.open(url, completionHandler: nil)
                } else {
                    Logger.error("不能打开该 URL")
                }
            }
        }
        alertController.addAction(okAction)
        Judy.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

}


struct VersionCheckViewModel {

    // subjects
    let bundleID = BehaviorRelay<String>(value: "com.shengda.whalemall")
    let version = BehaviorRelay<String>(value: Judy.versionShort)
    
    /// 输出信息的 BehaviorRelay
    let outputInfoBehaviorRelay = BehaviorRelay<String>(value: "点击查询按钮开始查询")

    let queryButtonValid: Driver<Bool>
    /// 用户的输入提示信息
    let inputStatusInfo: Driver<String>
    let tapAction: ControlEvent<Void>
    
    private let bundleIDValid: Driver<Bool>
    private let versionValid: Driver<Bool>

    
    init(bundleID: ControlProperty<String>, version: ControlProperty<String>, tapAction: ControlEvent<Void>) {
        // bundleID 是否有效
        bundleIDValid = bundleID.asDriver()
            .map { $0.count >= 5 }

        // versionValid 是否有效
        versionValid = version.asDriver()
            .map { $0.count >= 1 }

        // 所有输入是否有效 -> 按钮是否可点击
        queryButtonValid = Driver.combineLatest(bundleIDValid, versionValid)
            .map { $0 && $1 }
        
        inputStatusInfo = Driver.combineLatest(bundleIDValid, versionValid)
            .map {
                if $0 == false { return "请输入正确的 bundleID" }
                if $1 == false { return "请输入正确的版本号" }
                return "点击查询按钮开始查询"
            }
        
        self.tapAction = tapAction
        
    }
        
    /// 用 Drive 的方式查询 App 版本状态
    func appStoreInfoDrive() -> Driver<(AppVersionStatus, String?)> {
        return requestAppStoreInfo()
            .asDriver(onErrorJustReturn: (.notFound, nil))
        
    }
    
    /// 查询当前 App 的版本状态
    private func requestAppStoreInfo() -> Observable<(AppVersionStatus, String?)> {
        let values = Observable.combineLatest(bundleID, version)
        return tapAction.throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map {
                outputInfoBehaviorRelay.accept("查询中……")
            }
            .withLatestFrom(values)  // 取 infos 的最新元素
            .map { (bundle: String, version: String) -> (URLRequest, String) in
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
                        sleep(5) // 线程休眠 5 秒
                        guard json["resultCount"].intValue != 0 else {
                            return (AppVersionStatus.notFound, nil)
                        }
                        let info = json["results", 0]
                        // 服务器的版本
                        let versionOnLine: String = info["version"].stringValue
                        
                        let versionStatus = AppVersionStatus.versionStatus(localVersion: version, onLineVersion: versionOnLine)
                        
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
                outputInfoBehaviorRelay.accept(status.description)
                return (status, url)
            }

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
    
    
    /// 获取当前版本状态。通过传入一个线上版本号与当前版本进行比较得出当前的版本状态。
    /// - Parameters:
    ///   - localVersion: 本地版本号
    ///   - onLineVersion: AppStore 的版本号
    /// - Returns: 当前 App 的版本状态
    static func versionStatus(localVersion: String, onLineVersion: String) -> AppVersionStatus {
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

        // 比较版本
        for i in 0..<versionLocalList.count {
            guard  let versionLocal = Int(versionLocalList[i]), let versionServer = Int(versionOnLineList[i]) else {
                Logger.error("版本号中存在非 Int 字符")
                return .latest
            }
            if versionLocal == versionServer {
                versionStatus = .latest
                continue
            }
            if versionLocal < versionServer {
                versionStatus = .older
                break
            }
            if versionLocal > versionServer {
                versionStatus = .review
                break
            }
        }
        
        return versionStatus
    }

}

// 添加本地化描述，我们可以显示对用户友好的错误信息。
extension AppVersionStatus: CustomStringConvertible {
    
    var description: String {
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
