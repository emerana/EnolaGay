//
//  FundSearchViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/18.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 基金筛选界面
class FundSearchViewCtrl: JudyBaseSearchViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet weak var tableViewFooterLabel: JudyBaseLabel!

    // MARK: - public var property - 公开var

//    override var viewTitle: String? {
//        return "<#标题#>"
//    }

    // MARK: - private var property - 私有var
    private var fundDataSource = [Fund]() {
        didSet{
            tableView?.reloadData()
        }
    }
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        searchBar?.backgroundImage = UIImage()
        tableViewFooterLabel.font = UIFont(size: 16)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法
    
    override func registerReuseComponents() {
        // Judy-mark: 这样注册 cell 代替 Storyboard 里添加 cell
        let nib = UINib.init(nibName: "FundCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "FundCell")

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
        if segue.identifier == "showFundDetailViewCtrl" {
            let viewCtrl: FundDetailViewCtrl = segue.destination as! FundDetailViewCtrl
            viewCtrl.fund = sender as? Fund
        }
    }
    
}



// MARK: - tableView dataSource
extension FundSearchViewCtrl {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewFooterLabel.text = "共\(fundDataSource.count)只基金信息"

        return fundDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断 cell == nil
        let cell: FundCell = tableView.dequeueReusableCell(withIdentifier: "FundCell", for: indexPath) as! FundCell
        
        cell.setFund(fund: fundDataSource[indexPath.row])
        
        return cell
    }

}


// MARK: - tableView delegate
extension FundSearchViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        performSegue(withIdentifier: "showFundDetailViewCtrl", sender: fundDataSource[indexPath.row])
    }
    
}


// MARK: - searchbar delegate

extension FundSearchViewCtrl {
    
    // 取消按钮点击事件
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    /// 搜索条内容改变事件
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keywords = searchBar.text ?? ""
        
        if searchText == "" {
            fundDataSource.removeAll()
        } else {
            fundDataSource = FundDataSourceCtrl.judy.searchFundListBy(keywords: keywords, isAllColumn: true)
        }
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 设置是否动画效果的显示或隐藏取消按钮
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    // 搜索框失去焦点事件
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        Judy.log("失去焦点")
        //        searchBar.setShowsCancelButton(false, animated: true)
        
    }
    
}


// MARK: - 导航条代理

extension FundSearchViewCtrl: UINavigationControllerDelegate {

    //  Judy-mark: 隐藏当前界面的导航条
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isSelf = viewController .isKind(of: self.classForCoder)
        self.navigationController?.setNavigationBarHidden(isSelf, animated: true)
    }

}
