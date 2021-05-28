//
//  KeyBoardPopUpViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/4/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 实现像微信的聊天输入框跟随键盘方案。
class KeyBoardPopUpViewCtrl: UIViewController {
    
    /// 需要跟随键盘移动的目标 View。
    @IBOutlet weak var keyBaordView: UIView!
    @IBOutlet weak var textFeild: UITextField!
    
    let keyboardHelper = KeyboardHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        judy.alert()
        
        textFeild.placeholder = "输入消息内容"
        textFeild.returnKeyType = .send
        textFeild.enablesReturnKeyAutomatically  = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTouches(sender:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)

        keyboardHelper.registerKeyBoardListener(forView: keyBaordView, ignoreSafeAreaInsetsBottom: true)
    }
    
    
    @objc func handleTouches(sender: UITapGestureRecognizer) {
        // 只要点击区域不在键盘范围即收起键盘。
        if sender.location(in: view).y < view.bounds.height - keyboardHelper.keyboardHeight {
            textFeild.resignFirstResponder()
        }
    }
    
    deinit { Judy.logHappy("正常释放！") }
}


