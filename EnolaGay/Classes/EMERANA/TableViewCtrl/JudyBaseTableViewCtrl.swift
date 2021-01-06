//
//  BaseTableViewCtrl.swift
//  基本的tableViewCtrl
//
//  Created by 醉翁之意 on 2018/4/2.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

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

