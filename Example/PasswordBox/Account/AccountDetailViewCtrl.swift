//
//  AccountDetailViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa

/// 密码详情界面
class AccountDetailViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "密码详情" }

    // MARK: - let property and IBOutlet

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    
    // MARK: - public var property
    
    /// 一个账号密码实体，在该界面的操作对象。
    var account: Account?
    
    // MARK: - private var property
    private let disposeBag = DisposeBag()

    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard account != nil else {
            JudyTip.message(messageType: .error, text: "对象为空")
            return
        }
        // Do any additional setup after loading the view.
        // iconButton.imageView?.image =
        
        // 查询备注信息
        let remark = DataBaseCtrl.judy.getAccountRemark(account: account!)
        account?.remark = remark
        
        let viewModel = AccountDetailViewModel(userName: userNameTextField.rx.text.orEmpty.asObservable(),
                                               password: passwordTextField.rx.text.orEmpty.asObservable())

        twoWayBinding(viewModel: viewModel, account: account!)
        // UI 控件、事件绑定
        viewModel.isEditing.bind(to: userNameTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        viewModel.isEditing.bind(to: passwordTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        viewModel.isEditing.bind(to: remarkTextView.rx.isEditable)
            .disposed(by: disposeBag)

        // 编辑状态绑定到编辑按钮
        viewModel.isEditing.map { status in
            return status ? "完成" : "编辑"
        }
        .bind(to: editBarButtonItem.rx.title)
        .disposed(by: disposeBag)
        
        // 编辑状态绑定到删除按钮，是编辑期间不能执行删除
        viewModel.isEditing.map { status in
            return !status
        }
        .bind(to: deleteButton.rx.isEnabled)
        .disposed(by: disposeBag)

        // 编辑按钮点击事件
        editBarButtonItem.rx.tap.subscribe { [weak self] Void in
            viewModel.isEditing.accept(!(self?.userNameTextField.isEnabled ?? true))
            
        }.disposed(by: disposeBag)
        
        // 分组按钮点击事件
        groupButton.rx.tap.subscribe { [weak self] Void in
            Judy.logHappy("请选择分组")
        }.disposed(by: disposeBag)

        // 图标按钮点击事件
        iconButton.rx.tap.subscribe { [weak self] Void in
            Judy.logHappy("请选择图标")
        }.disposed(by: disposeBag)

        // 删除按钮点击事件
        deleteButton.rx.tap.subscribe { [weak self] Void in
            Judy.logHappy("请删除该数据")
            self?.judy.alert(confirmction: { action in
                Judy.logWarning("执行了删除")
            })
            
        }.disposed(by: disposeBag)


        
    }

    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }
    
    // MARK: - override
    
    // MARK: - event response

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - private methods

private extension AccountDetailViewCtrl {
    
    /// 实现双向数据绑定
    func twoWayBinding(viewModel: AccountDetailViewModel, account: Account) {
        // UI 绑定到 viewModel，用户输入的数据绑定到模型
        userNameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        remarkTextView.rx.text.orEmpty
            .bind(to: viewModel.remark)
            .disposed(by: disposeBag)
        
        // viewModel 绑定到 UI，使数据显示在 UI
        viewModel.username
            .bind(to: userNameTextField.rx.text)
            .disposed(by: disposeBag)
        viewModel.password
            .bind(to: passwordTextField.rx.text)
            .disposed(by: disposeBag)
        viewModel.remark
            .bind(to: remarkTextView.rx.text)
            .disposed(by: disposeBag)
        viewModel.createTime
            .bind(to: createTimeLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.updateTime
            .bind(to: updateTimeLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.groupName
            .bind(to: groupButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        // 暂时没找到如此使用的方式
        //        viewModel.account.subscribe { account in
        //
        //        }
        //        .disposed(by: disposeBag)
        // account 值绑定
        viewModel.username.accept(account.name)
        viewModel.password.accept(account.password)
        viewModel.remark.accept(account.remark?.remark)
        viewModel.createTime.accept("创建时间： \(account.createTime)")
        viewModel.updateTime.accept("上次修改时间： \(account.updateTime)")
        if let groupName = account.remark?.group?.name {
            viewModel.groupName.accept("所在分组： \(groupName)")
        } else {
            viewModel.groupName.accept("无分组 ‣▸▶︎")
        }
        //        viewModel.account.accept(account)
    }
    
}


class AccountDetailViewModel {
    /// 当前是否为编辑状态，默认为 false
    let isEditing = BehaviorRelay<Bool>(value: false)
    /// 内部有个 account 对象,，此对象暂时不知道怎么使用。
    let account = BehaviorRelay<Account?>(value: nil)

    /// 用户名是否有效
    let userNameValid: Observable<Bool>
    /// 密码是否有效
    let passwordValid: Observable<Bool>
    /// 当前输入是否允许有效
    let saveStatusValid: Observable<Bool>

    let groupName = BehaviorRelay<String>(value: "")

    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let remark = BehaviorRelay<String?>(value: nil)
    let createTime = BehaviorRelay<String>(value: "")
    let updateTime = BehaviorRelay<String>(value: "")

    /// 生成 ViewModel 输入绑定
    /// - Parameters:
    ///   - userName: 用户名控件
    ///   - password: 密码控件
    ///   - remark: 备注控件
    init(userName: Observable<String>,
         password: Observable<String>) {

        userNameValid = userName
            .map { $0.count >= 1 }
            .share(replay: 1)
        passwordValid = password
            .map { $0.count >= 1 }
            .share(replay: 1)
        saveStatusValid = Observable.combineLatest(userNameValid,  passwordValid)
            .map{ $0 && $1 }
            .share(replay: 1)
    }
    
}
