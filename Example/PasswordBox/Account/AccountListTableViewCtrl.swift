//
//  AccountListTableViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa

/// 密码列表界面
class AccountListTableViewCtrl: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "密码" }
    
    // MARK: - let property and IBOutlet
    
    /// 统计的 Label
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    
    /// 编辑组按钮
    @IBOutlet weak var editGroupBarButtonItem: UIBarButtonItem!
    
    /// section 的 headerView，内含 101 为 UISearchBar
    @IBOutlet var headerView: UITableViewHeaderFooterView!
    /// 搜索条
    private var searchBar: UISearchBar? {
        didSet {
            searchBar?.backgroundImage = UIImage()
        }
    }
    
    // MARK: - public var property
    
    /// 数据源，账号列表
    private(set) var accountList = [Account]()
    
    /// 此属性用于标识当前数据源是否有组信息
    var groupInfo: Group?
    
    // MARK: - private var property
    private let disposeBag = DisposeBag()

    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // 所在组名
        let groupName: Observable<Group?> = Observable.create { [weak self] observer -> Disposable in
            observer.onNext(self?.groupInfo)
            return Disposables.create()
        }
        // 绑定到导航条标题
        groupName.map { ($0?.name == nil) ? "所有密码":$0?.name }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        // 根据 group 信息设置数据源
        groupName.subscribe { [weak self] _ in
            guard let self = self else { return }
            
            // 根据组信息设置数据源
            if self.groupInfo != nil {
                self.accountList = DataBaseCtrl.judy.getGroupDataList(group: self.groupInfo!)
            } else {
                self.accountList = DataBaseCtrl.judy.getAccountList()
            }
        }.disposed(by: disposeBag)
        
        // 决定右上角按钮
        groupName.map { $0 != nil }
            .bind(to: editGroupBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView?.reloadData()
    }
        
    // MARK: - override
    
    // MARK: - event response
    
    // MARK: - Navigation
    
    /// AccountDetailViewCtrl 删除数据时发来的最终请求，要求更新已有数据源
    @IBAction func unwindToDeleteAccount(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! AccountDetailViewCtrl
        if sourceViewController.account?.id == accountList[sourceViewController.indexPath.row].id {
            accountList.remove(at: sourceViewController.indexPath.row)
            tableView?.reloadData()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let detailViewCtrl = segue.destination as? AccountDetailViewCtrl {
            if let cell = sender as? UITableViewCell, let indexPath = tableView?.indexPath(for: cell) {
                detailViewCtrl.account = accountList[indexPath.row]
                detailViewCtrl.indexPath = indexPath
                detailViewCtrl.updateAccountCallback = { [weak self] (account, indexPath) in
                    guard indexPath != nil else { return }
                    if account.id == self?.accountList[indexPath!.row].id {
                        self?.accountList[indexPath!.row] = account
                    }
                }
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
        cell.imageView?.image = ICON.judy.image(withName: account.remark?.icon ?? "",
                                                    iconBundle: .icons_password)
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
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        // MARK: Judy-mark: 动态地隐藏/显示导航栏姿势
//        let pan = scrollView.panGestureRecognizer
//        let velocity = pan.velocity(in: scrollView).y
//        if velocity < -5 {  // 上拉
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        } else if velocity > 5 {    // 下拉
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//        
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 44 }
    
    // viewForHeaderInSection
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        var headerView: UITableViewHeaderFooterView!
        
        //        headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "leftHeader")
//        headerView.backgroundView?.backgroundColor = .clear
        searchBar = headerView.viewWithTag(101) as? UISearchBar
        return headerView
    }
    
}
