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

    private var bundleID = BehaviorSubject<String>(value: "com.shengda.whalemall")
    private var version = BehaviorSubject<String>(value: Judy.versionShort)

    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.text = ""

        bundleID.bind(to: bundleIDTextField.rx.text).disposed(by: disposeBag)
        version.bind(to: versionTextField.rx.text).disposed(by: disposeBag)

        bundleIDTextField.rx.text.orEmpty.bind(to: bundleID).disposed(by: disposeBag)
        versionTextField.rx.text.orEmpty.bind(to: version).disposed(by: disposeBag)
        
        // bundleID 是否有效
        let bundleIDValid = bundleIDTextField.rx.text.orEmpty
            .map { $0.count >= 5 }
            .share(replay: 1)
        
        // versionValid 是否有效
        let versionValid = versionTextField.rx.text.orEmpty
            .map { $0.count >= 1 }
            .share(replay: 1)
        
        // 所有输入是否有效
        let everyValid = Observable.combineLatest(bundleIDValid, versionValid)
            .map { $0 && $1 }
            .share(replay: 1)
        
        // 所有输入是否有效 -> 按钮是否可点击
        everyValid.bind(to: queryButton.rx.isEnabled).disposed(by: disposeBag)

        // 按钮点击事件
        queryButton.rx.tap.asSignal()
            .emit(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.infoLabel.text = "查询中……"
                self.queryButton.isHidden = true
                self.view.endEditing(true)
                self.versionCheck()
            }).disposed(by: disposeBag)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }
}

private extension VersionCheckViewCtrl {
    /// 查询版本是否有强制更新
    func versionCheck() {
        let _ = Observable.zip(getVersionInfo(), getVersionForce())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (versionStatus, force) in
                guard let `self` = self else { return }
                self.queryButton.isHidden = false

                Judy.log("查询到的 versionStatus：\(versionStatus)")
                Judy.log("查询强制更新响应的 isHot = \(force)")
                
                var infoString = "查询结果\n"
                infoString += "Bundle ID: \(try! self.bundleID.value())\n"
                infoString += "Version: \(try! self.version.value())\n"
                infoString += versionStatus.0.rawValue
                
                self.infoLabel.text = infoString
                let highlightedColor = UIColor.darkText
                let highlightedFont = UIFont(name: FontName.HlvtcNeue, size: 16)
                self.infoLabel.judy.setHighlighted(text: "查询结果", color: highlightedColor, font: highlightedFont)
                self.infoLabel.judy.setHighlighted(text: "Bundle ID:", color: highlightedColor, font: highlightedFont)
                self.infoLabel.judy.setHighlighted(text: "Version:", color: highlightedColor, font: highlightedFont)

                /// 只有要求强制更新且有新版本的时候弹出强制更新窗口
                if versionStatus.0 == .older && force {
                    let alertController = UIAlertController(title: "请更新版本",
                                                            message: nil,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "去更新", style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
                        if let url = URL(string: versionStatus.1 ?? "") {
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
                }
            }, onError: { error in
                print("获取信息失败: \(error)")
            }, onCompleted: {
                Judy.log("单纯得完成了序列")
            })
    }

    /// 查询是否有新版本
    func getVersionInfo() -> Observable<(Judy.AppVersionStatus, String?)> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            
            Judy.queryVersionInfoAtAppStore(bundleIdentifier: try! self.bundleID.value(), version: try! self.version.value()) { versionStatus, appStoreURL in
                observer.onNext((versionStatus, appStoreURL))
            }
            
            return Disposables.create()
        }
    }
    
    /// 从服务器查询是否强制更新
    func getVersionForce() -> Observable<Bool> {
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
