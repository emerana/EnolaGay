//
//  EMERANA.swift
//
//  Created by 艾美拉娜 on 2018/10/5.
//  Copyright © 2018. All rights reserved.
//

import SwiftyJSON

// MARK: typealias

/// 一个不传递任何参数的闭包
public typealias Closure = (() -> Void)
/// 传递一个 JSON 对象的闭包
public typealias ClosureJSON = ((JSON) -> Void)
/// 传递一个 String 对象的闭包
public typealias ClosureString = ((String) -> Void)


// MARK: - 为 ViewCtrl 新增部分协议

// 为 JudyBaseViewCtrl 扩展函数实现。
public extension JudyBaseViewCtrl {
    /// 是否隐藏所有界面 reqApi() 时显示等待的 HUD，此函数已默认实现返回 false，通过 public extension JudyBaseViewCtrl 重写此函数以改变默认值。
    static func isGlobalHideWaitingHUD() -> Bool { false }
}


// MARK: - 刷新视图专用协议，主要用于 tableView、collectionView

/// 刷新控件适配器协议。
public protocol RefreshAdapter where Self: UIApplication {

    /// 配置头部刷新控件（即下拉刷新）。
    func initHeaderRefresh(scrollView: UIScrollView?, callback: @escaping (()->Void))
    /// 配置底部刷新控件（即上拉加载）。
    func initFooterRefresh(scrollView: UIScrollView?, callback: @escaping (()->Void))
    
    /// 结束所有上拉、下拉状态。
    func endRefresh(scrollView: UIScrollView?)
    /// 结束没有更多数据的函数。
    func endRefreshingWithNoMoreData(scrollView: UIScrollView?)
    
    /// 重置没有更多数据。
    func resetNoMoreData(scrollView: UIScrollView?)
    
    /// 询问分页请求中页码和页大小字段名，默认实现为 "pageIndex","pageSize".
    /// - Warning: 第一个元素为页码，第二个元素为页大小。
    func pageParameterStrings() -> (String, String)

}

/// 默认实现。
public extension RefreshAdapter {
    func pageParameterStrings() -> (String, String) { ("pageIndex","pageSize") }
}

/// tableView、collectionView 专用刷新协议。
/// - Warning: 此协议仅对 JudyBaseViewCtrl 及其派生类提供。
public protocol EMERANA_Refresh where Self: JudyBaseViewCtrl {
    
    /// 缺省请求页码，通常第一页码为1，但有的情况可能为 0.
    var defaultPageIndex: Int { get }
    /// 请求页码。初始化、下拉刷新时会重置到默认值 defaultPageIndex.
    var currentPage: Int { get }
    
    /// 每页的数据大小。
    var pageSize: Int { get }

    /// 该属性标识最后操作是否为上拉加载，通常在获取到服务器数据后需要判断该值进行数据的处理。
    var isAddMore: Bool { get }
    
    
    /// 请在此函数中配置头部（下拉）刷新控件。
    func initHeaderRefresh()
    /// 请在此函数中配置底部（上拉）加加载控件。
    func initFooterRefresh()
    
    /// 询问分页请求中的当前页码字段名，默认实现为 "pageIndex"，否则请重写此函数以配置正确的字段名。
    func pageParameterString() -> String
    /// 询问分页请求中的每页大小的字段名，默认实现为 "pageSize"，否则请重写此函数以配置正确的字段名。
    func pageSizeParameterString() -> String
    
    /// 当 currentPage 发生变化的操作。
    func didSetCurrentPage()

    /// 执行下拉刷新之前的事件补充。
    func refreshHeader()
    /// 执行上拉加载之前的事件补充。
    func refreshFooter()

    /// 询问当前分页数据的总页数。
    ///
    /// 通过服务器响应的数据量来判断是否还有更多数据，通常以请求数据大小为条件，只要没有达到目标数据大小即视为没有更多数据，参考代码：
    /// ```
    /// return apiData["data"].arrayValue.count != 10 ? currentPage:currentPage+1
    /// ```
    /// - Warning: 若未覆盖此函数，默认值为 1.
    func setSumPage() -> Int
    
    /// 重置当前页面请求页数及上下拉状态。
    ///
    /// 在此函数中请将 `currentPage`、`isAddMore` 设置为初始值。
    /// - Warning: 此函数一般用于 segmentCtrl 发生切换并需要重新请求 Api 时重置当前刷新状态。
    func resetStatus()
}

/*
 # 注意：协议扩展是针对抽象类的，而协议本身是针对具体对象的。
 */
extension EMERANA_Refresh {
    
    /// 是否隐藏上拉刷新控件？默认 false
    /// - warning: 所有实现 EMERANA_Refresh 协议的对象均能触发此扩展函数
    ///     * 在此函数中补充所需操作，扩展对应的类并重写此函数
    func hideFooterStateLabel() -> Bool { false }
}


/// 此协议仅适用于包含基础集合视图的 tableViewCtrl、collectionViewCtrl。
protocol EMERANA_CollectionBasic where Self: JudyBaseViewCtrl {
    
    /// 主要数据源，需要手动赋值，默认为空数组。
    var dataSource: [JSON] { get set }
    
    /// 重写此方法并在此方法中注册 Cell 或 HeaderFooter。**此方法在 ViewDidLoad() 中被执行**
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
    /// - Warning: 一个 Nib 里面只放一个 Cell，且里面的 Cell 不能自带 identifier，否则必须用自带的 identifier 进行注册。
    func registerReuseComponents()
}

// MARK: - tableViewCell 和 collectionViewCell 专用协议

/// Cell 基础协议。
/// - Warning: 此协议针对 tableViewCell、collectionViewCell 类定制。
public protocol EMERANA_CellBasic {
    
    /// 标题。
    var titleLabel: UILabel? { get set }
    /// 副标题。
    var subTitleLabel: UILabel? { get set }
    /// 主图片。
    var masterImageView: UIImageView? { get set }
    /// Cell 中的数据源。
    ///
    /// 设置该值的时候将触发 jsonDidSetAction()，函数中的默认对应:
    /// * titleLabel -> EMERANA.Key.Cell.title
    /// * subTitleLabel -> EMERANA.Key.Cell.subtitle
    var json: JSON { get set }
    
    /// 设置 json 数据源事件。
    func jsonDidSetAction()
}
/*
 // MARK: 默认实现的注意点
 
 # 注意：协议扩展是针对抽象类的，而协议本身是针对具体对象的。
 # 当声明协议时没有进行限定则须注意一下：
 # 重写协议的默认实现函数调用权重为 子类>实现类>默认实现，若没有在实现类实现函数则直接调用默认实现函数，此时子类的重写无效。
 */
/// 为 EMERANA_CellBasic 协议新增的扩展函数（非默认实现函数）。
public extension EMERANA_CellBasic {
    
    /// 所有实现 EMERANA_CellBasic 协议的对象在初始函数中均会先触发此扩展函数，在此函数中补充所需操作。
    ///
    /// 扩展对应的类并重写此函数即可使该类执行重写后的函数。
    func globalAwakeFromNib() { }
    
    func selectedDidSet(isSelected: Bool) { }
}


// MARK: - 字体样式协议。目前用于 button、label、textField

@available(*, unavailable, message: "该协议已更新", renamed: "FontStyle")
public protocol EMERANA_FontStyle: AnyObject {}
/// 字体专用协议。
/// - Warning: 此协仅支持对象类型。
public protocol FontStyle: AnyObject {
    
    /// 配置 EMERANA 字体大小及样式，默认值为 m.
    ///
    /// 实现协议参考如下：建议在 didSet 中直接设置 font.
    /// ```
    /// var fontStyle: EMERANA.FontStyle = .m {
    ///     didSet{
    ///         font = .judy(fontStyle: fontStyle)
    ///     }
    /// }
    /// ```
    /// - warning: 设置该属性等同直接设置 UIFont
    var fontStyle: UIFont.FontStyle { get set }
}

/*
 
 // MARK: - @available 使用

 @available： 可用来标识计算属性、函数、类、协议、结构体、枚举等类型的生命周期。（依赖于特定的平台版本 或 Swift 版本）
 available 特性经常与参数列表一同出现，该参数列表至少有两个特性参数，参数之间由逗号分隔。
 
 unavailable：表示该声明在指定的平台上是无效的。
 introduced：表示指定平台从哪一版本开始引入该声明。
 deprecated：表示指定平台从哪一版本开始弃用该声明。虽然被弃用，但是依然使用的话也是没有问题的。若省略版本号，则表示目前弃用，同时可直接省略冒号。
 obsoleted：表示指定平台从哪一版本开始废弃该声明。当一个声明被废弃后，它就从平台中移除，不能再被使用。
 message：说明信息。当使用被弃用或者被废弃的声明时，编译器会抛出警告或错误信息。
 renamed：新的声明名称信息。当使用旧声明时，编译器会报错提示修改为新名字。
 
 如果 available 特性除了平台名称参数外，只指定了一个 introduced 参数，那么可以使用以下简写语法代替：
 @available(平台名称 版本号, *)
 
 @available(*, unavailable, message: "此协议已废弃，请更新协议命名", renamed: "EMERANA_Config")
 
 */


// MARK: UIColor 配置扩展

public extension UIColor {
    
    /*
     * static 定义的属性和func 没办法被子类 override.
     * class 定义的属性和func 可以被子类 override.
     */
    
    /// 此颜色为白色。
    static let scrollView: UIColor = .white

    // MARK: 构造函数
    
    /// 通过16进制转换成 UIColor。
    ///
    /// - Parameters:
    ///   - rgbValue: 如:0x36c7b7（其实就是#36c7b7）。
    ///   - alpha: 默认1。 可见度，0.0~1.0，值越高越不透明，越小越透明。
    convenience init(rgbValue: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(Float((rgbValue & 0xff0000) >> 16)) / 255.0,
                  green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0),
                  blue: CGFloat((Float(rgbValue & 0xff) / 255.0)),
                  alpha: alpha)
    }
    
    /// 通过指定 RGB 比值生成 UIColor，不需要2/255，只填入2即可。
    /// - Parameters:
    ///   - r: 红色值。
    ///   - g: 绿色值。
    ///   - b: 蓝色值。
    ///   - a: 默认1。 透密昂度，0.0~1.0，值越高越不透明，越小越透明。
    /// - Warning: 传入的 RGB 值在 0~255 之间哈。
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: a)
    }
}


// MARK: - UIFont 配置

/// UIFont EMERANA 配置协议，此协议已经默认实现
/// - Warning: 使用注意事项
///     * 如需自定义请 public extension UIFont 覆盖 judy() 函数
///     * 此协仅对 UIFont 类型提供
public protocol EMERANA_UIFont { // where Self: UIFont

    /// 配置 FontStyle 的函数。若有需要，请 public extension UIFont 并覆盖此函数，分别返回对应 style 下的 fontName 和 fontSize
    /// # 此函数仅对此构造函数有效
    /// ```
    /// init?(style: UIFont.FontStyle)
    /// ```
    /// - Parameter style: 对应的 FontStyle
    /// - warning:通过 init(style: UIFont.FontStyle) 函数创建的字体大小最大值被限制为 100
    func configFontStyle(_ style: UIFont.FontStyle) -> (UIFont.FontName, CGFloat)
}

// EMERANA_UIFont 协议默认实现，使其变成可选函数。
public extension EMERANA_UIFont where Self: UIFont {
    
    func configFontStyle(_ style: UIFont.FontStyle) -> (UIFont.FontName, CGFloat) {
        // 通过判断原始值为奇数使用加粗字体，N系列自定义
        var fontName: UIFont.FontName = style.rawValue%2 == 0 ? .HelveticaNeue:.HelveticaNeue_Bold
        var fontSize: CGFloat = 28
        switch style {

        case .xxxs, .xxxs_B: // 最小码
            fontSize = 8
        case .xxs, .xxs_B: // 极小码
            fontSize = 9
        case .XS, .XS_B: // 超小码
            fontSize = 10
        case .S, .S_B:   // 小码
            fontSize = 11
        case .M, .M_B:   // 均码
            fontSize = 12
        case .L, .L_B:   // 大码
            fontSize = 13
        case .XL, .XL_B: // 超大码
            fontSize = 14
        case .xxl, .xxl_B:
            fontSize = 16
        case .xxxl, .xxxl_B:
            fontSize = 18
            
        // 其他码号配置
        case .Nx1:
            fontSize = 28
            fontName = .苹方_简_常规体
        case .Nx2:
            fontSize = 38
            fontName = .苹方_简_细体
        case .Nx3:
            fontSize = 48
            fontName = .苹方_简_极细体
        case .Nx4:
            fontSize = 58
            fontName = .苹方_简_中粗体
        case .Nx5:
            fontSize = 68
            fontName = .苹方_简_中黑体
        }
        
        return (fontName, fontSize)
    }
}


// MARK: UIFont 扩展

public extension UIFont {
    
    /// 字体样式。**EMERANA 中默认使用 M 码**
    /// - warning: 使用注意事项
    /// - 原始值范围-8...14，N系列从10开始
    /// - 原始值为奇数表示加粗（N系列除外）
    enum FontStyle: Int {
        
        /// 比 xxs 码还要小一号
        case xxxs = -8, xxxs_B = -7
        /// 比 XS 码还要小一号
        case xxs = -6, xxs_B = -5
        /// 超小码
        case XS = -4, XS_B = -3
        /// 小码
        case S = -2, S_B = -1
        /// 均码，默认值
        case M = 0, M_B = 1
        /// 大码
        case L = 2, L_B = 3
        /// 超大码
        case XL = 4, XL_B = 5
        /// 比 XL 码还要大一号
        case xxl = 6, xxl_B = 7
        /// 比 xxl 码还要大一号
        case xxxl = 8, xxxl_B = 9
        
        /// 其他补充码号，从 10 开始
        case Nx1, Nx2, Nx3, Nx4, Nx5
        
        /// FontStyle 构造器，安全地构建一个 FontStyle 实例
        /// - Parameter rawValue: FontStyle 实例对象，若传入不合法的值将返回 m
        static func new(rawValue: Int) -> FontStyle {
            var raw = 0
            if (-8...14).contains(rawValue) { raw = rawValue }
            return FontStyle(rawValue: raw)!
        }
        
    }
    
    /// 常用字体名
    enum FontName: String {
        case 苹方_简_极细体 = "PingFangSC-Ultralight"
        case 苹方_简_纤细体 = "PingFangSC-Thin"
        case 苹方_简_细体 = "PingFangSC-Light"
        case 苹方_简_常规体 = "PingFangSC-Regular"
        case 苹方_简_中黑体 = "PingFangSC-Medium"
        case 苹方_简_中粗体 = "PingFangSC-Semibold"
        
        /// HelveticaNeue 纤细体
        case HelveticaNeue_Thin = "HelveticaNeue-Thin"
        /// HelveticaNeue 细体
        case HelveticaNeue_Light = "HelveticaNeue-Light"
        /// HelveticaNeue 常规体
        case HelveticaNeue = "HelveticaNeue"
        /// HelveticaNeue 中黑体
        case HelveticaNeue_Medium = "HelveticaNeue-Medium"
        /// HelveticaNeue 粗体
        case HelveticaNeue_Bold = "HelveticaNeue-Bold"
    }

    /// 通过 FontStyle 获得一个 UIFont 对象。
    /// - warning: 若有需要，请 public extension UIFont 并覆盖 configFontStyle()
    /// - Parameter style: 目标 style
    convenience init(style: UIFont.FontStyle) {

        if EMERANA.fontStyleConfigDelegate == nil {
            Judy.logWarning("请 extension UIApplication: EMERANA_UIFont 配置字体协议")
            self.init(name: UIFont.FontName.苹方_简_常规体.rawValue, size: 16)!
        } else {
            let style = EMERANA.fontStyleConfigDelegate!.configFontStyle(style)
            self.init(name: style.0.rawValue, size: min(style.1, 100))!
        }
        
    }
}


// MARK: 字体、颜色管理类

/// EnolaGay 框架全局适配协议，该协议只允许 UIApplication 继承。
public protocol EnolaGayAdapter where Self: UIApplication {
    
    /// 询问管理全局外观的实体，该实例为 Appearance 及其子类。
    // func appearanceForApplication() -> Appearance
    
    /// 询问 JudyBaseViewCtrl 及其子类的背景色，该函数默认实现为 white.
    func viewBackgroundColor() -> UIColor
    /// 询问 JudyBaseCollectionViewCtrl、JudyBaseTableViewCtrl 容器 View 的背景色，该函数默认实现为 white.
    func scrollViewBackGroundColor() -> UIColor
    
    /// 询问 JudyBaseNavigationCtrl 中的 标题颜色及 tintColor（标题两侧 items），该函数默认实现为 systemBlue.
    func navigationBarItemsColor() -> UIColor
}

public extension EnolaGayAdapter {
    func viewBackgroundColor() -> UIColor { .white }

    func scrollViewBackGroundColor() -> UIColor { .white }

    func navigationBarItemsColor() -> UIColor { .systemBlue }
}

/// 外观配置基类。
open class Appearance {
    
}

// MARK: Date 扩展

public extension Date {

    @available(*, unavailable, message: "请直接使用构造函数", renamed: "init(string:)")
    static func stringConvertDate(string: String, dateFormat: String="yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: string)
    }
    
    /// 通过一个 string 构建一个北京时区的 date 对象。
    /// - Parameters:
    ///   - string: 该 string 应符合一个正常日期格式。
    ///   - format: 目标的日期格式，该值默认为："yyyy-MM-dd"
    init(string: String, format: String = "yyyy-MM-dd") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: string) {
            self = date.judy.dateFromGMT()
        } else {
            self.init()
        }
    }
}

public extension EnolaGayWrapper where Base == Date {
    /// 转换成北京时区的 Date 值。
    func dateFromGMT() -> Date {
        // let today = Date()// 获取格林威治时间（GMT）/ 标准时间
        // print("today = \(today)")// 打印出的时间是GTM时间，比北京时间早了8个小时
        // 转成北京时区 date: 2020-09-19 00:05:41 +0000 日期正常
        // seconds:1600473941.265026 时间戳多了8小时
        //date = Date.dateFromGMT(date)
        //print("转成北京时区 date: \(date)")
        //print("seconds:\(date.timeIntervalSince1970)")
        /// 获取当前时区和 GMT 的时间间隔，当前时区和格林威治时区的时间差 8小时 = 28800秒。
        let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: base))
        return base.addingTimeInterval(secondFromGMT)
    }
    
    /// 获取目标格式的 String 值。
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
    
    /// 当 Date 转换成北京时区的目标格式 string 值。
    /// - Parameter format: 目标格式，默认为 "yyyy-MM-dd".
    /// - Returns: format 对应的目标值。
    func stringGMT(format: String = "yyyy-MM-dd") -> String {
        return dateFromGMT().judy.stringFormat(dateFormat: format)
    }
}



// MARK: UIApplication 扩展
public extension EnolaGayWrapper where Base: UIApplication {
    /// 获取状态栏 View。
    var statusBarView: UIView? {
        
        if #available(iOS 13.0, *) {
            let tag = 3848245
            
            if let statusBar = Judy.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = Judy.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
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

public extension UIApplication {
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.statusBarView")
    var statusBarView: UIView? { nil }
}


// MARK: - UIImage 扩展

public extension EnolaGayWrapper where Base: UIImage {
    /// 重设图片大小
    /// - Parameter reSize: 目标 size
    /// - Returns: 目标 image
    func reSizeImage(reSize: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        base.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return reSizeImage
    }

    /// 等比缩放。
    /// - Parameter scaleSize: 缩放倍数。
    /// - Returns: 目标 image.
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: base.size.width * scaleSize, height: base.size.height * scaleSize)

        return reSizeImage(reSize: reSize)
    }
    
    /// 压缩图像的体积。
    ///
    /// 此函数将返回 UIImage 对象通过此函数得到一个小于原始体积的 Data，通常用于图片上传时限制体积。
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
        
        //调整大小
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
        //取最短边长
        let shotest = min(base.size.width, base.size.height)
        //输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        //开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        //添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        //绘制图片
        base.draw(in: CGRect(x: (shotest-base.size.width)/2,
                        y: (shotest-base.size.height)/2,
                        width: base.size.width,
                        height: base.size.height))
        //获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }

}

public extension UIImage {
    
    /// 通过颜色生成一张图片。
    /// - Parameter color: 该颜色用于直接生成一张图像。
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
    
    /// 通过渐变颜色生成一张图片，渐变色方向为从左往右。
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
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.reSizeImage")
    func reSizeImage(reSize: CGSize) -> UIImage { UIImage() }
     
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.scaleImage")
    func scaleImage(scaleSize: CGFloat) -> UIImage { UIImage() }
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.resetImgSize")
    func judy_resetImgSize(maxImageLenght: CGFloat, maxSizeKB: CGFloat) -> Data { Data() }

    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.imageCircle")
    func imageCircle() -> UIImage { UIImage() }
    

    @available(*, unavailable, message: "此方法已不推荐使用，建议使用新函数 image(gradientColors …… )")
    static func image(fromLayer layer: CALayer) -> UIImage {return UIImage()}
}


// MARK: - UIImageView IBDesignable 扩展

public extension UIImageView {
    
    /// 标识该 imageView 是否需要设置为正圆，需要的话请确保其为正方形，否则不生效。
    /// - Warning: 若在 Cell 中不能正常显示正圆，请覆盖 Cell 中 layoutIfNeeded() 设置正圆，或在父 View 中设置。
    @IBInspectable private(set) var isRound: Bool {
        set {
            if newValue {
                guard frame.size.width == frame.size.height else {
                    Judy.logWarning("该 UIImageView 非正方形，无法设置为正圆！")
                    return
                }
                layer.masksToBounds = true
                contentMode = .scaleAspectFill  // 设为等比拉伸。
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
    
    /// 为当前 Label 显示的文本中设置部分文字高亮。
    /// - Parameters:
    ///   - textColor: 默认文本颜色。
    ///   - highlightedText: label 中需要要高亮的文本。
    ///   - highlightedColor: 高亮部分文本颜色，默认 nil，即使用原有颜色。
    ///   - highlightedFont: 高亮部分文本字体，默认为 nil，即使用原有字体。
    /// - Warning: 在调用此函数前 label.text 不能为 nil。
    func setHighlighted(text highlightedText: String, color highlightedColor: UIColor? = nil, font highlightedFont: UIFont? = nil) {
        // attributedText 即 label.text，所以直接判断 attributedText 不为 nil 即可。
        guard base.text != nil, base.attributedText != nil else { return }
        //  attributedText: 为该属性分配新值也会将 text 属性的值替换为相同的字符串数据，但不包含任何格式化信息。此外，分配一个新值将更新字体、textColor 和其他与样式相关的属性中的值，以便它们反映从带属性字符串的位置 0 开始的样式信息。
        
        var attrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色。
        attrs[.foregroundColor] = highlightedColor
        // 高亮文本字体。
        attrs[.font] = highlightedFont
        // 将 label 的 NSAttributedString 转换成 NSMutableAttributedString。
        let attributedString = NSMutableAttributedString(attributedString: base.attributedText!)
        //  let attributedString = NSMutableAttributedString(text: text!, textColor: textColor, textFont: font, highlightText: highlightedText, highlightTextColor: highlightedColor, highlightTextFont: highlightedFont)
        // 添加到指定范围。
        let highlightedRange = attributedString.mutableString.range(of: highlightedText)
        attributedString.addAttributes(attrs, range: highlightedRange)
        
        // 重新给 label 的 attributedText 赋值。
        base.attributedText = attributedString
    }
}

public extension UILabel {
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.setHighlighted")
    func judy_setHighlighted(text highlightedText: String, color highlightedColor: UIColor? = nil, font highlightedFont: UIFont? = nil) {
        // attributedText 即 label.text，所以直接判断 attributedText 不为 nil 即可。
        guard text != nil, attributedText != nil else { return }
        //  attributedText: 为该属性分配新值也会将 text 属性的值替换为相同的字符串数据，但不包含任何格式化信息。此外，分配一个新值将更新字体、textColor 和其他与样式相关的属性中的值，以便它们反映从带属性字符串的位置 0 开始的样式信息。
        
        var attrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色。
        attrs[.foregroundColor] = highlightedColor
        // 高亮文本字体。
        attrs[.font] = highlightedFont
        // 将 label 的 NSAttributedString 转换成 NSMutableAttributedString。
         let attributedString = NSMutableAttributedString(attributedString: attributedText!)
        //  let attributedString = NSMutableAttributedString(text: text!, textColor: textColor, textFont: font, highlightText: highlightedText, highlightTextColor: highlightedColor, highlightTextFont: highlightedFont)
        // 添加到指定范围。
        let highlightedRange = attributedString.mutableString.range(of: highlightedText)
        attributedString.addAttributes(attrs, range: highlightedRange)
        
        // 重新给 label 的 attributedText 赋值。
        attributedText = attributedString
    }
    
}


// MARK: - NSAttributedString 扩展函数
public extension NSAttributedString {
    
}


// MARK: - NSMutableAttributedString 扩展函数
public extension NSMutableAttributedString {

    /// 生成一个高配版 NSMutableAttributedString。
    /// - Parameters:
    ///   - text: 要显示的文本信息。
    ///   - textColor: 文本颜色，默认为 nil。
    ///   - textFont: 文本的字体，默认为 nil。
    ///   - highlightText: 高亮的文本，该文本应该是 text 的一部分。
    ///   - highlightTextColor: 高亮文本的颜色，该值默认为 nil，。
    ///   - highlightTextFont: 高亮状态文本的字体，默认为 nil。
    /// - Returns: attributedString。
    /// - Warning: addAttribute() 或 addAttributes() 均需要指定一个 range，如需扩展，可模拟此函数创建新的自定义函数。
    convenience init(text: String, textColor: UIColor? = nil, textFont: UIFont? = nil, highlightText: String? = nil, highlightTextColor: UIColor? = nil, highlightTextFont: UIFont? = nil) {
        // 默认配置。
        var defaultAttrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色。
        defaultAttrs[.foregroundColor] = textColor
        // 高亮文本字体。
        defaultAttrs[.font] = textFont
        
        self.init(string: text, attributes: defaultAttrs)
        
        // 指定范围添加 attributes。
        if highlightText != nil {
            var attrs = [NSAttributedString.Key : Any]()
            // 高亮文本颜色。
            attrs[.foregroundColor] = highlightTextColor
            // 高亮文本字体。
            attrs[.font] = highlightTextFont
            // 添加到指定范围。
            addAttributes(attrs, range: mutableString.range(of: highlightText!))
        }
        
        // 基线对齐方式。
        // NSBaselineOffsetAttributeName:@(([UIFont systemFontOfSize:30].lineHeight - [UIFont systemFontOfSize:15].lineHeight)/2 + (([UIFont systemFontOfSize:30].descender - [UIFont systemFontOfSize:15].descender))),
        //                                  NSParagraphStyleAttributeName
        
        // 指定范围单个添加 addAttribute。
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


// MARK: - UIView frame 相关的扩展

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
    
    /// 设置 view 的边框样式。
    /// - Parameters:
    ///   - border: 边框大小，默认0.
    ///   - color: 边框颜色，默认 .darkGray.
    func viewBorder(border: CGFloat = 0, color: UIColor? = .darkGray) {
        base.borderWidth = border
        base.borderColor = color
    }
    
    /// 给当前操作的 View 设置正圆，该函数会验证 View 是否为正方形，若不是正方形则圆角不生效。
    /// - warning: 请在 viewDidLayout 函数或涉及到布局的函数中调用，否则可能出现问题。
    /// - Parameters:
    ///   - border: 边框大小，默认 0.
    ///   - color: 边框颜色，默认深灰色。
    /// - Returns: 是否成功设置正圆。
    @discardableResult
    func viewRound(border: CGFloat = 0, color: UIColor? = .darkGray) -> Bool {
        viewBorder(border: border, color: color)
        
        guard base.frame.size.width == base.frame.size.height else { return false }
        base.cornerRadius = base.frame.size.height / 2
        
        return true
    }
    
    /// 给当前操作的 View 设置圆角。
    ///
    /// - Parameters:
    ///   - radiu: 圆角大小，默认 10.
    ///   - border: 边框大小，默认 0.
    ///   - color: 边框颜色，默认深灰色。
    func viewRadiu(radiu: CGFloat = 10, border: CGFloat = 0, color: UIColor? = .darkGray) {
        viewBorder(border: border, color: color)
        base.cornerRadius = radiu
    }
    
    /// 为指定的角设置圆角。
    ///
    /// - Parameters:
    ///   - rectCorner: 需要设置的圆角，若有多个可以为数组，如：[.topLeft, .topRight ]
    ///   - cornerRadii: 圆角的大小。
    func viewRadiu(rectCorner: UIRectCorner, cornerRadii: CGSize) {
        let path = UIBezierPath(roundedRect: base.bounds,
                                byRoundingCorners: rectCorner,
                                cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = base.bounds
        maskLayer.path = path.cgPath
        base.layer.mask = maskLayer
    }

    /// 给当前操作的 View 设置阴影效果。
    /// * 注意：该函数会将 layer.masksToBounds = false.
    /// - Parameters:
    ///   - offset: 阴影偏移量，默认（0,0）.
    ///   - opacity: 阴影可见度，默认 0.6.
    ///   - color: 阴影颜色，默认黑色。
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
    /// - Parameter borderWidth: 边框大小，默认1
    /// - Parameter borderColor: 边框颜色，默认红色
    @available(*, unavailable, message: "此函数尚未完善，待修复")
    func viewBorder(borderWidth: CGFloat = 1, borderColor: UIColor = .red){
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 30, width: base.frame.size.width, height: 10)
        borderLayer.backgroundColor = borderColor.cgColor
        // layer.addSublayer(borderLayer)
        base.layer.insertSublayer(borderLayer, at: 0)
        
    }
    
    /// 给 View 设置渐变背景色，改背景色的方向为从左往右。
    ///
    /// 此方法中会先移除最底层的 CAGradientLayer（该 Layer 的 name 为 EMERANAGRADIENTLAYER）
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认 red.
    ///   - endColor: 渐变结束颜色，默认 blue.
    @discardableResult
    func gradientView(startColor: UIColor = .red, endColor: UIColor = .blue) -> CAGradientLayer {
        // 渐变 Layer 层。
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "EMERANAGRADIENTLAYER"
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1] // 对应 colors 的 alpha 值。
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // 渐变色起始点。
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5) // 渐变色终止点。
        gradientLayer.frame = base.bounds
        // layer.addSublayer(gradient1)
        if base.layer.sublayers?[0].name == "EMERANAGRADIENTLAYER" {
            // 先移除再插入！
            base.layer.sublayers?[0].removeFromSuperlayer()
        }
        //  if layer.sublayers?[0].classForCoder == CAGradientLayer.classForCoder() {
        //  // 先移除再插入！
        //  layer.sublayers?[0].removeFromSuperlayer()
        //  }
        // 插入到最底层。
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
    
    /// 执行一次发光效果。
    ///
    /// 该函数以 View 为中心执行一个烟花爆炸动效。
    /// - warning: 如有必要可参考此函数创建新的扩展函数。
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
            //        anim.isRemovedOnCompletion = true
            
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

}

// MARK: - UIView IBDesignable 扩展
public extension UIView {

    /// 边框宽度。
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }

    
    /// 边框颜色.
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else { return nil }
        }
    }
    
    /// 圆角程度。
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get { return layer.cornerRadius }
    }

    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.x")
    var x_emerana: CGFloat {
        set { frame.origin.x = newValue }
        get { return frame.origin.x }
    }
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.y")
    var y_emerana: CGFloat {
        set { frame.origin.y = newValue }
        get { return frame.origin.y }
    }
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.viewBorder")
    func viewBorder(border: CGFloat = 0, color: UIColor = .darkGray) { }
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.viewRound")
    @discardableResult
    func viewRound(border: CGFloat = 0, color: UIColor = .darkGray) -> Bool { false }
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.viewRadiu")
    func viewRadiu(radiu: CGFloat = 10, border: CGFloat = 0, color: UIColor = .darkGray) { }
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.viewRadiu")
    func viewRadiu(rectCorner: UIRectCorner, cornerRadii: CGSize) { }

    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.viewShadow")
    func viewShadow(offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.6, color: UIColor = .black, radius: CGFloat = 3) { }
        
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.gradientView")
    @discardableResult
    func gradientView(startColor: UIColor = .red, endColor: UIColor = .blue) -> CAGradientLayer { CAGradientLayer() }
    
    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.updateWindowFrame")
    func updateWindowFrame(isReset: Bool = false, offset: CGFloat = 88) { }

    @available(*, unavailable, message: "请使用 judy 持有者", renamed: "judy.blingBling")
    func judy_blingBling(finishededAction: (()->Void)? = nil) { }
}


// MARK: - UIButton 扩展


// MARK: - UITextFieldView 扩展


// MARK: - Double 扩展
/// 为空间包装对象 Double 添加扩展函数。
public extension EnolaGayWrapper where Base == Double {
    
    /// 将 double 四舍五入到指定小数位数并输出 String.
    ///
    /// - Parameter f: 要保留的小数位数，默认为 2。
    /// - Returns: 转换后的 String。
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
    
    /// utf8 编码的 URL。适用于当URL地址中包含中文时无法正常加载等情况。
    ///
    /// - Parameter utf8StringURL: 带有中文的链接，比如：http://api.tuoken.pro/api/product/qrDode?address=渠道商ETH地址。
    /// - Returns: 对应的 URL 对象，如：http://api.tuoken.pro/api/product/qrDode?address=%E6%B8%A0%E9%81%93%E5%95%86ECH%E5%9C%B0%E5%9D%80.
    @available(*, unavailable, message: "请使用构造函数", renamed: "init(stringUTF8:)")
    static func utf8URL(utf8StringURL: String) -> URL? {
        let data = utf8StringURL.data(using: String.Encoding.utf8)
        guard data != nil else {
            return nil
        }
        return URL(dataRepresentation: data!, relativeTo: nil)
    }
    
    /// 构造一个经过 utf8 编码的 URL. 若链接中包含了中文，请使用此函数构建 URL 对象。
    ///
    /// 通常情况下使用默认的 URL 构造器无法直接将带中文的链接转换成 URL，会得到一个 nil. 使用此构造函数能够将带有中文的 urlString 转成正常的链接，如："https://www.%E7%8E%8B%E4%BB%81%E6%B4%81.com". 当然即使 stringUTF8 不包含中文也没关系。
    /// - Parameter stringUTF8: 要转换成 URL 的字符串链接，该链接中可能包含中文。如：http://www.王仁洁.com.
    init?(stringUTF8: String) {
        guard let data = stringUTF8.data(using: String.Encoding.utf8) else {
            self.init(string: stringUTF8)
            return
        }
        self.init(dataRepresentation: data, relativeTo: nil)!
    }
}

// MARK: - 针对 String 扩展的便携方法，这些方法尚未验证其准确性

public extension String {
    
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
    
    /// 将字符串转换成时间格式。如将"2016-08-19 16:23:09" 转成 "16:23:09".
    ///
    /// - Parameters:
    ///   - formatterIn: 该字符串的原始时间格式。默认 "yyyy-MM-dd HH:mm:ss".
    ///     - 可选
    ///        - yyyy-MM-dd'T'HH:mm:ssZ
    ///        - yyyy-MM-dd'T'HH:mm:ss.SSSXXX
    ///   - formatterOut: 目标时间格式。默认 "HH:mm:ss"
    /// - Returns: 目标格式的时间 String
    func dateFormatter(formatterIn: String = "yyyy-MM-dd HH:mm:ss", formatterOut: String = "HH:mm:ss") -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatterIn
        dateFormatter.timeZone = .current

        if let dated = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = formatterOut
            return dateFormatter.string(from: dated)
        } else {
            Judy.log("时间转换失败")
            return "time error"
        }

    }

    /// 清除字符串中的所有空格。
    ///
    /// - Returns: 如："str abc", "strabc".
    func clean() -> String { replacingOccurrences(of: " ", with: "") }
    
    /// 计算文本的 size。
    ///
    /// - Parameters:
    ///   - font: 字体，默认按照 M 码字体计算。
    ///   - maxSize: 最大尺寸，默认为 CGSize(width: 320, height: 68)
    /// - Returns: 文本所需宽度。
    func textSize(maxSize: CGSize = CGSize(width: 320, height: 68), font: UIFont = UIFont(style: .M)) -> CGSize {
        // 根据文本内容获取尺寸，计算文字尺寸 UIFont.systemFont(ofSize: 14.0)
        return self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin],
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size
    }

    func sizeWith(font: UIFont = UIFont(style: .M) , maxSize : CGSize = CGSize(width: 168, height: 0) , lineMargin : CGFloat = 2) -> CGSize {
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin
        
        var attributes = [NSAttributedString.Key : Any]()
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let textBouds = self.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        
        return textBouds.size
    }
    
    /// 下标获取字符串。
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)), upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
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

    /// 将 tableView 滚动到最底部。
    ///
    /// 在此之前的方法可能会引起数组越界问题，此函数针对该问题修复。
    /// - Parameter animated: 是否需要动画效果？默认为 true。
    /// - warning: 在调用该函数之前请先调用 reloadData()。
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
 
 结构较小，适用于复制操作，相比一个 class 的实例被多次引用，struct 更加安全，无须担心内存泄漏或者多线程冲突问题。
 */

/// EMERANA 结构体，项目中所有辅助性功能应该基于 EMERANA 模块化，可以通过 public extension 新增模块。
/// - Warning: 该结构体已禁用 init() 函数，请使用 judy 单例对象
public struct EMERANA {
    /// EMERANA 结构体的唯一实例。在单例模式下，只有该实例被首次访问时才会创建该对象（触发 init() ）。
    public static let judy = EMERANA()
    
    /// 字体样式配置代理。
    static let fontStyleConfigDelegate: EMERANA_UIFont? = UIApplication.shared as? EMERANA_UIFont
    
    /// EnolaGay 框架全局适配器。
    static let enolagayAdapter: EnolaGayAdapter? = UIApplication.shared as? EnolaGayAdapter
    
    /// API 层适配器。
    static let apiAdapter: ApiAdapter? = UIApplication.shared as? ApiAdapter
    
    /// 刷新视图适配器。
    static let refreshAdapter: RefreshAdapter? = UIApplication.shared as? RefreshAdapter
    
    /// 全局外观配置管理员。
    // private var appearanceManager: Appearance?
    
    
    // 私有化构造器；在单例模式下，只有该单例被首次访问时才会创建该对象。
    private init() {
        // TODO: 获取 Appearance 实例。
        // appearanceManager = enolagayAdapter?.appearanceForApplication()
    }
    
    /// 该数据结构的主要用来封装少量相关简单数据值。
    /// - Warning: 注意
    ///     * 项目中所有固定的可访问性字符都应该封装在此结构体内，在此结构体中定义所有可访问性数据（字符）
    ///     * 希望数据结构的实例被赋值给另一个实例时是拷贝而不是引用，封装的数据及其中存储的值也是拷贝而不是引用
    ///     * 该数据结构不需要使用继承
    public struct Key { }
    

    public enum Info: String {
        case 新增Api请求代理管理
        case 新增全局Cell代理管理
    }
    
    /// 常用错误代码。
    public struct ErrorCode {
        /// 默认错误，代码 250。
        static let `default` = 250
        /// 在 ApiRequestConfig 中发起请求时没有设置 Api。
        static let notSetApi = 2500
    }
}


public extension EMERANA.Key {
    
    /// Api 层中的 JSON 常用 Key
    @available(*, deprecated, message: "该可访问性元素已弃用", renamed: "JSON")
    struct Api {}

    /// 用于 JSON 中的常用的可访问性 KEY。
    struct JSON {
        /// 一般通过此字段判断 ERROR 是否为空，如果不为空则存在错误信息
        ///
        /// 此 Key 的 Value 应该是一个字典，msg、code 均作为 Key 存在 error 层级下
        public static let error = "EMERANA_KEY_API_ERROR"
        /// 一般用于保存响应的消息
        public static let msg = "EMERANA_KEY_API_MSG"
        /// 一般用于保存服务器的响应代码
        public static let code = "EMERANA_KEY_API_CODE"
    }

    /// 与各种 Cell 相关的常用 Key
    /// - since: 1.0
    struct Cell {
        /// Cell 的重用标识符，能够代表该 Cell 具体类型标识
        public static let cell = "EMERANA_KEY_Cell_identitierCell"

        /// 标识 cell 的高度
        public static let height = "EMERANA_KEY_Cell_heightCell"
        /// 标识 Cell 的高宽比
        public static let proportion = "EMERANA_KEY_Cell_proportionCell"

        /// 在 JudyBaseCell 中 对应 titleLabel
        public static let title = "EMERANA_KEY_Cell_titleCell"
        /// 在 JudyBaseCell 中 对应 subtitle
        public static let subtitle = "EMERANA_KEY_Cell_subtitleCell"
        
        /// 一般用于数据源中的数组标识
        public static let datas = "EMERANA_KEY_Cell_datasCell"

        /// 一般用来标识 segue
        public static let segue = "EMERANA_KEY_Cell_segueIdentifierCell"
        /// 如果有用到本地小图标这选择这个 Key，注意不要和 image 搞混
        public static let icon = "EMERANA_KEY_Cell_iconCell"
        /// 在 JudyBaseCell 中对应 masterImageView 的 URL
        public static let image = "EMERANA_KEY_Cell_imageCell"

        // MARK: cell 中的输入场景
        
        /// 占位符，一般用于输入框场景
        public static let placeholder = "EMERANA_KEY_Cell_placeholderCell"
        /// 一般表示输入框的值
        public static let value = "EMERANA_KEY_Cell_valueCell"
        /// 是否支持输入？一般对应一个 Bool 值
        public static let input = "EMERANA_KEY_Cell_inputEnableCell"
        
        /// 一般用来标识 对应的Api Key
        public static let apiKey = "EMERANA_KEY_Cell_apiKeyCell"

        // MARK: header/footer

        /// 标识 section header
        public static let header = "EMERANA_KEY_Cell_headerViewCell"
        /// 标识 section footer
        public static let footer = "EMERANA_KEY_Cell_footerViewCell"
        /// 标识 section 底部偏移量
        public static let insetBottom = "EMERANA_KEY_Cell_insetBottomCell"
        /// 标识 section 顶部偏移量
        public static let insetTop = "EMERANA_KEY_Cell_insetTopCell"

    }
    
    @available(*, unavailable, message: "已废弃，请重命名", renamed: "Api")
    struct ApiKey {}
    @available(*, unavailable, message: "已废弃，请重命名", renamed: "Cell")
    struct CellKey {}
}


// MARK: - 正确地处理键盘遮挡输入框

/// 防止键盘遮挡输入框的工具类，让指定 view 跟着键盘移动就像微信的键盘输入效果。
///
/// 仅需通过 registerKeyBoardListener() 函数即可实现输入框跟随键盘位置移动从而保证输入框不被遮挡。
public final class KeyboardHelper {
    
    /// 此属性用于记录当下键盘的高度，若键盘已被收起则为 0。
    public private(set) var keyboardHeight: CGFloat = 0
    /// 输入框所在的 view,当键盘出现或隐藏，会根据键盘的高度移动该 view.
    private(set) var textFieldWrapperView = UIView()
    /// 是否保留安全区域底部距离，默认 true，textFieldWrapperView 在跟随键盘弹出时会预留该距离是底部的安全区域可见，反之亦然。
    private(set) var isKeepSafeAreaInsetsBottom = false
    
    public init() { }
    
    /// 注册监听键盘弹出收起事件，该函数可使 inputView 跟随键盘弹出收起。
    ///
    /// - Warning:
    /// 请注意与 IQKeyboardManagerSwift 的冲突导致键盘高度计算不准确，关闭之即可。
    /// 当需要实现点击空白区域即收起键盘时需要注意，参考如下代码确定点击的位置：
    /// ```
    /// if sender.location(in: view).y < view.bounds.height - keyboardHelper.keyboardHeight {
    ///    textFeild.resignFirstResponder()
    /// }
    /// ```
    /// - Parameters:
    ///   - inputView: 输入框所在的 view,即需要跟随键盘的出现而移动的 view。
    ///   - isKeepSafeAreaInsetsBottom: inputView 在往上移动时是否保留安全区域底部距离，默认 false.若将该值传入 true 请确保输入框的底部边距 ≥ 安全区域高度。
    public func registerKeyBoardListener(forView inputView: UIView, isKeepSafeAreaInsetsBottom: Bool = false) {
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.textFieldWrapperView = inputView
        self.isKeepSafeAreaInsetsBottom = isKeepSafeAreaInsetsBottom
    }

    /// 监听事件，键盘弹出或收起时均会触发此函数。
    @objc private func keyBoardShowHideAction(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        /// 改变目标 textFieldWrapperView 的执行过程事件，更新其 2D 仿射变换矩阵。
        let animations: (() -> Void) = { [weak self] in
            guard let strongSelf = self else { return }
            // 键盘弹出事件。
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度。
                strongSelf.keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                
                /// 键盘高度即 textFieldWrapperView.y 轴需要移动的距离。
                var yDiff = -strongSelf.keyboardHeight
                // 需要保留底部安全区域处理，需要再往上移动安全区域的高度。
                if !strongSelf.isKeepSafeAreaInsetsBottom {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                    yDiff += bottomPadding
                }
                strongSelf.textFieldWrapperView.transform = CGAffineTransform(translationX: 0,y: yDiff)
            }
            // 键盘收起事件。
            if notification.name == UIResponder.keyboardWillHideNotification {
                strongSelf.textFieldWrapperView.transform = CGAffineTransform.identity
                strongSelf.keyboardHeight = 0
            }
        }
        
        // 键盘弹出过程时长。
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘，直接更新 textFieldWrapperView 2D 仿射变换矩阵。
            animations()
        }

    }

}



// MARK: - 命名空间

/// 在 EnolaGay 中的兼容包装类型，该包装类型为 EnolaGay 中的方便方法提供了一个扩展点。
public struct EnolaGayWrapper<Base> {
    /// 包装对象在 EnolaGay 中对应的原始对象。
    public var base: Base
    public init(_ base: Base) { self.base = base }
}

/// 表示与 EnolaGay 兼容的对象类型协议。
///
/// 目标类型在实现该协议后即可使用`judy`属性在 EnolaGay 的名称空间中获得一个值包装后的对象。（不限制 AnyObject）
public protocol EnolaGayCompatible { }

extension EnolaGayCompatible {
    /// 获取在 EnolaGay 中的兼容类型包装对象，即 EnolaGay 空间持有者对象。
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


/*
 system_login_no(2100, "请先登录！"),
 system_login_timeout(2101,"登录超时，请重新登录！"),
 system_refuse(3000, "访问过于频繁，休息一下！"),
 system_message_excess(3001, "短信发送已经超出一天限制，请明天再试！"),
 
 */
