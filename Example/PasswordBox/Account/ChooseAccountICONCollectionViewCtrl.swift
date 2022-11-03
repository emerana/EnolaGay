//
//  ChooseAccountICONCollectionViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/11/3.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa

/// 选择账号图标界面
class ChooseAccountICONCollectionViewCtrl: JudyBaseCollectionViewCtrl {
    override var viewTitle: String? { "选择图标" }
    
    // MARK: - let property and IBOutlet
    
    @IBOutlet weak var confirmButtonItem: UIBarButtonItem!
    // MARK: - public var property
    
    override var itemSpacing: CGFloat { 8 }
    
    // MARK: - private var property
    
    /// 清除包。订阅管理机制，当清除包被释放的时候，清除包内部所有可被清除的资源（Disposable）都将被清除
    private let disposeBag = DisposeBag()

    var iconNameList: [String] {
        return ICON.judy.names(iconBundle: .icons_password)
    }
    private(set) var iconSelectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: itemSpacing,
                                                    bottom: 0, right: itemSpacing)
        
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

// MARK: - Private Methods
private extension ChooseAccountICONCollectionViewCtrl {
    
}

// MARK: - UICollectionViewDataSource
extension ChooseAccountICONCollectionViewCtrl {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return iconNameList.count
    }
    
     /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例。

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        (cell.viewWithTag(101) as? UIImageView)?.image =
        ICON.judy.image(withName: iconNameList[indexPath.row],
                        iconBundle: .icons_password)
        
        if iconSelectedIndexPath == indexPath {
            cell.judy.viewBorder(border: 2, color: .purple)
        } else {
            cell.judy.viewBorder(border: 0, color: nil)
        }

        return cell
    }

}


// MARK: - UICollectionViewDelegate
extension ChooseAccountICONCollectionViewCtrl {
    /// 选中事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("选中\(indexPath)")
        
        iconSelectedIndexPath = indexPath
        
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChooseAccountICONCollectionViewCtrl {
    /// 询问 cell 大小，在此函数中计算好对应的 size.
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// 在一个 line 中需要显示的 cell 数量
        let countOfCells: CGFloat = 3
        /// cell 参与计算的边长，初值为 line 的长度（包含间距）
        /// 
        /// 一个 line 中需要显示的所有 cell. 宽度（或高度）及他们之间所有间距的总和，以此来确定单个 cell 的边长
        /// - Warning: 请注意在此处减去不参与计算 cell 边长的部分，比如 collectionView.contentInset 的两边
        var lineWidthOfCell = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 collectionView 的 Estimate Size，将其设置为 None.
        lineWidthOfCell = (lineWidthOfCell + itemSpacing)/countOfCells - itemSpacing
        
        return CGSize(width: lineWidthOfCell, height: lineWidthOfCell)
    }
    
}
