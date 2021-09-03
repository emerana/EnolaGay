//
//  ViewController.swift
//  MyRxSwfit
//
//  Created by 王仁洁 on 2021/9/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EnolaGay

class ViewController: UIViewController {
    
    @IBOutlet weak var textField_A: JudyBaseTextField!
    @IBOutlet weak var textField_B: JudyBaseTextField!
    
    @IBOutlet weak var infoLabel: JudyBaseLabel!
    
    @IBOutlet weak var actionButton: JudyBaseButton!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // textField_B 作为观察者
        textField_A.rx.text.bind(to: textField_B.rx.text).disposed(by: disposeBag)
        // textField_A 作为观察者
        textField_B.rx.text.bind(to: textField_A.rx.text).disposed(by: disposeBag)

        actionButton.rx.tap.subscribe(onNext: { [weak self] _ in
                self?.infoLabel.text = "正在获取信息……"
                self?.versionCheck()
            }).disposed(by: disposeBag)
    }
    
//    func getInfo() {
//        Observable.zip(getVersionInfo(), password())
//            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (teacher, comments) in
//                self?.infoLabel.text = "\(teacher), \(comments)"
//            }, onError: { error in
//                print("获取老师信息或评论失败: \(error)")
//            }, onCompleted: {
//                Judy.log("单纯得完成了序列")
//            })
//            .disposed(by: disposeBag)
//    }
//    
//    func getVersionInfo() -> Observable<String> {
//        return Observable.create { observer -> Disposable in
//            Judy.queryVersionInfoAtAppStore(bundleIdentifier: "com.shengda.whalemall", version: "1.6.2") { versionStatus, appStoreURL in
//                Judy.log("查询到的 versionStatus：\(versionStatus)")
//                Judy.log("对应的URL：\(String(describing: appStoreURL))")
//                observer.onNext(versionStatus.rawValue)
//            }
//            return Disposables.create()
//        }
//    }
//
//    func password() -> Observable<String> {
//        return Observable.create { observer -> Disposable in
//            observer.onNext("EMERANA")
//            return Disposables.create()
//        }
//    }
    
    /// 查询版本是否有强制更新
    func versionCheck() {
        let _ = Observable.zip(getVersionInfo(), getVersionForce())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (versionStatus, force) in
                Judy.log("查询到的 versionStatus：\(versionStatus)")
                Judy.log("查询强制更新响应的 isHot = \(force)")
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
                print("获取老师信息或评论失败: \(error)")
            }, onCompleted: {
                Judy.log("单纯得完成了序列")
            })
    }
    
    /// 查询是否有新版本
    private func getVersionInfo() -> Observable<(Judy.AppVersionStatus, String?)> {
        return Observable.create { observer -> Disposable in
            Judy.queryVersionInfoAtAppStore(bundleIdentifier: "com.shengda.whalemall", version: "1.6.3") { versionStatus, appStoreURL in
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
