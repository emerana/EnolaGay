//
//  ViewController.swift
//  ToastDemo
//
//  Created by 醉翁之意 on 2022/11/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak private var makeToastButton: UIButton!
    @IBOutlet weak private var makeToastCustomButton: UIButton!
    @IBOutlet weak private var showToastButton: UIButton!
    @IBOutlet weak private var showToastActivityButton: UIButton!
    @IBOutlet weak private var hideToastButton: UIButton!
    @IBOutlet weak private var hideToastActivityButton: UIButton!

    /// 清除包。当清除包被释放的时候，清除包内部所有可被清除的资源（Disposable）都将被清除。
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        maskToastAction()
        maskToastCustomAction()
        showToastAction()
        showToastActivityAction()
        hideToastAction()
        hideToastActivity()
    }

}

private extension ViewController {
    
    func maskToastAction() {
        makeToastButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.message("大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁", position: .top)
        })
        .disposed(by: disposeBag)
    }
    
    
    func maskToastCustomAction() {
        makeToastCustomButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.message("""
消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体
""",
                         duration: TimeInterval(5),
                         point: self!.view.center,
                         title: "这是标题",
                                       image: nil,//UIImage(named: "jiesuo"),
                                 style: ToastManager.shared.style) { didTap in
                Judy.log("点击了，结果为：\(didTap)")
            }
        })
        .disposed(by: disposeBag)
    }
    
    func showToastAction() {
        showToastButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.message("你妹的")
        })
        .disposed(by: disposeBag)
    }
    
    func showToastActivityAction() {
        showToastActivityButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.activity()
        })
        .disposed(by: disposeBag)
    }
    
    func hideToastAction() {
        hideToastButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.hide()
        })
        .disposed(by: disposeBag)
    }
    
    func hideToastActivity() {
        hideToastActivityButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.hideActivity()
        })
        .disposed(by: disposeBag)
    }

}
