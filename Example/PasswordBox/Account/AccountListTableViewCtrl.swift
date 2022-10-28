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
    
    /// 此属性用于标识当前数据源是否有组信息
    var groupInfo: Group?
    
    // MARK: - private var property
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar?.backgroundImage = UIImage()
        // 修改导航条上的标题
        if groupInfo?.name != nil {
            navigationItem.title = groupInfo?.name
        } else {
            navigationItem.title = "所有密码"
        }
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
        if let detailViewCtrl = segue.destination as? AccountDetailViewCtrl {
            if let cell = sender as? UITableViewCell, let indexPath = tableView?.indexPath(for: cell) {
                detailViewCtrl.account = accountList[indexPath.row]
            }
        }
        
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
        
    // MARK: scrollView DataSource
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // MARK: Judy-mark: 动态地隐藏/显示导航栏姿势
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -5 {  // 上拉
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 5 {    // 下拉
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
    }
}
