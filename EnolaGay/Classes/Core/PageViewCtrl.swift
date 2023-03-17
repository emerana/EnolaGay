//
//  JudyBasePageViewCtrl.swift
//  LifeCatcher
//
//  Created by 王仁洁 on 2019/12/17.
//  Copyright © 2019 指尖躁动. All rights reserved.
//

/// JudyBasePageViewCtrl 模型驱动专用协议，该协议只有 AnyObject 类型才能定义成 weak 代理对象
///
/// 此协议主要包含生成 viewCtrl 模型的函数
public protocol EMERANA_JudyBasePageViewCtrlModel: AnyObject {
    /// 询问对应 index 的 viewCtrl
    func viewCtrl(for index: Int, at title: String) -> UIViewController
}

/// PageViewCtrl 切换协议，该协议只有继承 class 类型才能定义成 weak 代理对象
///
/// 代理需要定义成 weak 形式才能避免强引用
public protocol EMERANA_JudyPageViewCtrlAnimating: UIViewController {
    /// pageViewCtrl 切换事件，此函数在手动切换 pageViewCtrl 时触发
    func pageViewCtrlDidFinishAnimating(at index: Int)
}


import UIKit

/// 支持模型驱动和数据驱动的标准 JudyBasePageViewCtrl.
///
/// 通过 setPageViewDataSource 函数设置数据及界面，此类适用于切换的页面较少的场景，会保留所有出现的 viewCtrl
/// - Warning: setPageViewDataSource 函数中直接明确了所有需要出现的 viewCtrls 及对应的 titles
/// - Warning: 如果是模型驱动，则必须实现 enolagay 代理对象
open class JudyBasePageViewCtrl: UIPageViewController, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    /// emerana 代理，此代理负责处理 pageViewCtrl 切换事件
    weak public var emerana: EMERANA_JudyPageViewCtrlAnimating?
    
    /// 模型驱动代理，在使用模型驱动时必须实现该代理，并通过此代理设置 viewCtrl 模型
    weak public var enolagay: EMERANA_JudyBasePageViewCtrlModel?

    /// 记录当前显示的索引，该值默认为 0.
    public internal(set) var currentIndex = 0

    /// 当最左边的 ViewCtrl 继续向右拖动达到指定位置时执行 Pop()，默认值应该为 false.
    /// - Warning: 只有当前导航条为 JudyNavigationCtrl 时该属性才起作用
    @IBInspectable public lazy var isAutoPop: Bool = false
    
    /// 是否支持弹簧效果，默认为 true
    /// - Warning: 将该值设为 false 则 pageViewCtrl 首位界面没有向外部滚动的弹簧效果
    @IBInspectable public lazy var isBounces: Bool = true

    /// 该值用于记录最后一次视图的转换是否由用户通过拖拽触发，该值默认为 true.
    ///
    /// 若该值为 false（如因为 segmentCtrl 切换触发转换），则不应该响应导航条 Pop() 函数
    /// - Warning: 若当前导航条为 JudyNavigationCtrl 时才需要该属性
    public lazy var isDrag = true

    /// pageViewCtrl 中出现的所有 viewCtrl 数组
    public private(set) var viewCtrlArray = [UIViewController]()
    
    /// viewCtrlArray 对应的 titles.
    public private(set) lazy var viewCtrlTitleArray = [String]()
    
    /// 在 UIPageViewController 中的核心 ScrollView.
    public private(set) var scrollView: UIScrollView?

    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        guard transitionStyle == .scroll else {
            fatalError("请设置 pageViewCtrl.transitionStyle 为 scroll。")
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 通过手势拖动时要设置的数据源，若不需要手势控制，将其设为 nil 即可
        dataSource = self
        delegate = self

        scrollView = view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
        scrollView?.delegate = self
    }

    /// 通过此函数启动 pageViewCtrl 以设置数据源，默认会显示数据源中的第一项
    ///
    /// - Parameters:
    ///   - dataSource: 在以模型为驱动时，传入 titles，该 titles 会自动设置 viewCtrl 的 title；在以界面为驱动时，传入 viewControllers.
    ///   - index: dataSource 中用于显示首页的索引，默认为 0
    public final func onStart<DataSource>(dataSource: [DataSource], index: Int = 0) {
        guard !dataSource.isEmpty else { return }
        guard index < dataSource.count else {
            currentIndex = 0
            return
        }
        currentIndex = index

        if dataSource is [String] { // 传入的标题，以模型驱动
            guard enolagay != nil else { fatalError("模型驱动必须实现 enolagay！") }
            
            viewCtrlTitleArray = dataSource as! [String]
            // 根据 viewCtrlTitleArray 设置 viewCtrlArray.
            viewCtrlArray = viewCtrlTitleArray.enumerated().map({ (index, title) -> UIViewController in
                let viewCtrl = enolagay!.viewCtrl(for: index, at: title)
                viewCtrl.title = title
                return viewCtrl
            })
            // 配置默认显示的界面
            setViewControllers([viewCtrlArray[currentIndex]], direction: .forward, animated: true)

        } else if dataSource is [UIViewController] {  // 传入的 viewCtrl，以 viewCtrl 驱动
            viewCtrlArray = dataSource as! [UIViewController]
            // 配置默认显示的界面
            setViewControllers([viewCtrlArray[currentIndex]], direction: .forward, animated: true)

            // 根据 viewCtrlArray 设置 viewCtrlTitleArray.
            viewCtrlTitleArray = viewCtrlArray.map({ (item) -> String in
                let viewController = item
                var theViewTitle: String?
                
                if let viewCtrl: JudyBaseViewCtrl = viewController as? JudyBaseViewCtrl {
                    theViewTitle = viewCtrl.viewTitle
                    if theViewTitle == nil { theViewTitle = viewController.title }
                } else {
                    theViewTitle = viewController.title
                }
                
                guard theViewTitle != nil, theViewTitle != "" else {
                    Judy.logWarning("viewController title 为空，请检查！")
                    return "EMERANA"
                }
                
                return theViewTitle!
            })

        } else { Judy.logWarning("未知数据源类型！") }
    }
    
    /// 滚动到指定索引界面，此函数类似用户触发 segmented 发生的转换，常用于不需要由用户拖拽发生转换的场景
    /// - Parameter index: 该索引为当前 viewCtrlArray 中的有效索引，否则函数将不生效
    public final func scrollTo(index: Int) {
        // segmentedCtrl 改变 viewControllers.
        guard index < viewCtrlArray.count else {
            Judy.logWarning("目标 index 不在 viewCtrlArray 范围!")
            return
        }
        isDrag = false
        let viewCtrls = [viewCtrlArray[index]]
        // 不应该在 completion 里设置 currentIndex，这样不及时
        setViewControllers(viewCtrls, direction: ((currentIndex < index) ? .forward : .reverse), animated: true)
        currentIndex = index
    }

    /// 外部可能需重设 scrollView?.delegate 时通过调用此函数将 scrollView.delegate 设置为初始状态，也就是 JudyBasePageViewCtrl 本身
    public final func resetScrollViewDelegate() {
        scrollView?.delegate = self
    }
    
    deinit { Judy.logHappy("\(title ?? "\(classForCoder)") 已经释放。") }

    
    // MARK: - UIPageViewControllerDelegate
    
    // 通过用户拖拽 pageViewCtrl 直到手指离开屏幕后且要转换的目标界面不为 nil 时即触发此函数
    // 手势驱动转换完成后调用。使用completed参数来区分完成的转换(翻页)和用户中止的转换(未翻页)
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        isDrag = true
        
        if completed {
            currentIndex = indexOfViewController(viewCtrl: pageViewController.viewControllers!.last!)
            emerana?.pageViewCtrlDidFinishAnimating(at: currentIndex)
            // Judy.log("当前切换到：\(UInt(lastSelectIndex))")
        } else {
            // Judy.log("中止翻页")
        }
    }

    
    // MARK: - UIScrollViewDelegate

    /// 滚动视图发生向右滚动超过指定范围时执行特定事件
    /// 如果重写此方法方法，需要覆盖父类方法，否则将不能实现手势返回
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = isBounces

        guard isAutoPop, isDrag,
              navigationController is JudyNavigationCtrl,
              navigationController!.children.count > 1, // 守护 JudyNavigationCtrl 不是最底层，最底层无法 pop.
              currentIndex == 0 else {
            return
        }
        
        if view.frame.width - scrollView.contentOffset.x > 68 {
            (navigationController as! JudyNavigationCtrl).doPopAction()
            scrollView.delegate = nil
        }
    }

}

private extension JudyBasePageViewCtrl {
    
    /// 通过当前 viewCtrl 获取对应的在 viewCtrlArray 中的 index.
    /// - Parameter viewCtrl: 此 viewCtrl 必须是 viewCtrlArray 中的一员
    func indexOfViewController(viewCtrl: UIViewController) -> Int {
        return viewCtrlArray.firstIndex(of: viewCtrl) ?? NSNotFound
    }
    
    /// 通过 index 在 viewCtrlArray 中获取一个 viewCtrl.
    ///
    /// - Parameter index: 索引
    func viewCtrlBySwitchAtIndex(index: Int) -> UIViewController? {
        if (viewCtrlArray.count == 0) || (index >= viewCtrlArray.count) {
            return nil
        }
        // 从 viewCtrlArray 中直接拿出对应的 viewCtrl.
        return viewCtrlArray[index]
    }
    
}

// MARK: UIPageViewControllerDataSource
extension JudyBasePageViewCtrl: UIPageViewControllerDataSource {
    
    /// 显示上一页
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = indexOfViewController(viewCtrl: viewController)
        // 判断是否已经是第一页
        if index == 0 || index == NSNotFound { return nil }
        
        return viewCtrlBySwitchAtIndex(index: index-1)
    }
    
    
    /// 显示下一页
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = indexOfViewController(viewCtrl: viewController)
        // 判断是否已经是最后一页或超出范围
        if index == NSNotFound || (index + 1) >= viewCtrlArray.count {
            return nil
        }
        
        return viewCtrlBySwitchAtIndex(index: index+1)
    }
}

/// 适用于 JudyLivePageViewCtrl 等 UIPageViewController 子类管理 viewCtrl 的协议
///
/// 该协议中定义了如何确定具体的 viewCtrl，以及确定该 viewCtrl 所需要的唯一数据
public protocol JudyPageViewCtrlDelegate: AnyObject {
    
    /// 询问 pageViewCtrl 中所有 viewCtrl 对应的数据源实体，该实体为一个数组
    func entitys(for pageViewCtrl: UIPageViewController) -> [Any]

    /// 询问 viewCtrl 在 entitys 中对应的索引
    ///
    /// - Parameters:
    ///   - viewCtrl: 每个 viewCtrl 都有一个 entity 作为其唯一标识符，通过该 entity 确定在 entitys 中的索引。若该 viewCtrl 不存在 entitys 中请返回 0.
    ///   - entitys: viewCtrl 所在的数据源实体数组，viewCtrl 应该对应该数组中的某个元素
    /// - Warning: viewCtrl 可能为 emptyViewCtrl，请注意与 emptyViewCtrl(for pageViewCtrl: UIPageViewController) 代理函数返回的 viewCtrl 正确区分
    func index(for viewCtrl: UIViewController, at entitys: [Any] ) -> Int
    
    /// 询问目标实体 entity 对应的 viewCtrl.
    ///
    /// 每个 viewCtrl 都应包含一个 entity，该 entity 作为该 viewCtrl 的唯一标识符
    func viewCtrl(for entity: Any) -> UIViewController
    
    /// 询问当 pageViewCtrl 中没有可显示的 viewCtrl 时用于显示的界面。在该界面应做好重载数据及初始化工作
    ///
    /// 由于不允许传入 nil，setViewControllers(nil, direction: .forward, animated: true) 将直接崩溃。如果能够保证永远不需要空白界面则可不实现此函数，该函数默认返回 UIViewController()
    func emptyViewCtrl(for pageViewCtrl: UIPageViewController) -> UIViewController
    
    /// 询问代理添加下拉刷新控件。该函数默认为空实现
    ///
    /// 请在此为 pageViewCtrl 添加下拉刷新功能，如： scrollView.mj_header = MJRefreshNormalHeader，
    /// scrollView 仅支持下拉刷新，如有上拉加载更多的需求请考虑使用 tableView.
    /// - Parameter scrollView: pageViewCtrl 中的核心 scrollView.
    func addReloadHeaderView(for scrollView: UIScrollView)
}

// 默认实现函数，使其变成可选协议函数
public extension JudyPageViewCtrlDelegate {
    func emptyViewCtrl(for pageViewCtrl: UIPageViewController) -> UIViewController {
        return UIViewController()
    }
    
    func addReloadHeaderView(for scrollView: UIScrollView) { }
}

/// 适用于直播、短视频类型的（viewCtrl 数量不限）轻量级 pageViewCtrl
///
/// 别忘了设置滚动方向 pageViewCtrl.navigationOrientation，根据需要设置为水平方向滑动还是垂直方向滑动
/// - Warning: 注意事项：
/// * 请记得设置 transitionStyle 为 scroll；
/// * 当确定 enolagay.entitys 后请调用 onStart() 使 pageViewCtrl 开始工作;
open class JudyLivePageViewCtrl: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    /// viewCtrl 数据源配置代理对象，所有要显示的 viewCtrl 均通过此协议配置
    weak public var enolagay: JudyPageViewCtrlDelegate!
    
    @available(*, unavailable, message: "请使用 enolagay 实现下拉刷新")
    public var scrollViewClosure: ((UIScrollView) -> Void)?
    /// 在 UIPageViewController 中的核心 ScrollView.
    public private(set) var scrollView: UIScrollView? {
        didSet{
            if scrollView != nil {
                enolagay.addReloadHeaderView(for: scrollView!)
            }
        }
    }
    
    /// 用于控制所有显示的 viewCtrl 的实体数据，该数据来源于 enolagay.entitys
    public var entitys: [Any] { enolagay.entitys(for: self) }
    
    /// 当前正在显示的 viewCtrl 在 entitys 中的索引，若该值为 -1 说明当前显示为空界面
    ///
    /// 即使正在翻页中尚未完成一个完整的翻页
    public private(set) var currentIndex = -1
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        guard transitionStyle == .scroll else {
            fatalError("请设置 pageViewCtrl.transitionStyle 为 scroll。")
        }
    }
    
    open override func viewDidLoad() {
        guard enolagay != nil else {
            fatalError("在 JudyLivePageViewCtrl 中必须设置 enolagay 代理！")
        }
        super.viewDidLoad()
        
        scrollView = view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
        scrollView?.delegate = self
    }
    
    /// 初始化所有数据配置及逻辑
    ///
    /// 该函数将询问数据源并重置到数据源中的第一页，，若 enolagay.entitys 为空，则询问 enolagay.emptyViewCtrl()，且需在 enolagay.entitys 首次不为空时重新调用此函数以初始化
    public final func onStart() {
        if entitys.isEmpty {
            // 询问空视图界面
            let emptyViewCtrl = enolagay.emptyViewCtrl(for: self)
            setViewControllers([emptyViewCtrl], direction: .forward, animated: false)
            dataSource = nil
            delegate = nil
            currentIndex = -1
        } else {
            let homePage = enolagay.viewCtrl(for: entitys[0])
            // 设置初始页
            setViewControllers([homePage], direction: .forward, animated: false)
            dataSource = self
            delegate = self
            currentIndex = 0
        }
    }
    
    deinit { Judy.logHappy("\(title ?? "\(classForCoder)") 已经释放。") }

    // MARK: - UIPageViewControllerDataSource
    
    /// 显示前一页
    public final func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let index = enolagay.index(for: viewController, at: entitys)
        if index <= 0 { return nil } // 已经是第一页了

        return enolagay.viewCtrl(for: entitys[index-1])
    }
    
    /// 显示下一页
    public final func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = enolagay.index(for: viewController, at: entitys)
        if index >= entitys.count - 1 { return nil } // 已经是最后一页了
        
        return enolagay.viewCtrl(for: entitys[index+1])
    }
    
    // MARK: - UIPageViewControllerDelegate

    // 通过用户拖拽 pageViewCtrl 直到手指离开屏幕后且要转换的目标界面不为 nil 时即触发此函数
    // 手势驱动转换完成后调用。使用completed参数来区分完成的转换(翻页)和用户中止的转换(未翻页)
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // Judy.log("完成翻页")
            // 只有完成了一个翻页才需要确定 currentIndex.
            currentIndex = enolagay.index(for: pageViewController.viewControllers!.last!, at: entitys)
        } else {
            // Judy.log("中止翻页")
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 允许弹簧效果
        scrollView.bounces = true
    }
    
}
