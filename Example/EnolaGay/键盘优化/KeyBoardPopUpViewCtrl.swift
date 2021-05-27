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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFeild.placeholder = "输入消息内容"
        textFeild.returnKeyType = .send
        textFeild.enablesReturnKeyAutomatically  = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTouches(sender:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        registerKeyBoardListener(forView: keyBaordView, isSafeAreaInsetsBottom: true)
    }
    
    
    @objc func handleTouches(sender: UITapGestureRecognizer) {
        // 只要点击区域不在键盘范围即收起键盘。
        if sender.location(in: view).y < view.bounds.height - keyBoardHeight {
            textFeild.resignFirstResponder()
        }
    }
    
    deinit { Judy.logHappy("正常释放！") }
}


class KeyboardHelper {
    var keyBoardHeight: CGFloat = 0
    var keyBoardView = UIView()
    var isSafeAreaInsetsBottom = false
    
    /// 监听事件，键盘弹出或收起时均会触发此函数。
    @objc private func keyBoardShowHideAction(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        /// 改变目标 keyBoardView 的执行过程事件，更新其 2D 仿射变换矩阵。
        let animations: (() -> Void) = { [weak self] in
            // 键盘弹出事件。
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度。
                self?.keyBoardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                
                /// quoteKeyBoardView y 轴需要移动的距离。
                var yDiff = -self!.keyBoardHeight
                // 判断是否有底部安全区域。
                if self!.isSafeAreaInsetsBottom {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                    yDiff += bottomPadding
                }
                self?.keyBoardView.transform = CGAffineTransform(translationX: 0,y: yDiff)
            }
            // 键盘收起事件。
            if notification.name == UIResponder.keyboardWillHideNotification {
                self?.keyBoardView.transform = CGAffineTransform.identity
            }
        }
        
        // 键盘弹出过程时长。
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘，直接更新 keyBoardView 2D仿射变换矩阵。
            animations()
        }

    }

}
