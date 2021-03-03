//
//  JudyBaseTableRefreshViewCtrl.swift
//  RunEn
//
//  Created by 醉翁之意 on 2018/4/28.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

import UIKit
import MJRefresh

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
/// - since: V1.1 2020年11月06日11:12:05
open class JudyBaseTableRefreshViewCtrl: JudyBaseTableViewCtrl, EMERANA_Refresh {
    
    // MARK: - let property and IBOutlet
    
    // MARK: - var property
    
    open var initialPage: Int { return 1 }
    
    final private(set) public var currentPage: Int = 0 { didSet{ didSetCurrentPage() } }

    final private(set) lazy public var isAddMore = false
    
    @IBInspectable private(set) lazy public var isNoHeader: Bool = false
    
    @IBInspectable private(set) lazy public var isNoFooter: Bool = false

    private(set) lazy public var mj_header: MJRefreshNormalHeader? = nil

    private(set) lazy public var mj_footer: MJRefreshBackNormalFooter? = nil

    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPage = initialPage
        initRefresh()
    }
    

    // MARK: - override - 重写重载父类的方法
    
    
    // MARK: Api相关


    /// 设置 api、param.
    ///
    /// 参考如下代码：
    ///```
    ///requestConfig.api = .???
    ///requestConfig.parameters?["userName"] = "Judy"
    ///```
    /// - warning: 此函数中已经设置好 requestConfig.parameters?["page"] = currentPage，子类请 super
    open override func setApi() { requestConfig.parameters?["page"] = currentPage }
    
    open override func reqNotApi() {
        if isAddMore {
            // 如果是因为没有设置 api 导致请求结束需要将当前页减1
            currentPage -= 1
        }
        endRefresh()
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
    open override func reqResult() { endRefresh() }
    
    /// 请求成功的消息处理
    ///
    /// 此函数已经处理是否有更多数据，需自行根据服务器响应数据更改数据源及刷新 tableView
    /// - version: 1.1
    /// - since: 2020年11月06日11:27:24
    /// - warning: 此函数中影响设置总页数函数 setSumPage(), 无关的逻辑应该在此排除
    open override func reqSuccess() {
        // 设置总页数
        let sumPage = setSumPage()
        // 在此判断是否有更多数据。结束刷新已经在 reqResult() 中完成。
        if sumPage <= currentPage {    // 最后一页了，没有更多
            // 当没有更多数据的时候要将当前页设置为总页数或默认页数
            currentPage = sumPage <= initialPage ? initialPage:sumPage
            // 当没有开启 mj_footer 时这里可能为nil
            tableView?.mj_footer?.endRefreshingWithNoMoreData()
        }
    }
    
    /// 请求失败的消息处理
    ///
    /// 重写此方法务必调用父类方法
    /// - warning:当 isAddMore = true (上拉刷新)时触发了此函数，此函数会将 currentPage - 1
    /// - since: V1.1 2020年11月06日13:23:36
    open override func reqFailed() {
        super.reqFailed()
        
        if isAddMore { currentPage -= 1 }
    }
    
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - private method - 私有方法的代码尽量抽取创建公共class。
    
    // 主要方法
    
    public final func initRefresh() {
        if !isNoHeader {
            mj_header = MJRefreshNormalHeader(refreshingBlock: {
                [weak self] in

                self?.refreshHeader()

                self?.isAddMore = false
                self?.currentPage = self!.initialPage
                self?.tableView?.mj_footer?.resetNoMoreData()
                self?.reqApi()
            })
            tableView?.mj_header = mj_header!
        }
        
        if !isNoFooter {
            mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
                [weak self] in

                guard self?.requestConfig.api != nil else {
                    self?.tableView?.mj_footer?.endRefreshingWithNoMoreData()
                    return
                }
                
                self?.refreshFooter()

                self?.isAddMore = true
                self?.currentPage += 1
                self?.reqApi()
            })
            mj_footer?.stateLabel?.isHidden = hideFooterStateLabel()
            tableView?.mj_footer = mj_footer!
        }
    }
    
    open func didSetCurrentPage() {}
    open func refreshHeader() {}
    open func refreshFooter() {}
    
    public final func endRefresh() {
        tableView?.mj_header?.endRefreshing()
        tableView?.mj_footer?.endRefreshing()
    }
    
    
    open func setSumPage() -> Int { return 1 }
    
    
    final public func resetCurrentStatusForReqApi() {
        currentPage = initialPage
        isAddMore = false
    }
    
}
