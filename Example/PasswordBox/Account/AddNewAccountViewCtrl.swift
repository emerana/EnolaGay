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

    // MARK: - public var property
    /// 用于新添加的账号对象
    var addAccount: Account?
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

        addAccount = Account(id: 0, name: userName!, password: password!, createTime: "", updateTime: "")
        // 触发 unwind 事件
        performSegue(withIdentifier: "completeAndDismissAction", sender: nil)
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
