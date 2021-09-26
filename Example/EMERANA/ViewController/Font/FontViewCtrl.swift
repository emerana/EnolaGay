//
//  FontViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/30.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

/// 字体对照界面
class FontViewCtrl: JudyBaseTableViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    
    /// 搜索条
    @IBOutlet weak var searchBar: UISearchBar?
    
    // MARK: - var property

    // MARK: - public var property - 公开var

    override var viewTitle: String? {
        return "iOS系统字体大全"
    }

    // MARK: - private var property - 私有var

    private var dataSourceIndex = [String]()
    /// 分区后的数据源
    private var newDataSource = [[JSON]]()
    
    /// 存储一下 footerView
    private var tableFooterView: UIView?
    
    
    // MARK: 搜索结果代理
    
    /// 搜索结果代理
    private let searchAgent = FontViewSearchAgent()
    
    
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.sectionIndexColor = .systemBlue
        tableView?.sectionIndexMinimumDisplayRowCount = 8
        
        // 获取字体数据源
        let familyNames = UIFont.familyNames
        familyNames.forEach { familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            fontNames.forEach { fontName in
                dataSource.append(JSON(fontName))
            }
        }
        dataSource.sort()   // 排序
        
        var temp = ""
        var tempDataSection = [JSON]()
        
        // 设置索引数据源
        dataSource.forEach { (json) in
            // 得到首字母
            let tempForList = (json.stringValue as NSString).substring(with: NSMakeRange(0, 1))
            
            if temp != tempForList { // 不同前缀
                temp = tempForList
                dataSourceIndex.append(temp)
                //  将上一个 tempDataSection 添加到 newDataSource 中
                if !tempDataSection.isEmpty {
                    newDataSource.append(tempDataSection)
                }
                tempDataSection = [JSON]()
                tempDataSection.append(json)
            } else {
                tempDataSection.append(json)
            }
        }
        newDataSource.append(tempDataSection)
        
        tableViewFooterLabel.text = "\(dataSource.count)种系统字体"
        tableViewFooterLabel.font = UIFont(size: 16)
        tableFooterView = view.viewWithTag(101)
        
        searchAgent.didSelectRow = { string in
            self.performSegue(withIdentifier: "showFontDetailViewCtrl", sender: string)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
//        enableCancel()

    }

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件

    // MARK: - Event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。


     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
        if segue.identifier == "showFontDetailViewCtrl" {
            let viewCtrl: FontDetailViewCtrl = segue.destination as! FontDetailViewCtrl
            viewCtrl.fontName = sender as! String
        }
     }
    
}


// MARK: - 本类方法
private extension FontViewCtrl {
    
    /// 保持取消按钮为可用状态
//    func enableCancel() {
//        let cancelButton = searchBar?.value(forKey: "cancelButton")
//        (cancelButton as? UIButton)?.isEnabled = true
////        Judy.log("取消按钮已改变")
//    }
    
    /// 设置新的代理
    /// - Parameter isSelf: 是否为本类？默认 false
    func setTableViewAgent(isSelf: Bool = false) {
        tableView?.dataSource = isSelf ? self:searchAgent
        tableView?.delegate = isSelf ? self:searchAgent
        if isSelf {
            tableView?.tableFooterView = tableFooterView
        } else {
            tableView?.tableFooterView = UIView()
        }
        
    }
    
    
}


// MARK: - UISearchBarDelegate

extension FontViewCtrl: UISearchBarDelegate {

    /// 搜索条内容改变事件
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        Judy.log("搜索框输入:\(searchBar.text)")
        if searchText == "" {
            setTableViewAgent(isSelf: true)
        } else {
            searchAgent.searchDataSource = dataSource.filter { (json) -> Bool in
                let range = (json.stringValue as NSString).range(of: searchText, options: [.caseInsensitive, .numeric])
                return range.length > 0
            }
            setTableViewAgent()
        }
        tableView?.reloadData()
    }
    
    /// 取消按钮点击事件，关闭键盘
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    /// 键盘搜索按钮点击事件，关闭键盘
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //  enableCancel()
    }
    
    /// searchBar 聚焦事件
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
        
    // 搜索框失去焦点事件
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        Judy.log("失去焦点")
    }

    
}


// MARK: - tableView dataSource
extension FontViewCtrl {
    
    // 建立索引
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSourceIndex
    }
    
    // 索引数据源与 section 数量需要保持一致
    func numberOfSections(in tableView: UITableView) -> Int {
        return newDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newDataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = newDataSource[indexPath.section][indexPath.row].stringValue
        cell.textLabel?.font = UIFont.init(name: newDataSource[indexPath.section][indexPath.row].stringValue, size: 18)

        return cell
    }
}


// MARK: - tableView delegate
extension FontViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        performSegue(withIdentifier: "showFontDetailViewCtrl", sender: newDataSource[indexPath.section][indexPath.row].stringValue)
    }
}
