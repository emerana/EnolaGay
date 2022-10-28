//
//  AccountViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 账号界面
class AccountViewCtrl: JudyBaseCollectionRefreshViewCtrl {
    override var viewTitle: String? { "分组浏览" }
    override var itemSpacing: CGFloat { return 28 }

    // MARK: - let property and IBOutlet
    
    /// “添加账号”按钮
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - public var property
    
    /// 分组数量
    var groups = [Group]()
    
    // MARK: - private var property
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = nil
        // Do any additional setup after loading the view.
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        addButton.judy.viewShadow()

        // 注册 footerView
        let addGroupNib = UINib(nibName: "AddNewGropuUICollectionReusableView", bundle: nil)
        collectionView?.register(addGroupNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "AddGroupButtonFooterView")

    }

    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadData()
    }

    // MARK: - override

    // MARK: - event response
    
    /// 添加按钮事件
    @IBAction func AddPasswordAction(_ sender: Any) {
        Judy.log("点击了添加")
    }
        
    /// AddNewAccountViewCtrl 释放时发来的最终请求，要求添加一条 Account 数据
    @IBAction func unwindToAddNewAccountViewCtrl(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! AddNewAccountViewCtrl
        if let account = sourceViewController.addAccount {
            // 添加账号到数据库
            DataBaseCtrl.judy.addNewData(model: account) { rs in }
            // DataBaseCtrl.judy.addNewAccount(account: account) { rs in }

            // 不管添加的结果，直接更新
            reloadData()
        }
        
    }
    
    /// AddNewGroupViewCtrl 释放时发来的最终请求，要求添加一条 Group 数据
    @IBAction func unwindToAddNewGroupViewCtrl(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! AddNewGroupViewCtrl
        if let group = sourceViewController.group {
            // 添加组到数据库
            DataBaseCtrl.judy.addNewData(model: group) { rs in }
            // 不管添加的结果，直接更新
            reloadData()
        }
    }


    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         if let accountListTableViewCtrl = segue.destination as? AccountListTableViewCtrl {
             let cell: AccountCollectionCell = sender as! AccountCollectionCell
             accountListTableViewCtrl.groupInfo = cell.group

             let accountList: [Account]
             if cell.group == nil { // 所有密码
                 accountList = DataBaseCtrl.judy.getAccountList()
             } else { // 具体组下的密码
                 accountList = DataBaseCtrl.judy.getGroupDataList(group: cell.group!)
             }
             accountListTableViewCtrl.accountList = accountList
         }
     }
    
}


// MARK: - private methods

private extension AccountViewCtrl {
    
    /// 载入数据并显示
    func reloadData() {
        // 获取分组数量
        groups = DataBaseCtrl.judy.getGroupList()
        collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension AccountViewCtrl {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! AccountCollectionCell
        
        if indexPath.row == 0 { // 所有账号
            cell.group = nil
            cell.masterImageView?.image = UIImage(named: "placeholder")
            cell.backgroundColor = UIColor.浅蓝紫
            cell.titleLabel?.text = "所有密码"
            cell.subTitleLabel?.text = String(DataBaseCtrl.judy.getAccountsCount())
        } else { // 具体分组
            cell.group = groups[indexPath.row - 1]
        }
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let supplementView: AddNewGropuUICollectionReusableView = collectionView.dequeueReusableSupplementaryView (
            ofKind:  UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "AddGroupButtonFooterView",
            for: indexPath) as! AddNewGropuUICollectionReusableView
        
        supplementView.addGroupClosure = { [weak self] in
            /// 添加新分组事件
            Judy.logHappy("点击了添加新分组")
            self?.performSegue(withIdentifier: "showAddNewGroupViewCtrl", sender: nil)
        }
        
        return supplementView
    }
    
}


// MARK: - UICollectionViewDelegate
extension AccountViewCtrl {
    /// 选中事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("选中\(indexPath)")
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension AccountViewCtrl {
    
    /// 询问 Cell 大小，在此函数中计算好对应的 size.
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        /// 在一个 Line 中需要显示的 Cell 数量。
        let cellCount: CGFloat = 2
        /// Line 的长度（包含间距），请注意在此处减去该不属于 Collection 部分。
        let lineWidth: CGFloat = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        /// Cell 边长。
        let cellWidth: CGFloat = (lineWidth - itemSpacing * (cellCount - 1))/cellCount
                
        return CGSize(width: cellWidth, height: cellWidth*9/7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return CGSize(width: 0, height: 68)
    }
    
}


/// 添加分组按钮专用 elementKindSectionFooter.
class AddNewGropuUICollectionReusableView: UICollectionReusableView {
    /// 点击添加组回调
    var addGroupClosure: Closure?
    
    @IBAction private func addGroupAction(_ sender: Any) {
        addGroupClosure?()
    }
    
}
