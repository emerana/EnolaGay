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
    
    @IBOutlet weak var userNameTextField: JudyBaseTextField!
    @IBOutlet weak var passwordTextField: JudyBaseTextField!
    
    @IBOutlet weak var infoLabel: JudyBaseLabel!
    
    @IBOutlet weak var actionButton: JudyBaseButton!

    let disposeBag = DisposeBag()

    let a = BehaviorRelay(value: 1)
    let b = BehaviorRelay(value: 2)

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let c = Observable.combineLatest(a.asObservable(), b.asObservable()){ $0 + $1 }
//        c.subscribe(onNext:  { value in
//            Judy.log("获取到 C 的新值 = \(value)")
//        }).disposed(by: disposeBag)
//
//        a.accept(3)

        // 实现将 userNameTextField 的值实时用 label 显示出来
        //        userNameTextField.rx.text.orEmpty
        //            .bind(to: infoLabel.rx.text)
        //            .disposed(by: disposeBag)

        let viewModel = ViewModel()
        
        twoWayBinding(viewModel: viewModel)
        /*
         因为 viewModel.username 已经和 userNameTextField 做好了双向绑定
         输入框只有在用户输入且 resignFirstResponder 的时候才会触发绑定 Label 显示
         */
        viewModel.username
            .bind(to: infoLabel.rx.text)
            .disposed(by: disposeBag)
//        userNameTextField.rx.text.orEmpty
//            .bind(to: infoLabel.rx.text)
//            .disposed(by: disposeBag)
   
        actionButton.rx.tap
            .subscribe(onNext: {
                //                Judy.log("viewModel 的 username 是：\(viewModel.username.value)")
                //                Judy.log("viewModel 的 password 是：\(viewModel.password.value)")
                viewModel.username.accept("EMERANA")
            }).disposed(by: disposeBag)

    }
    
}

// 双向绑定
private extension ViewController {

    /// 实现双向绑定
    func twoWayBinding(viewModel: ViewModel) {
        // UI 绑定到 viewModel
        userNameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)

        // viewModel 绑定到 UI
        viewModel.username
            .bind(to: userNameTextField.rx.text)
            .disposed(by: disposeBag)
        viewModel.password
            .bind(to: passwordTextField.rx.text)
            .disposed(by: disposeBag)

    }
    
}

// MARK: - ViewModel

class ViewModel {
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")

}
