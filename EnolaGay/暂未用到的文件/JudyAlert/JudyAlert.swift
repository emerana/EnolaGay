//
//  JudyAlert.swift
//  car8891
//
//  Created by Judy-王仁洁 on 2017/7/25.
//  Copyright © 2017年 8891.com.tw. All rights reserved.
//

import UIKit
/*
 
 var maskView = JudyAlert.judy(isSingle: false, confirmHandle: { Void in
 //                Judy.log("去实名认证")
 let vc = Judy.getViewCtrl(storyboardName: "FixProductMain", ident: "UploadIDPhotoViewController")
 Judy.topViewCtrl.navigationController?.pushViewController(vc, animated: true)
 //                Judy.openURL("judy://u/post", completionHandler: { (rs) in })
 
 }, cancelHandle: nil)

 */

/// 自定义的弹窗
public class JudyAlert: UIView {
    
    // MARK: - 公开对应的变量
    
    /// 遮罩层能见度,默认0.68
    public var maskAlpha: CGFloat = 0.68 {
        didSet{
            self.maskRootView.alpha = maskAlpha
        }
    }
    
    /// 标题
    public var title: String? {
        didSet{
            self.titleLabel.text = title
        }
    }
    
    /// 子标题
    public var subTitle: String? {
        didSet{
            if subTitle == nil {
                self.subTitleLabel.removeFromSuperview()
            } else {
                self.subTitleLabel.text = subTitle
            }
        }
    }
    
    /// 确认按钮标题
    public var confirmBtnTitle: String? {
        didSet{
            self.confirmButton.setTitle(confirmBtnTitle, for: UIControl.State.normal)
        }
    }
    
    /// 取消按钮标题
    public var cancelBtnTitle: String? {
        didSet{
            //  Judy-mark: 设置按钮标题的正确姿势！！！
            self.cancelButton?.setTitle(cancelBtnTitle, for: UIControl.State.normal)
        }
    }
    
    /// 确认事件回调 sender: Any
    private var confirmClosure: (() -> Void)?
    /// 取消事件回调 sender: Any
    private var cancelClosure: (() -> Void)?
    
    /// 获取一个弹窗实例并置顶显示
    ///
    /// - Parameters:
    ///   - isSingle: 是否单个按钮的弹窗
    ///   - confirmHandle: 确认按钮事件处理函数
    ///   - cancelHandle: 取消按钮事件处理函数(左边按钮)
    /// - Returns: 该JudyAlert实例对象，可以使用该对象改变其属性。允许不接收返回值
    @discardableResult
    public static func judy(isSingle: Bool, confirmHandle: (() -> Void)?,
                            cancelHandle: (() -> Void)?) -> JudyAlert {
        
        let judyView = Bundle.main.loadNibNamed("Alert", owner: self, options: nil)![isSingle ? 0:1] as! JudyAlert
        judyView.frame = UIScreen.main.bounds
        judyView.confirmClosure = confirmHandle
        judyView.cancelClosure = cancelHandle
        Judy.topViewCtrl.view.window?.addSubview(judyView)
        return judyView
    }
    
    // MARK: - 私有变量及IBOutlet
    
    /// 遮罩View
    @IBOutlet private weak var maskRootView: UIView!
    
    /// 确认按钮
    @IBOutlet private weak var confirmButton: UIButton!
    /// 放弃按钮，只有alertDouble View才有，可能为nil
    @IBOutlet private weak var cancelButton: UIButton?
    
    /// 标题
    @IBOutlet private weak var titleLabel: UILabel!
    /// 子标题
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    /// 确认按钮点击事件
    ///
    /// - Parameter sender: sender
    @IBAction private func confirmAction(_ sender: Any) {
        self.removeFromSuperview()
        if self.confirmClosure != nil {
            self.confirmClosure!()
        }
    }
    
    /// 放弃按钮点击事件,只有alertDouble View才有
    ///
    /// - Parameter sender: sender
    @IBAction private func cancelAction(_ sender: Any) {
        self.removeFromSuperview()
        if self.cancelClosure != nil {
            self.cancelClosure!()
        }
    }
    
}
