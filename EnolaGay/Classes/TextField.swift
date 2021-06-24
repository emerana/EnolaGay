//
//  JudyBaseTextField.swift
//  Chain
//
//  Created by 艾美拉娜 on 2018/10/12.
//  Copyright © 2018 杭州拓垦网络科技. All rights reserved.
//

import UIKit

/// EMERANA框架中所用到的 TextField，默认 FontStyle 为均码。
open class JudyBaseTextField: UITextField, FontStyle {

    // MARK: 配置字体样式
    // @IBInspectable private(set) public var initFontStyle: Int = 0

    public var fontStyle: UIFont.FontStyle = .M {
        didSet{
            font = UIFont(style: fontStyle)
        }
    }

    var inputType: ContentType = .默认 {
        didSet{
            setInputType()
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // font = UIFont(style: UIFont.FontStyle.new(rawValue: initFontStyle))
        
//        delegate = self
    }

}


public extension UITextField {
    
    /// 为 placeholder 设置一个颜色，只有在设置了 placeholder 时此函数才生效
    func setPlaceholderColor(color: UIColor = .red ) {
        guard placeholder != nil else { return }
        let attrString = NSAttributedString(string: placeholder!, attributes: [.foregroundColor : color])
        attributedPlaceholder = attrString
    }

}


public extension JudyBaseTextField {
    
    enum ContentType {
        /// 系统最初始的样子
        case 默认
        case 身份证
        case 邮箱
        case 固定电话
        case 手机号
        case 数字
        case 非零的正整数
        case 零和非零开头的数字
        /// 一般用于钱的表示
        case 非零开头最多带两位小数的数字
        case 密码
    }

    //    public enum ContentType {
    //        /// 系统最初始的样子
    //        case 默认
    //        case 身份证(_: String)
    //        case 邮箱(_: String)
    //        case 固定电话(_: String)
    //        case 手机号(_: String)
    //        case 数字(_: String)
    //        case 非零的正整数(_: String)
    //        case 零和非零开头的数字(_: String)
    //        case 非零开头的最多带两位小数的数字(_: String)
    //        case 密码(_: String)
    //    }

    
    
}


// MARK: - 私有函数
private extension JudyBaseTextField {
    
    /// 设置 inputType 事件
    func setInputType() {
        switch inputType {
        case .默认, .密码:
            keyboardType = .default
        case .身份证:
            keyboardType = .numbersAndPunctuation
        case .邮箱:
            keyboardType = .emailAddress
        case .固定电话, .手机号, .数字, .非零的正整数, .零和非零开头的数字:
            keyboardType = .numberPad
        case .非零开头最多带两位小数的数字:
            keyboardType = .decimalPad
        }
    }
    
}

// MARK: - UITextFieldDelegate
//public extension JudyBaseTextField: UITextFieldDelegate {
//    
//    // 输入验证。当值发生更改时的确认。
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
////        if textField.tag == 101 {
////            return Judy.number(textField: textField, range: range, string: string, num: 11, maxNumber: 0)
////        }
////        return Judy.number(textField: textField, range: range, string: string, num: 6, maxNumber: 0)
//        
//        Judy.log("shouldChangeCharactersIn<!-- \(string) -->,输入之前为--> \(String(describing: textField.text))")
//        
//        return true
//    }
//    
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        Judy.log(textField.text)
//    }
//
//}
