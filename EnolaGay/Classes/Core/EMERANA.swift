//
//  EMERANA.swift
//
//  Created by 艾美拉娜 on 2018/10/5.
//  Copyright © 2018. All rights reserved.
//

// MARK: typealias

/// 一个不传递任何参数的闭包类型
public typealias Closure = (() -> Void)
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

/*
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
    var dataSource: [Any] { get set }
    
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
 */


/*
 // MARK: 默认实现的注意点
 
 # 注意：协议扩展是针对抽象类的，而协议本身是针对具体对象的
 # 当声明协议时没有进行限定则须注意以下：
 # 重写协议的默认实现函数调用权重为 子类>实现类>默认实现，若没有在实现类实现函数则直接调用默认实现函数，此时子类的重写无效
 */

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
//    static let enolagayAdapter: EnolaGayAdapter? = UIApplication.shared as? EnolaGayAdapter
    
    /// API 层适配器
//    static let apiAdapter: ApiAdapter? = UIApplication.shared as? ApiAdapter
    
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

