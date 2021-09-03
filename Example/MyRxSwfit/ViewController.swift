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
                self?.getInfo()
            }).disposed(by: disposeBag)
    }
    
    func getInfo() {
        Observable.zip(getVersionInfo(), password())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (teacher, comments) in
                self?.infoLabel.text = "\(teacher), \(comments)"
            }, onError: { error in
                print("获取老师信息或评论失败: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func getVersionInfo() -> Observable<String> {
        return Observable.create { observer -> Disposable in
            Judy.queryVersionInfoAtAppStore(bundleIdentifier: "com.shengda.whalemall", version: "1.6.2") { versionStatus, appStoreURL in
                Judy.log("查询到的 versionStatus：\(versionStatus)")
                Judy.log("对应的URL：\(String(describing: appStoreURL))")
                observer.onNext(versionStatus.rawValue)
            }
            // observer.onCompleted()
            return Disposables.create()
        }
    }

    func password() -> Observable<String> {
        return Observable.create { observer -> Disposable in
            observer.onNext("EMERANA")
            return Disposables.create()
        }
    }

    
}
