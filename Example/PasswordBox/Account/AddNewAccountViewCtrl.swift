//
//  AddNewAccountViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa

/// 创建账号界面
class AddNewAccountViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "创建账号界面" }

    // MARK: - let property and IBOutlet
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak private var addButton: JudyBaseButton!
    
    // MARK: - public var property
    /// 用于新添加的账号对象
    var addAccount: Account?
    // MARK: - private var property
    /// 清除包。订阅管理机制，当清除包被释放的时候，清除包内部所有可被清除的资源（Disposable）都将被清除
    private let disposeBag = DisposeBag()

    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = AddNewAccountViewModel(userName:
                                                userNameTF.rx.text.orEmpty.asObservable(),
                                               password:
                                                passwordTextField.rx.text.orEmpty.asObservable())
        
        // 所有输入是否有效绑定到编辑按钮
        viewModel.everythingValid.bind(to: addButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        addButton.rx.tap.subscribe { [weak self] _ in
            // 保存数据
            let userName = self?.userNameTF.text
            let password = self?.passwordTextField.text

            self?.addAccount = Account(id: 0, name: userName!, password: password!, createTime: "", updateTime: "")
            // 触发 unwind 事件
            self?.performSegue(withIdentifier: "completeAndDismissAction", sender: nil)
        }.disposed(by: disposeBag)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}


class AddNewAccountViewModel {

    /// 用户名是否有效
    let userNameValid: Observable<Bool>
    /// 密码是否有效
    let passwordValid: Observable<Bool>
    /// 所有输入是否有效
    let everythingValid: Observable<Bool>
    
    init(userName: Observable<String>,
         password: Observable<String>) {
        userNameValid = userName
            .map { $0.count >= 1 }
            .share(replay: 1)
        passwordValid = password
            .map { $0.count >= 1 }
            .share(replay: 1)
        everythingValid = Observable.combineLatest(userNameValid,  passwordValid)
            .map { $0 && $1 }
            .share(replay: 1)
    }
    
}
