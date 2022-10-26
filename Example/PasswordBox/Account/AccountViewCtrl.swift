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
    override var viewTitle: String? { "账号" }
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
        
        // Do any additional setup after loading the view.
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        addButton.judy.viewShadow()

    }

    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
        
        // 获取分组数量
        groups = DataBaseCtrl.judy.getGroupList()

        let accountNum = DataBaseCtrl.judy.getAccountsCount()
        Judy.log("账号总数：\(accountNum)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }

    
    /// 添加按钮事件
    @IBAction func AddPasswordAction(_ sender: Any) {
        Judy.log("点击了添加")
        DataBaseCtrl.judy.getAccountList()
    }
    
    // MARK: - override

    // MARK: - event response

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - private methods

private extension AccountViewCtrl {

}

// MARK: - UICollectionViewDataSource
extension AccountViewCtrl {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! AccountCollectionCell
        
        if indexPath.row == 0 { // 所有账号
            cell.masterImageView?.image = UIImage(named: "placeholder")
            cell.backgroundColor = UIColor(rgbValue: 0xb3d465)
            cell.titleLabel?.text = "所有账号"
            cell.subTitleLabel?.text = String(DataBaseCtrl.judy.getAccountsCount())
        } else { // 具体分组
            cell.group = groups[indexPath.row - 1]
        }
        return cell
    }

}


// MARK: - UICollectionViewDelegate
extension AccountViewCtrl {
    /// 选中事件。
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
    

}
