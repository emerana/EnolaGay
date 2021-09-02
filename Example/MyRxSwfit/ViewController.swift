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

    let dispost = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        textField_A.rx.text.orEmpty.subscribe { [weak self] str in
            self?.textField_B.text = str
        } onError: { error in
            Judy.log("错误:\(error)")
        } onCompleted: {
            Judy.log("onCompleted")
        } onDisposed: {
            Judy.log("onDisposed")
        }.disposed(by: dispost)
        
        textField_B.rx.text.orEmpty.subscribe { [weak self] str in
            self?.textField_A.text = str
        } onError: { error in
            Judy.log("错误:\(error)")
        } onCompleted: {
            Judy.log("onCompleted")
        } onDisposed: {
            Judy.log("onDisposed")
        }.disposed(by: dispost)

        actionButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.infoLabel.text = "正在获取信息……"
                self?.getInfo()
            })
            .disposed(by: dispost)

    }
    
    func getInfo() {
        Observable.zip(userName(), password())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (teacher, comments) in
                self?.infoLabel.text = "\(teacher), \(comments)"
            }, onError: { error in
                print("获取老师信息或评论失败: \(error)")
            })
            .disposed(by: dispost)
    }
    
    func userName() -> Observable<String> {
        return Observable.create { observer -> Disposable in
            observer.onNext("Judy")
            sleep(6)
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
