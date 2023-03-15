//
//  JudyBaseSearchViewCtrl.swift
//  ScientificAuxiliary
//
//  Created by 醉翁之意 on 2018/5/22.
//  Copyright © 2018年 吾诺瀚卓.王仁洁. All rights reserved.
//

import UIKit

/**
 通用搜索界面，已将 searchBar?.delegate = self。需设置 dataSource，且将 searchDataSource = dataSource 内容查看效果
 ## 重写 searchBarSearchButtonClicked 代理以执行搜索按钮点击事件
 - 已禁用下拉刷新
 - 请自行配置好 searchBar
 - 请自行实现代理 textDidChange searchText
 - 已配置一个默认的 searchDataSource
 */
open class JudyBaseSearchViewCtrl: JudyBaseTableRefreshViewCtrl {
    
    // MARK: - let property and IBOutlet
    
    /// 搜索条
    @IBOutlet weak public var searchBar: UISearchBar?
    
    // MARK: - var property
    
    /// 禁用下拉刷新
    // open override var isNoHeader: Bool { true }
    
    /// 搜索图标，重写此属性以设置searchBar上面的搜索图标，如果为nil则显示系统默认的图标
    @IBInspectable lazy public var searchIcon: UIImage? = nil

    /// 输入框的光标和输入的文本颜色，默认 Licorice
    @IBInspectable public var textFieldTintColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    /// 输入框的背景色，默认为 AppStore 搜索界面一样的颜色
    @IBInspectable public var textFieldBackgroundColor: UIColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)

    /// 搜索结果数据源，当 searchDataSource 发生改变时会 reload tableView.
//    public var searchDataSource = [JSON](){
//        didSet{
//            tableView?.reloadData()
//        }
//    }
    
    // MARK: navigationItem 上搜索框相关属性

    /// 显示导航条上的搜索框，需要自行实例化，且自行设定宽度和高度。默认是nil。实例化代码参考如下：
    /// ```
    /// searchView = JudySearchView.judy(type: JudySearchView.searchViewType.button)
    /// searchView.searchButton?.setImage(UIImage(name: "abc"), for: .normal)
    /// ```
    public var searchView: JudySearchView? = nil {
        didSet{
            if searchView != nil {
                navigationItem.titleView = searchView
            }
        }
    }

    /**
     设置 searchView 的 x 锚点。默认为0.5，值介于1~0之间，越大视图越往左移。
     # 锚点与X起点关系：设本视图的x为X，本视图X的锚点为Y，则：
     - X = 父视图宽度 * 父视图锚点 - 本视图宽度 * Y
     - Y = (父视图宽度 * 父视图锚点 - X )/本视图宽度
     ```
     anchorPointX = 0.45，// 搜索视图会向右偏移
     ```
     */
    public var searchViewAnchorPointX = 0.5 {
        didSet{
            searchView?.layer.anchorPoint =  CGPoint(x: searchViewAnchorPointX, y: 0.5)
        }
    }

    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar?.delegate = self
        
        // 设置取消按钮文字只需要将 info.plist 中 Localization native development region 改为 China 就会变成中文的取消
        
        // 应用于搜索栏中的关键元素的颜色。这里主要是光标和取消按钮的颜色
        //        searchBar?.tintColor = .red

        // Judy-mark: 在 Storyboard 中 searchBar.View.background 为背景色，searchBar.view.tint 为光标和取消按钮的颜色
        
        // 设置搜索图标
        if searchIcon != nil {
            searchBar?.setImage(searchIcon, for: .search, state: .normal)
        }
                
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard searchBar != nil else {
            return
        }
        //  修改 searchBar 输入框颜色信息
        for subView in searchBar!.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.font = UIFont(size: 16)
                    // 输入框的背景色
                    textField.backgroundColor = textFieldBackgroundColor
                    // 输入的文本颜色
                    textField.textColor = textFieldTintColor
                    // 光标颜色，如果不设置将会同取消按钮保持一致
                    //                    textField.tintColor = .red
                    
                    return
                }
            }
        }
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar?.becomeFirstResponder()

    }
        
    // MARK: - override - 重写重载父类的方法
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        enableCancel()

    }
    
    // MARK: - Target Methods - 点击事件或通知事件

    @available(*, unavailable, message: "该方法已废弃")
    func cancelAction() { }

    // MARK: - Intial Methods - 初始化的方法
    
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: dataSource
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchDataSource.isEmpty {
            return dataSource.count
        }
        return searchDataSource.count
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - UISearchBarDelegate
extension JudyBaseSearchViewCtrl: UISearchBarDelegate {
    
    // MARK: searchBar delegate
    
    /// 搜索条内容改变事件
    /*
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     Judy.log(searchText)
     if searchText == "" {
     searchDataSource = dataSource
     } else {
     searchDataSource.removeAll()
     searchDataSource.append(JSON(["name": "newJudy"]))
     }
     tableView?.reloadData()
     }
     */
    
    /// 取消按钮点击事件，关闭键盘且dismiss
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
        
//        dismiss(animated: true, completion: nil)
    }
    
    /// 键盘搜索按钮点击事件，关闭键盘
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        enableCancel()
    }
    
    /// searchBar聚焦事件
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {

        return true
    }

}

// MARK: - 本类方法
public extension JudyBaseSearchViewCtrl {
    
    /// 该函数将取消按钮设为可用状态
    final func enableCancel() {
        let cancelButton = searchBar?.value(forKey: "cancelButton")
        (cancelButton as? UIButton)?.isEnabled = true
        //        Judy.log("取消按钮已改变")
    }
    
}
