//
//  TestTableRefreshTableViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/4/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class TestTableRefreshTableViewCtrl: JudyBaseTableRefreshViewCtrl {
    
    override var viewTitle: String? { return "上下拉刷新测试" }
    override var defaultPageIndex: Int {0}
    
    override var pageIndexParameter: String { "JUDY" }
    override var pageSizeParameter: String { "EMERANA" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSource()
        
    }
    
    
    // MARK: - override
    
    // MARK: Api 相关
    
    override func setApi() {
        super.setApi()
        
        requestConfig.api = Actions.createUserChatToken
        requestConfig.parameters?["userid"] = 323430

    }
    
    override func reqSuccess() {
        super.reqSuccess()
        
        Judy.log("请求成功-\(apiData)")
        /*
         if isAddMore {
         dataSource += apiData["data", "<#rows#>"].arrayValue
         } else {
         dataSource = apiData["data", "<#rows#>"].arrayValue
         }
         tableView?.reloadSections(IndexSet(integer: <#0#>), with: .fade)
         或
         tableView?.reloadData()
         
         */
    }

    
    // MARK: - event response

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }

}


// MARK: - private methods
private extension TestTableRefreshTableViewCtrl {
    
    /// 设置 JSON 数据源
    func setDataSource() {
        
        dataSource = [
            [
                EMERANA.Key.title: "模拟数据",
                EMERANA.Key.segue: "模拟数据",
            ],
            [EMERANA.Key.title: "模拟数据", ],
            [EMERANA.Key.title: "模拟数据", ],
        ]
    }
    
}


// MARK: - tableView dataSource
extension TestTableRefreshTableViewCtrl {


    /// 初始化 Cell，此处 Cell 默认的 identifier = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) // as! JudyBaseTableCell

        //  cell.json = dataSource[indexPath.row]
        //  cell.textLabel?.text = dataSource[indexPath.row]["title"].stringValue
        //  if dataSource[indexPath.row]["subtitle"] == nil {
        //      cell.detailTextLabel?.text = nil
        //      cell.accessoryType = .disclosureIndicator
        //  } else {
        //      cell.detailTextLabel?.text = dataSource[indexPath.row]["subtitle"].stringValue
        //      cell.accessoryType = .none
        //  }
        
        return cell
    }



}


// MARK: - tableView delegate
extension TestTableRefreshTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
    }

}
