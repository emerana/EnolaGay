//
//  AccountDetailViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 密码详情界面
class AccountDetailViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "密码详情" }

    // MARK: - let property and IBOutlet
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var updateTimeLabel: UILabel!

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var remarkTextView: UITextView!

    // MARK: - public var property
    
    /// 一个账号密码实体，在该界面的操作对象。
    var account: Account?
    
    // MARK: - private var property
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard account != nil else {
            JudyTip.message(messageType: .error, text: "对象为空")
            return
        }
        // Do any additional setup after loading the view.
        // iconButton.imageView?.image =
        createTimeLabel.text = "创建时间： \(account!.createTime)"
        updateTimeLabel.text = "上次修改时间： \(account!.updateTime)"

        userNameTextField.text = account!.name
        passwordTextField.text = account!.password
        remarkTextView.text = account!.remark?.remark

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

}
