//
//  AddNewAccountViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 创建账号界面
class AddNewAccountViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "创建账号界面" }

    // MARK: - let property and IBOutlet
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var remarkTextView: UITextView!
    // MARK: - public var property

    // MARK: - private var property
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    // MARK: - override
    
    // MARK: - event response
    
    /// 完成事件
    @IBAction func CompleteAction(_ sender: Any) {
        // 保存数据
        let userName = userNameTF.text
        let password = passwordTextField.text
//        let remark = remarkTextView.text
        let acc = Account(id: 0, name: userName!, password: password!, createTime: "", updateTime: "")
        
        DataBaseCtrl.judy.addNewAccount(account: acc) { rs in
            if rs {
                dismiss(animated: true)
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

private extension AddNewAccountViewCtrl {

}
