//
//  SearchView.swift
//  Promote
//
//  Created by 醉翁之意 on 2018/4/12.
//  Copyright © 2018年 吾诺瀚卓.王仁洁. All rights reserved.
//

import UIKit

/**
 搜索框 View
 * 包含 input 和 button 两种类型，searchViewType
 * button类型需要实现 action 闭包，如下
 ```
 JudySearchView.judy().action = { button in ...}
 ```
 */
open class JudySearchView: UIView {
    
    @IBOutlet private weak var widthForSearchView: NSLayoutConstraint!
    @IBOutlet private weak var heightForSearchView: NSLayoutConstraint!

    // MARK: search input view
    
    @IBOutlet weak var searchTextField: UITextField?

    // MARK: search button view

    @IBOutlet weak var searchButton: UIButton?
    
    /// 按钮标题或输入的文本颜色
    var titleColor: UIColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    
    /// searchView的宽度，默认为屏幕宽度 - 126
    var viewWidth: CGFloat = Judy.getScreenWidth() - 126 {
        didSet{
            widthForSearchView.constant = viewWidth
        }
    }
    
    /// searchView的高度，默认为32
    var viewHeight: CGFloat = 32 {
        didSet{
            heightForSearchView.constant = viewHeight
        }
    }
    
    /// 搜索框placeholder，默认为 "请输入关键字"
    var searchPlaceholderText: String = "请输入关键字" {
        didSet{
            searchTextField?.placeholder = searchPlaceholderText
        }
    }

    /// 当type为按钮时，实现此回调以响应点击事件
    var action: ((UIButton) -> Void)?
    
    /// 搜索框类型
    ///
    /// - input: 输入框类型
    /// - button: 按钮类型，此类型的搜索框需要实现回调以执行点击按钮响应操作
    /// - button: 按钮类型，但内容文本靠左对齐
    public enum searchViewType{
        case input
        case button
    }
    
    /// 获取一个inputSearchView，主要用于放在navigationBar上面，默认有4像素的圆角
    ///
    /// - Parameters:
    ///   - alignLeft: 文字是否向左对齐，默认 false。
    ///   - type: 搜索框类型
    ///   - viewWidth: 视图宽度，默认为Judy.getScreenWidth() - 126
    ///   - viewHeight: 视图高度，默认32
    /// - Returns: 搜索框View
    public static func judy(alignLeft: Bool = false,
                            type: searchViewType,
                            viewWidth: CGFloat = Judy.getScreenWidth() - 126,
                            viewHeight: CGFloat = 32) -> JudySearchView? {
        // 直接根据类名来获取xib.
        let judyView = Bundle.main.loadNibNamed(NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!,
                                                           owner: self, options: nil)![0] as? JudySearchView
        
        if judyView != nil {
            judyView!.judy.viewRadiu(radiu: 8)
            judyView!.widthForSearchView.constant = viewWidth
            judyView!.heightForSearchView.constant = viewHeight

            /// 背景色默认为 AppStore 搜索界面一样的颜色
            judyView?.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            switch type {
            case .input:
                judyView?.searchButton?.removeFromSuperview()
                judyView?.searchButton = nil

                // Judy-mark: 修改 textField 的光标颜色
                judyView!.searchTextField?.tintColor = judyView!.titleColor
                judyView!.searchTextField?.font = UIFont(name: .苹方_简_中黑体, size: 16)
//                judyView!.searchTextField?.textColor = judyView!.titleColor
                // Judy-mark: 修改所有textField的光标颜色
                //            UITextField.appearance().tintColor = .black
                judyView!.searchTextField?.textAlignment = alignLeft ? .left:.center
            case .button:
                judyView?.searchTextField?.removeFromSuperview()
                judyView?.searchTextField = nil
                // Judy-mark: 修改searchButton颜色
                judyView!.searchButton?.setTitleColor(judyView!.titleColor, for: .normal)
                judyView!.searchButton?.titleLabel?.font = UIFont(name: .苹方_简_中黑体, size: 16)
                judyView!.searchButton?.contentHorizontalAlignment = alignLeft ? .left:.center
                judyView!.searchButton?.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: alignLeft ? 8:0, bottom: 0, right: 0)
                judyView!.searchButton?.setImageTextSpacing(spacing: 8)
            }
        }
        
        return judyView
    }
    
    /// 点击事件
    @IBAction private func clickedAction(_ sender: Any) {
        action?(sender as! UIButton)
    }

}
