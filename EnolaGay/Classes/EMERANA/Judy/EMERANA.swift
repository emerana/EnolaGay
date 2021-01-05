//
//  EMERANA.swift
//
//  Created by 艾美拉娜 on 2018/10/5.
//  Copyright © 2018 杭州拓垦网络科技. All rights reserved.
//

/*
 // MARK: - Objective-C 桥接文件模板
 
 #ifndef Bridging_Header_h
 #define Bridging_Header_h
 
 #import "JudySegmentedCtrl.h"
 #import "ChatViewCtrl.h"
 
 #endif /* Bridging_Header_h */
 */

// MARK: - typealias

/// 一个不传递任何参数的闭包
public typealias Closure = (() -> Void)
/// 传递一个 JSON 对象的闭包
public typealias ClosureJSON = ((JSON) -> Void)
/// 传递一个 String 对象的闭包
public typealias ClosureString = ((String) -> Void)


// MARK: - 为 ViewCtrl 新增部分协议

/// viewCtrl 基础协议
/// * warning: 此协议仅对 JudyBaseViewCtrl 及其派生类提供
/// * since: 1.0 2020年10月22日16:50
public protocol EMERANA_ViewCtrl where Self: JudyBaseViewCtrl {

    /// navigationItem.title，该 viewTitle 优先于 self.title 显示，且将覆盖 self.title 值
    ///
    /// * 如需更改该值请在 viewDidLoad 之后 navigationItem.title = 新 title 即可
    /// * 重写读写属性方式为实现 get、set，且里面最好全调用 super，尤其是 set
    var viewTitle: String? { get }

    /// 当前界面包含的 json 数据，设置该值将触发 jsonDidSet() 函数，初值为 JSON()
    var json: JSON { get set }
    
    /// 当 json 被赋值将执行此函数，重写此函数以配置对应 json 变化
    func jsonDidSet()

}

// MARK: - Api专用协议，仅适用于 JudyBaseViewCtrl 规范 Api 流程。

/// ViewCtrl 专用 Api 协议，此协议中规定了一个viewCtrl中必须的属性及函数
/// * warning: 此协议限制为 JudyBaseViewCtrl 及其派生类使用
/// * since: 1.2
public protocol EMERANA_Api: EMERANA_ViewCtrl {
    
    /// 请求配置对象
    var requestConfig: ApiRequestConfig { get set }

    /// 服务器响应的 JSON 数据
    var apiData: JSON { get }

    /// 当前界面网络请求成功的标识，默认 false。
    /// * 当该值为 true，viewWillAppear() 将不执行 reqApi()，反之发起请求。
    /// * 若需要取消自动请求，请重写 viewWillAppear() 并在 super.viewWillAppear() 之前将该值设为 true，**注意生命周期，每次都会调用**。
    /// * 若需要界面每次出现都发送请求，请在 super.viewWillAppear() 之前或 reqApi() 响应后（如 reqOver()）将该值设为 false。
    /// * 当 requestConfig.api = nil，reqApi()会将该值设为 true
    var isReqSuccess: Bool { get set }
    
    /// 未设置 requestConfig.api 时是否隐藏 HUD，默认 false
    var isHideNotApiHUD: Bool { get }
    
    /// 是否隐藏所有界面 reqApi() 时显示等待的 HUD，此函数已默认实现返回 false，通过 public extension JudyBaseViewCtrl 重写此函数以改变默认值
    static func isGlobalHideWaitingHUD() -> Bool
    
    
    /// 发起网络请求的方法。此方法中将更新 apiData。**请求结果在此方法中分流。**
    ///
    ///* # 此方法中将最先执行 setApi() 函数，重写它并在其中设置 requestConfig 信息
    ///* # 此方法中会更改 isReqSuccess 对应状态
    ///* # 此方法中将依次执行 setApi() -> reqNotApi() / { reqResult() -> reqFailed() / reqSuccess() }
    ///* # 重写以上方法以实现对应操作
    ///
    /// - Parameters:
    ///   - isSetApi: 是否需要调用 setApi()，默认 true，若 isSetApi = false，则本次请求不调用 setApi()
    func reqApi(isSetApi: Bool)
    
    /**
     设置 requestConfig 及其它任何需要在发起请求前处理的事情
     # 在整个 reqApi()请求流程中最先执行的方法
     - 在此方法中配置好 requestConfig 对象
     ```
     domain = "http://www.baidu.com/Api"
     ```
     ## 设置请求api的字段.
     ```
     requestConfig.api = .???
     ```
     ## 设置请求参数体.
     ```
     requestConfig.parameters?["userName"] = "Judy"
     ```
     */
    func setApi()

    /// 当 api 为 nil 时调用 reqApi() ，请求流将终止在此方法中，不会进行网络请求，且 isReqSuccess 将被设为 true。
    ///
    /// **此方法应主要执行在上下拉刷新界面时需要中断 header、footer 刷新状态，更改 isReqSuccess 等操作。**。
    func reqNotApi()
    
    /// 当服务器有响应时，最先执行此方法，无论请求是否成功。**此时 apiData 为服务器返回的元数据**。
    func reqResult()
    
    /// 请求成功的消息处理
    func reqSuccess()
    
    /// 请求失败或服务器响应失败时的消息处理
    func reqFailed()

    /// 在整个请求流程中最后执行的方法。
    /// # 执行到此方法时，setApi() -> reqNotApi() / [ reqResult() -> reqFailed() / reqSuccess() ] 整个流程已经全部执行完毕
    func reqOver()

}
// 默认实现
public extension EMERANA_Api where Self: JudyBaseViewCtrl {
    
    static func isGlobalHideWaitingHUD() -> Bool { return false }
}


// MARK: - 刷新视图专用协议，主要用于 tableView、collectionView
import MJRefresh
/// tableView、collectionView 专用刷新协议
/// * warning: 此协议仅对 JudyBaseViewCtrl 及其派生类提供
/// * since: 1.0
public protocol EMERANA_Refresh where Self: JudyBaseViewCtrl {
    
    /// 初始页数，默认为1，该值决定了 currentPage 的初始值，下拉刷新时 currentPage 会重置为该值。一般建议定义为计算属性
    var initialPage: Int { get }
    
    /// 当前请求的页数。初始化、下拉刷新时会被 initialPage 赋值
    var currentPage: Int { get }
    
    /// 是否上拉加载更多？默认否
    /// # 此变量标识当前是上拉还是下拉，以便在 reqSuccess 处理数据源是重新赋值还是在原有基础上添加。
    var isAddMore: Bool { get }
    
    /// 是否不需要下拉加载，默认 false。
    /// # 当不需要下拉加载时将此属性设为 true 即可，tableView 在 viewdidLoad 时将不会初始化刷新控件
    var isNoHeader: Bool { get }
    
    /// 是否不需要上拉加载，默认 false
    /// # 当不需要上拉加载时将此属性设为 true 即可，tableView 在 viewdidLoad 时将不会初始化刷新控件
    var isNoFooter: Bool { get }
    
    /// 头部刷新控件，可通过该属性设置下拉刷新时的样式
    var mj_header: MJRefreshNormalHeader? { get }
    /// 底部刷新控件，可通过该属性设置上拉加载时的样式
    var mj_footer: MJRefreshBackNormalFooter? { get }

    
    /// 初始化上下拉刷新控件，一般应该在 viewDidLoad() 执行。
    /// # 注意初始化控件时闭包中使用 [weak self]，否则会引发循环引用
    func initRefresh()
    
    /// 当 currentPage 发生变化的事件
    func didSetCurrentPage()

    /// 下拉后的补充事件
    /// * 此方法执行前已经将 reqApi() 流程执行完毕，此方法是对操作下拉的事件补充
    func refreshHeader()
    
    /// 上拉加载补充事件
    /// * 此方法执行前已经将 reqApi() 流程执行完毕，此方法是对操作上拉的事件补充
    func refreshFooter()

    /// 结束所有上拉、下拉状态。
    func endRefresh()

    /// 分页加载数据时重写此方法从服务器确认总页数，默认值为 1
    func setSumPage() -> Int
    
    /// 重置当前页面请求页数及上下拉状态。
    /// # 用于 segmentCtrl 切换并请求 Api 时重置当前界面状态。
    /// * 此方法将会重置 currentPage 和 isAddMore 为最初状态
    func resetCurrentStatusForReqApi()
    
}
/*
 # 注意：协议扩展是针对抽象类的，而协议本身是针对具体对象的。
 */
public extension EMERANA_Refresh {
    
    /// 是否隐藏上拉刷新控件？默认 false
    /// * warning: 所有实现 EMERANA_Refresh 协议的对象均能触发此扩展函数
    ///     * 在此函数中补充所需操作，扩展对应的类并重写此函数
    /// * since: 1.0
    func hideFooterStateLabel() -> Bool {
        return false
    }

}

/// tableViewCtrl、collectionViewCtrl 基础协议
/// * warning: 此协议仅对 JudyBaseViewCtrl 及其派生类提供
/// * since: 1.0
public protocol EMERANA_CollectionBasic where Self: JudyBaseViewCtrl {

    /// 主要数据源，需要手动赋值，默认为空数组。
    var dataSource: [JSON] { get set }
    
    /// 重写此方法并在此方法中注册 Cell 或 HeaderFooter。**此方法在 ViewDidLoad() 中被执行**
    /// ## 注意：一个 Nib 里面只放一个 Cell，且里面的 cell 不能自带 identifier。如果有则必须用自带的 identifier 进行注册
    /// * 注册 Cell 参考代码
    /// ```
    /// let nib = UINib.init(nibName: "<#XibName#>", bundle: nil)
    /// tableView?.register(nib, forCellReuseIdentifier: "<#Cell#>")
    /// let rightHeader = UINib.init(nibName: "<#XibName#>", bundle: Bundle.main)
    /// tableView?.register(leftHeader, forHeaderFooterViewReuseIdentifier: "<#Header#>")
    /// ```
    /// * 创建 Cell 参考代码
    /// ```
    /// let cell = tableView.dequeueReusableCell(withIdentifier: "<#Cell#>", for: indexPath)
    /// ```
    func registerReuseComponents()
}

// MARK: - tableViewCell 和 collectionViewCell 专用协议

/// Cell 基础协议
/// * warning: 此协议针对 tableViewCell、collectionViewCell 类定制
/// * since: 1.0
public protocol EMERANA_CellBasic {
    
    /// 标题
    var titleLabel: UILabel? { get set }
    
    /// 副标题
    var subTitleLabel: UILabel? { get set }
    
    /// 主图片
    var masterImageView: UIImageView? { get set }
    
    /// 该集合中的 label 将会统一设置颜色为 .judy(.text)
    var labelsForColor: [UILabel]? { get set }
    
    /// 本 cell 中的 json 数据源
    /// # didSet 将触发 jsonDidSetAction()，函数中的默认对应:
    /// * titleLabel -> EMERANA.Key.Cell.title
    /// * subTitleLabel -> EMERANA.Key.Cell.subtitle
    /// * masterImageView -> EMERANA.Key.Cell.icon
    var json: JSON { get set }
    
    /// 设置数据源事件
    func jsonDidSetAction()

}
/*
 // MARK: 默认实现的注意点
 # 注意：协议扩展是针对抽象类的，而协议本身是针对具体对象的。
 # 当声明协议时没有进行限定则须注意一下：
 # 重写协议的默认实现函数调用权重为 子类>实现类>默认实现，若没有在实现类实现函数则直接调用默认实现函数，此时子类的重写无效。
 */
public extension EMERANA_CellBasic {
    
    /// 所有实现 EMERANA_CellBasic 协议的对象在初始函数中均会先触发此扩展函数，在此函数中补充所需操作
    /// # 扩展对应的类并重写此函数
    func globalAwakeFromNib() {
        Judy.log("Cell 触发了全局函数，相关信息：\(self)，若有需要请扩展类并重写此函数")
    }
    
    func selectedDidSet(isSelected: Bool) {
        Judy.log("默认实现的 selectedDidSet")
    }

}

// MARK: - 字体样式协议。目前用于 button、label、textField

/// 字体专用协议
/// * warning: 此协仅对 class 类型提供
/// * since: 1.0
public protocol EMERANA_FontStyle: class {
    
    /// 配置 EMERANA 字体大小及样式，默认值为 m
    /// 实现协议参考如下：建议在 didSet 中直接设置 font
    /// ```
    /// var fontStyle: EMERANA.FontStyle = .m {
    ///     didSet{
    ///         font = .judy(fontStyle: fontStyle)
    ///     }
    /// }
    /// ```
    /// # 设置该属性等同直接设置 UIFont
    var fontStyle: UIFont.FontStyle { get set }

    /// 初始字体样式,将通过该值得到一个 EMERANA.FontStyle，默认 0，奇数为粗体，**该值仅对初始化时有效**
    /// * 与 FontStyle 的对应关系：
    /// * -4：xs，-3：xsb，-2：s，-1：sb，0：m，1：mb，2：l，3：lb，4：xl，5：xlb，6：other
    /// * 实现协议参考如下：
    /// ```
    /// @IBInspectable private(set) var initFontStyle: Int = 0
    /// ```
    /// 调用方式
    /// ```
    /// EMERANA.FontStyle.new(rawValue: initFontStyle)
    /// ```
    var initFontStyle: Int { get }
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


// MARK: - UIColor 配置

/// UIColor EMERANA 配置协议，此协议已经默认实现
/// * warning: 使用注意事项
///     * 如需自定义请 extension UIColor 覆盖 judy() 函数
///     * 此协仅对 UIColor 类型提供
/// * since: 1.0
public  protocol EMERANA_UIColor where Self: UIColor {
    /*
     # static 定义的属性和func 没办法被子类 override.
     # class 定义的属性和func 可以被子类 override.
     */
    
    /// 使用 EMERANA 配置获取颜色
    /// * 自定义配置请 public extension UIColor 并覆盖此函数
    /// - Parameter style: 颜色样式，参阅 ColorStyle
    static func judy(_ style: UIColor.ColorStyle) -> UIColor
}

// EMERANA_UIColor 协议默认实现
public extension EMERANA_UIColor where Self: UIColor {
    
    static func judy(_ style: UIColor.ColorStyle) -> UIColor {
        
        switch style {
        
        case .appTint:
            return #colorLiteral(red: 0.9363723993, green: 0.3479409218, blue: 0.03348073736, alpha: 0.9995727539)
        case .navigationBarTint:
            return .blue
        case .navigationBarTitle, .navigationBarItems:
            return .white
        case .text:
            if #available(iOS 13, *) {
                return .label
            } else {
                return .black
            }
        case .darkText:
            return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        case .lightText:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .separate: // systemGray6
            if #available(iOS 13, *) {
                return .separator
            } else {
                return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.09803921569)
            }
        case .view, .scrollView:
            if #available(iOS 13, *) {
                return UIColor { (trainCollection) -> UIColor in
                    return trainCollection.userInterfaceStyle == .dark ? .darkGray:.groupTableViewBackground
                }
            } else {
                return .white
            }
        case .selected:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .colorStyle1:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case .colorStyle2:
            return #colorLiteral(red: 1, green: 0.1764705882, blue: 0.3333333333, alpha: 1)
        case .colorStyle3:
            return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        case .colorStyle4:
            return #colorLiteral(red: 1, green: 0.3094263673, blue: 0.4742257595, alpha: 1)
        case .colorStyle5:
            return #colorLiteral(red: 0.9568627451, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            
        case .gradientStyle1_start:
            return .red
        case .gradientStyle1_end:
            return .green
        case .gradientStyle2_start:
            return .blue
        case .gradientStyle2_end:
            return .brown
            
        default:
            return .red
        }
    }
}

extension UIColor: EMERANA_UIColor {
    
    /// EMERANA 对 App 中所使用的的 UIColor 集中管理
    public enum ColorStyle {
        /// App 主色调、通用前景色
        case appTint

        /// 导航条色彩样式，这里的颜色透明度可以为 nil
        case navigationBarTint
        /// 导航条上 title 颜色
        case navigationBarTitle
        /// 导航条上所有 items 颜色(tintColor)
        case navigationBarItems

        /// 通用文本颜色
        case text
        /// 深色文本颜色
        case darkText
        /// 浅色文本颜色，一般与 text 对称，text 越深则越浅
        case lightText
        
        /// 用于表示分割线的颜色
        case separate
        /// 所有普通 viewCtrl 背景颜色
        case view
        /// 所有 tableView/collectionView/scrollView/pageViewCtrl 背景颜色
        case scrollView
        /// 选中、高亮状态的颜色
        case selected
        /// 其他颜色样式，具体用途请自行 public extension
        case colorStyle1, colorStyle2, colorStyle3, colorStyle4, colorStyle5
        /// 渐变色可选样式
        case gradientStyle1_start, gradientStyle1_end, gradientStyle2_start, gradientStyle2_end
        
        @available(*, deprecated, message: "请使用新命名 colorStyle1……", renamed: "colorStyle1")
        case colorStyleA, colorStyleB, colorStyleC, colorStyleD, colorStyleE
    }
    
    // MARK: 构造函数
    
    /// 通过16进制转换成 UIColor
    ///
    /// - Parameters:
    ///   - rgbValue: 如:0x36c7b7（其实就是#36c7b7）
    ///   - alpha: 默认1。 可见度，0.0~1.0，值越高越不透明，越小越透明。
    /// - Returns: UIColor
    public convenience init(rgbValue: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(Float((rgbValue & 0xff0000) >> 16)) / 255.0,
                               green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0),
                               blue: CGFloat((Float(rgbValue & 0xff) / 255.0)),
                               alpha: alpha)
    }
    
    /// 通过指定 RGB 比值生成 UIColor，不需要2/255，只填入2即可。
    /// # 传入的 RGB 值在 0~255 之间哈
    /// - Parameters:
    ///   - r: 红色值
    ///   - g: 绿色值
    ///   - b: 蓝色值
    ///   - a: 默认1。 透密昂度，0.0~1.0，值越高越不透明，越小越透明。
    /// - Returns: UIColor
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: a)
    }
    
}


// MARK: - UIFont 配置


/// UIFont EMERANA 配置协议，此协议已经默认实现
/// * warning: 使用注意事项
///     * 如需自定义请 public extension UIFont 覆盖 judy() 函数
///     * 此协仅对 UIFont 类型提供
/// * since: 1.0    //    where Self: UIFont
public protocol EMERANA_UIFont {

    /// 配置 FontStyle 的函数。若有需要，请 public extension UIFont 并覆盖此函数，分别返回对应 style 下的 fontName 和 fontSize
    /// # 此函数仅对此构造函数有效
    /// ```
    /// init?(style: UIFont.FontStyle)
    /// ```
    /// - Parameter style: 对应的 FontStyle
    /// * warning:通过 init(style: UIFont.FontStyle) 函数创建的字体大小最大值被限制为 100
    func configFontStyle(_ style: UIFont.FontStyle) -> (UIFont.FontName, CGFloat)
}

// EMERANA_UIFont 协议默认实现
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
    
    @available(*, unavailable, renamed: "UIFont(style:)", message: "此函数已废弃，请使用新的构造函数")
    static func judy(_ style: UIFont.FontStyle) -> UIFont { return .systemFont(ofSize: 16) }
    
}
//  UIFont 实现 EMERANA_UIFont 协议
extension UIFont {
    
    static let fontStyleConfig: EMERANA_UIFont? = UIApplication.shared as? EMERANA_UIFont
    
    /// 字体样式。**EMERANA 中默认使用 M 码**
    /// * warning: 原始值范围-8...14，N系列从10开始
    /// * warning: 原始值为奇数表示加粗（N系列除外）
    public enum FontStyle: Int {

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
            if (-8...14).contains(rawValue) {
                raw = rawValue
            }
            return FontStyle.init(rawValue: raw)!
        }
        
    }
    
    /// 常用字体名
    public enum FontName: String {
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
    /// # 若有需要，请 public extension UIFont 并覆盖 configFontStyle()
    /// - Parameter style: 目标 style
    public convenience init(style: UIFont.FontStyle) {

        if UIFont.fontStyleConfig == nil {
            Judy.log("请 extension UIApplication: EMERANA_UIFont 配置字体协议")
            self.init(name: UIFont.FontName.苹方_简_常规体.rawValue, size: 16)!
        } else {
            let style = UIFont.fontStyleConfig!.configFontStyle(style)
            self.init(name: style.0.rawValue, size: min(style.1, 100))!
        }
        
    }
    
    
}

// MARK: - UIImage 扩展

public extension UIImage {
    
    /// 生成圆形图片
    func imageCircle() -> UIImage {
        //取最短边长
        let shotest = min(size.width, size.height)
        //输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        //开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        //添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        //绘制图片
        draw(in: CGRect(x: (shotest-size.width)/2,
                        y: (shotest-size.height)/2,
                        width: size.width,
                        height: size.height))
        //获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }
    
    /// 通过颜色生成一张图片
    @available(*, unavailable, message: "请使用init构造函数", renamed: "init(color:)")
    static func image(with color: UIColor) -> UIImage { return UIImage() }
    
    /// 通过渐变颜色生成一张图片
    @available(*, unavailable, message: "请使用init构造函数", renamed: "init(gradientColors:endColor:frame:)")
    static func image(gradientColors startColor: UIColor = .red, endColor: UIColor = .blue, frame: CGRect) -> UIImage { return UIImage() }
    
    
    /// 通过颜色生成一张图片
    /// - Parameter color: 该颜色用于直接生成一张图像
    /// * since 1.0 2020年10月24日11:22
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
            Judy.log("通过颜色生成图像时发生错误！")
            return
        }
        self.init(cgImage: image!.cgImage!)
    }
    
    
    /// 通过渐变颜色生成一张图片
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认red
    ///   - endColor: 渐变结束颜色，默认blue
    ///   - frame: 生成的图片 frame
    /// * since 1.0 2020年10月24日11:32
    convenience init(gradientColors startColor: UIColor = .red, endColor: UIColor = .blue, frame: CGRect) {
        
        let gradientLayer : CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        //gradient colors
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        UIGraphicsBeginImageContext(frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard outputImage?.cgImage != nil else {
            self.init()
            Judy.log("通过渐变颜色生成图像时发生错误！")
            return
        }
        self.init(cgImage: outputImage!.cgImage!)

    }

    @available(*, unavailable, message: "此方法已不推荐使用，建议使用新函数 image(gradientColors …… )")
    static func image(fromLayer layer: CALayer) -> UIImage {return UIImage()}

}

public extension UIImage {
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return reSizeImage
    }
     
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: size.width * scaleSize, height: size.height * scaleSize)

        return reSizeImage(reSize: reSize)
    }
    
    /// 压缩图像的体积
    /// * warning: UIImage 对象通过此函数得到一个小于原始体积的 Data，通常用于图片上传限制体积
    /// * since: V1.2   2020年10月30日14:58:38
    /// - Parameters:
    ///   - maxImageLenght: 最大长度，如：0
    ///   - maxSizeKB: 最大 KB 体积，如 2048
    /// - Returns: 目标 Data
    func judy_resetImgSize(maxImageLenght: CGFloat, maxSizeKB: CGFloat) -> Data {
        
        var maxSize = maxSizeKB
        
        var maxImageSize = maxImageLenght
        
        if (maxSize <= 0.0) { maxSize = 1024.0 }
        
        if (maxImageSize <= 0.0) { maxImageSize = 1024.0 }
        
        //先调整分辨率
        var newSize = CGSize.init(width: size.width, height: size.height)
        let tempHeight = newSize.height / maxImageSize;
        let tempWidth = newSize.width / maxImageSize;
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            newSize = CGSize.init(width: size.width / tempWidth, height: size.height / tempWidth)
        } else if (tempHeight > 1.0 && tempWidth < tempHeight){
            newSize = CGSize.init(width: size.width / tempHeight, height: size.height / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
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

}


// MARK: - UIImageView IBDesignable 扩展

@IBDesignable public extension UIImageView {
    
    /// 标识该 imageView 是否需要设置为正圆，需要的话请确保其为正方形，否则不生效
    /// * since: 1.2
    /// * author: 王仁洁
    /// * date: 2020年12月22日09:16:32 强化属性
    /// * warning: 若在 Cell 中不能正常显示正圆，请覆盖 Cell 中 layoutIfNeeded() 设置正圆，或在父 View 中设置
    @IBInspectable private(set) var isRound: Bool {
        set {
            if newValue {
                if viewRound() {
                    contentMode = .scaleAspectFill  // 设为等比拉伸
                }
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
            Judy.log("图片非正方形，无法设置正圆！")
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


// MARK: - UILabel 扩展

public extension UILabel {
    
    // MARK: NSMutableAttributedString 函数
    
    /// 设置部分文字高亮
    /// * warning: label 的 attributedText 不能直接添加属性，需先转换成 NSMutableAttributedString。
    /// * since: V1.1   2020年10月30日13:36
    /// - Parameters:
    ///   - highlightedText: label 中需要要高亮的文本
    ///   - highlightedColor: 高亮颜色，默认红色
    func judy_setHighlighted(text highlightedText: String, color highlightedColor: UIColor = .red) {
        guard attributedText != nil else { return }
        
        // 将 label 的 NSAttributedString 转换成 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(attributedString: attributedText!)
        
        //        attributedString.addAttributes(
        //            [.foregroundColor: highlightedColor],
        //            // 指定范围
        //            range: attributedString.mutableString.range(of: highlightedText)
        //        )
        
        // 指定范围的文字高亮
        attributedString.addAttribute(.foregroundColor, value: highlightedColor, range: attributedString.mutableString.range(of: highlightedText))
        
        // 重新赋值
        attributedText  = attributedString
    }
    
    
    /// 给 label 设置一个全新的 attributedText
    /// * warning: 此函数将覆盖 label 的 text/attributedText。
    /// * since: V1.0   2020年10月30日13:53
    /// - Parameters:
    ///   - text: 显示的完整文本
    ///   - textColor: 显示的文本颜色，默认蓝色
    ///   - highlightText: 在 text 中要高亮的文本，默认为 nil
    ///   - highlightTextColor: 要高亮的文本颜色，默认为红色
    func judy_attributedText(text: String, textColor: UIColor = .blue, highlightText: String? = nil, highlightTextColor: UIColor = .red) {
        
        // 创建 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: text,
                                                         attributes: [ .foregroundColor: textColor ]
        )
        
        if highlightText != nil {
            
            // 指定范围添加 attribute
            attributedString.addAttribute(.foregroundColor, value: highlightTextColor, range: attributedString.mutableString.range(of: highlightText!))
        }
        
        // 单个添加 addAttribute
        // let attributed = EMERANA.judy.judy_highlightAttributedString(text: "我已阅读并同意《直播主播入驻协议》", textColor: .judy(.colorStyle4), highlightText: "《直播主播入驻协议》", highlightTextColor: .judy(.colorStyle2))
        //        attributed.addAttribute(.link, value: "https://www.baidu.com", range: attributed.mutableString.range(of: "《直播主播入驻协议》"))
        //        attributed.addAttribute(.underlineColor, value: UIColor.clear, range: attributed.mutableString.range(of: "《直播主播入驻协议》"))
        //        attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: attributed.mutableString.range(of: "《直播主播入驻协议》"))
        //        attributed.mutableString.range(of: "《直播主播入驻协议》")
        // label.attributedText = attributed

        // 给属性赋值
        attributedText  = attributedString

    }
    
    
}


// MARK: - NSAttributedString 扩展函数
public extension NSMutableAttributedString {
    
    /// 生成一个 NSMutableAttributedString
    /// - warning: addAttribute() 或 addAttributes() 均需要指定一个 range，如需扩展，可模拟此函数创建新的自定义函数。
    /// - since: 1.0 2020年10月30日11:29
    /// - Parameters:
    ///   - text: 要显示的文本信息
    ///   - textColor: 文本颜色，若不指定该值，该颜色默认为白色
    ///   - highlightText: 高亮的文本，该文本应该是 text 的一部分
    ///   - highlightTextColor: 高亮文本的颜色，若不指定，该值默认为 nil，即使用函数内部的随机颜色
    /// - Returns: attributedString
    convenience init(text: String, textColor: UIColor = .blue, highlightText: String? = nil, highlightTextColor: UIColor? = nil) {
        
        self.init(string: text,
                  attributes: [.foregroundColor: textColor ]
        )

        if highlightText != nil {
            var highlightColor = #colorLiteral(red: 1, green: 0.368627451, blue: 0.6509803922, alpha: 1)
            if highlightTextColor == nil {
                let colors = [ #colorLiteral(red: 0.1294117647, green: 0.9098039216, blue: 1, alpha: 1), #colorLiteral(red: 0.4549019608, green: 0.6941176471, blue: 0.7843137255, alpha: 1), #colorLiteral(red: 0.1294117647, green: 0.9098039216, blue: 0.2941176471, alpha: 1), #colorLiteral(red: 0.262745098, green: 1, blue: 0.8352941176, alpha: 1), #colorLiteral(red: 1, green: 0.368627451, blue: 0.6509803922, alpha: 1), #colorLiteral(red: 0.2352941176, green: 0.8235294118, blue: 0.4784313725, alpha: 1), #colorLiteral(red: 1, green: 0.3098039216, blue: 0.4784313725, alpha: 1),]
                //返回 0 到 N-1 范围内的一个随机数
                highlightColor = colors[Int( arc4random_uniform(UInt32(colors.count-1))) ]
            } else {
                highlightColor = highlightTextColor!
            }
            
            // 指定范围添加 attribute
            addAttribute(.foregroundColor, value: highlightColor, range: mutableString.range(of: highlightText!))
        }

    }

}



// MARK: - UIView IBDesignable 扩展

@IBDesignable public extension UIView {

    // MARK: - UIView frame 相关的扩展
    
    /// 边框宽度
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    /// borderColor
    /// - 这里防止与其他库的属性产生冲突故以此命名
    @IBInspectable var borderColor_EMERANA: UIColor? {
        set { layer.borderColor = newValue!.cgColor }
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

    /// 获取当前操作 View 的 frame.origin.x
    var x_emerana: CGFloat {
        set { frame.origin.x = newValue }
        get { return frame.origin.x }
    }

    /// /// 获取当前操作 View 的 frame.origin.y
    var y_emerana: CGFloat {
        set { frame.origin.y = newValue }
        get { return frame.origin.y }
    }
    
    
    // MARK: UIView layer 相关的扩展
    
    /// 设置 view 的边框样式
    /// - Parameters:
    ///   - border: 边框大小，默认0
    ///   - color: 边框颜色，默认 .darkGray
    func viewBorder(border: CGFloat = 0, color: UIColor = .darkGray) {
        layer.borderWidth = border
        layer.borderColor = color.cgColor
    }
    
    /// 给当前操作的 View 设置正圆，该函数会验证 View 是否为正方形，若不是正方形则圆角不生效
    /// * since: 1.1
    /// * author: 王仁洁
    /// * date: 2020年12月22日09:18:00 优化宽高验证
    /// * warning: 请在 viewDidLayout 函数或涉及到布局的函数中调用，否则可能出现问题
    /// - Parameters:
    ///   - border: 边框大小，默认0
    ///   - color: 边框颜色，默认深灰色
    /// - Returns: 是否成功设置正圆
    @discardableResult
    func viewRound(border: CGFloat = 0, color: UIColor = .darkGray) -> Bool {
        
        viewBorder(border: border, color: color)
        layer.masksToBounds = true
        
        guard frame.size.width == frame.size.height else { return false }
        layer.cornerRadius = frame.size.height / 2
        
        return true
    }
    
    /// 给当前操作的 View 设置圆角
    ///
    /// - Parameters:
    ///   - radiu: 圆角大小，默认10
    ///   - border: 边框大小，默认0
    ///   - color: 边框颜色，默认深灰色
    func viewRadiu(radiu: CGFloat = 10, border: CGFloat = 0, color: UIColor = .darkGray) {
        viewBorder(border: border, color: color)
        
        layer.cornerRadius = radiu
        layer.masksToBounds = true
    }
    
    /// 给当前操作的 View 设置阴影效果
    /// * 注意：该函数会将 layer.masksToBounds = false
    /// - Parameters:
    ///   - offset: 阴影偏移量，默认（0,0）
    ///   - opacity: 阴影可见度，默认 0.6
    ///   - color: 阴影颜色，默认黑色
    ///   - radius: 阴影圆角，默认 3
    func viewShadow(offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.6, color: UIColor = .black, radius: CGFloat = 3) {
        
        layer.masksToBounds = false

        //shadowOffset阴影偏移,x向右偏移，y向下偏移，默认0,
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
    }
    
    /// 给当前操作的 View 设置边框
    /// - Parameter borderWidth: 边框大小，默认1
    /// - Parameter borderColor: 边框颜色，默认红色
    @available(*, unavailable, message: "此函数尚未完善，待修复")
    func viewBorder(borderWidth: CGFloat = 1, borderColor: UIColor = .red){
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 30, width: frame.size.width, height: 10)
        borderLayer.backgroundColor = borderColor.cgColor
        // layer.addSublayer(borderLayer)
        layer.insertSublayer(borderLayer, at: 0)
        
    }
    
    /// 给 View 设置渐变背景色
    /// * 此方法中会先移除最底层的 CAGradientLayer（该 Layer 的 name 为 EMERANAGRADIENTLAYER）
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认 red
    ///   - endColor: 渐变结束颜色，默认 blue
    @discardableResult
    func gradientView(startColor: UIColor = .red, endColor: UIColor = .blue) -> CAGradientLayer {
        // 渐变 Layer 层
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "EMERANAGRADIENTLAYER"
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        // layer.addSublayer(gradient1)
        if layer.sublayers?[0].name == "EMERANAGRADIENTLAYER" {
            // 先移除再插入！
            layer.sublayers?[0].removeFromSuperlayer()
        }
        //  if layer.sublayers?[0].classForCoder == CAGradientLayer.classForCoder() {
        //  // 先移除再插入！
        //  layer.sublayers?[0].removeFromSuperlayer()
        //  }
        // 插入到最底层
        layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    

    // MARK: UIView 弹出键盘时调整窗体位置扩展
    
    
    /// 根据键盘调整 window origin
    ///
    /// - Parameter isReset: 是否重置窗口？默认 flase
    /// - Parameter offset: 偏移距离，默认 88
    func updateWindowFrame(isReset: Bool = false, offset: CGFloat = 88){
        
        //滑动效果
        UIView.beginAnimations("ResizeKeyboard", context: nil)
        UIView.setAnimationDuration(0.30)
        
        //恢复屏幕
        if isReset {
            window?.frame.origin.y = 0
        } else {
            window?.frame.origin.y = -offset
        }
        UIView.commitAnimations()
        
    }

    
    /// 执行一次发光效果
    ///
    /// 该函数以 View 为中心执行一个烟花爆炸动效
    /// * warning: 如有必要可参考此函数创建新的扩展函数
    /// * since: V1.0 2020年11月12日13:26:57
    /// - Parameter finishededAction: 动画完成后执行的事件，默认为 nil
    func judy_blingBling(finishededAction: (()->Void)? = nil) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            // 放大倍数
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
            let anim = CABasicAnimation(keyPath: "strokeStart")
            anim.fromValue = 0.5 // 从 View 的边缘处开始执行
            anim.toValue = 1
            anim.beginTime = CACurrentMediaTime()
            anim.repeatCount = 1    // 执行次数
            anim.duration = 0.2
            anim.fillMode = .forwards
            //        anim.isRemovedOnCompletion = true
            
            let count = 12 // 发光粒子数量
            let spacing: Double = Double(self.bounds.width) + 5 // 发光粒子与 view 间距
            for i in 0..<count {
                let path = CGMutablePath()
                /*
                 x=x+s·cosθ
                 y=y+s·sinθ
                 */
                path.move(to: CGPoint(x: self.bounds.midX, y: self.bounds.midY))
                path.addLine(to: CGPoint(
                    x: Double(self.bounds.midX)+spacing*cos(2*Double.pi*Double(i)/Double(count)),
                    y: Double(self.bounds.midY)+spacing*sin(2*Double.pi*Double(i)/Double(count))
                ))
                
                let trackLayer = CAShapeLayer()
                trackLayer.strokeColor = UIColor.orange.cgColor
                trackLayer.lineWidth = 1
                trackLayer.path = path
                trackLayer.fillColor = UIColor.clear.cgColor
                trackLayer.strokeStart = 1
                self.layer.addSublayer(trackLayer)
                trackLayer.add(anim, forKey: nil)
            }
            
        }, completion: { finished in
            self.transform = CGAffineTransform.identity
            finishededAction?()
        })
        
    }
    

}

// MARK: - JudySegmentCtrl 扩展

public extension JudySegmentedCtrl {

    /// 快速配置 JudySegmentedCtrl
    ///
    /// 此函数将快速设置 JudySegmentedCtrl 一些基础属性以便直接调用或设置
    /// * warning:该函数应该在 JudySegmentedCtrl 创建的最初时机调用，其他属性的配置均应该在此函数之后调用
    /// * since: V1.1 2020年11月28日09:03:30
    /// - Parameters:
    ///   - indicatorHeight: JudySegmentedCtrl 指示器的高度，若将该值设为0，则为 none (没有指示器)
    final func judy_configSegmentedCtrl(withIndicatorHeight indicatorHeight: CGFloat = 2) {
        
        //  标题数组
        sectionTitles = ["请设置-->", "sectionTitles"]
        //  segmentedCtrl默认选中的下标
        selectedSegmentIndex = 0
        //  指定段宽度的样式，布局样式，fixed为固定平摊，dynamic为根据文字内容来决定大小
        segmentWidthStyle = .fixed //.dynamic
        //  segmentedCtrl.segmentEdgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        //  segmentedCtrl.autoresizingMask =
        //UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        // 选中指示器
        if indicatorHeight == 0 {
            selectionIndicatorLocation = .none
        } else {
            // 指定选择指示器的样式。
            selectionStyle = .textWidthStripe
            //  指定选择指示器的位置。
            selectionIndicatorLocation = .down
            // 不透明度
            selectionIndicatorBoxOpacity = 1
            selectionIndicatorHeight = indicatorHeight
            // 选中指示器线条的宽度通过偏移量设置，右边 = 左边 *2
            selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
        }
        
        judy_configNormolStyle()
        judy_configSelectedStyle()

        // 添加事件
        //        judySegmentedCtrl.addTarget(self, action: #selector(emerana_segmentedCtrlValueChangeAction(segmentedCtrl:)), for: .valueChanged)
    }
    
    
    /// 设置 JudySegmentedCtrl 普通状态下的字体及颜色
    final func judy_configNormolStyle(color newColor: UIColor = .judy(.text), font newFont: UIFont = UIFont(style: .M)) {
        
        //  普通状态下的字体及颜色
        titleTextAttributes = [
            NSAttributedString.Key.font: newFont,
            NSAttributedString.Key.foregroundColor: newColor
        ]
    }
    
    
    /// 设置 JudySegmentedCtrl 选中（高亮）状态下的字体及颜色，包含指示器的颜色
    final func judy_configSelectedStyle(color newColor: UIColor = .judy(.text), font newFont: UIFont = UIFont(style: .M)) {
        // 选中（高亮）状态下的字体及颜色
        selectedTitleTextAttributes = [
            NSAttributedString.Key.font: newFont,
            NSAttributedString.Key.foregroundColor: newColor
        ]
        
        // 选中指示器线条颜色，默认和选中状态下的文本颜色一致
        selectionIndicatorColor = newColor
    }
    
    
}


// MARK: - UIAlertController 扩展

public extension UIAlertController {
    /// 弹出一个普通的提示框，不带任何事件
    /// - Parameters:
    ///   - msg: 提示框的消息体
    ///   - buttonText: 确认按钮的文本
    /// - Returns: 该 UIAlertController 对象
    @available(*, deprecated, message: "请直接使用 ViewCtrl 中的 alert()")
    convenience init(msg: String, buttonText: String = "好") {

        self.init(title: msg, message: nil, preferredStyle: .alert)
        // 创建UIAlertAction空间， style: .destructive 红色字体
        let okAction = UIAlertAction(title: buttonText, style: .destructive, handler: nil)
        self.addAction(okAction)
        

    }
    
}


// MARK: - UIButton 扩展


// MARK: - UITextFieldView 扩展


// MARK: - Double 扩展

public extension Double {
    
    /// 将 double 四舍五入到指定小数位数并输出 String
    ///
    /// - Parameter f: 要保留的小数位数，默认为 2
    /// - Returns: 转换后的 String
    func format(f: Int = 2) -> String {
        //String(format: "%.3f", 0.3030000000000000) ==> 0.303
        return String(format: "%.\(f)f", self)
    }
    
}

// MARK: - URL 扩展

public extension URL {
    
    /// utf8 编码的 URL。适用于当URL地址中包含中文时无法正常加载等情况
    ///
    /// - Parameter utf8StringURL: 带有中文的链接，比如：http://api.tuoken.pro/api/product/qrDode?address=渠道商ETH地址
    /// - Returns: 对应的 URL 对象，如：http://api.tuoken.pro/api/product/qrDode?address=%E6%B8%A0%E9%81%93%E5%95%86ECH%E5%9C%B0%E5%9D%80
    static func utf8URL(utf8StringURL: String) -> URL? {
        let data = utf8StringURL.data(using: String.Encoding.utf8)
        guard data != nil else {
            return nil
        }
        return URL(dataRepresentation: data!, relativeTo: nil)
    }
    
}

// MARK: - 针对 String 扩展的便携方法，这些方法尚未验证其准确性

public extension String {
    
    
    /// 通过一个时间戳获取视频的总时长
    /// - Parameter duration: 视频的 player.duration，如 1942.2760000000001
    /// - Returns: 如：00:32:22
    static func getVideoTime(duration: TimeInterval) -> String {
        let timeStamp: NSInteger = NSInteger(duration)
        
        let h = String(format: "%02d", timeStamp/3600)
        let m = String(format: "%02d", timeStamp/60)
        let s = String(format: "%02d", timeStamp%60)
        
        return "\(h):\(m):\(s)"
        
    }
    
    /// 将字符串转换成时间格式。如将"2016-08-19 16:23:09" 转成 "16:23:09"。
    ///
    /// - Parameters:
    ///   - formatterIn: 该字符串的原始时间格式。默认 "yyyy-MM-dd HH:mm:ss"
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

    /// 清除字符串中的所有空格
    ///
    /// - Returns: "strabc"
    func clean() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    

    /// 计算文本的 size
    ///
    /// - Parameters:
    ///   - font: 字体，默认按照 M 码字体计算
    ///   - maxSize: 最大尺寸，默认为 CGSize(width: 320, height: 68)
    /// - Returns: 文本所需宽度
    func textSize(maxSize: CGSize = CGSize(width: 320, height: 0), font: UIFont = UIFont(style: .M)) -> CGSize {
        // Judy-mark: 根据文本内容获取尺寸，计算文字尺寸 UIFont.systemFont(ofSize: 14.0)
        let size = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil).size
        
        return size
    }

    func sizeWith(font: UIFont = UIFont(style: .M) , maxSize : CGSize = CGSize(width: 168, height: 0) , lineMargin : CGFloat = 2) ->CGSize {
        
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin
        
        var attributes = [NSAttributedString.Key : Any]()
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let textBouds = self.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        return textBouds.size
        
    }

    
    // 下标获取字符串
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
public extension UITableView {
    
    /// 将 tableView 滚动到最底部
    /// 
    /// 在此之前的方法可能会引起数组越界问题，此函数针对该问题修复
    /// - Parameter animated: 是否需要动画效果？默认为 true
    /// * warning: 在调用该函数之前请先调用 reloadData()
    /// - since: V1.0 2020年11月09日22:11:19
    func scrollToBottom(animated: Bool = true) {
        
        if numberOfSections > 0 {
            let lastSectionIndex = numberOfSections-1
            let lastRowIndex = numberOfRows(inSection: lastSectionIndex)-1
            if lastRowIndex > 0 {
                let indexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                scrollToRow(at: indexPath, at: .bottom, animated: animated)
                
            }
        }
    }
    
}


import UIKit


/// EMERANA 结构体，项目中所有辅助性功能应该基于 EMERANA 模块化，可以通过 public extension 新增模块
/// * warning: 该结构体已禁用 init() 函数，请使用 judy 单例对象
/// * since: 1.2
public struct EMERANA {
    
    /// EMERANA 结构体的唯一实例
    public static let judy = EMERANA()

    
    private init() {

//        if UIColor.colorConfig == nil {
//            Judy.log("尚未配置 colorConfig！")
//        }
        
    }
    
    /// 该数据结构的主要用来封装少量相关简单数据值
    /// * warning: 注意
    ///     * 项目中所有固定的可访问性字符都应该封装在此结构体内，在此结构体中定义所有可访问性数据（字符）
    ///     * 希望数据结构的实例被赋值给另一个实例时是拷贝而不是引用，封装的数据及其中存储的值也是拷贝而不是引用
    ///     * 该数据结构不需要使用继承
    /// * since: 1.0
    public struct Key { }
    
}


public extension EMERANA.Key {
    
    /// Api 层中的 JSON 常用 Key
    /// * since: 1.0
    struct Api {
        /// 一般通过此字段判断 ERROR 是否为空，如果不为空则存在错误信息
        /// * 此 Key 的 Value 应该是一个字典，EMERANA.Key.Api.msg/EMERANA.Key.Api.code 均作为 Key 存在 EMERANA.Key.Api.error 层级下
        public static let error = "API_ERROR"
        /// 一般用于保存响应的消息
        public static let msg = "API_MSG"
        /// 一般用于保存服务器的响应代码
        public static let code = "API_CODE"
    }

    /// 与各种 Cell 相关的常用 Key
    /// * since: 1.0
    struct Cell {
        /// Cell 的重用标识符，能够代表该 Cell 具体类型标识
        public static let cell = "identitierCellKey"

        /// 标识 cell 的高度
        public static let height = "heightCellKey"
        /// 标识 Cell 的高宽比
        public static let proportion = "proportionCellKey"

        /// 在 JudyBaseCell 中 对应 titleLabel
        public static let title = "titleCellKey"
        /// 在 JudyBaseCell 中 对应 subtitle
        public static let subtitle = "subtitleCellKey"
        
        /// 一般用于数据源中的数组标识
        public static let datas = "datasCellKey"

        /// 一般用来标识 segue
        public static let segue = "segueIdentifierCellKey"
        /// 如果有用到本地小图标这选择这个 Key，注意不要和 image 搞混
        public static let icon = "iconCellKey"
        /// 在 JudyBaseCell 中对应 masterImageView 的 URL
        public static let image = "imageCellKey"

        // MARK: cell 中的输入场景
        
        /// 占位符，一般用于输入框场景
        public static let placeholder = "placeholderCellKey"
        /// 一般表示输入框的值
        public static let value = "valueCellKey"
        /// 是否支持输入？一般对应一个 Bool 值
        public static let input = "inputEnableCellKey"
        
        /// 一般用来标识 对应的Api Key
        public static let apiKey = "apiKeyCellKey"

        // MARK: header/footer

        /// 标识 section header
        public static let header = "headerViewCellKey"
        /// 标识 section footer
        public static let footer = "footerViewCellKey"
        /// 标识 section 底部偏移量
        public static let insetBottom = "insetBottomCellKey"
        /// 标识 section 顶部偏移量
        public static let insetTop = "insetTopCellKey"

        
    }
    
    @available(*, unavailable, message: "已废弃，请重命名", renamed: "Api")
    struct ApiKey {}
    @available(*, unavailable, message: "已废弃，请重命名", renamed: "Cell")
    struct CellKey {}

}


public extension EMERANA {
    
    /// 一个气泡动画类
    /// * warning: 通过调用 judy_popBubble 函数来弹出一个气泡动画
    /// * since: 1.0
    class JudyPopBubble {
        
        /// 指定气泡的中心点，默认为 bubble_belowView 的中心点
        public var bubble_image_Center: CGPoint?
        
        /// 气泡冒出时的动画所需时长
        public var bubble_animate_showDuration = 0.2
        /// 气泡旋转动画所需时长
        public var bubble_animate_rotatedDuration: TimeInterval = 2
        /// 气泡往上飘所需时长
        public var bubble_animate_windUp: TimeInterval = 3
        /// 气泡消失时所需时长
        public var bubble_animate_dissmiss: TimeInterval = 3
        /// 气泡动画路径高度
        public var bubble_animate_height: CGFloat = 350

        
        /// 气泡图片
        private(set) public var bubble_image: UIImage?
        /// 气泡所在的 View
        private(set) public var bubble_parentView: UIView?
        /// 将该气泡放在该 View 下面，该 view 决定了气泡的起始位置，通常情况下是该对象是触发按钮
        private(set) public var bubble_belowView: UIView?
        
        
        public init(){}
        
        
        /// 执行一个气泡图片动画
        /// - Parameters:
        ///   - image: 气泡图片对象
        ///   - parentView: 执行气泡动画的 View
        ///   - belowView: 将该气泡放在该 View 下面，该 view 决定了气泡的起始位置
        public func judy_popBubble(withImage image: UIImage?, inView parentView: UIView, belowSubview belowView: UIView) {
            guard image != nil else { return }
            
            bubble_image = image!
            bubble_parentView = parentView
            bubble_belowView = belowView
            
            /// 气泡图片
            let bubbleImageView = UIImageView(image: bubble_image)
            
            // 设置气泡图片的起始位置
            if bubble_image_Center == nil {
                if bubble_belowView!.superview == bubble_parentView {
                    bubbleImageView.center = CGPoint(x: bubble_belowView!.center.x, y: bubble_belowView!.frame.origin.y)
                    bubble_parentView?.insertSubview(bubbleImageView, belowSubview: bubble_belowView!)
                } else {
                    bubbleImageView.center = bubble_belowView!.convert(bubble_belowView!.center, to: bubble_parentView)
                    bubbleImageView.center.x -= bubble_belowView!.frame.origin.x
                    bubbleImageView.center.y -= bubble_belowView!.frame.origin.y
                    bubble_parentView?.insertSubview(bubbleImageView, belowSubview: bubble_belowView!.superview!)
                }
            } else {
                bubbleImageView.center = bubble_image_Center!
            }
            

            bubbleImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            bubbleImageView.alpha = 0 // 初始为完全透明
            
            // 气泡冒出动画
            UIView.animate(withDuration: bubble_animate_showDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveEaseOut) {
                bubbleImageView.transform = CGAffineTransform.identity
                bubbleImageView.alpha = 1
            } completion: { isCompletion in }
            
            // 随机偏转角度 control 点
            let j = CGFloat(arc4random_uniform(2))
            /// 随机方向，-1 OR 1 代表了顺时针或逆时针
            let travelDirection = CGFloat(1 - (2*j))
            
            // 旋转气泡
            UIView.animate(withDuration: bubble_animate_rotatedDuration) {
                var transform = bubbleImageView.transform
                let rs = Double.pi/4//(4+Double(rotationFraction)*0.2)
                transform = transform.rotated(by: travelDirection*CGFloat(rs)) // 顺时针或逆时针旋转
                // transform = transform.translatedBy(x: 0, y: 200)//平移
                // transform = transform.scaledBy(x: 0.5, y: 0.5)//缩放
                bubbleImageView.transform = transform
            }
            
            // 随机终点
            let ViewX = bubbleImageView.center.x
            let ViewY = bubbleImageView.center.y
            let endPoint = CGPoint(x: ViewX + travelDirection*10, y: ViewY - bubble_animate_height)
            
            let m1 = ViewX + CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
            let n1 = ViewY - CGFloat(60 + travelDirection*CGFloat(arc4random_uniform(20)))
            let m2 = ViewX - CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
            let n2 = ViewY - CGFloat(90 + travelDirection*CGFloat(arc4random_uniform(20)))
            let controlPoint1 = CGPoint(x: m1, y: n1)   //control 根据自己动画想要的效果做灵活的调整
            let controlPoint2 = CGPoint(x: m2, y: n2)
            
            /// 气泡移动轨迹路径
            let travelPath = UIBezierPath()
            travelPath.move(to: bubbleImageView.center)
            //根据贝塞尔曲线添加动画
            travelPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            
            // 关键帧动画,实现整体图片位移
            let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
            keyFrameAnimation.path = travelPath.cgPath
            keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
            keyFrameAnimation.duration = bubble_animate_windUp // 往上飘动画时长,可控制速度
            bubbleImageView.layer.add(keyFrameAnimation, forKey: "positionOnPath")
            
            // 消失动画
            UIView.animate(withDuration: bubble_animate_dissmiss) {
                bubbleImageView.alpha = 0.0
            } completion: { finished in
                bubbleImageView.removeFromSuperview()
            }
            
        }

    }
    
}



//MARK: Swift提供的许多功能强大的全局函数

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
