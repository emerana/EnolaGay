//
//  extensions.swift
//
//
//  Created by 醉翁之意 on 2023/3/17.
//  Copyright © 2023年 EnolaGay All rights reserved.
//

// MARK: - Double 扩展

/// 为空间包装对象 Double 添加扩展函数
public extension EnolaGayWrapper where Base == Double {
    
    /// 将 double 四舍五入到指定小数位数并输出 String.
    ///
    /// - Parameter f: 要保留的小数位数，默认为 2
    /// - Returns: 转换后的 String
    func format(f: Int = 2) -> String {
        // String(format: "%.3f", 0.3030000000000000) ==> 0.303
        return String(format: "%.\(f)f", base)
    }
}

public extension Double {
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.format")
    func format(f: Int = 2) -> String { "" }
}


// MARK: - URL 扩展

public extension URL {
    
    /// utf8 编码的 URL适用于当URL地址中包含中文时无法正常加载等情况
    ///
    /// - Parameter utf8StringURL: 带有中文的链接，比如：http://api.tuoken.pro/api/product/qrDode?address=渠道商ETH地址
    /// - Returns: 对应的 URL 对象，如：http://api.tuoken.pro/api/product/qrDode?address=%E6%B8%A0%E9%81%93%E5%95%86ECH%E5%9C%B0%E5%9D%80.
    @available(*, unavailable, message: "请使用构造函数", renamed: "init(stringUTF8:)")
    static func utf8URL(utf8StringURL: String) -> URL? {
        let data = utf8StringURL.data(using: String.Encoding.utf8)
        guard data != nil else {
            return nil
        }
        return URL(dataRepresentation: data!, relativeTo: nil)
    }
    
    /// 构造一个经过 utf8 编码的 URL. 若链接中包含了中文，请使用此函数构建 URL 对象
    ///
    /// 通常情况下使用默认的 URL 构造器无法直接将带中文的链接转换成 URL，会得到一个 nil. 使用此构造函数能够将带有中文的 urlString 转成正常的链接，如："https://www.%E7%8E%8B%E4%BB%81%E6%B4%81.com". 当然即使 stringUTF8 不包含中文也没关系
    /// - Parameter stringUTF8: 要转换成 URL 的字符串链接，该链接中可能包含中文如：http://www.王仁洁.com.
    init?(stringUTF8: String) {
        guard let data = stringUTF8.data(using: String.Encoding.utf8) else {
            self.init(string: stringUTF8)
            return
        }
        self.init(dataRepresentation: data, relativeTo: nil)!
    }
}


// MARK: - NSAttributedString 扩展函数
public extension NSAttributedString {
    
}


// MARK: - NSMutableAttributedString 扩展函数
public extension NSMutableAttributedString {

    /// 生成一个高配版 NSMutableAttributedString.
    /// - Parameters:
    ///   - text: 要显示的文本信息
    ///   - textColor: 文本颜色，默认为 nil.
    ///   - textFont: 文本的字体，默认为 nil.
    ///   - highlightText: 高亮的文本，该文本应该是 text 的一部分
    ///   - highlightTextColor: 高亮文本的颜色，该值默认为 nil.
    ///   - highlightTextFont: 高亮状态文本的字体，默认为 nil.
    /// - Returns: attributedString.
    /// - Warning: addAttribute() 或 addAttributes() 均需要指定一个 range，如需扩展，可模拟此函数创建新的自定义函数
    convenience init(text: String, textColor: UIColor? = nil, textFont: UIFont? = nil, highlightText: String? = nil, highlightTextColor: UIColor? = nil, highlightTextFont: UIFont? = nil) {
        // 默认配置
        var defaultAttrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色
        defaultAttrs[.foregroundColor] = textColor
        // 高亮文本字体
        defaultAttrs[.font] = textFont
        
        self.init(string: text, attributes: defaultAttrs)
        
        // 指定范围添加 attributes
        if highlightText != nil {
            var attrs = [NSAttributedString.Key : Any]()
            // 高亮文本颜色
            attrs[.foregroundColor] = highlightTextColor
            // 高亮文本字体
            attrs[.font] = highlightTextFont
            // 添加到指定范围
            addAttributes(attrs, range: mutableString.range(of: highlightText!))
        }
        
        // 基线对齐方式
        // NSBaselineOffsetAttributeName:@(([UIFont systemFontOfSize:30].lineHeight - [UIFont systemFontOfSize:15].lineHeight)/2 + (([UIFont systemFontOfSize:30].descender - [UIFont systemFontOfSize:15].descender))),
        //                                  NSParagraphStyleAttributeName
        
        // 指定范围单个添加 addAttribute
        /*
         attributed.addAttribute(.foregroundColor, value: highlightedColor, range: attributedString.mutableString.range(of: highlightedText))
         attributed.addAttribute(.foregroundColor, value: highlightTextColor, range: attributedString.mutableString.range(of: highlightText!))
         attributed.addAttribute(.link, value: "https://www.baidu.com", range: attributed.mutableString.range(of: "《直播主播入驻协议》"))
         attributed.addAttribute(.underlineColor, value: UIColor.clear, range: attributed.mutableString.range(of: "《直播主播入驻协议》"))
         attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: attributed.mutableString.range(of: "《直播主播入驻协议》"))
         attributedText = attributed
         */
    }

}
