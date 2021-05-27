//
//  JudyBaseLabel.swift
//  emerana
//
//  Created by 醉翁之意 on 2018/8/2.
//  Copyright © 2018年 艾美拉娜.王仁洁 All rights reserved.
//

import UIKit

/// EMERANA 框架中所用到的 Label，实现 EMERANA_FontStyle，默认 fontStyle 为均码。
/// ## 支持功能：
/// * 在 label 上显示删除线
/// * 单击弹出复制功能（在 storyboard 中启用 isSupportCopy 或 isSupportCopy = true）
/// * 内边距属性调整功能
/// * 支持深度拷贝，参考 copy(with zone: NSZone? = nil) -> Any 函数
open class JudyBaseLabel: UILabel, EMERANA_FontStyle {
    
    /// 是否显示一条删除线，默认 false.
    @IBInspectable var isUnderline: Bool = false
    
    // MARK: 复制文本功能
    
    /// 允许成为第一响应
    open override var canBecomeFirstResponder: Bool { true }
    /// 是否支持复制功能，默认 false.
    @IBInspectable var isSupportCopy: Bool = false
    /// 当 isSupportCopy = true 时，点击 label 进行复制时的提示文字
    @IBInspectable public var altTitle: String = ""
    /// 要复制的文本，默认 nil(复制时将复制整个 Label 的值)
    public var pasteboardText: String? = nil
    
    // MARK: - EMERANA 字体
    
    @IBInspectable private(set) dynamic public var initFontStyle: Int = 0

    public var fontStyle: UIFont.FontStyle = .M {
        didSet{
            font = UIFont(style: fontStyle)
        }
    }

    // MARK: - 内边距属性
    
    /// 内边距
    /// - warning: 请在设置 label.text 前使用，否则可能影响到 frame
    public var padding = UIEdgeInsets.zero
    
    /// 文本左边距，请在设置 label.text 前使用，否则可能影响到 frame
    @IBInspectable public var paddingLeft: CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }
    
    /// 文本右边距，请在设置 label.text 前使用，否则可能影响到 frame
    @IBInspectable public var paddingRight: CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }
    
    /// 文本上边距，请在设置 label.text 前使用，否则可能影响到 frame
    @IBInspectable public var paddingTop: CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }
    
    /// 文本下边距，请在设置 label.text 前使用，否则可能影响到 frame
    @IBInspectable public var paddingBottom: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }
    
    
    // MARK: - 重写父类方法
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        font = UIFont(style: UIFont.FontStyle.new(rawValue: initFontStyle))
        // 复制功能
        if isSupportCopy {
            isUserInteractionEnabled = isSupportCopy
            
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(longPressAction(recognizer:)))
            // longPress.minimumPressDuration = 1   // 长按时间
            addGestureRecognizer(tapGesture)
        }
        // 删除线
        if isUnderline {
            guard text != nil else { return }
            let str = text! as NSString
            let attributedString = NSMutableAttributedString(string: text!)
            
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range:NSRange(location:0,length:str.length))
            attributedText = attributedString
        }

        
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = self.padding
        
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x    -= insets.left
        rect.origin.y    -= insets.top
        rect.size.width  += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
    
    // 请求接收响应程序在用户界面中启用或禁用指定的命令。
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(customCopy(sender:))
    }
    

    // MARK: - 事件
    
    // 单击弹出菜单控制器
    @objc func longPressAction(recognizer: UIGestureRecognizer) {
        becomeFirstResponder()
        
        UIMenuController.shared.menuItems = [UIMenuItem(title: (altTitle == "") ? "复制":altTitle, action: #selector(customCopy(sender:)))]
        UIMenuController.shared.showMenu(from: superview!, rect: frame)
                
    }
    
    // 复制事件
    @objc func customCopy(sender: Any){
        let pasteboard: UIPasteboard = UIPasteboard.general
        pasteboard.string = pasteboardText ?? text
    }
}

// MARK: - 深度对象拷贝
extension JudyBaseLabel: NSCopying {
    
    // 深度拷贝
    public func copy(with zone: NSZone? = nil) -> Any {
        let label = JudyBaseLabel()
        label.font = font
        label.textColor = textColor
        label.cornerRadius = cornerRadius
        label.backgroundColor = backgroundColor
        label.padding = padding
        return label
    }
    

}
