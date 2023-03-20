//
//  Wrapper.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 2023/3/18.
//

// MARK: - 命名空间

/// 在 EnolaGay 中的兼容包装对象，该包装类型为 EnolaGay 中的方便方法提供了一个扩展点。
public struct EnolaGayWrapper<Base> {
    /// 包装对象在 EnolaGay 中对应的原始对象
    var base: Base
    init(_ base: Base) { self.base = base }
}

/// 表示与 EnolaGay 兼容的对象类型协议。使指定类型接受命名空间兼容类型协议，指定类型就可以使用 Judy 命名空间。
///
/// 目标类型在实现该协议后即可使用`judy`属性在 EnolaGay 的名称空间中获得一个值包装后的对象（不限制 AnyObject）。
public protocol EnolaGayCompatible { }

extension EnolaGayCompatible {
    /// 获取在 EnolaGay 中的兼容类型包装对象，即 EnolaGay 空间持有者对象。
    public var judy: EnolaGayWrapper<Self> {
        get { return EnolaGayWrapper(self) }
        set { }
    }
}


// MARK: - Double 扩展

// 使 Double 接受命名空间兼容类型协议
extension Double: EnolaGayCompatible { }

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


// MARK: - String 扩展

// 使 String 接受命名空间兼容类型协议
extension String: EnolaGayCompatible { }

/// 为空间包装对象 String 添加扩展函数
public extension EnolaGayWrapper where Base == String {
    /// 通过一个时间戳获取视频的总时长
    /// - Parameter duration: 视频的 player.duration，如 1942.2760000000001.
    /// - Returns: 如：00:32:22.
    static func getVideoTime(duration: TimeInterval) -> String {
        let timeStamp: NSInteger = NSInteger(duration)
        
        let h = String(format: "%02d", timeStamp/3600)
        let m = String(format: "%02d", timeStamp/60)
        let s = String(format: "%02d", timeStamp%60)
        
        return "\(h):\(m):\(s)"
    }
    
    /// 将字符串转换成时间格式如将"2016-08-19 16:23:09" 转成 "16:23:09".
    ///
    /// - Parameters:
    ///   - formatterIn: 该字符串的原始时间格式默认 "yyyy-MM-dd HH:mm:ss".
    ///     - 可选
    ///        - yyyy-MM-dd'T'HH:mm:ssZ
    ///        - yyyy-MM-dd'T'HH:mm:ss.SSSXXX
    ///   - formatterOut: 目标时间格式默认 "HH:mm:ss"
    /// - Returns: 目标格式的时间 String
    func dateFormatter(formatterIn: String = "yyyy-MM-dd HH:mm:ss", formatterOut: String = "HH:mm:ss") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatterIn
        dateFormatter.timeZone = .current
        
        if let dated = dateFormatter.date(from: base) {
            dateFormatter.dateFormat = formatterOut
            return dateFormatter.string(from: dated)
        } else {
            log("时间转换失败")
            return "time error"
        }
    }
    
    /// 计算文本的 size.
    ///
    /// - Parameters:
    ///   - font: 以该字体作为计算尺寸的参考
    ///   - maxSize: 最大尺寸，默认为 CGSize(width: 320, height: 68).
    /// - Returns: 文本所需宽度
    func textSize(maxSize: CGSize = CGSize(width: 320, height: 68), font: UIFont = UIFont(size: 16)) -> CGSize {
        // 根据文本内容获取尺寸，计算文字尺寸 UIFont.systemFont(ofSize: 14.0)
        return base.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin],
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size
    }
    
    /// 计算文本的 size.
    func sizeWith(font: UIFont = UIFont(size: 16) , maxSize : CGSize = CGSize(width: 168, height: 0) , lineMargin : CGFloat = 2) -> CGSize {
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin
        
        var attributes = [NSAttributedString.Key : Any]()
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let textBouds = base.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        
        return textBouds.size
    }

    /// 清除字符串中的所有空格
    ///
    /// - Returns: 如："str abc", "strabc".
    func clean() -> String { base.replacingOccurrences(of: " ", with: "") }
}


// MARK: - Calendar 扩展

// 使 Calendar 接受命名空间兼容类型协议
extension Calendar: EnolaGayCompatible { }

public extension EnolaGayWrapper where Base == Calendar {
    /// 获取当月从今天算起剩余的天数
    var daysResidueInCurrentMonth: Int {
        var startComps = DateComponents()
        startComps.day = components.day
        startComps.month = components.month
        startComps.year = components.year
        
        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = (components.month == 12) ? 1 : ((components.month ?? 0) + 1)
        endComps.year = (components.month == 12) ? ((components.year ?? 0) + 1) : components.year
        
        let diff = base.dateComponents([.day], from: startComps, to: endComps)
        
        return diff.day ?? 1
    }
    
    /// 便携式访问该日历当前时间点的日期组件，包含年月日时分秒
    var components: DateComponents {
        return base.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: Date())
    }
    
    /// 当前月份的天数
    var daysInCurrentMonth: Int {
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = components.month
        startComps.year = components.year
        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = components.month == 12 ? 1 : ((components.month ?? 0) + 1)
        endComps.year = components.month == 12 ? ((components.year ?? 0) + 1) : components.year
        
        let diff = base.dateComponents([.day], from: startComps, to: endComps)
        return diff.day ?? 0
    }
    
    /// 计算指定月份的天数
    ///
    /// - Parameters:
    ///   - year: 指定的年份信息
    ///   - month: 指定的月份信息
    /// - Returns: 该年该月的天数
    func getDaysInMonth(year: Int, month: Int) -> Int {
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        
        let diff = Calendar.current.dateComponents([.day], from: startComps, to: endComps)
        return diff.day ?? 0
    }
    
    /// 获取指定年月日的星期
    /// - Parameters:
    ///   - year: 指定的年份
    ///   - month: 指定的月份
    ///   - day: 指定的日期
    /// - Returns: 星期，1为周日，7为周六
    func getWeekday(year: Int, month: Int, day: Int) -> Int {
        let date = Date(year: year, month: month, day: day)
        guard let weekday = base.dateComponents([.weekday], from: date).weekday else {
            logWarning("获取星期失败，默认返回1")
            return 1
        }
        return weekday
    }
}


// MARK: - Date 扩展

// 使 Date 接受命名空间兼容类型协议
extension Date: EnolaGayCompatible { }

public extension EnolaGayWrapper where Base == Date {
    @available(*, unavailable, message: "此函数已被优化", renamed: "stringValue(format:)")
    func stringFormat(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String { "" }
    @available(*, unavailable, message: "此函数已被优化", renamed: "stringDateFormGMT")
    func stringGMT() -> Date { Date() }

    /// 将当前 Date() 转转换成北京时区的 Date.
    ///
    /// Date() 将得到格林威治时间（标准时间），比北京时间早了 8 小时。此函数将其转换成北京时间。
    /// 如 Date() 为 2022-11-18 06:08:47 +0000，此函数将转成 2022-11-18 14:08:47 +0000.
    /// - Returns: 转换成北京时间的 Date 对象
    func dateFromGMT() -> Date {
        // let today = Date()   // 获取格林威治时间（GMT）即：标准时间
        // print(today) // 打印出的时间是 GTM 时间，比北京时间早了8个小时。
        /// 获取当前时区和 GMT 的时间间隔，当前时区和格林威治时区的时间差 8小时 = 28800秒。
        let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: base))
        return base.addingTimeInterval(secondFromGMT)
    }
    
    /// 将当前 Date 值转换成指定格式化样式字符串
    ///
    /// 如 Date() 为 2022-11-18 06:08:47 +0000 ，此函数将转成 2022-11-18 06:08:47.
    ///
    /// - Parameter dateFormat: date 值的目标样式，默认值为 "yyyy-MM-dd HH:mm:ss".
    /// - Returns: String 格式的目标样式
    func stringValue(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let timeZone = TimeZone(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = format
        let date = formatter.string(from: base)
        // return date.components(separatedBy: "-").first!
        return date
    }
    
    /// 当 Date 转换成北京时区的目标格式 string 值
    /// - Parameter format: 目标格式，默认为 "yyyy-MM-dd HH:mm:ss".
    /// - Returns: format 对应的目标值
    func stringDateFormGMT(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        return dateFromGMT().judy.stringValue(format: format)
    }
}



// MARK: - Swift提供的许多功能强大的全局函数

/*
 
 var intValue = -10
 
 abs(intValue) //绝对值, 10
 
 advance(intValue, 30) //移动，20
 
 alignof(Float)  //对齐，4
 
 alignofValue(intValue) //对齐，8
 //断言，如果条件不成立，抛出异常并打印信息
 assert(intValue < 0, "intValue小于0", file: "iOS_Playground", line: 10)
 assert(intValue < 0, "intValue小于0...")
 
 c_putchar(98) //打印ASCII码
 //包含
 var arr = [100, 20, 4, 15]
 if contains(arr, 2) {
 println("arr contains 2")
 } else  {
 println("arr not contains 2")
 }
 
 count(20..39) //统计范围里值的个数, 19
 
 countElements(arr) //统计元素个数
 countElements(1...20)
 
 countLeadingZeros(1) //统计二进制数的前导0的个数
 
 debugPrint("abc") //调试输出
 
 distance(9, 11) //计算距离
 
 dropFirst(arr) //截去第一个元素后的数组，不改变原始数组
 
 dropLast(arr) //截去最后一个元素后的数组，不改变原始数组
 
 dump(arr) //导出对象内容
 
 public enumerate(arr)
 
 var arr2 = [1, 20, 4, 5]
 equal(arr, arr2)
 
 //fatalError("Fata Error", file: "iOS_Playground", line: 40)
 //过滤，第一个参数为源数据，第二个为过滤方法（闭包）
 var filtered = filter(arr, { $0 > 3 } )
 //查找元素，第一个参数为源数据，第二个参数为目标数据
 find(arr, 2)
 
 indices(arr)
 //插入排序
 insertionSort(&arr, Range(start: 0, end: arr.count))
 
 var arr3 = ["x", "y", "z"]
 //连接数组元素
 join("oooo", arr3)
 //映射，map的第一个参数为源数据，第二个参数为映射的方法（闭包）
 var arr4 = Array(map(arr, { $0 + 10 }))
 arr4
 //最大值
 max(1, 2, 4, 8, 19, 200)
 maxElement(arr)
 minElement(arr)
 
 arr
 //化简，
 reduce(arr, 1000, { return $0 + $1 })
 reduce(arr, 1, { return $0 * $1 })
 
 */

// MARK: - Podfile 多 target 管理

/*
 
 platform :ios, '10.0'
 use_frameworks!
 
 abstract_target 'Judy' do
 
 pod 'Alamofire'
 ……
 
 target 'Chain'
 target 'ChainTuoKen'
 target 'ChainInstall'
 
 end
 */
