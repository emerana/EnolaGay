//
//  AddNewGroupViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 添加分组界面
class AddNewGroupViewCtrl: JudyBaseCollectionViewCtrl {
    override var viewTitle: String? { "添加分组" }

    // MARK: - let property and IBOutlet
    
    /// 显示图标的按钮
    @IBOutlet weak private var iconButton: UIButton!
    /// 组名
    @IBOutlet weak private var groupNameTextField: JudyBaseTextField!
    
    
    // MARK: - public var property
    
    /// 用于构建新组的模型
    private(set) var group: Group?
    
    override var itemSpacing: CGFloat { 16 }

    // MARK: - private var property
    
    /// 记录当前选中的 indexPath，单选方案。
    private(set) var selectedIndexPath = IndexPath(item: 0, section: 0)

    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    // MARK: - override
    
    // MARK: - event response

    /// 添加事件
    @IBAction private func completeAction(_ sender: Any) {
        group = Group(id: 0, name: groupNameTextField.text!)
        
        // 触发 unwind 事件
        performSegue(withIdentifier: "completeAndDismissAction", sender: nil)
    }
    
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

private extension AddNewGroupViewCtrl {

}


// MARK: - UICollectionViewDataSource
extension AddNewGroupViewCtrl {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Group.backgroundColors.count
    }
    

     /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例。
     override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
         cell.backgroundColor = UIColor(rgbValue: Group.backgroundColors[indexPath.row])
         
         if selectedIndexPath == indexPath {
             cell.judy.viewBorder(border: 6, color: .white)
         } else {
             cell.judy.viewBorder(border: 0, color: nil)
         }
         
         return cell
     }

}


// MARK: - UICollectionViewDelegate
extension AddNewGroupViewCtrl {
    /// 选中事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        selectedIndexPath = indexPath

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AddNewGroupViewCtrl {
    /// 询问 cell 大小，在此函数中计算好对应的 size.
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let lineWidthOfCell = collectionView.frame.height
        return CGSize(width: lineWidthOfCell, height: lineWidthOfCell)
    }
    
}
