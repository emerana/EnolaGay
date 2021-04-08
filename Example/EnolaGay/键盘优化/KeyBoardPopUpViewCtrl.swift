//
//  KeyBoardPopUpViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/4/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

/// 实现像微信的聊天输入框跟随键盘方案。
class KeyBoardPopUpViewCtrl: UIViewController {
    
    /// 需要跟随键盘移动的目标 View。
    @IBOutlet weak var keyBaordView: UIView!
    @IBOutlet weak var textFeild: UITextField!
    
    private var keyBoardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFeild.placeholder = "输入消息内容"
        textFeild.returnKeyType = .send
        textFeild.enablesReturnKeyAutomatically  = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTouches(sender:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
        
    @objc func keyBoardShowHideAction(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let animations: (() -> Void) = { [weak self] in
            // 键盘弹出过程。
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度。
                self?.keyBoardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                self?.keyBaordView.transform = CGAffineTransform(translationX: 0,y: -self!.keyBoardHeight)
            }
            // 键盘收起过程。
            if notification.name == UIResponder.keyboardWillHideNotification {
                self?.keyBaordView.transform = CGAffineTransform.identity
            }
        }
        
        // 键盘弹出过程时长。
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘。
            animations()
        }
        
    }
    
    @objc func handleTouches(sender: UITapGestureRecognizer) {
        // 只要点击区域不再键盘范围即收起键盘。
        if sender.location(in: view).y < view.bounds.height - keyBoardHeight {
            textFeild.resignFirstResponder()
        }
    }

}
