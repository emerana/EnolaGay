//
//  ViewController.swift
//  MyRxSwfit
//  以此模板实现 MVVM 双向绑定
//  Created by 王仁洁 on 2021/9/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EnolaGay

// MARK: - View

class ViewController: UIViewController {
    
    /// 用户名输入框
    @IBOutlet weak var userNameTextField: JudyBaseTextField!
    /// 用于显示信息的label
    @IBOutlet weak var infoLabel: JudyBaseLabel!
    /// 触发该表模型值事件
    @IBOutlet weak var actionButton: JudyBaseButton!
    /// 编辑按钮
    @IBOutlet weak var editButton: UIButton!

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textField 只有输入的值才会发出元素
        userNameTextField.rx.text.orEmpty
            .bind(to: infoLabel.rx.text)
            .disposed(by: disposeBag)
        
        let viewModel = ViewModel(userNameOutlet: userNameTextField.rx.text.orEmpty.asObservable())
        // account 对象绑定到输入框
        viewModel.account
            .bind(to: userNameTextField.rx.text.orEmpty)
            .disposed(by: disposeBag)
        // 编辑状态绑定到输入框可用
        viewModel.isStatusEditing
            .bind(to: userNameTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        // 编辑按钮点击事件
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                var isEditing = try! viewModel.isStatusEditing.value()
                // 先切换状态
                viewModel.isStatusEditing.onNext(!isEditing)
                isEditing = try! viewModel.isStatusEditing.value()
                if isEditing {
                    Judy.log("进入编辑状态")
                    // 只有在编辑状态下才绑定按钮是否可用
                    viewModel.isSaveButtonEnabled
                        .bind(to: self.editButton.rx.isEnabled)
                        .disposed(by: self.disposeBag)
                } else {
                    Judy.log("退出编辑状态")
                }
            })
            .disposed(by: disposeBag)
        // 手动给输入框赋值，均无法改变 viewModel.account.bind 的控件显示。
        actionButton.rx.tap
            .subscribe(onNext: {
                //                self.userNameTextField.rx.text.orEmpty.onNext("泥马")
                //                self.userNameTextField.text = "卧槽"
                viewModel.account.accept("你好呀")
                
            })
            .disposed(by: disposeBag)
    }
    
}


class ViewModel {
    /// 当前是否为编辑状态，默认为 false.
    let isStatusEditing = BehaviorSubject<Bool>(value: false)

    let account: BehaviorRelay<String>

    /// 保存按钮是否有效，手动给 userNameOutlet 赋值将不作为元素发出。
    let isSaveButtonEnabled: Observable<Bool>

    init(userNameOutlet: Observable<String>) {
        isSaveButtonEnabled = userNameOutlet
            .map { $0.count > 0 }
            .share(replay: 1)
        
        account = BehaviorRelay<String>(value: "王仁洁")
    }

}
