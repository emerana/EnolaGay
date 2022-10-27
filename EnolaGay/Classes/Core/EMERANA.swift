//
//  EMERANA.swift
//
//  Created by 艾美拉娜 on 2018/10/5.
//  Copyright © 2018. All rights reserved.
//

import SwiftyJSON

// MARK: typealias

/// 一个不传递任何参数的闭包类型
public typealias Closure = (() -> Void)
/// 传递一个 JSON 对象的闭包类型
public typealias ClosureJSON = ((JSON) -> Void)
/// 传递一个 String 对象的闭包类型
public typealias ClosureString = ((String) -> Void)


// MARK: - 刷新视图专用协议，主要用于 tableView、collectionView

/// EMERANA 中的刷新控件适配器协议
public protocol RefreshAdapter where Self: UIApplication {
    /// 默认的请求参数 pageSize 字段名，该值默认为 EMERANA.Key.pageSizeParameter，即”pageSize“。
    var pageSizeParameter: String { get }
    /// 默认的请求参数 pageIndex 字段名，该值默认为 EMERANA.Key.pageSizeParameter，即”pageIndex“。
    var pageIndexParameter: String { get }

    /// 配置头部刷新控件（即下拉刷新）
    func initHeaderRefresh(scrollView: UIScrollView?, callback: @escaping (()->Void))
    /// 配置底部刷新控件（即上拉加载）
    func initFooterRefresh(scrollView: UIScrollView?, callback: @escaping (()->Void))
    
    /// 结束所有上拉、下拉状态
    func endRefresh(scrollView: UIScrollView?)
    /// 结束没有更多数据的函数
    func endRefreshingWithNoMoreData(scrollView: UIScrollView?)
    
    /// 重置没有更多数据
    func resetNoMoreData(scrollView: UIScrollView?)
    
}

/// 默认实现
public extension RefreshAdapter {
    var pageSizeParameter: String { EMERANA.Key.pageSizeParameter }
    var pageIndexParameter: String { EMERANA.Key.pageIndexParameter }
}

/// tableView、collectionView 专用刷新协议
/// - Warning: 此协议仅对 JudyBaseViewCtrl 及其派生类提供
public protocol EMERANA_Refresh where Self: JudyBaseViewCtrl {
    /// 缺省请求页码，通常第一页码为1，但有的情况可能为 0.
    var defaultPageIndex: Int { get }
    /// 请求页码初始化、下拉刷新时会重置到默认值 defaultPageIndex.
    var currentPage: Int { get }
    /// 每页的数据大小
    var pageSize: Int { get }

    /// 请求参数 pageSize 字段名，该值默认为 RefreshAdapter 协议中的 pageSizeParameter 属性，重写此属性以重新设置。
    var pageSizeParameter: String { get }
    /// 请求参数 pageIndex 字段名，该值默认为 RefreshAdapter 协议中的 pageIndexParameter 属性，重写此属性以重新设置。
    var pageIndexParameter: String { get }

    /// 该属性标识最后操作是否为上拉加载，通常在获取到服务器数据后需要判断该值进行数据的处理。
    var isAddMore: Bool { get }
    
    /// 请在此函数中配置头部（下拉）刷新控件
    func initHeaderRefresh()
    /// 请在此函数中配置底部（上拉）加加载控件
    func initFooterRefresh()
    
    /// 当 currentPage 发生变化的操作
    func didSetCurrentPage()

    /// 执行下拉刷新之前的事件补充
    func refreshHeader()
    /// 执行上拉加载之前的事件补充
    func refreshFooter()

    /// 询问当前分页数据的总页数
    ///
    /// 通过服务器响应的数据量来判断是否还有更多数据，通常以请求数据大小为条件，只要没有达到目标数据大小即视为没有更多数据，参考代码：
    /// ```
    /// return apiData["data"].arrayValue.count != 10 ? currentPage:currentPage+1
    /// ```
    /// - Warning: 若未覆盖此函数，默认值为 1.
    func setSumPage() -> Int
    
    /// 重置当前页面请求页数及上下拉状态
    ///
    /// 在此函数中请将 `currentPage`、`isAddMore` 设置为初始值
    /// - Warning: 此函数一般用于 segmentCtrl 发生切换并需要重新请求 Api 时重置当前刷新状态
    func resetStatus()
}

extension EMERANA_Refresh {
    /// 是否隐藏上拉刷新控件？默认 false.
    /// - warning: 所有实现 EMERANA_Refresh 协议的对象均能触发此扩展函数
    ///     * 在此函数中补充所需操作，扩展对应的类并重写此函数
    func hideFooterStateLabel() -> Bool { false }
}


/// 此协议仅适用于包含基础集合视图的 tableViewCtrl、collectionViewCtrl.
protocol EMERANA_CollectionBasic where Self: JudyBaseViewCtrl {
    
    /// 主要数据源，需要手动赋值，默认为空数组
    var dataSource: [JSON] { get set }
    
    /// 重写此方法并在此方法中注册 Cell 或 HeaderFooter**此方法在 ViewDidLoad() 中被执行**
    ///
    /// * 注册 Cell 参考代码
    /// ```
    /// let nib = UINib(nibName: "<#XibName#>", bundle: nil)
    /// tableView?.register(nib, forCellReuseIdentifier: "<#Cell#>")
    /// let rightHeader = UINib(nibName: "<#XibName#>", bundle: Bundle.main)
    /// tableView?.register(leftHeader, forHeaderFooterViewReuseIdentifier: "<#Header#>")
    /// ```
    /// * 创建 Cell 参考代码
    /// ```
    /// let cell = tableView.dequeueReusableCell(withIdentifier: "<#Cell#>", for: indexPath)
    /// ```
    /// - Warning: 一个 Nib 里面只放一个 Cell，且里面的 Cell 不能自带 identifier，否则必须用自带的 identifier 进行注册
    func registerReuseComponents()
}

// MARK: - tableViewCell 和 collectionViewCell 专用协议

/// Cell 基础协议
/// - Warning: 此协议针对 tableViewCell、collectionViewCell 类定制
public protocol EMERANA_CellBasic {
    /// 标题
    var titleLabel: UILabel? { get set }
    /// 副标题
    var subTitleLabel: UILabel? { get set }
    /// 主图片
    var masterImageView: UIImageView? { get set }
    /// Cell 中的数据源
    ///
    /// 设置该值的时候将触发 jsonDidSetAction()，函数中的默认对应:
    /// * titleLabel -> EMERANA.Key.Cell.title
    /// * subTitleLabel -> EMERANA.Key.Cell.subtitle
    var json: JSON { get set }
}

/*
 // MARK: 默认实现的注意点
 
 # 注意：协议扩展是针对抽象类的，而协议本身是针对具体对象的
 # 当声明协议时没有进行限定则须注意以下：
 # 重写协议的默认实现函数调用权重为 子类>实现类>默认实现，若没有在实现类实现函数则直接调用默认实现函数，此时子类的重写无效
 */
/// 为 EMERANA_CellBasic 协议新增的扩展函数（非默认实现函数）
public extension EMERANA_CellBasic {
    /// 所有实现 EMERANA_CellBasic 协议的对象在初始函数中均会先触发此扩展函数，在此函数中补充所需操作
    ///
    /// 扩展对应的类并重写此函数即可使该类执行重写后的函数
    func globalAwakeFromNib() { }
    
    func selectedDidSet(isSelected: Bool) { }
}

/*
 
 // MARK: - @available 使用

 @available： 可用来标识计算属性、函数、类、协议、结构体、枚举等类型的生命周期（依赖于特定的平台版本 或 Swift 版本）
 available 特性经常与参数列表（列表如下）一同出现，该参数列表至少有两个特性参数，参数之间由逗号分隔。
 
 unavailable：表示该声明在指定的平台上是无效的。
 introduced：表示指定平台从哪一版本开始引入该声明。
 deprecated：表示指定平台从哪一版本开始弃用该声明，虽然被弃用，但是依然使用的话也是没有问题的，若省略版本号，则表示目前弃用，同时可直接省略冒号。
 obsoleted：表示指定平台从哪一版本开始废弃该声明，当一个声明被废弃后，它就从平台中移除，不能再被使用
 message：说明信息当使用被弃用或者被废弃的声明时，编译器会抛出警告或错误信息。
 renamed：新的声明名称信息，当使用旧声明时，编译器会报错，提示修改为新名字。
 
 如果 available 特性除了平台名称参数外，只指定了一个 introduced 参数，那么可以使用以下简写语法代替：
 @available(平台名称 版本号, *)
 
 @available(*, unavailable, message: "此协议已废弃，请更新协议命名", renamed: "EMERANA_Config")
 
 */


// MARK: - UIColor 配置扩展

public extension UIColor {
    
    static let 淡红色 = #colorLiteral(red: 0.9254901961, green: 0.4117647059, blue: 0.2549019608, alpha: 1)
    static let 浅红橙 = #colorLiteral(red: 0.9450980392, green: 0.568627451, blue: 0.2862745098, alpha: 1)
    static let 浅黄橙 = #colorLiteral(red: 0.9725490196, green: 0.7098039216, blue: 0.3176470588, alpha: 1)
    static let 浅黄 = #colorLiteral(red: 1, green: 0.9568627451, blue: 0.3607843137, alpha: 1)
    static let 浅青豆绿 = #colorLiteral(red: 0.7019607843, green: 0.831372549, blue: 0.3960784314, alpha: 1)
    static let 浅黄绿 = #colorLiteral(red: 0.5019607843, green: 0.7607843137, blue: 0.4117647059, alpha: 1)
    static let 浅绿 = #colorLiteral(red: 0.1960784314, green: 0.6941176471, blue: 0.4235294118, alpha: 1)
    static let 浅绿青 = #colorLiteral(red: 0.07450980392, green: 0.7098039216, blue: 0.6941176471, alpha: 1)
    static let 浅青 = #colorLiteral(red: 0, green: 0.7176470588, blue: 0.9333333333, alpha: 1)
    static let 浅洋红 = #colorLiteral(red: 0.9176470588, green: 0.4078431373, blue: 0.6352941176, alpha: 1)
    static let 浅蓝紫 = #colorLiteral(red: 0.3725490196, green: 0.3215686275, blue: 0.6274509804, alpha: 1)
    static let 浅紫洋红 = #colorLiteral(red: 0.6823529412, green: 0.3647058824, blue: 0.631372549, alpha: 1)

    /*
     * static 和 class 的区别.
     *
     * static 定义的属性和 func 没办法被子类 override.
     * class 定义的属性和 func 可以被子类 override.
     */
    
    /// 此颜色为白色
    static let scrollView: UIColor = .white

    // MARK: 构造函数

    /// 通过一个 16 进制的 Int 值生成 UIColor
    ///
    /// - Parameters:
    ///   - rgbValue: 如:0x36c7b7（其实就是#36c7b7，但必须以0x开头才能作为 Int）
    ///   - alpha: 默认1 可见度，0.0~1.0，值越高越不透明，越小越透明
    convenience init(rgbValue: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(Float((rgbValue & 0xff0000) >> 16)) / 255.0,
                  green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0),
                  blue: CGFloat((Float(rgbValue & 0xff) / 255.0)),
                  alpha: alpha)
    }
    
    /// 通过指定 RGB 比值生成 UIColor，不需要2/255，只填入2即可
    /// - Parameters:
    ///   - r: 红色值
    ///   - g: 绿色值
    ///   - b: 蓝色值
    ///   - a: 默认1 透密昂度，0.0~1.0，值越高越不透明，越小越透明
    /// - Warning: 传入的 RGB 值在 0~255 之间哈
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: a)
    }
}


// MARK: UIFont 扩展

/// 字体专用协议
/// - Warning: 此协仅支持对象类型
protocol FontStyle: AnyObject {
    /// 是否不使用 protocol EnolaGayAdapter 中的 defaultFontName 返回的字体名，默认 false，将该值改为 true 即可单独使用在 xib 配置的值，从而忽略 defaultFontName 全局字体名称配置。
    ///
    /// 在 protocol EnolaGayAdapter 中 JudyBaseLabel、JudyBaseButton、JudyBaseTextfield 的默认字体名称使用 EMERANA.enolagayAdapter?.defaultFontName 的配置值。
    var disableFont: Bool { get }
}

/// 常用字体名
public enum FontName: String {
    @available(*, unavailable, message: "重命名", renamed: "苹方_极细体")
    case 苹方_简_极细体 = "PingFangSC-Ultr"
    @available(*, unavailable, message: "重命名", renamed: "苹方_纤细体")
    case 苹方_简_纤细体 = "PingFangSC-T"
    @available(*, unavailable, message: "重命名", renamed: "苹方_细体")
    case 苹方_简_细体 = "PingFangSC-Lgh"
    @available(*, unavailable, message: "重命名", renamed: "苹方_常规体")
    case 苹方_简_常规体 = "PingFangSC-ar"
    @available(*, unavailable, message: "重命名", renamed: "苹方_中黑体")
    case 苹方_简_中黑体 = "PingFangSCium"
    @available(*, unavailable, message: "重命名", renamed: "苹方_中粗体")
    case 苹方_简_中粗体 = "PingFangSCold"

    case 苹方_极细体 = "PingFangSC-Ultralight"
    case 苹方_纤细体 = "PingFangSC-Thin"
    case 苹方_细体 = "PingFangSC-Light"
    case 苹方_常规体 = "PingFangSC-Regular"
    case 苹方_中黑体 = "PingFangSC-Medium"
    case 苹方_中粗体 = "PingFangSC-Semibold"
    
    /// HelveticaNeue 纤细体
    case HlvtcThin = "HelveticaNeue-Thin"
    /// HelveticaNeue 细体
    case HlvtcNeue_Light = "HelveticaNeue-Light"
    /// HelveticaNeue 常规体
    case HlvtcNeue = "HelveticaNeue"
    /// HelveticaNeue 中黑体
    case HlvtcNeue_Medium = "HelveticaNeue-Medium"
    /// HelveticaNeue 粗体
    case HlvtcNeue_Bold = "HelveticaNeue-Bold"
}

public extension UIFont {
    /// 通过 FontName 获得一个 UIFont 对象
    /// - Parameters:
    ///   - name: 参见 FontName，该值默认为 .苹方_中黑体
    ///   - size: 字体的大小，该值最大取 100.
    convenience init(name: FontName = .苹方_中黑体, size: CGFloat) {
        self.init(name: name.rawValue, size: min(size, 100))!
    }
}


// MARK: - EnolaGayAdapter 协议：字体、颜色配置

/// EnolaGay 框架全局适配协议
///
/// 请自行 extension UIApplication: EnolaGayAdapter 实现想要的配置函数。
///
/// - Warning: 该协议仅允许 UIApplication 继承。
public protocol EnolaGayAdapter where Self: UIApplication {
    /// 配置 JudyBaseLabel、JudyBaseButton、JudyBaseTextField 的默认字体样式，但忽略配置字体大小。
    ///
    /// JudyBaseLabel、JudyBaseButton、JudyBaseTextField 无论是不是在 xib 中构建的都会访问该 font 以便获得 fontName.
    ///
    /// 在 xib 中若需要忽略全局配置，使用 xib 设置的字体时，请将 disableFont 设置为 true 即可。
    ///
    /// - Warning:  返回的目标字体仅会影响字体名称（仅使用其 UIFont.fontName），不影响字体大小。
    func defaultFontName() -> UIFont
    
    /// 配置 JudyBaseViewCtrl 及其子类的背景色。
    ///
    /// - Warning: 该函数有默认实现为 systemBackground.
    func viewBackgroundColor() -> UIColor
    
    /// 配置 JudyBaseCollectionViewCtrl、JudyBaseTableViewCtrl 容器 scrollView 的背景色。
    ///
    /// - Warning: 该函数有默认实现，为 systemBackground.
    func scrollViewBackGroundColor() -> UIColor
    
    /// 配置 JudyBaseNavigationCtrl 中的 标题颜色及 tintColor（标题两侧 items）。
    ///
    /// - Warning: 该函数有默认实现，为 systemBlue.
    func navigationBarItemsColor() -> UIColor
}

public extension EnolaGayAdapter {
    
    func defaultFontName() -> UIFont { UIFont(name: .苹方_中黑体, size: 12) }
    
    func viewBackgroundColor() -> UIColor { .systemBackground }

    func scrollViewBackGroundColor() -> UIColor { .systemBackground }

    func navigationBarItemsColor() -> UIColor { .systemBlue }
}

// MARK: - Calendar 扩展
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
            Judy.logWarning("获取星期失败，默认返回1")
            return 1
        }
        return weekday
    }
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

public extension EnolaGayWrapper where Base == Date {
    /// 转换成北京时区的 Date 值
    func dateFromGMT() -> Date {
        // let today = Date()// 获取格林威治时间（GMT）/ 标准时间
        // print("today = \(today)")// 打印出的时间是GTM时间，比北京时间早了8个小时
        // 转成北京时区 date: 2020-09-19 00:05:41 +0000 日期正常
        // seconds:1600473941.265026 时间戳多了8小时
        //date = Date.dateFromGMT(date)
        //print("转成北京时区 date: \(date)")
        //print("seconds:\(date.timeIntervalSince1970)")
        /// 获取当前时区和 GMT 的时间间隔，当前时区和格林威治时区的时间差 8小时 = 28800秒
        let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: base))
        return base.addingTimeInterval(secondFromGMT)
    }
    
    /// 获取目标格式的 String 值
    func stringFormat(dateFormat: String = "yyyy-MM-dd") -> String {
        let timeZone = TimeZone(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: base)
        return date
        // return date.components(separatedBy: "-").first!
    }
    
    /// 当 Date 转换成北京时区的目标格式 string 值
    /// - Parameter format: 目标格式，默认为 "yyyy-MM-dd".
    /// - Returns: format 对应的目标值
    func stringGMT(format: String = "yyyy-MM-dd") -> String {
        return dateFromGMT().judy.stringFormat(dateFormat: format)
    }
}


// MARK: - UIApplication 扩展
public extension EnolaGayWrapper where Base: UIApplication {
    /// 获取状态栏 View.
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            if let statusBar = Judy.keyWindow?.viewWithTag(EMERANA.Key.statusBarViewTag) {
                return statusBar
            } else {
                let height = Judy.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = EMERANA.Key.statusBarViewTag
                // 值越高，离观察者越近
                statusBarView.layer.zPosition = 999999
                
                Judy.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if base.responds(to: Selector(("statusBar"))) {
                return base.value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}


// MARK: - UIImage 扩展

public extension EnolaGayWrapper where Base: UIImage {
    /// 重设图片大小
    /// - Parameter reSize: 目标 size.
    /// - Returns: 目标 image.
    func reSizeImage(reSize: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        base.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return reSizeImage
    }

    /// 等比缩放
    /// - Parameter scaleSize: 缩放倍数
    /// - Returns: 目标 image.
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: base.size.width * scaleSize, height: base.size.height * scaleSize)

        return reSizeImage(reSize: reSize)
    }
    
    /// 压缩图像的体积
    ///
    /// 此函数将返回 UIImage 对象通过此函数得到一个小于原始体积的 Data，通常用于图片上传时限制体积
    /// 大小的计算（图像不得超过128K时）如：
    /// if image.pngData()!.count/1024 >= 128 { resetImgSize(maxImageLenght:131072, maxSizeKB: 128) }
    /// - Parameters:
    ///   - maxImageLenght: 最大长度，通常为 128 * 1024,即 131072.
    ///   - maxSizeKB: 最大 KB 体积，如 128.
    /// - Returns: 目标 Data.
    func resetImgSize(maxImageLenght: CGFloat, maxSizeKB: CGFloat) -> Data {
        
        var maxSize = maxSizeKB
        
        var maxImageSize = maxImageLenght
        
        if (maxSize <= 0.0) { maxSize = 1024.0 }
        
        if (maxImageSize <= 0.0) { maxImageSize = 1024.0 }
        
        //先调整分辨率
        var newSize = CGSize.init(width: base.size.width, height: base.size.height)
        let tempHeight = newSize.height / maxImageSize;
        let tempWidth = newSize.width / maxImageSize;
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            newSize = CGSize.init(width: base.size.width / tempWidth, height: base.size.height / tempWidth)
        } else if (tempHeight > 1.0 && tempWidth < tempHeight){
            newSize = CGSize.init(width: base.size.width / tempHeight, height: base.size.height / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        base.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imageData = newImage!.jpegData(compressionQuality: 1.0)
        var sizeOriginKB : CGFloat = CGFloat((imageData?.count)!) / 1024.0;
        
        // 调整大小
        var resizeRate = 0.9;
        while (sizeOriginKB > maxSize && resizeRate > 0.1) {
            
            imageData = newImage!.jpegData(compressionQuality: CGFloat(resizeRate));
            
            sizeOriginKB = CGFloat((imageData?.count)!) / 1024.0;
            
            resizeRate -= 0.1;
        }
        
        return imageData!
    }

    /// 生成圆形图片
    func imageCircle() -> UIImage {
        // 取最短边长
        let shotest = min(base.size.width, base.size.height)
        // 输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        // 开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        // 添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        // 绘制图片
        base.draw(in: CGRect(x: (shotest-base.size.width)/2,
                        y: (shotest-base.size.height)/2,
                        width: base.size.width,
                        height: base.size.height))
        // 获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }

}

public extension UIImage {
    
    /// 通过颜色生成一张图片
    /// - Parameter color: 该颜色用于直接生成一张图像
    convenience init(color: UIColor) {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard image?.cgImage != nil else {
            self.init()
            Judy.logWarning("通过颜色生成图像时发生错误！")
            return
        }
        self.init(cgImage: image!.cgImage!)
    }
    
    /// 通过渐变颜色生成一张图片，渐变色方向为从左往右
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认 red.
    ///   - endColor: 渐变结束颜色，默认 blue.
    ///   - frame: 生成的图片 frame.
    convenience init(gradientColors startColor: UIColor = .red, endColor: UIColor = .blue, frame: CGRect) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        // gradient colors.
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor] // 渐变的颜色信息
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        UIGraphicsBeginImageContext(frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard outputImage?.cgImage != nil else {
            self.init()
            Judy.logWarning("通过渐变颜色生成图像时发生错误！")
            return
        }
        self.init(cgImage: outputImage!.cgImage!)
    }
}


// MARK: - UIImageView IBDesignable 扩展

public extension UIImageView {
    
    /// 标识该 imageView 是否需要设置为正圆，需要的话请确保其为正方形，否则不生效
    /// - Warning: 若在 Cell 中不能正常显示正圆，请覆盖 Cell 中 layoutIfNeeded() 设置正圆，或在父 View 中设置
    @IBInspectable private(set) var isRound: Bool {
        set {
            if newValue {
                guard frame.size.width == frame.size.height else {
                    Judy.logWarning("该 UIImageView 非正方形，无法设置为正圆！")
                    return
                }
                layer.masksToBounds = true
                contentMode = .scaleAspectFill  // 设为等比拉伸
                layer.cornerRadius = frame.size.height / 2
            }
        }
        get {
            guard layer.cornerRadius != 0,
                  frame.size.width == frame.size.height,
                  layer.cornerRadius == frame.size.height/2
            else { return false }
            return true
        }
    }
    
    /// 给图片设置正圆，请确保 UIImageView 为正方形...此属性相对 roundImage() 函数更费性能
    /// # * 此函数相对 isRound 属性更节约性能，但只能在 viewDidLayoutSubviews() 中使用
    @available(*, deprecated, message: "此函数尚未确定其正确性，不建议使用！")
    final func roundImage() {
        guard bounds.size.height == bounds.size.width else {
            Judy.logWarning("图片非正方形，无法设置正圆！")
            return
        }
        //开始图形上下文
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        //获取图形上下文
        let ctx = UIGraphicsGetCurrentContext()
        //根据一个rect创建一个椭圆
        ctx!.addEllipse(in: bounds)
        //裁剪
        ctx!.clip()
        //将原照片画到图形上下文
        image?.draw(in: bounds)
        //从上下文上获取剪裁后的照片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        guard newImage != nil else {
            Judy.log("上下文图片创建失败!")
            return
        }
        image? = newImage!
        layer.masksToBounds = true
    }
    
}


// MARK: - 解决 UIScrollView 不响应 touches 事件

public extension UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
}


// MARK: - UILabel 扩展 NSMutableAttributedString 函数

public extension EnolaGayWrapper where Base: UILabel {
    
    /// 为当前 Label 显示的文本中设置部分文字高亮
    /// - Parameters:
    ///   - textColor: 默认文本颜色
    ///   - highlightedText: label 中需要要高亮的文本
    ///   - highlightedColor: 高亮部分文本颜色，默认 nil，即使用原有颜色
    ///   - highlightedFont: 高亮部分文本字体，默认为 nil，即使用原有字体
    /// - Warning: 在调用此函数前 label.text 不能为 nil
    func setHighlighted(text highlightedText: String, color highlightedColor: UIColor? = nil, font highlightedFont: UIFont? = nil) {
        // attributedText 即 label.text，所以直接判断 attributedText 不为 nil 即可
        guard base.text != nil, base.attributedText != nil else { return }
        //  attributedText: 为该属性分配新值也会将 text 属性的值替换为相同的字符串数据，但不包含任何格式化信息此外，分配一个新值将更新字体、textColor 和其他与样式相关的属性中的值，以便它们反映从带属性字符串的位置 0 开始的样式信息
        
        var attrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色
        attrs[.foregroundColor] = highlightedColor
        // 高亮文本字体
        attrs[.font] = highlightedFont
        // 将 label 的 NSAttributedString 转换成 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(attributedString: base.attributedText!)
        //  let attributedString = NSMutableAttributedString(text: text!, textColor: textColor, textFont: font, highlightText: highlightedText, highlightTextColor: highlightedColor, highlightTextFont: highlightedFont)
        // 添加到指定范围
        let highlightedRange = attributedString.mutableString.range(of: highlightedText)
        attributedString.addAttributes(attrs, range: highlightedRange)
        
        // 重新给 label 的 attributedText 赋值
        base.attributedText = attributedString
    }
}

public extension UILabel {
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.setHighlighted")
    func judy_setHighlighted(text highlightedText: String, color highlightedColor: UIColor? = nil, font highlightedFont: UIFont? = nil) {
        // attributedText 即 label.text，所以直接判断 attributedText 不为 nil 即可
        guard text != nil, attributedText != nil else { return }
        //  attributedText: 为该属性分配新值也会将 text 属性的值替换为相同的字符串数据，但不包含任何格式化信息此外，分配一个新值将更新字体、textColor 和其他与样式相关的属性中的值，以便它们反映从带属性字符串的位置 0 开始的样式信息
        
        var attrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色
        attrs[.foregroundColor] = highlightedColor
        // 高亮文本字体
        attrs[.font] = highlightedFont
        // 将 label 的 NSAttributedString 转换成 NSMutableAttributedString
         let attributedString = NSMutableAttributedString(attributedString: attributedText!)
        //  let attributedString = NSMutableAttributedString(text: text!, textColor: textColor, textFont: font, highlightText: highlightedText, highlightTextColor: highlightedColor, highlightTextFont: highlightedFont)
        // 添加到指定范围
        let highlightedRange = attributedString.mutableString.range(of: highlightedText)
        attributedString.addAttributes(attrs, range: highlightedRange)
        
        // 重新给 label 的 attributedText 赋值
        attributedText = attributedString
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


// MARK: - UIView frame 相关扩展

public extension EnolaGayWrapper where Base: UIView {
    
    /// view 的 frame.origin.x.
    var x: CGFloat {
        set { base.frame.origin.x = newValue }
        get { base.frame.origin.x }
    }

    /// view 的 frame.origin.y.
    var y: CGFloat {
        set { base.frame.origin.y = newValue }
        get { base.frame.origin.y }
    }
    
    /// 设置 view 的边框样式
    /// - Parameters:
    ///   - border: 边框大小，默认0.
    ///   - color: 边框颜色，默认 .darkGray.
    func viewBorder(border: CGFloat = 0, color: UIColor? = .darkGray) {
        base.borderWidth = border
        base.borderColor = color
    }
    
    /// 给当前操作的 View 设置正圆，该函数会验证 View 是否为正方形，若不是正方形则圆角不生效
    /// - Warning: 请在 viewDidLayout 函数或涉及到布局的函数中调用，否则可能出现问题
    /// - Parameters:
    ///   - border: 边框大小，默认 0.
    ///   - color: 边框颜色，默认深灰色
    /// - Returns: 是否成功设置正圆
    @discardableResult
    func viewRound(border: CGFloat = 0, color: UIColor? = .darkGray) -> Bool {
        viewBorder(border: border, color: color)
        
        guard base.frame.size.width == base.frame.size.height else { return false }
        base.cornerRadius = base.frame.size.height / 2
        
        return true
    }
    
    /// 给当前操作的 View 设置圆角
    ///
    /// - Parameters:
    ///   - radiu: 圆角大小，默认 10.
    ///   - border: 边框大小，默认 0.
    ///   - color: 边框颜色，默认深灰色
    func viewRadiu(radiu: CGFloat = 10, border: CGFloat = 0, color: UIColor? = .darkGray) {
        viewBorder(border: border, color: color)
        base.cornerRadius = radiu
    }
    
    /// 为指定的角设置圆角
    ///
    /// - Parameters:
    ///   - rectCorner: 需要设置的圆角，若有多个可以为数组，如：[.topLeft, .topRight ]
    ///   - cornerRadii: 圆角的大小
    func viewRadiu(rectCorner: UIRectCorner, cornerRadii: CGSize) {
        let path = UIBezierPath(roundedRect: base.bounds,
                                byRoundingCorners: rectCorner,
                                cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = base.bounds
        maskLayer.path = path.cgPath
        base.layer.mask = maskLayer
    }

    /// 给当前操作的 View 设置阴影效果
    /// * 注意：该函数会将 layer.masksToBounds = false.
    /// - Parameters:
    ///   - offset: 阴影偏移量，默认（0,0）.
    ///   - opacity: 阴影可见度，默认 0.6.
    ///   - color: 阴影颜色，默认黑色
    ///   - radius: 阴影圆角，默认 3.
    func viewShadow(offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.6, color: UIColor = .black, radius: CGFloat = 3) {
        
        base.layer.masksToBounds = false

        // shadowOffset阴影偏移,x向右偏移，y向下偏移，默认 0.
        base.layer.shadowOffset = offset
        base.layer.shadowOpacity = opacity
        base.layer.shadowColor = color.cgColor
        base.layer.shadowRadius = radius
    }
    
    /// 给当前操作的 View 设置边框
    /// - Parameter borderWidth: 边框大小，默认 1.
    /// - Parameter borderColor: 边框颜色，默认红色
    @available(*, unavailable, message: "此函数尚未完善，待修复")
    func viewBorder(borderWidth: CGFloat = 1, borderColor: UIColor = .red){
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 30, width: base.frame.size.width, height: 10)
        borderLayer.backgroundColor = borderColor.cgColor
        // layer.addSublayer(borderLayer)
        base.layer.insertSublayer(borderLayer, at: 0)
    }
    
    /// 给 View 设置渐变背景色，改背景色的方向为从左往右
    ///
    /// 此方法中会先移除最底层的 CAGradientLayer.
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认 red.
    ///   - endColor: 渐变结束颜色，默认 blue.
    @discardableResult
    func gradientView(startColor: UIColor = .red, endColor: UIColor = .blue) -> CAGradientLayer {
        // 渐变 Layer 层
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = EMERANA.Key.gradientViewName
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1] // 对应 colors 的 alpha 值
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // 渐变色起始点
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5) // 渐变色终止点
        gradientLayer.frame = base.bounds
        // layer.addSublayer(gradient1)
        if base.layer.sublayers?[0].name == EMERANA.Key.gradientViewName {
            // 先移除再插入！
            base.layer.sublayers?[0].removeFromSuperlayer()
        }
        //  if layer.sublayers?[0].classForCoder == CAGradientLayer.classForCoder() {
        //  // 先移除再插入！
        //  layer.sublayers?[0].removeFromSuperlayer()
        //  }
        // 插入到最底层
        base.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    
    /// 根据键盘调整 window origin.
    ///
    /// - Parameter isReset: 是否重置窗口？默认 flase.
    /// - Parameter offset: 偏移距离，默认 88.
    func updateWindowFrame(isReset: Bool = false, offset: CGFloat = 88) {
        //滑动效果
        UIView.animate(withDuration: 0.3) { [self] in
            //恢复屏幕
            if isReset {
                base.window?.frame.origin.y = 0
            } else {
                base.window?.frame.origin.y = -offset
            }
            base.window?.layoutIfNeeded()
        }
    }
    
    /// 执行一次发光效果
    ///
    /// 该函数以 View 为中心执行一个烟花爆炸动效
    /// - Warning: 如有必要可参考此函数创建新的扩展函数
    /// - Parameter finishededAction: 动画完成后执行的事件，默认为 nil.
    func blingBling(finishededAction: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            // 放大倍数
            base.transform = CGAffineTransform(scaleX: 2, y: 2)
            let anim = CABasicAnimation(keyPath: "strokeStart")
            anim.fromValue = 0.5 // 从 View 的边缘处开始执行
            anim.toValue = 1
            anim.beginTime = CACurrentMediaTime()
            anim.repeatCount = 1    // 执行次数
            anim.duration = 0.2
            anim.fillMode = .forwards
            // anim.isRemovedOnCompletion = true
            
            let count = 12 // 发光粒子数量
            let spacing: Double = Double(base.bounds.width) + 5 // 发光粒子与 view 间距
            for i in 0..<count {
                let path = CGMutablePath()
                /*
                 x=x+s·cosθ
                 y=y+s·sinθ
                 */
                path.move(to: CGPoint(x: base.bounds.midX, y: base.bounds.midY))
                path.addLine(to: CGPoint(
                    x: Double(base.bounds.midX)+spacing*cos(2*Double.pi*Double(i)/Double(count)),
                    y: Double(base.bounds.midY)+spacing*sin(2*Double.pi*Double(i)/Double(count))
                ))
                
                let trackLayer = CAShapeLayer()
                trackLayer.strokeColor = UIColor.orange.cgColor
                trackLayer.lineWidth = 1
                trackLayer.path = path
                trackLayer.fillColor = UIColor.clear.cgColor
                trackLayer.strokeStart = 1
                base.layer.addSublayer(trackLayer)
                trackLayer.add(anim, forKey: nil)
            }
            
        }, completion: { finished in
            base.transform = CGAffineTransform.identity
            finishededAction?()
        })
    }
    
    /// 模拟抖音双击视频点赞效果
    /// - Parameters:
    ///   - duration: 动画的执行时长，默认 0.3 秒
    ///   - spring: 弹簧阻尼，默认 0.5，值越小震动效果越明显
    func doubleClickThumbUp(duration: TimeInterval = 0.3, spring: CGFloat = 0.5) {
        var transform = base.transform
        /// 随机偏转角度 control 点，该值限制为 0 和 1.
        let j = CGFloat(arc4random_uniform(2)) 
        /// 随机方向，-1/1 代表了顺时针或逆时针
        let travelDirection = CGFloat(1 - 2*j)
        let angle = CGFloat(Double.pi/4)
        // 顺时针或逆时针旋转
        transform = transform.rotated(by: travelDirection*angle)
        base.transform = transform
        /*
         1. withDuration: TimeInterval  动画执行时间
         2. delay: TimeInterval 动画延迟执行时间
         3. usingSpringWithDamping: CGFloat 弹簧阻力，取值范围为0.0-1.0，数值越小“弹簧”振动效果越明显
         4. initialSpringVelocity: CGFloat  动画初始的速度（pt/s），数值越大初始速度越快但要注意的是，初始速度取值较高而时间较短时，也会出现反弹情况
         5. options: UIViewAnimationOptions 运动动画速度曲线
         6. animations: () -> Void  执行动画的函数，也是本动画的核心
         7. completion: ((Bool) -> Void)?   动画完成时执行的回调，可选性，可以为 nil
         */
        /// 出现动画：变大->变小
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: spring, initialSpringVelocity: 3) {
            // 缩放
            transform = transform.scaledBy(x: 0.8, y: 0.8)
            base.transform = transform
        } completion: { finished in
            // 消失过程动画停留 0.5 秒再消失
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                // 缩放
                transform = transform.scaledBy(x: 8, y: 8)
                base.transform = transform
                base.alpha = 0
            } completion: { finished in
                base.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIView IBDesignable 扩展
public extension UIView {
    /// 边框宽度
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }

    /// 边框颜色
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else { return nil }
        }
    }
    
    /// 圆角程度
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get { return layer.cornerRadius }
    }
}


// MARK: - UIButton 扩展

// MARK: - UITextField 扩展

// MARK: - UITextFieldDelegate 扩展函数

public extension UITextFieldDelegate {
    /// 限制当前输入的字符为整数
    /// - Warning: 此函数仅限在输入阶段的 shouldChangeCharactersIn() 使用
    /// - Parameters:
    ///   - textField: 输入框对象
    ///   - string: 输入的字符，即代理方法中的 string.
    ///   - maxNumber: 允许输入的最大数值，默认为0，不限制
    /// - Returns: 是否符合验证，若输入的值不合符该值将不会出现在输入框中
    func numberRestriction(textField: UITextField, inputString string: String, maxNumber: Int = 0) -> Bool {
        // 回退
        guard string != "" else { return true }
        /// 仅允许输入指定的字符
        let cs = CharacterSet(charactersIn: "0123456789\n").inverted
        /// 过滤输入的字符
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        guard (string as String) == filtered  else { Judy.logWarning("只能输入数值"); return false }
        
        // 最大值校验
        if maxNumber != 0 {
            let textFieldString = (textField.text!) + string
            // 将输入的整数值
            let numberValue = Int(textFieldString) ?? 0
            if numberValue > maxNumber {
                Judy.logWarning("只能输入小于\(maxNumber)的值")
                return false
            }
        }
        return true
    }
}


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

// MARK: - 针对 String 扩展的便携方法，这些方法尚未验证其准确性
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
            Judy.log("时间转换失败")
            return "time error"
        }
    }
    
    /// 清除字符串中的所有空格
    ///
    /// - Returns: 如："str abc", "strabc".
    func clean() -> String { base.replacingOccurrences(of: " ", with: "") }
    
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

}

public extension String {
    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.getVideoTime")
    static func getVideoTime(duration: TimeInterval) -> String { "" }
    
    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.dateFormatter")
    func dateFormatter(formatterIn: String = "yyyy-MM-dd HH:mm:ss", formatterOut: String = "HH:mm:ss") -> String { "" }

    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.clean")
    func clean() -> String { "" }
    
    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.textSize")
    func textSize(maxSize: CGSize = CGSize(width: 320, height: 68), font: UIFont = UIFont(size: 16)) -> CGSize { .zero }
    
    @available(*, unavailable, message: "请使用空间持有者 judy 对象", renamed: "judy.sizeWith")
    func sizeWith(font: UIFont = UIFont(size: 16) , maxSize : CGSize = CGSize(width: 168, height: 0) , lineMargin : CGFloat = 2) -> CGSize { .zero }
    
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
    
    /// 16进制属性转成 10 进制的 Int 值。
    ///
    /// 如 "0x606060" 调用此属性即可获得 559964256（0x606060 的 10 进制）。
    /// - warning: 仅在该字符内容是正确16进制值时调用该属性
    var change_16_StringToIntValue: Int {
        let str = self.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
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


// MARK: - 为 tableView 增加滚动到底部函数
public extension EnolaGayWrapper where Base: UITableView {
    /// 将 tableView 滚动到最底部
    ///
    /// 在此之前的方法可能会引起数组越界问题，此函数针对该问题修复
    /// - Parameter animated: 是否需要动画效果？默认为 true
    /// - warning: 在调用该函数之前请先调用 reloadData()
    func scrollToBottom(animated: Bool = true) {
        if base.numberOfSections > 0 {
            let lastSectionIndex = base.numberOfSections-1
            let lastRowIndex = base.numberOfRows(inSection: lastSectionIndex)-1
            if lastRowIndex > 0 {
                let indexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                base.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}

public extension UITableView {
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.scrollToBottom")
    func scrollToBottom(animated: Bool = true) { }
}


import UIKit

/*
 什么时候用结构体，什么时候用类？
 
 把结构体看做值，如位置（经纬度）坐标（二维坐标，三维坐标）温度……
 把类看做是物体，如人、车、动物……
 
 结构较小，适用于复制操作，相比一个 class 的实例被多次引用，struct 更加安全，无须担心内存泄漏或者多线程冲突问题
 */

/// EMERANA 结构体，项目中所有辅助性功能应该基于 EMERANA 模块化，可以通过 public extension 新增模块
/// - Warning: 该结构体已禁用 init() 函数，请使用 judy 单例对象
public struct EMERANA {
    /// EMERANA 结构体的唯一实例在单例模式下，只有该实例被首次访问时才会创建该对象（触发 init() ）
    public static let judy = EMERANA()
    
    /// EnolaGay 框架全局适配器
    static let enolagayAdapter: EnolaGayAdapter? = UIApplication.shared as? EnolaGayAdapter
    
    /// API 层适配器
    static let apiAdapter: ApiAdapter? = UIApplication.shared as? ApiAdapter
    
    /// 刷新视图适配器
    static let refreshAdapter: RefreshAdapter? = UIApplication.shared as? RefreshAdapter
    
    /// 全局外观配置管理员
    // private var appearanceManager: Appearance?
    
    
    // 私有化构造器；在单例模式下，只有该单例被首次访问时才会创建该对象
    private init() { }
    
    /// 该数据结构为 EMERANA 中可访问性数据的封装
    /// - Warning: 注意
    ///     * 项目中所有固定的可访问性字符都应该封装在此结构体内，在此结构体中定义所有可访问性数据（字符）
    ///     * 希望数据结构的实例被赋值给另一个实例时是拷贝而不是引用，封装的数据及其中存储的值也是拷贝而不是引用
    ///     * 该数据结构不需要使用继承
    public struct Key {
        /// 在分页加载的界面中用于表示 pageIndex 的字段名
        public static let pageIndexParameter = "pageIndex"
        /// 在分页加载的界面中用于表示 pageSize 的字段名
        public static let pageSizeParameter = "pageSize"

        /// 状态栏 View 专用 tag.
        public static let statusBarViewTag = 20210727
        /// 该值用作于 EMERANA UIView 扩展函数 gradientView() 辨别 gradientLayer.name.
        public static let gradientViewName = "EMERANA_GRADIENT_LAYER_NAME"
        /// 在 JudyBaseTableViewCtrl/JudyBaseCollectionViewCtrl 中 dequeueReusableCell 用到的 Cell 标识符
        public static let cell = "Cell"
        
        public static let title = "title"
        public static let subtitle = "subtitle"
        public static let segue = "segue"
        public static let icon = "icon"
        public static let placeholder = "placeholder"
        public static let value = "value"
        public static let input = "input"
        public static let datas = "datas"
    }
    
    /// 定义 String 类型的 enum 样板，这种 enum 可以不用 rawValue.
    public enum Info: String {
        case 新增Api请求代理管理
        case 新增全局Cell代理管理
    }
    
    /// 常用代码
    public struct Code {
        /// 默认错误，代码 250
        public static let `default` = 250
        /// 在 ApiRequestConfig 中发起请求时没有设置 Api
        public static let notSetApi = 2500
    }
}

// MARK: - 正确地处理键盘遮挡输入框

/// 防止键盘遮挡输入框的工具类，让指定 view 跟着键盘移动就像微信的键盘输入效果
///
/// 仅需通过 registerKeyBoardListener() 函数即可实现输入框跟随键盘位置移动从而保证输入框不被遮挡
public final class KeyboardHelper {
    
    /// 此属性用于记录当下键盘的高度，若键盘已被收起则为 0.
    public private(set) var keyboardHeight: CGFloat = 0
    /// 输入框所在的 view,当键盘出现或隐藏，会根据键盘的高度移动该 view.
    private(set) var textFieldWrapperView = UIView()
    /// 是否保留安全区域底部距离，默认 true，textFieldWrapperView 在跟随键盘弹出时会预留该距离是底部的安全区域可见，反之亦然
    private(set) var isKeepSafeAreaInsetsBottom = false
    
    public init() { }
    
    /// 注册监听键盘弹出收起事件，该函数可使 inputView 跟随键盘弹出收起
    ///
    /// - Warning:
    /// 请注意与 IQKeyboardManagerSwift 的冲突导致键盘高度计算不准确，关闭之即可
    /// 当需要实现点击空白区域即收起键盘时需要注意，参考如下代码确定点击的位置：
    /// ```
    /// if sender.location(in: view).y < view.bounds.height - keyboardHelper.keyboardHeight {
    ///    textFeild.resignFirstResponder()
    /// }
    /// ```
    /// - Parameters:
    ///   - inputView: 输入框所在的 view,即需要跟随键盘的出现而移动的 view
    ///   - isKeepSafeAreaInsetsBottom: inputView 在往上移动时是否保留安全区域底部距离，默认 false.若将该值传入 true 请确保输入框的底部边距 ≥ 安全区域高度
    public func registerKeyBoardListener(forView inputView: UIView, isKeepSafeAreaInsetsBottom: Bool = false) {
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.textFieldWrapperView = inputView
        self.isKeepSafeAreaInsetsBottom = isKeepSafeAreaInsetsBottom
    }

    /// 监听事件，键盘弹出或收起时均会触发此函数
    @objc private func keyBoardShowHideAction(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        /// 改变目标 textFieldWrapperView 的执行过程事件，更新其 2D 仿射变换矩阵
        let animations: (() -> Void) = { [weak self] in
            guard let strongSelf = self else { return }
            // 键盘弹出事件
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度
                strongSelf.keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                
                /// 键盘高度即 textFieldWrapperView.y 轴需要移动的距离
                var yDiff = -strongSelf.keyboardHeight
                // 需要保留底部安全区域处理，需要再往上移动安全区域的高度
                if !strongSelf.isKeepSafeAreaInsetsBottom {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                    yDiff += bottomPadding
                }
                strongSelf.textFieldWrapperView.transform = CGAffineTransform(translationX: 0,y: yDiff)
            }
            // 键盘收起事件
            if notification.name == UIResponder.keyboardWillHideNotification {
                strongSelf.textFieldWrapperView.transform = CGAffineTransform.identity
                strongSelf.keyboardHeight = 0
            }
        }
        
        // 键盘弹出过程时长
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘，直接更新 textFieldWrapperView 2D 仿射变换矩阵
            animations()
        }
    }
}


// MARK: - 命名空间

/// 在 EnolaGay 中的兼容包装类型，该包装类型为 EnolaGay 中的方便方法提供了一个扩展点
public struct EnolaGayWrapper<Base> {
    // 可以不用 public
    /// 包装对象在 EnolaGay 中对应的原始对象
    var base: Base
    init(_ base: Base) { self.base = base }
}

/// 表示与 EnolaGay 兼容的对象类型协议
///
/// 目标类型在实现该协议后即可使用`judy`属性在 EnolaGay 的名称空间中获得一个值包装后的对象（不限制 AnyObject）
public protocol EnolaGayCompatible { }

extension EnolaGayCompatible {
    /// 获取在 EnolaGay 中的兼容类型包装对象，即 EnolaGay 空间持有者对象
    public var judy: EnolaGayWrapper<Self> {
        get { return EnolaGayWrapper(self) }
        set { }
    }
}

// MARK: 使指定类型接受命名空间兼容类型协议，指定类型就可以使用 Judy 命名空间

extension UIViewController: EnolaGayCompatible { }

extension Double: EnolaGayCompatible { }

extension UIView: EnolaGayCompatible { }

extension UIImage: EnolaGayCompatible { }

extension UIApplication: EnolaGayCompatible { }

extension Date: EnolaGayCompatible { }

extension Calendar: EnolaGayCompatible { }

extension String: EnolaGayCompatible { }


// MARK: - EnolaGay 中为 UIView 新增 toast 函数

/// 在 EnolaGay 中的 Toast 兼容包装类型，该包装类型为 EnolaGay 中的方便方法提供了一个扩展点
public struct EnolaGayToastWrapper {
    /// 包装对象在 EnolaGay 中对应的原始对象
    var base: UIView
    init(_ base: UIView) { self.base = base }
}

/// EnolaGay 中为 UIView 新增 toast 函数协议
public protocol EnolaGayToastCompatible: UIView { }

extension EnolaGayToastCompatible {
    /// 获取在 EnolaGay 中的兼容类型包装对象，即在 EnolaGay 空间持有者对象，通过该对象调用 toast 相关方法。
    public var toast: EnolaGayToastWrapper {
        get { return EnolaGayToastWrapper(self) }
        set { }
    }
}

extension UIView: EnolaGayToastCompatible { }

// MARK: - Make Toast Methods
public extension EnolaGayToastWrapper {
    /// 创建并显示新的 toast
    /// - Parameters:
    ///   - message: 显示的消息体
    ///   - duration: toast 显示的持续时间
    ///   - position: toast 显示的位置
    ///   - title: 标题
    ///   - image: 在 toast 中添加一张图片
    ///   - style: toast 风格。当为 nil 时，将使用共享样式。
    ///   - completion: 完成闭包，在 toast 视图消失后执行。如果 toast 从 tap 中删除，则 didTap 将为 true.
    func makeToast(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, title: String? = nil, image: UIImage? = nil, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)? = nil) {
        
        base.makeToast(message, duration: duration, position: position,
                       title: title, image: image, style: style, completion: completion)
    }
    
    /// 创建新的 toast 视图并在给定的中心点显示它
    /// - Parameters:
    ///   - message: 显示的消息体
    ///   - duration: toast 显示的持续时间
    ///   - point: toast 的中心点
    ///   - title: 标题
    ///   - image: 在 toast 中添加一张图片
    ///   - style: toast 风格。当为 nil 时，将使用共享样式。
    ///   - completion: 完成闭包，在 toast 视图消失后执行。如果 toast 从 tap 中删除，则 didTap 将为 true.
    func makeToast(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, title: String?, image: UIImage?, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)?) {
        
        base.makeToast(message, duration: duration, point: point,
                       title: title, image: image, style: style, completion: completion)
    }
    
    // MARK: - Hide Toast Methods
   
    /// 隐藏活跃的 toast
    ///
    /// 如果一个视图中有多个活动的 toast，这个方法会隐藏最旧的的 toast(第一个已经出现的 toast)，
    /// 你可以使用 hideAllToasts() 方法从视图中删除所有活动的 toast.
    /// - Warning: 此方法对活跃的 toast 没有影响。使用 hideToastActivity 方法隐藏活跃的 toast.
    func hideToast() {
        base.hideToast()
    }
    
    /// 隐藏一个活跃的 toast
    /// - Warning: 这并不能清除当前在队列中等待的 toast
    /// - Parameter toast: 将被消失的 toast.任何当前显示在屏幕上的 toast 都被认为是活跃的。
    func hideToast(_ toast: UIView) {
        base.hideToast(toast)
    }
    
    /// 隐藏所有 toast
    /// - Parameters:
    ///   - includeActivity: 如果 true，活跃的 toast 也会被隐藏。该值默认为 false.
    ///   - clearQueue: 如果 true，则从队列中删除所有 toast.该值默认为 true.
    func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        base.hideAllToasts(includeActivity: includeActivity, clearQueue: clearQueue)
    }
    
    /// 从队列中删除所有 toast 视图
    /// - Warning: 这对活跃的 toast 没有影响。你可以使用 hideAllToasts(clearQueue:) 隐藏活跃的 toast 并清除队列。
    func clearToastQueue() {
        base.clearToastQueue()
    }
    
}

// MARK: - Show Toast Methods
public extension EnolaGayToastWrapper {
    
    /// 在指定的位置和持续时间将任何视图显示为 toast
    /// - Parameters:
    ///   - toast: 显示成 toast 的 view
    ///   - duration: 持续时长
    ///   - position: toast 要显示的位置
    ///   - completion: toast 完成的闭包，在 toast 消失后，将执行 completion，如果 toast 已经消失 didTap 将为 true.
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, completion: ((_ didTap: Bool) -> Void)? = nil) {
        base.showToast(toast, duration: duration, position: position, completion: completion)
    }
    
    /// 在提供的中心点和持续时间上将任何视图显示为 toast
    /// - Parameters:
    ///   - toast: 显示成 toast 的 view
    ///   - duration: 持续时长
    ///   - point: toast 的中心点
    ///   - completion: toast 完成的闭包，在 toast 消失后，将执行 completion，如果 toast 已经消失 didTap 将为 true.
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
        base.showToast(toast, duration: duration, point: point, completion: completion)
    }
    
}

// MARK: - Activity Methods
public extension EnolaGayToastWrapper {
    /// 在指定位置创建并显示一个新的 toast 活动指示器视图
    /// - Warning: 每个父视图只能显示一个 toast 活动指示器视图。随后对 makeToastActivity(position:) 函数的调用将被忽略，直到 hideToastActivity() 被调用。
    /// - Warning: makeToastActivity(position:) 独立于 showToast 方法。toast 活动视图可以在 toast 视图被显示时显示和取消。makeToastActivity(position:) 对 showToast 方法的排队行为没有影响。
    /// - Parameter position: toast 的位置
    func makeToastActivity(_ position: ToastPosition) {
        base.makeToastActivity(position)
    }
    
    /// 在指定位置创建并显示一个新的 toast 活动指示器视图
    /// - Warning: 每个父视图只能显示一个 toast 活动指示器视图。随后对 makeToastActivity(point:) 函数的调用将被忽略，直到 hideToastActivity() 被调用。
    /// - Warning: makeToastActivity(point:) 独立于 showToast 方法。toast 活动视图可以在 toast 视图被显示时显示和取消。makeToastActivity(point:) 对 showToast 方法的排队行为没有影响。
    /// - Parameter point: toast 的中心
    func makeToastActivity(_ point: CGPoint) {
        base.makeToastActivity(point)
    }
    
    /// 隐藏/使消失活跃的 toast 活动指示器视图
    func hideToastActivity() {
        base.hideToastActivity()
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
