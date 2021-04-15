//
//  TableViewCtrl.swift
//  与 UITableView 相关的文件
//
//  Created by 醉翁之意 on 2018/4/2.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

// MARK: - JudyBaseTableViewCtrl

import UIKit
import SwiftyJSON

/**
 *  该类包含一个 tableView，请将 tableView 与故事板关联
 *  * 该 tableView 已经实现 dataSource 和 delegate
 *  * 默认 tableViewCellidentitier 为 "Cell"
 */
open class JudyBaseTableViewCtrl: JudyBaseViewCtrl, EMERANA_CollectionBasic {
    
    
    // MARK: - let property and IBOutlet
    
    /// 视图中的主要 tableView，该 tableView 默认将 dataSource、dataSource 设置为 self
    @IBOutlet weak public var tableView: UITableView?
    
    // MARK: - var property
    
    /// 是否隐藏 tableFooterView，默认 false，将该值调为 true 即可隐藏多余的 cell
    @IBInspectable private(set) lazy public var isHideFooter: Bool = false

    lazy public var dataSource = [JSON]()
        
    
    // MARK: - Life Cycle
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
                
        guard tableView != nil else {
            Judy.log("🚔 tableView 没有关联 IBOutlet！")
            return
        }
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        registerReuseComponents()

        if isHideFooter { tableView?.tableFooterView = UIView() }
        
        // 滑动时关闭键盘
        tableView?.keyboardDismissMode = .onDrag
        
        
        // 配置 tableView 的背景色
        if #available(iOS 13.0, *) {
            if tableView?.backgroundColor == UIColor.systemBackground {
                tableView?.backgroundColor = .judy(.scrollView)
            }
        } else {
            if tableView?.backgroundColor == nil {
                tableView?.backgroundColor = .judy(.scrollView)
            }
        }

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
        
        // Judy-mark: 正确的活动隐藏显示导航栏姿势！
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -5 {  // 上拉
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 5 {    // 下拉
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        
        // MARK: Judy-mark:scrollView的代理方法，取消tableViewHeader悬停的办法 取消悬停
        let sectionHeaderHeight:CGFloat = 8   // 这里的高度一定要>=heightForHeaderInSection的高度
        if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
        
    }
    */
    
    
    /// 默认在父类里 deselectRow，实现此函数覆盖 super 即可
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
     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
     }
     */
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断 Cell 是否为 nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
        return cell
    }
    
}


// MARK: - JudyBaseTableRefreshViewCtrl


/// 在 JudyBaseTableViewCtrl 的基础上加上刷新控件，以支持分页加载数据
///
/// 需要重写 setSumPage() 函数以设置总页数
/// - warning: reqApi() 周期主要匹配分页加载功能，若存在多种用途请注意参考重写以下函数：
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
open class JudyBaseTableRefreshViewCtrl: JudyBaseTableViewCtrl, EMERANA_Refresh {
    
    open var pageSize: Int { 10 }

    open var defaultPageIndex: Int { 1 }

    final public var currentPage = 0 { didSet{ didSetCurrentPage() } }

    final lazy public var isAddMore = false


    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 要求重置刷新相关数据。
        resetCurrentStatusForReqApi()
        // 配置刷新控件。
        if !isNoHeader() {
            EMERANA.refreshAdapter?.initHeaderRefresh(scrollView: tableView, callback: {
                [weak self] in
                
                self?.refreshHeader()

                self?.isAddMore = false
                self?.currentPage = self!.defaultPageIndex
               
                EMERANA.refreshAdapter?.resetNoMoreData(scrollView: self?.tableView)
                
                self?.reqApi()
                
            })
        }
        if !isNoFooter() {
            
            EMERANA.refreshAdapter?.initFooterRefresh(scrollView: tableView, callback: {
                [weak self] in
                
                self?.refreshFooter()

                self?.isAddMore = true
                self?.currentPage += 1
                self?.reqApi()
            })
        }
    }

    public func setSumPage() -> Int {
        return 10
    }
    
    // MARK: Api相关


    /// 设置 api、param.
    ///
    /// 参考如下代码：
    ///```
    ///requestConfig.api = .???
    ///requestConfig.parameters?["userName"] = "Judy"
    ///```
    /// - Warning: 此函数中已经设置好 requestConfig.parameters?["page"] = currentPage，子类请 super
    open override func setApi() {
        requestConfig.parameters?[pageParameterString()] = currentPage
        requestConfig.parameters?[pageSizeParameterString()] = pageSize
    }
    
    open override func reqNotApi() {
        if isAddMore {
            // 如果是因为没有设置 api 导致请求结束需要将当前页减1
            currentPage -= 1
        }
        EMERANA.refreshAdapter?.endRefresh(scrollView: tableView)
    }
    
    /// 当服务器响应时首先执行此函数
    ///
    /// 此函数中会调用 endRefresh()，即结束 header、footer 的刷新状态。
    /// - warning: 此函数中影响上下拉状态，请确认正确条件下调用 super.reqResult()
    /// ```
    /// if  requestConfig.api?.value == ApiActions.Live.getAnchorLibraries.rawValue {
    ///     super.reqResult()
    /// }
    /// ```
    open override func reqResult() { EMERANA.refreshAdapter?.endRefresh(scrollView: tableView) }
    
    /// 请求成功的消息处理
    ///
    /// 此函数已经处理是否有更多数据，需自行根据服务器响应数据更改数据源及刷新 tableView
    /// - Warning: 此函数中影响设置总页数函数 setSumPage(), 无关的逻辑应该在此排除
    open override func reqSuccess() {
        // 设置总页数
        let sumPage = setSumPage()
        // 在此判断是否有更多数据。结束刷新已经在 reqResult() 中完成。
        if sumPage <= currentPage {    // 最后一页了，没有更多
            // 当没有更多数据的时候要将当前页设置为总页数或默认页数
            currentPage = sumPage <= defaultPageIndex ? defaultPageIndex:sumPage
            EMERANA.refreshAdapter?.endRefreshingWithNoMoreData(scrollView: tableView)
        }
    }
    
    /// 请求失败的消息处理。
    ///
    /// 重写此方法务必调用父类方法。
    /// - Warning:当 isAddMore = true (上拉刷新)时触发了此函数，此函数会将 currentPage - 1
    open override func reqFailed() {
        super.reqFailed()
        
        reqNotApi()
    }
            
}
