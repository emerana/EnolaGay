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

class ToastViewController: UIViewController {
    
    @IBOutlet weak private var message1Button: UIButton!
    @IBOutlet weak private var message2Button: UIButton!
    @IBOutlet weak private var message3Button: UIButton!
    @IBOutlet weak private var activityButton: UIButton!
    @IBOutlet weak private var hideToastButton: UIButton!
    @IBOutlet weak private var hideAllButton: UIButton!
    @IBOutlet weak private var hideActivityButton: UIButton!

    /// 清除包。当清除包被释放的时候，清除包内部所有可被清除的资源（Disposable）都将被清除。
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        message1Button.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.message("大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁大家好，我是王仁洁", position: .top)
        })
        .disposed(by: disposeBag)

        message2Button.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.message("""
消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体消息体，大家好我是王仁洁，这是自定义配置的方法弹出来的消息体
""",
                                     duration: TimeInterval(5),
                                     point: self!.view.center,
                                     title: "这是标题",
                                     image: UIImage(named: "jiesuo"),//UIImage(named: "jiesuo"),
                                     style: ToastManager.shared.style) { didTap in
            }
        })
        .disposed(by: disposeBag)

        message3Button.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.message("你妹的")
        })
        .disposed(by: disposeBag)

        activityButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.activity()
        })
        .disposed(by: disposeBag)

        hideToastButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.hide()
        })
        .disposed(by: disposeBag)

        hideAllButton.rx.tap.asObservable().subscribe {
            [weak self] _ in
               self?.view.toast.hideAll()
        }.disposed(by: disposeBag)
        
        hideActivityButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            self?.view.toast.hideActivity()
        })
        .disposed(by: disposeBag)

    }

}
