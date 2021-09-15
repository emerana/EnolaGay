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

class VersionCheckViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "版本查询" }

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
            version: versionTextField.rx.text.orEmpty.asObservable())
        // 模型 -> UI
        viewModel.bundleID.bind(to: bundleIDTextField.rx.text).disposed(by: disposeBag)
        viewModel.version.bind(to: versionTextField.rx.text).disposed(by: disposeBag)
        viewModel.queryResult.bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        // UI -> 模型
        bundleIDTextField.rx.text.orEmpty.bind(to: viewModel.bundleID).disposed(by: disposeBag)
        versionTextField.rx.text.orEmpty.bind(to: viewModel.version).disposed(by: disposeBag)
        
        viewModel.queryButtonValid.bind(to: queryButton.rx.isEnabled).disposed(by: disposeBag)

        // 按钮点击事件
        queryButton.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.queryButton.isHidden = true
                self.view.endEditing(true)
                
//                self.viewModel.versionCheck()
//                    .subscribe(onNext: { (versionInfo, force) in
//                        self.queryButton.isHidden = false
//
//                        Judy.log("查询到的 versionStatus：\(versionInfo)")
//                        Judy.log("查询强制更新响应的 isHot = \(force)")
//
//                        var infoString = "查询结果\n"
//                        infoString += "Bundle ID: \(try! self.viewModel.bundleID.value())\n"
//                        infoString += "Version: \(try! self.viewModel.version.value())\n"
//                        infoString += versionInfo.0.rawValue
//
//                        self.infoLabel.text = infoString
//                        let highlightedColor = UIColor.darkText
//                        let highlightedFont = UIFont(name: FontName.HlvtcNeue, size: 16)
//                        self.infoLabel.judy.setHighlighted(text: "查询结果", color: highlightedColor, font: highlightedFont)
//                        self.infoLabel.judy.setHighlighted(text: "Bundle ID:", color: highlightedColor, font: highlightedFont)
//                        self.infoLabel.judy.setHighlighted(text: "Version:", color: highlightedColor, font: highlightedFont)
//
//                        /// 只有要求强制更新且有新版本的时候弹出强制更新窗口
//                        if versionInfo.0 == .older && force {
//                            let alertController = UIAlertController(title: "请更新版本",
//                                                                    message: nil,
//                                                                    preferredStyle: .alert)
//                            let okAction = UIAlertAction(title: "去更新", style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
//                                if let url = URL(string: versionInfo.1 ?? "") {
//                                    if UIApplication.shared.canOpenURL(url) {
//                                        Judy.logHappy("正在打开：\(url)")
//                                        UIApplication.shared.open(url, completionHandler: nil)
//                                    } else {
//                                        Judy.logWarning("不能打开该 URL")
//                                    }
//                                }
//                            })
//                            alertController.addAction(okAction)
//
//                            Judy.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
//                        }
//                    })
//                    .disposed(by: self.disposeBag)
                
//                self.viewModel.versionCheckCompletable().subscribe { event in
//                    Judy.log("任务完成了")
//                    let highlightedColor = UIColor.darkText
//                    let highlightedFont = UIFont(name: FontName.HlvtcNeue, size: 16)
//                    self.infoLabel.judy.setHighlighted(text: "查询结果", color: highlightedColor, font: highlightedFont)
//                    self.infoLabel.judy.setHighlighted(text: "Bundle ID:", color: highlightedColor, font: highlightedFont)
//                    self.infoLabel.judy.setHighlighted(text: "Version:", color: highlightedColor, font: highlightedFont)
//
//                    self.queryButton.isHidden = false
//                }
//                .disposed(by: self.disposeBag)
                self.viewModel.versionCheckSingle()
                    .subscribe { event in
                        switch event {
                        case .success(let appStoreURL):
                            Judy.log("拿到AppStore链接:\(appStoreURL)")
                            if appStoreURL == "" { break }
                            let alertController = UIAlertController(title: "请更新版本",
                                                                    message: nil,
                                                                    preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "去更新", style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
                                if let url = URL(string: appStoreURL) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        Judy.logHappy("正在打开：\(url)")
                                        UIApplication.shared.open(url, completionHandler: nil)
                                    } else {
                                        Judy.logWarning("不能打开该 URL")
                                    }
                                }
                            })
                            alertController.addAction(okAction)
                            
                            Judy.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                        case .failure(_):
                            Judy.log("任务返回了失败")
                        }
                        let highlightedColor = UIColor.darkText
                        let highlightedFont = UIFont(name: FontName.HlvtcNeue, size: 16)
                        self.infoLabel.judy.setHighlighted(text: "查询结果", color: highlightedColor, font: highlightedFont)
                        self.infoLabel.judy.setHighlighted(text: "Bundle ID:", color: highlightedColor, font: highlightedFont)
                        self.infoLabel.judy.setHighlighted(text: "Version:", color: highlightedColor, font: highlightedFont)

                        self.queryButton.isHidden = false
                    }
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

}


class VersionCheckViewModel {
    // 双向绑定
    let bundleID = BehaviorSubject<String>(value: "com.shengda.whalemall")
    let version = BehaviorSubject<String>(value: Judy.versionShort)
    /// 查询结果的 BehaviorSubject
    let queryResult = BehaviorSubject<String>(value: "点击查询按钮开始查询")

    // 输出
    let bundleIDValid: Observable<Bool>
    let versionValid: Observable<Bool>
    let queryButtonValid: Observable<Bool>
    
    // 输入
    init(bundleID: Observable<String>, version: Observable<String>) {
        
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
    }
    
    /// 查询版本是否有强制更新
    func versionCheck() -> Observable<((Judy.AppVersionStatus, String?), Bool) > {
        return Observable.zip(getVersionInfo(), getVersionForce())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
    }
    
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
                        Judy.log("查询到的 versionStatus：\(versionInfo)")
                        Judy.log("查询强制更新响应的 isHot = \(force)")

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

    /// 以 Single 方式查询
    func versionCheckSingle() -> Single<String> {
        queryResult.onNext("查询中……")
        return Single<String>.create { [weak self] single in
            guard let `self` = self  else { return Disposables.create {} }
            _ = Observable.zip(self.getVersionInfo(), self.getVersionForce())
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .observe(on: MainScheduler.instance)
                .subscribe({ event in
                    switch event {
                    case .next((let versionInfo, let force)):
                        Judy.log("查询到的 versionStatus：\(versionInfo)")
                        Judy.log("查询强制更新响应的 isHot = \(force)")

                        var infoString = "查询结果\n"
                        infoString += "Bundle ID: \(try! self.bundleID.value())\n"
                        infoString += "Version: \(try! self.version.value())\n"
                        infoString += versionInfo.0.rawValue
                        self.queryResult.onNext(infoString)
                        if versionInfo.0 == .older && force {
                            single(.success(versionInfo.1 ?? ""))
                        } else {
                            single(.success(""))
                        }
                    default:
                        single(.failure(event.error.unsafelyUnwrapped))
                    }
                })
           
            return Disposables.create {}
        }
    }

    
    /// 查询是否有新版本
    private func getVersionInfo() -> Observable<(Judy.AppVersionStatus, String?)> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            Judy.queryVersionInfoAtAppStore(bundleIdentifier: try! self.bundleID.value(), version: try! self.version.value()) { versionStatus, appStoreURL in
                observer.onNext((versionStatus, appStoreURL))
            }
            
            return Disposables.create()
        }
    }
    
    /// 从服务器查询是否强制更新
    private func getVersionForce() -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            let apiRequest = ApiRequestConfig()
            apiRequest.api = Version.GetAppVersion
            apiRequest.parameters?["client"] = "ios"
            apiRequest.request { json in
                let isForce = json["data","isHot"]
                Judy.log("查询强制更新响应的 isHot = \(isForce)")
                observer.onNext(isForce.boolValue)
            }
            return Disposables.create()
        }
    }

}
