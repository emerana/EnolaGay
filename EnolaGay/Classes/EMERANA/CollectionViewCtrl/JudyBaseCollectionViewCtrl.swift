//
//  BaseCollectionViewCtrl.swift
//  RunEn
//
//  Created by 醉翁之意 on 2018/4/23.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 该类包含一个 collectionView，请将 collectionView 与故事板关联
/// * 该类已经实现了三个代理，UICollectionReusableView 在 dataSource 里
/// * delegateFlowLayout 里面定义了布局系统
/// * 默认 collectionViewCellidentitier 为 "Cell"
open class JudyBaseCollectionViewCtrl: JudyBaseViewCtrl, EMERANA_CollectionBasic {
    
    
    // MARK: - let property and IBOutlet
    
    /// 主要的 CollectionView,该 CollectionView 默认将 dataSource、dataSource 设置为 self
    @IBOutlet public weak var collectionView: UICollectionView?

    
    // MARK: - var property
    
    open lazy var dataSource = [JSON]()
    
    /// 同一 line 中 item（cell）之间的最小间隙
    open var itemSpacing: CGFloat { return 6 }

    
    // MARK: - Life Cycle
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard collectionView != nil else {
            Judy.log("🚔 collectionView 没有关联 IBOutlet！")
            return
        }

        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        registerReuseComponents()
        
        // 滑动时关闭键盘
        collectionView?.keyboardDismissMode = .onDrag

        // 配置 collectionView 的背景色
        if #available(iOS 13.0, *) {
            if collectionView?.backgroundColor == UIColor.systemBackground {
                collectionView?.backgroundColor = .judy(.scrollView)
            }
        } else {
            if collectionView?.backgroundColor == nil {
                collectionView?.backgroundColor = .judy(.scrollView)
            }
        }
        
    }
    
    open func registerReuseComponents() {
        /*
         // Judy-mark: 这样注册 cell 代替 Storyboard 里添加 cell
         let nib = UINib.init(nibName: "<#xibName#>", bundle: nil)
         tableView?.register(nib, forCellReuseIdentifier: "<#Cell#>")
         // 获取Cell
         let cell = tableView.dequeueReusableCell(withIdentifier: "<#Cell#>", for: indexPath)
         */
    }    

}


// MARK: - UICollectionViewDataSource
extension JudyBaseCollectionViewCtrl: UICollectionViewDataSource {
    
    // cell数量
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataSource.count
    }
    
    // section数量
    //    func numberOfSections(in collectionView: UICollectionView) -> Int{
    //        return 1
    //    }
    
    // MARK: Cell初始化
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        return cell
    }
    
    // 生成 HeaderView 和 FooterView
    /*
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     
     let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
     
     if kind == UICollectionElementKindSectionFooter {
     let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
     
     return footerView
     }
     
     
     return headerView
     }
     */

}


// MARK: - UICollectionViewDelegate
extension JudyBaseCollectionViewCtrl: UICollectionViewDelegate {
    
    // MARK: scrollView delegate
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Judy-mark: 正确的活动隐藏显示导航栏姿势！
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -5 {  // 上拉
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 5 {    // 下拉
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        // MARK: Judy-mark:scrollView的代理方法，取消tableViewHeader悬停的办法 取消悬停
        let sectionHeaderHeight:CGFloat = 8   // 这里的高度一定要>=heightForHeaderInSection的高度
        if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsets.init(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsets.init(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
        
    }
    */
    
    
    // MARK: collectionView delegate
    
    
    // 选中事件
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("点击-\(indexPath)")
    }
    
    // Judy-mark: 完美解决 collectionView 滚动条被 Header 遮挡问题
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension JudyBaseCollectionViewCtrl: UICollectionViewDelegateFlowLayout {
        
    // 设置headerView的Size。一般用不上这个方法，在生成HeaderView中就可以设置高度或者在xib中设置高度即可。
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     
     // 这里设置宽度不起作用
     return CGSize.init(width: 0, height: <#58#>)
     }
     
     */
    
    // cell大小
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        var widthForCell: CGFloat = collectionView.frame.width
        let heightForCell: CGFloat = 88
        // 在同一个 Line 中需要显示的 Cell 数量
        let numForCellInRow: CGFloat = 3
        
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 CollectionView 的 Estimate Size，将其设置为 None.
        widthForCell = (widthForCell + itemSpacing)/numForCellInRow - itemSpacing
        if let cellHeight = dataSource[indexPath.section][EMERANA.Key.Cell.height].float {
            return CGSize(width: widthForCell, height: CGFloat(cellHeight))
        }
        
        return CGSize(width: widthForCell, height: heightForCell)
    }

    /* 针对 Section 进行偏移。可直接在 Storyboard 中设置，必要的情况下重写此函数即可。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    */
    
    
    // 一个 section 中连续的行或列之间的最小间距，默认为0。实际值可能大于该值，但不会比其小。
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return itemSpacing
    }
    
    // 同一行中连续的 Cell 间的最小间距，该间距决定了一行内有多少个 Cell，Cell 数量确定后，实际的间距可能会比该值大。
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return itemSpacing
    }

}

