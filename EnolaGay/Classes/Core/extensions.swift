//
//  extensions.swift
//
//  Created by 醉翁之意 on 2023/3/17.
//  Copyright © 2023年 EnolaGay All rights reserved.
//

// MARK: - String 扩展

public extension String {
    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.getVideoTime")
    static func getVideoTime(duration: TimeInterval) -> String { "" }
    
    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.dateFormatter")
    func dateFormatter(formatterIn: String = "yyyy-MM-dd HH:mm:ss", formatterOut: String = "HH:mm:ss") -> String { "" }

    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.clean")
    func clean() -> String { "" }
    
    
    /// 下标获取字符串
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)), upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    /// 转换成10进制的 Int 值
    ///
    /// 如"0x606060"/"606060"，调用此属性即可获得559964256.
    ///
    /// 由于某些原因，使用了 String(15493441,radix:16) 函数将某个10进制的值转成16进制的 String,现在只能通过 String 的此属性还原成10进制的 Int.
    ///
    /// - Warning: 请确保该字符串内容是正确的16进制值
    var intValueFrom16Decimal: Int {
        let str = self.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 { // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }

    /*
     let str = "Hello, world!"
     let index = str.index(str.startIndex, offsetBy: 4)
     str[index] // 返回字符 'o'
     
     let endIndex = str.index(str.endIndex, offsetBy:-2)
     str[index ..< endIndex] // 返回 字符串 "o, worl"
     
     String(str.suffix(from: index)) // 返回 字符串 "o, world!"
     String(str.prefix(upTo: index)) // 返回 字符串 "Hell"
     
     */
    @available(*, unavailable, message: "此函数尚未验证其准确性")
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }
    
    /// 截取 String 前几位子字符串
    /// - Parameter toIndex: 0 ..< toIndex
    @available(*, unavailable, message: "此函数尚未验证其准确性")
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    //不包含后几个字符串的方法
    //    func dropLast(_ n: Int = 1) -> String {
    //        return String(characters.dropLast(n))
    //    }
    //    var dropLast: String {
    //        return dropLast()
    //    }
}


// MARK: - Date 扩展

public extension Date {
    
    /// 通过一个 string 构建一个北京时区的 date 对象
    /// - Parameters:
    ///   - string: 该 string 应符合一个正常日期格式
    ///   - format: 目标的日期格式，该值默认为："yyyy-MM-dd".
    init(string: String, format: String = "yyyy-MM-dd") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: string) {
            self = date.judy.dateFromGMT()
        } else {
            self.init()
        }
    }
    
    /// 通过一个 string 构建一个北京时区的 date 对象
    init(year: Int = 2020, month: Int = 3, day: Int = 22) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = "\(year)-\(month)-\(day)"
        if let date = dateFormatter.date(from: dateString) {
            self = date.judy.dateFromGMT()
        } else {
            self.init()
        }
    }
    
}


// MARK: - URL 扩展

public extension URL {
    
    /// 构造一个经过 utf8 编码的 URL. 若链接中包含了中文，请使用此函数构建 URL 对象。
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
