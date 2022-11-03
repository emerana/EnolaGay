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
    
    /// 该界面的账号密码实体，该对象不包含 remark 信息。
    var account: Account?
    /// 记录 account 在来源列表中的 indexPath
    var indexPath: IndexPath!
    /// 更新了 account 的回调
    var updateAccountCallback: ((Account, IndexPath?) -> Void)?
    
    /// 当前是否为编辑状态，默认为 false.
    let isStatusEditing = PublishSubject<Bool>()
    
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

        // 从数据库查询信息
        account = DataBaseCtrl.judy.getAccountDetail(accountID: account!.id)
        // 查询备注信息
        let remark = DataBaseCtrl.judy.getAccountRemark(account: account!)
        account!.remark = remark

        let viewModel = AccountDetailViewModel(userName:
                                                userNameTextField.rx.text.orEmpty.asObservable(),
                                               password:
                                                passwordTextField.rx.text.orEmpty.asObservable(),
                                               account: account!)
        bindings(viewModel: viewModel)

        // 编辑状态绑定到用户是否可输入
        isStatusEditing.bind(to: userNameTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        isStatusEditing.bind(to: passwordTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        isStatusEditing.bind(to: remarkTextView.rx.isEditable)
            .disposed(by: disposeBag)
        // 编辑状态绑定到编辑按钮
        isStatusEditing.map { $0 ? "完成" : "编辑" }
            .bind(to: editBarButtonItem.rx.title)
            .disposed(by: disposeBag)
        // 编辑状态绑定到导航条返回按钮
        isStatusEditing.bind(to: navigationItem.rx.hidesBackButton)
            .disposed(by: disposeBag)
        // 编辑状态绑定到删除按钮，是编辑期间不能执行删除
        isStatusEditing.map { !$0 }
            .bind(to: deleteButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // 先发出一个 false
        isStatusEditing.onNext(false)
        isStatusEditing.bind { [weak self] isEditing in
            Judy.log(isEditing ? "正在编辑":"完成编辑")
            let saveDisposeBag = DisposeBag()
            if !isEditing {
                Observable.combineLatest(self!.userNameTextField.rx.text.orEmpty,
                                         self!.passwordTextField.rx.text.orEmpty,
                                         self!.remarkTextView.rx.text.orEmpty)
                .map { (uName, pwd, remark) in

                    self?.account?.name = uName
                    self?.account?.password = pwd
                    
                    if self?.account?.remark == nil {
                        self?.account?.remark = AccountRemark(id: 0)
                    }
                    self?.account?.remark?.remark = remark
                    
                    return self!.account!
                }.subscribe { account in
                    // 保存修改
                    DataBaseCtrl.judy.modifyAccount(account: account) { rs, msg in
                        Judy.log("修改结果\(rs),\(msg)")
                        if rs {
                            self?.updateAccountCallback?(account, self!.indexPath)
                        } else {
                            JudyTip.message(messageType: .error, text: msg)
                        }

                    }
                }.disposed(by: saveDisposeBag)
            }
        }.disposed(by: disposeBag)

        // 编辑按钮点击事件
        editBarButtonItem.rx.tap.subscribe { [weak self] _ in
            self?.isStatusEditing.onNext( !(self!.userNameTextField.isEnabled) )
        }.disposed(by: disposeBag)
        
        
        // 分组按钮点击事件
        groupButton.rx.tap.subscribe { [weak self] _ in
            Judy.logHappy("请选择分组")
        }.disposed(by: disposeBag)

        // 图标按钮点击事件
        iconButton.rx.tap.subscribe { [weak self] _ in
            Judy.logHappy("请选择图标")
        }.disposed(by: disposeBag)

        // 删除按钮点击事件
        deleteButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.judy.alert(msg: "此操作将会删除这条数据！", confirmction: { action in
                DataBaseCtrl.judy.deleteAccount(account: self.account!) { rs, msg in
                    if rs {
                        self.performSegue(withIdentifier: "completeDeleteAction", sender: nil)
                    } else {
                        JudyTip.message(messageType: .error, text: msg)
                    }
                }
            })
            
        }.disposed(by: disposeBag)

    }

    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }
    
    // MARK: - override
    
    // MARK: - event response
    
    /// 收到选择图标界面消失时发来的请求，要求修改图标
    @IBAction func unwindFromChooseICONViewCtrl(_ unwindSegue: UIStoryboardSegue) {
        guard let account = account else { return }
        
        let sourceViewController = unwindSegue.source as! ChooseAccountICONCollectionViewCtrl
        // Use data from the view controller which initiated the unwind segue
        let iconName = sourceViewController.iconNameList[sourceViewController.iconSelectedIndexPath.row]
        
        if account.remark == nil {
           account.remark = AccountRemark(id: 0)
        }
        account.remark?.icon = iconName
        // 保存图标修改
        DataBaseCtrl.judy.modifyAccount(account: account) { [weak self] rs, msg in
            Judy.log("修改结果\(rs),\(String(describing: msg))")
            if rs {
                self?.updateAccountCallback?(account, self!.indexPath)
            } else {
                JudyTip.message(messageType: .error, text: msg)
            }
        }
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


// MARK: - private methods

private extension AccountDetailViewCtrl {
    
    /// 数据绑定
    func bindings(viewModel: AccountDetailViewModel) {
        
        // viewModel 绑定到 UI
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
            .map { "创建时间： \($0)" }
            .bind(to: createTimeLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.updateTime
            .map { "上次修改时间： \($0)" }
            .bind(to: updateTimeLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.groupName
            .map { $0 == nil ? "无分组 ➤" : "所在分组： \($0!)" }
            .bind(to: groupButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        viewModel.icon
            .map {
                ICON.judy.image(withName: $0 ?? "",
                                iconBundle: .icons_password)
            }
            .bind(to: iconButton.rx.backgroundImage(for: .normal))
            .disposed(by: disposeBag)
        

        // UI 绑定到 viewModel
        userNameTextField.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        remarkTextView.rx.text.orEmpty
            .bind(to: viewModel.remark)
            .disposed(by: disposeBag)

        // 所有输入是否有效绑定到编辑按钮
        viewModel.everythingValid.bind(to: editBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

    }
    
}


/// 数据模型
class AccountDetailViewModel {
    
    // 输出
    
    /// 用户名是否有效
    let userNameValid: Observable<Bool>
    /// 密码是否有效
    let passwordValid: Observable<Bool>
    /// 所有输入是否有效
    let everythingValid: Observable<Bool>

    /// account 对象相关属性
    let icon: BehaviorRelay<String?>,
        groupName: BehaviorRelay<String?>,
        username: BehaviorRelay<String>,
        password: BehaviorRelay<String>,
        remark: BehaviorRelay<String?>,
        createTime: BehaviorRelay<String>,
        updateTime: BehaviorRelay<String>

    /// 生成 ViewModel 输入绑定
    /// - Parameters:
    ///   - userName: 用户名控件
    ///   - password: 密码控件
    ///   - remark: 备注控件
    init(userName: Observable<String>,
         password: Observable<String>,
         account: Account) {
        
        icon = BehaviorRelay<String?>(value: account.remark?.icon)
        groupName = BehaviorRelay<String?>(value: account.remark?.group?.name)
        username = BehaviorRelay<String>(value: account.name)
        self.password = BehaviorRelay<String>(value: account.password)
        remark = BehaviorRelay<String?>(value: account.remark?.remark)
        createTime = BehaviorRelay<String>(value: account.createTime)
        updateTime = BehaviorRelay<String>(value: account.updateTime)

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
