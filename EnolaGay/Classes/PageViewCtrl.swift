//
//  JudyBasePageViewCtrl.swift
//  LifeCatcher
//
//  Created by 王仁洁 on 2019/12/17.
//  Copyright © 2019 指尖躁动. All rights reserved.
//

/// JudyBasePageViewCtrl 模型驱动专用协议，该协议只有继承 class 类型才能定义成 weak 代理对象
/// * 此协议主要包含生成 viewCtrl 模型的函数
public protocol EMERANA_JudyBasePageViewCtrlModel: UIViewController {
    
    /// 初始化对应 index 的 viewCtrl，一般地，此处应返回一个 viewCtrl 模板对象
    /// - Parameter index: 目标 index
    func viewController(forIndex index: Int) -> UIViewController
}

/// PageViewCtrl 切换协议，该协议只有继承 class 类型才能定义成 weak 代理对象
/// # 代理需要定义成 weak 形式才能避免强引用
public protocol EMERANA_JudyPageViewCtrlAnimating: UIViewController {
    
    /// pageViewCtrl 切换事件，此函数在手动切换 pageViewCtrl 时触发
    /// - Parameter index: 对应界面的目标 index
    func pageViewCtrlDidFinishAnimating(atIndex index: Int)
}


/// JudyBasePageViewCtrl 专用协议，仅限于 JudyBasePageViewCtrl
public protocol EMERANA_PageViewCtrl where Self: JudyBasePageViewCtrl {
    
    /// 当最左边的 ViewCtrl 继续向右拖动达到指定位置时执行 Pop()，默认值应该为 false
    /// * 只有当前导航条为 JudyNavigationCtrl 时该属性才起作用
    /// # 实现协议参考如下:
    /// ```
    /// @IBInspectable lazy var isAutoPop: Bool = false
    /// ```
    var isAutoPop: Bool { get }
    
    /// 是否支持弹簧效果，默认为 true
    /// * 将该值设为 false 则 pageViewCtrl 首位界面没有向外部滚动的弹簧效果
    var isBounces: Bool { get }

    /// 该值用于记录是否通过拖拽 viewCtrl 触发的切换，默认值应该为 true。
    /// * 若当前导航条为 JudyNavigationCtrl 时才需要该属性
    /// * 若该值为 false（如 segmentCtrl 触发切换函数），则不应该响应 Pop()函数
    /// # 实现协议参考如下：
    /// ```
    /// lazy var isScrollByViewCtrl = true
    /// ```
    var isScrollByViewCtrl: Bool { get }
    
    /// 当前记录的选中索引，默认值应该为 0
    /// * # 实现协议参考如下：
    /// ```
    /// lazy var lastSelectIndex = 0
    /// ```
    var lastSelectIndex: Int { get }
     
    /// 所有在 pageViewCtrl 中出现的 viewCtrls
    /// # 实现协议参考如下：
    /// ```
    /// var viewCtrlArray = [UIViewController]()
    /// ```
    var viewCtrlArray: [UIViewController] { get }
    
    /// viewCtrlArray 对应的 titles
    var viewCtrlTitleArray: [String] { get }
    
    
    /// emerana 代理，此代理负责处理 pageViewCtrl 切换事件
    /// # 实现协议参考如下：
    /// ```
    /// weak var emerana: EMERANA_PageViewCtrlDelegate?
    /// ```
    var emerana: EMERANA_JudyPageViewCtrlAnimating? { get set }
    
    /// 模型驱动代理，在使用模型驱动时必须实现该代理，并通过此代理设置 viewCtrl 模型
    /// # 实现协议参考如下：
    /// ```
    /// weak var enolagay: EMERANA_ModelPageViewCtrlDelegate?
    /// ```
    var enolagay: EMERANA_JudyBasePageViewCtrlModel? { get set }

}


import UIKit

/// 支持模型驱动和数据驱动的标准 JudyBasePageViewCtrl
///
/// 通过 setPageViewDataSource 函数设置数据及界面
/// - version: 2.3.0
/// - warning: setPageViewDataSource 函数中直接明确了所有需要出现的 viewCtrls 及对应的 titles。
/// - warning: 如果是模型驱动，则必须实现 enolagay 代理对象。
open class JudyBasePageViewCtrl: UIPageViewController, EMERANA_PageViewCtrl {
    
    @IBInspectable lazy public var isAutoPop: Bool = false
    
    @IBInspectable lazy public var isBounces: Bool = true

    lazy public var isScrollByViewCtrl = true

    lazy public var lastSelectIndex = 0
    
    private(set) public var viewCtrlArray = [UIViewController](){
        didSet{
            // 配置默认显示的界面
            setViewControllers([viewCtrlArray[0]], direction: .forward, animated: true)
        }
    }
    
    private(set) lazy public var viewCtrlTitleArray = [String]()

    weak public var emerana: EMERANA_JudyPageViewCtrlAnimating?
    
    weak public var enolagay: EMERANA_JudyBasePageViewCtrlModel?

    
    
    open override func viewDidLoad() {
        guard transitionStyle == .scroll else {
            fatalError("请设置 pageViewCtrl.transitionStyle 为 scroll")
        }
        super.viewDidLoad()
        
        view.backgroundColor = .judy(.scrollView)
        // 通过手势拖动时要设置的数据源，若不需要手势控制，将其设为 nil 即可
        dataSource = self
        delegate = self

        let scrollView = view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self

    }
    
    /// 设置数据源，默认会显示第一项
    /// - Parameter dataSource: 在以模型为驱动时，传入 titles，该 titles 会对应 viewCtrl 的 title；在以界面为驱动时，传入viewControllers
    final public func setPageViewDataSource<DataSource>(dataSource: [DataSource]) {
        guard !dataSource.isEmpty else {
            Judy.log("dataSource 不能为空！- \(classForCoder)")
            return
        }
        
        if dataSource is [String] { // 模型驱动
            guard enolagay != nil else { fatalError("模型驱动必须实现 enolagay！") }
            
            viewCtrlTitleArray = dataSource as! [String]
            // 根据 viewCtrlTitleArray 设置 viewCtrlArray
            viewCtrlArray = viewCtrlTitleArray.enumerated().map({ (index, title) -> UIViewController in
                let viewCtrl = enolagay!.viewController(forIndex: index)
                viewCtrl.title = title
                return viewCtrl
            })
            
        } else if dataSource is [UIViewController] {  // viewCtrl 驱动
            viewCtrlArray = dataSource as! [UIViewController]
            // 根据 viewCtrlArray 设置 viewCtrlTitleArray
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
                    Judy.log("🚔 viewController title 为空，请检查！")
                    return "EMERANA"
                }
                
                return theViewTitle!
            })

        } else {
            Judy.log("未知数据源类型！")
        }
    }
    
    
    deinit { Judy.log("🚙 <\(title ?? "未命名界面")> 已经释放 - \(classForCoder)") }
}


// MARK: 私有配置函数
private extension JudyBasePageViewCtrl {
    
    /// 通过当前 ViewCtrl 获取对应的在 viewCtrlArray 中的 index
    /// - Parameter viewCtrl: 此 viewCtrl 必须是 viewCtrlArray 中的一员
    func indexOfViewController(viewCtrl: UIViewController) -> Int {
        return viewCtrlArray.firstIndex(of: viewCtrl) ?? NSNotFound
    }
    
    /// 通过 index 在 viewCtrlArray 中获取一个 viewCtrl
    ///
    /// - Parameter index: 索引
    /// - Returns: 目标 viewCtrl
    func viewCtrlBySwitchAtIndex(index: Int) -> UIViewController? {
        if (viewCtrlArray.count == 0) || (index >= viewCtrlArray.count) {
            return nil
        }
        // 从 viewCtrlArray 中直接拿出对应的 viewCtrl
        return viewCtrlArray[index]
    }
    
}

// MARK: UIPageViewControllerDataSource
extension JudyBasePageViewCtrl: UIPageViewControllerDataSource {
    
    /// 显示上一页
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = indexOfViewController(viewCtrl: viewController)
        // 判断是否已经是第一页
        if index == 0 || index == NSNotFound {
            return nil
        }
        
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

// MARK: - UIPageViewControllerDelegate
extension JudyBasePageViewCtrl: UIPageViewControllerDelegate {
    
    // 只有通过拖动 pageViewCtrl 才会触发此函数
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        isScrollByViewCtrl = true
        lastSelectIndex = indexOfViewController(viewCtrl: pageViewController.viewControllers!.last!)
        
        emerana?.pageViewCtrlDidFinishAnimating(atIndex: lastSelectIndex)
        Judy.log("当前切换到：\(UInt(lastSelectIndex))")
    }
    
}

// MARK: - UIScrollViewDelegate
extension JudyBasePageViewCtrl: UIScrollViewDelegate {
    
    /// 滚动视图发生向右滚动超过指定范围时执行特定事件
    /// 如果重写此方法方法，需要覆盖父类方法，否则将不能实现手势返回
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        scrollView.bounces = isBounces

        guard isAutoPop, isScrollByViewCtrl,
            navigationController is JudyNavigationCtrl,
            navigationController!.children.count > 1, // 守护 JudyNavigationCtrl 不是最底层，最底层无法 pop
            lastSelectIndex == 0 else {
                return
        }
        
        if view.frame.width - scrollView.contentOffset.x > 68 {
            (navigationController as! JudyNavigationCtrl).doPopAction()
            scrollView.delegate = nil
        }
        
    }
}


// MARK: - 配备 JudySegmentedCtrl 的 JudyBasePageViewCtrl

/// 配备 JudySegmentedCtrl 的 JudyBasePageViewCtrl
///  - warning: 本类中的 segmentedCtrl 已经和 pageViewCtrl 互相关联，无需手动配置二者关系
open class JudyBasePageViewSegmentCtrl: JudyBasePageViewCtrl, SegmentedViewDelegate {
    
    /// 分段控制器，如果有设置 pageViewCtrlToSegmentDelegate 对象，navigationSegmentedCtrl 将不会生效
    private(set) lazy public var segmentedCtrl: SegmentedView = {
        let segmentedView = SegmentedView()
        segmentedView.delegate = self
        return segmentedView
    }()


    open override func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        super.pageViewController(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
        
        segmentedCtrl.selectItem(at: lastSelectIndex)

    }
    
    // MARK: - segmentedCtrl 相关函数
    
    /// 设置 SegmentedCtrl 基本信息
    /// - warning: 此函数将会设置以下行为
    /// * sectionTitles 与 viewCtrlTitleArray 同步
    /// * segmentedCtrl.frame.size.width 被设为所有 title 宽度之和
    /// * backgroundColor = .clear
    /// * 配置 configSegmentedStyle 函数
    /// - Parameter isLesser: 是否较少内容，默认false，若需要使 segmentedCtrl 宽度适应内容宽度传入 true
    open func setSegmentedCtrl(isLesser: Bool = false) {
        
        //  segmentedCtrl.frame = judy_navigationCtrller().navigationBar.frame
        //  设置 title 数据源
        segmentedCtrl.backgroundColor = .clear
        
        if isLesser {
            var width = "".textSize().width
            viewCtrlTitleArray.forEach { (title) in
                width += title.textSize().width + 28
            }
            segmentedCtrl.frame.size.width = width
        }
        
        //  替换 titleView
        //  navigationItem.titleView = segmentedCtrl
    }
    
    open func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        
        isScrollByViewCtrl = false
        // segmentedCtrl 改变 viewControllers
        let index = index
        if index >= viewCtrlArray.count {
            Judy.log("切换目标 index 不在 viewCtrlArray 范围")
            return
        }
        let viewCtrls = [viewCtrlArray[index]]
        // 不应该在 completion 里设置 lastSelectIndexAtSegmentedCtrl，这样不及时
        setViewControllers(viewCtrls, direction: ((lastSelectIndex < index) ? .forward : .reverse), animated: true)
        lastSelectIndex = index
        
    }
    

}

@available(*, unavailable, message: "该协议已变更命名，请更新", renamed: "EMERANA_JudyLivePageViewCtrl")
public protocol EMERANA_JudyBasePageViewCtrlLiveModel {}

/// 适用于比如 JudyLivePageViewCtrl 等 UIPageViewController 子类管理 viewCtrl 的协议。
///
/// 该协议中定义了如何确定具体的 viewCtrl，以及确定该 viewCtrl 所需要的唯一数据。
public protocol JudyPageViewCtrlDelegate: UIViewController {
    
    /// 询问 pageViewCtrl 中所有 viewCtrl 对应的数据源实体，该实体为一个数组。
    func entitys(for pageViewCtrl: UIPageViewController) -> [Any]
    
    /// 询问 viewCtrl 在 entitys 数据源中的索引。
    ///
    /// 通常每个 viewCtrl 都有一个 entity 作为其唯一标识符，通过该 entity 确定在 entitys 的索引。
    func index(for viewCtrl: UIViewController, at entitys: [Any] ) -> Int
    
    /// 询问目标实体 entity 对应的 viewCtrl。
    ///
    /// 每个 viewCtrl 都应该有一个 entity，同时该 entity 作为该 viewCtrl 的唯一标识符。
    func viewCtrl(for entity: Any) -> UIViewController

}


/// 适用于直播、短视频类型的 pageViewCtrl。
///
/// 别忘了设置滚动方向 pageViewCtrl.navigationOrientation，根据需要设置为水平方向滑动还是垂直方向滑动。
/// - Warning: 请记得设置 transitionStyle 为 scroll；
/// * 请通过调用 onStart() 函数使 pageViewCtrl 正常工作，通常情况下在数据源被确定时调用此函数;
/// * JudyLivePageViewCtrl 支持下拉刷新请通过 scrollViewClosure 获取 scrollView;
open class JudyLivePageViewCtrl: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    /// viewCtrl 数据源配置代理对象，所有要显示的 ViewCtrl 均通过此协议配置
    weak public var enolagay: JudyPageViewCtrlDelegate!
    
    /// 当 scrollView 有值后触发此闭包以便外部设置 scrollView。
    public var scrollViewClosure:((UIScrollView) -> Void)?
    /// 在 UIPageViewController 中的核心 ScrollView，请通过 scrollViewClosure 获取有效的 scrollView。
    public private(set) var scrollView: UIScrollView? {
        didSet{
            if scrollView != nil {
                scrollViewClosure?(scrollView!)
            }
        }
    }
    
    /// 用于控制所有显示的 ViewCtrl 实体数据。
    private var entitys: [Any] { enolagay.entitys(for: self) }
    
    
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
    
    /// 重载所有数据配置及逻辑。
    ///
    /// 该函数将根据 enolagay 询问数据源并重置到初始页。
    public final func reload() {
        if entitys.first != nil {
            let firstViewCtrl = enolagay.viewCtrl(for: entitys.first!)
            // 设置初始页。
            setViewControllers([firstViewCtrl], direction: .forward, animated: true)
            dataSource = self
            delegate = self
        } else {
            setViewControllers(nil, direction: .forward, animated: true)
            dataSource = nil
            delegate = nil
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    /// 显示前一页。
    public final func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let index = enolagay.index(for: viewController, at: entitys)
        if index <= 0 { return nil } // 已经是第一页了。

        return enolagay.viewCtrl(for: entitys[index-1])
    }
    
    /// 显示下一页。
    public final func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = enolagay.index(for: viewController, at: entitys)
        if index >= entitys.count - 1 { return nil } // 已经是最后一页了。
        
        return enolagay.viewCtrl(for: entitys[index+1])
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    // 通过拖动 pageViewCtrl 才会触发此函数
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //  if completed { Judy.log("翻页完毕") }
    }
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = true
        
        // 判断是上拉还是下拉。
        /*
         let pan = scrollView.panGestureRecognizer
         let velocity = pan.velocity(in: scrollView).y
         Judy.log( velocity < -5 ? "上拉":"下拉")
         Judy.log("contentOffset: \(scrollView.contentOffset)")
         */
    }
    
}
