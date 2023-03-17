//
//  TestTableViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/13.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import MJRefresh

/// 所有基金信息界面
class FundViewController: JudyBaseTableRefreshViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet

    @IBOutlet weak var tableViewFooterLabel: JudyBaseLabel!
    /// 搜索条
    //    @IBOutlet weak var searchBar: UISearchBar?

    // MARK: - public var property - 公开var
    
    // MARK: - private var property - 私有var
    
    /// 所有基金信息数据源
    private var fundList = [Fund]()
    
    private var tableDataSource = [Fund]() {
        didSet{
            tableView?.reloadData()
        }
    }

    // MARK: - Life Cycle - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let header = tableView?.mj_header as! MJRefreshNormalHeader
        header.setTitle("下拉重新载入数据", for: .idle)
        header.setTitle("松开以重新加载", for: .pulling)
        header.setTitle("正在重新读取数据...", for: .refreshing)
        
        tableViewFooterLabel.font = UIFont(size: 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法
    
    func setApi() {
        if tableDataSource.count != fundList.count {
            return
        }
        // 重新读取数据库，并重载tableView
        fundList = FundDataSourceCtrl.judy.getFundList()
        tableDataSource = fundList

    }

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
            viewCtrl.deleteCallback = setApi
        }
        
    }
    
}


// MARK: - tableView dataSource
extension FundViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewFooterLabel.text = "共\(tableDataSource.count)只基金信息"

        return tableDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断 cell == nil
        let cell: FundCell = tableView.dequeueReusableCell(withIdentifier: "FundCell", for: indexPath) as! FundCell
        
        cell.setFund(fund: tableDataSource[indexPath.row])
        
        return cell
    }

}


// MARK: - tableView delegate
extension FundViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        performSegue(withIdentifier: "showFundDetailViewCtrl", sender: tableDataSource[indexPath.row])
    }
}

extension FundViewController {
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // Judy-mark: 判断是否滚动到最后一行
//        guard scrollView.contentSize.height > scrollView.frame.size.height else {
//            return
//        }
//
//        let minY = scrollView.contentSize.height - scrollView.frame.size.height
//        let contentOffsetY = scrollView.contentOffset.y
//        
//        if contentOffsetY >= minY {
//            print("到底了")
//        }
//    }
    
}

// MARK: - 私有函数

private extension FundViewController {
    
    /// 从plist文件获取基金信息
    func readFundInfoFromPlist() -> [Fund] {
        var funds = [Fund]()
        let fileContent = JudyFile.judy.readPlist(fileName: "Fund")
        
        for fundDictionary in fileContent {
            let fundDic: [String: Any] = fundDictionary as! [String: Any]
            var fund = Fund(fundID: fundDic["fundID"] as! String,
                            fundName: fundDic["fundName"] as! String,
                            fundStarRating: fundDic["fundStarRating"] as! Int,
                            fundRating: Float(fundDic["fundRating"] as! Double),
                            isStarManager: fundDic["isStarManager"] as! Bool,
                            institutionalView: .无,
                            institutionalPotential: .无,
                            institutionalFeatured: .无,
                            fundType: .股票型)
            
            switch fundDic["institutionalView"] as! String {
            case "乐观":
                fund.institutionalView = .乐观
            case "中立":
                fund.institutionalView = .中立
            case "谨慎":
                fund.institutionalView = .谨慎
            default:
                fund.institutionalView = .无
            }
            
            switch fundDic["institutionalPotential"] as! String {
                case "低估值":
                    fund.institutionalPotential = .低估值
                case "中估值":
                    fund.institutionalPotential = .中估值
                case "高估值":
                    fund.institutionalPotential = .高估值
                default:
                    fund.institutionalPotential = .无
            }
            
            switch fundDic["institutionalFeatured"] as! String {
            case "精选":
                fund.institutionalFeatured = .精选
            case "好基推荐":
                fund.institutionalFeatured = .好基推荐
            default:
                fund.institutionalFeatured = .无
            }
            
            switch fundDic["fundType"] as! String {
                case "指数型":
                    fund.fundType = .指数型
                case "股票型":
                    fund.fundType = .股票型
                default:
                    fund.fundType = .混合型
            }
            
            funds.append(fund)
        }
        return funds
    }
    
}

// MARK: - UISearchBarDelegate

extension FundViewController: UISearchBarDelegate {

    /// 搜索条内容改变事件
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keywords = searchBar.text ?? ""
        //        Judy.log("搜索框输入:\(searchBar.text)")
        if searchText == "" {
            tableDataSource = fundList
        } else {
            tableDataSource = FundDataSourceCtrl.judy.searchFundListBy(keywords: keywords)
        }
    }
    
    /// 取消按钮点击事件，关闭键盘
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    /// 键盘搜索按钮点击事件，关闭键盘
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    /// searchBar 聚焦事件
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        navigationController?.setNavigationBarHidden(false, animated: true)
        return true
    }
         
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 设置是否动画效果的显示或隐藏取消按钮
        searchBar.setShowsCancelButton(true, animated: true)

    }
    
    // 搜索框失去焦点事件
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        Judy.log("失去焦点")
//        moveNavigationBar()
        searchBar.setShowsCancelButton(false, animated: true)

    }
    
}
