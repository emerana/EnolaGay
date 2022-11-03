//
//  ChooseGroupTableViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/11/3.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 修改分组列表界面
class ChooseGroupTableViewCtrl: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "修改分组" }
    
    // MARK: - let property and IBOutlet
    
    // MARK: - public var property

    // MARK: - private var property
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: - 从数据库中获取组列表

        setDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    // MARK: - override
    
    // MARK: - event response
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }

}


// MARK: - private methods
private extension ChooseGroupTableViewCtrl {
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
extension ChooseGroupTableViewCtrl {
    /// 询问指定 indexPath 的 Cell 实例
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
extension ChooseGroupTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
    }

}
