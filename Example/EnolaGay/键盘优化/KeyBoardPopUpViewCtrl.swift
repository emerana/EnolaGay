//
//  KeyBoardPopUpViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/4/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class KeyBoardPopUpViewCtrl: UIViewController {
    
    @IBOutlet weak var keyBaordView: UIView!
    @IBOutlet weak var textFeild: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFeild.placeholder = "输入消息内容"
        textFeild.returnKeyType = .send
        textFeild.enablesReturnKeyAutomatically  = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTouches(sender:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
        
    @objc func keyBoardShowHideAction(notification: NSNotification) {
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            let userInfo  = notification.userInfo! as NSDictionary
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            let keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            _ = self.view.convert(keyBoardBounds, to:nil)
            _ = keyBaordView.frame
            
            let deltaY = keyBoardBounds.size.height
            
            let animations:(() -> Void) = {
                self.keyBaordView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
            }
            
            if duration > 0 {
                let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
            } else {
                animations()
            }
        }

        if notification.name == UIResponder.keyboardWillHideNotification {
            let userInfo  = notification.userInfo! as NSDictionary
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            let animations:(() -> Void) = {
                self.keyBaordView.transform = CGAffineTransform.identity
            }
            
            if duration > 0 {
                let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
                UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
            } else {
                animations()
            }
        }
    }
    
    
    @objc func handleTouches(sender: UITapGestureRecognizer) {
        
        if sender.location(in: self.view).y < self.view.bounds.height - 250 {
            textFeild.resignFirstResponder()
        }
    }

}
