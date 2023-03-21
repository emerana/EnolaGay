//
//  TableViewCtrl.swift
//  与 UITableView 相关的文件
//
//  Created by 醉翁之意 on 2018/4/2.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

// MARK: - JudyBaseTableViewCtrl

import UIKit

/**
 *  该类包含一个 tableView，请将 tableView 与故事板关联。
 *  * 该 tableView 已经实现 dataSource 和 delegate.
 *  * 默认 tableViewCellidentitier 为 "Cell".
 */
open class JudyBaseTableViewCtrl: JudyBaseViewCtrl {
    
    // MARK: - let property and IBOutlet
    
    /// 视图中的主要 tableView，该 tableView 默认将 dataSource、dataSource 设置为 self.
    @IBOutlet weak public var tableView: UITableView?

    // MARK: - var property
    
    /// 是否隐藏 tableFooterView，默认 false，将该值调为 true 即可隐藏多余的 cell.
    @IBInspectable private(set) lazy public var isHideFooter: Bool = false

    lazy open var dataSource = [Any]()
        
    
    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard tableView != nil else {
            logWarning("tableView 没有关联 IBOutlet！")
            return
        }
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        registerReuseComponents()
        
        if isHideFooter { tableView?.tableFooterView = UIView() }
        
        // 滑动时关闭键盘
        tableView?.keyboardDismissMode = .onDrag
        // 设置 tableView 的背景色
        // tableView?.backgroundColor = EMERANA.enolagayAdapter?.scrollViewBackGroundColor()

        // 配置 tableView 的背景色
        /*
        if #available(iOS 13.0, *) {
            if tableView?.backgroundColor == UIColor.systemBackground {
                tableView?.backgroundColor = .judy(.scrollView)
            }
        } else {
            if tableView?.backgroundColor == nil {
                tableView?.backgroundColor = .judy(.scrollView)
            }
        }
        */
    }
    
    open func registerReuseComponents() {
        /*
         // Judy-mark: 这样注册 cell 代替 Storyboard 里添加 cell
         let nib = UINib.init(nibName: "<#xibName#>", bundle: nil)
         tableView?.register(nib, forCellReuseIdentifier: "<#Cell#>")
         // 获取Cell
         let cell = tableView.dequeueReusableCell(withIdentifier: "<#Cell#>", for: indexPath)
         */
    }
}

// MARK: - UITableViewDelegate
extension JudyBaseTableViewCtrl: UITableViewDelegate {
    
    // MARK: scrollView DataSource
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // MARK: Judy-mark: 动态地隐藏/显示导航栏姿势
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -5 {  // 上拉
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 5 {    // 下拉
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        // MARK: Judy-mark: scrollView 的代理方法，取消 tableViewHeader 悬停的办法 取消悬停
        let sectionHeaderHeight:CGFloat = 8   // 这里的高度一定要>=heightForHeaderInSection的高度
        if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
        
    }
    */
    
    /// 选中事件。默认在父类里 deselectRow，实现此函数覆盖 super 即可
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /*
     其他代理方法

     heightForRowAt -> UITableView.automaticDimension
     
     heightForHeaderInSection
     
     // viewForHeaderInSection
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         var headerView: UITableViewHeaderFooterView!
         
         headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "leftHeader")
         headerView.contentView.backgroundColor = UIColor.groupTableViewBackground
         
         return headerView
     }
     
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return "标题\(section)"
     }

     */
}

// MARK: - UITableViewDataSource
extension JudyBaseTableViewCtrl: UITableViewDataSource {
    /*
     /// 询问 tableView 中的 section 数量
     func numberOfSections(in tableView: UITableView) -> Int { 2 }
     */
    
    /// 询问指定 section 中的 cell 数量，默认为 dataSource.count.
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    /// 询问指定 indexPath 的 Cell 实例，默认取 identifier 为 Cell 的实例
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断 Cell 是否为 nil.
        return tableView.dequeueReusableCell(withIdentifier: EMERANA.Key.cell, for: indexPath)
    }
    
}

// MARK: - JudyBaseTableRefreshViewCtrl

/// 在 JudyBaseTableViewCtrl 的基础上加上刷新控件，以支持分页加载数据
///
/// 请实现刷新控件适配器 extension UIApplication: RefreshAdapter ；重写 setSumPage() 函数以设置总页数
/// - Warning: reqApi() 周期主要匹配分页加载功能，若存在无关分页请求需重写以下函数：
///     * reqResult()，此函数中影响上下拉状态，无需控制 UI 状态时需要在此函数中排除
///     * reqSuccess()，此函数中影响设置总页数函数 setSumPage(), 无关的逻辑应该在此排除
///```
///override func reqResult() {
///    if requestConfig.api == 分页加载的 Api 请求 {
///        super.reqResult()
///    }
///}
///override func reqSuccess() {
///    if requestConfig.api == 分页加载的 Api 请求 {
///        super.reqSuccess()
///    }
///}
///```
open class JudyBaseTableRefreshViewCtrl: JudyBaseTableViewCtrl {
    open var pageSize: Int { 10 }
    open var defaultPageIndex: Int { 1 }
    open var pageSizeParameter: String {
        EMERANA.refreshAdapter?.pageSizeParameter ?? EMERANA.Key.pageSizeParameter
    }
    open var pageIndexParameter: String {
        EMERANA.refreshAdapter?.pageIndexParameter ?? EMERANA.Key.pageIndexParameter
    }
    
    final public private(set) var currentPage = 0 { didSet{ didSetCurrentPage() } }
    final lazy public private(set) var isAddMore = false
    
    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        resetStatus()
        // 配置刷新控件
        initHeaderRefresh()
        initFooterRefresh()
    }

    // MARK: Api相关

    /// 设置 api、param.
    ///
    /// 参考如下代码：
    ///```
    ///requestConfig.api = .???
    ///requestConfig.parameters?["userName"] = "Judy"
    ///```
    /// - Warning: 此函数中已经设置好 requestConfig.parameters?["page"] = currentPage，子类请务必调用父类方法
//    open override func setApi() {
//        requestConfig.parameters?[pageIndexParameter] = currentPage
//        requestConfig.parameters?[pageSizeParameter] = pageSize
//    }

    /// 未设置 requestConfig.api 却发起了请求时的消息处理
    ///
    /// 当 isAddMore = true (上拉刷新)时触发了此函数，此函数会将 currentPage - 1.
    /// - Warning: 重写此方法务必调用父类方法
//    open override func reqNotApi() {
//        if isAddMore { currentPage -= 1 }
//    }
    
    /// 当请求得到响应时首先执行此函数
    ///
    /// 此函数中会调用 endRefresh()，即结束 header、footer 的刷新状态
    /// - Warning: 此函数影响上下拉状态，请确认只有在分页相关请求条件下调用 super.reqResult()
    /// ```
    /// if  requestConfig.api?.value == ApiActions.Live.getAnchorLibraries.rawValue {
    ///     super.reqResult()
    /// }
    /// ```
//    open override func reqResult() { EMERANA.refreshAdapter?.endRefresh(scrollView: tableView) }
    
    /// 请求成功的消息处理，子类请务必调用父类函数
    ///
    /// 此函数已经处理是否有更多数据，需自行根据服务器响应数据更改数据源及刷新 tableView
    /// - Warning: 此函数中影响设置总页数函数 setSumPage(), 与分页无关的逻辑应该在此排除
//    open override func reqSuccess() {
//        // 设置总页数
//        let sumPage = setSumPage()
//        // 在此判断是否有更多数据。结束刷新已经在 reqResult() 中完成
//        if sumPage <= currentPage { // 最后一页了，没有更多
//            // 当没有更多数据的时候要将当前页设置为总页数或默认页数
//            currentPage = sumPage <= defaultPageIndex ? defaultPageIndex:sumPage
//            EMERANA.refreshAdapter?.endRefreshingWithNoMoreData(scrollView: tableView)
//        }
//    }
    
    /// 请求失败的消息处理，此函数中会触发 reqNotApi 函数
    ///
    /// - Warning: 重写此方法务必调用父类方法
//    open override func reqFailed() {
//        super.reqFailed()
//        reqNotApi()
//    }
    

    // MARK: - EMERANA_Refresh
    
    open func initHeaderRefresh() {
        EMERANA.refreshAdapter?.initHeaderRefresh(scrollView: tableView, callback: {
            [weak self] in
            self?.refreshHeader()
            
            self?.isAddMore = false
            self?.currentPage = self!.defaultPageIndex
            EMERANA.refreshAdapter?.resetNoMoreData(scrollView: self?.tableView)
            
//            self?.reqApi()
        })
    }
    
    open func initFooterRefresh() {
        EMERANA.refreshAdapter?.initFooterRefresh(scrollView: tableView, callback: {
            [weak self] in
            self?.refreshFooter()
            
            self?.isAddMore = true
            self?.currentPage += 1
            
//            self?.reqApi()
        })
    }
    
    open func didSetCurrentPage() {}
    
    open func refreshHeader() {}
    open func refreshFooter() {}

    /// 询问分页接口数据总页数，该函数已实现自动计算总页数
    ///
    /// 一般用当前页返回到数量与 pageSize 作比较来判断是否还有下一页
    /// - Warning: 若 apiData["data"].arrayValue 字段不同请覆盖此函数配置正确的总页数
    open func setSumPage() -> Int { 1
//        apiData["data"].arrayValue.count != pageSize ? currentPage:currentPage+1
    }

    open func resetStatus() {
        currentPage = defaultPageIndex
        isAddMore = false
    }

}


/// tableVie 通用 cell，包含一张主要图片、副标题以及默认数据源 json.
/// * labelsForColor 中的 labels 会配置颜色 foreground.
open class JudyBaseTableCell: UITableViewCell {
    
    /// 是否需要解决 UITableView 有 footerView 时最后一个 cell 不显示分割线问题，默认 false
    @IBInspectable lazy var isShowSeparatorAtFooter: Bool = false

    // MARK: - let property and IBOutlet

    @IBOutlet weak public var titleLabel: UILabel?
    @IBOutlet weak public var subTitleLabel: UILabel?
    @IBOutlet weak public var masterImageView: UIImageView?
    

    // MARK: - var property

    /**
     didSet 时重新定义 super.frame.
     # 切记是要更改 super.frame，而不是 self，否则会进入死循环
     */
    open override var frame: CGRect {
        didSet{
            // 改变 super 的 frame，需要计算好 row height。如实际需要100，底部留空10，则 row height 应该为 100 + 10
            // super.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height - 10))
        }
    }
        
    
    
    // MARK: - Life Cycle
    
    // Cell 准备重用时执行的方法
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        // 此处应重置 Cell 状态，清除在重用池里面设置的值
    }
    
    /// 重写了此方法必须调用 super.awakeFromNib()，里面实现了配置
    open override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    /// 布局子视图。创建对象顺序一定是先有 frame，再 awakeFromNib，再调整布局
    open override func layoutSubviews() {
        super.layoutSubviews()

        // 此处涉及到布局，因此必须放在 layoutSubviews() 中
        if isShowSeparatorAtFooter {
            // 解决 UITableView 有 footerView 时最后一个 Cell 不显示分割线问题
            for var separatorView in self.contentView.superview!.subviews {
                if NSStringFromClass(separatorView.classForCoder).hasSuffix("SeparatorView") {
                    separatorView.alpha = 1
                    separatorView.judy.x = separatorInset.left
                    let newWidth = frame.width - (separatorInset.left + separatorInset.right)
                    separatorView.frame.size = CGSize(width: newWidth, height: separatorView.frame.size.height)
                    
                }
            }
        }

    }
    
    // 如果布局更新挂起，则立即布局子视图
    open override func layoutIfNeeded() {
        super.layoutIfNeeded()
        // 设置正圆
        if masterImageView?.isRound ?? false {
            masterImageView?.judy.viewRound(
                border: masterImageView!.borderWidth,
                color: masterImageView!.borderColor)
        }        
    }
    
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


// MARK: - JudyInputCell

/// 包含一个输入框的 UITableViewCell，**在设置 json 之前请务必设置 indexPath**
/// # * 设置 json 键值对必选字段
/// # EMERANA.Key.Cell.title -> cell 最左边的 title，
/// # EMERANA.Key.Cell.placeholder -> 输入框的 placeholder,
/// # EMERANA.Key.Cell.value -> 输入框的值，
/// # EMERANA.Key.Cell.input -> 如果需要支持输入请将该值设为 true，否则该输入框将仅供展示
open class JudyInputCell: JudyBaseTableCell {
    
    /// 输入框，请确保该输入框的类型是 JudyCellTextField
    @IBOutlet weak public var inputTextField: JudyCellTextField?
    
    /// 对应 cell 中的 indexPath，请在设置 json 之前设置好该值
    public var indexPath: IndexPath! {
        didSet{ inputTextField?.indexPath = indexPath }
    }
}


/// 包含一个 indexPath 的 UITextField，该 UITextField 通常嵌于 TableViewCell 里，为此在里面指定一个 indexPath.
/// - Warning: 此类必须独立出来
final public class JudyCellTextField: JudyBaseTextField {
    /// 对应 cell 中的 indexPath.
    public var indexPath: IndexPath!
}
