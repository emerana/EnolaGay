//
//  AccountListTableViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 密码列表界面
class AccountListTableViewCtrl: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "密码" }
    
    // MARK: - let property and IBOutlet
    
    /// 统计的 Label
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    /// 搜索条
    @IBOutlet weak var searchBar: UISearchBar?

    // MARK: - public var property
    
    /// 数据源，账号列表
    var accountList = [Account]()
    
    // MARK: - private var property
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar?.backgroundImage = UIImage()

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
private extension AccountListTableViewCtrl {
    
}


// MARK: - tableView dataSource
extension AccountListTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewFooterLabel.text = "共\(accountList.count)条记录"
       return accountList.count
    }
    
    /// 询问指定 indexPath 的 Cell 实例
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let account = accountList[indexPath.row]

        cell.textLabel?.text = account.name
        cell.detailTextLabel?.text = account.password
        cell.imageView?.image = UIImage(imageLiteralResourceName: "placeholder")
        //  if dataSource[indexPath.row]["subtitle"] == nil {
        //
        //      cell.accessoryType = .disclosureIndicator
        //  } else {
        //      cell.detailTextLabel?.text = dataSource[indexPath.row]["subtitle"].stringValue
        //      cell.accessoryType = .none
        //  }

        // cell.masterImageView?.image

        return cell
    }

}


// MARK: - tableView delegate
extension AccountListTableViewCtrl {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
    }

}
