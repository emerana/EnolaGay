//
//  FundOptionViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/23.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 自选基金表
class FundOptionViewCtrl: JudyBaseTableRefreshViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet

    // MARK: - public var property - 公开var

    // MARK: - private var property - 私有var
    
    /// 本类数据源
    private var fundList = [Fund]()

    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法
    func setApi() {
        // 重新读取数据库，并重载tableView
        fundList = FundDataSourceCtrl.judy.getOptionList()
        tableView?.reloadData()
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
            viewCtrl.deleteOptionCallback = ({
//                self.reqApi()
            })
        }
    }
    
}


// MARK: tableView dataSource
extension FundOptionViewCtrl {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (view.viewWithTag(1001) as? JudyBaseLabel)?.text = "\(fundList.count)只自选基金"
        return fundList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断 cell == nil
        let cell: FundCell = tableView.dequeueReusableCell(withIdentifier: "FundCell", for: indexPath) as! FundCell
        
        cell.setFund(fund: fundList[indexPath.row])
        
        return cell
    }
}

// MARK: tableView delegate
extension FundOptionViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        performSegue(withIdentifier: "showFundDetailViewCtrl", sender: fundList[indexPath.row])
    }

}
