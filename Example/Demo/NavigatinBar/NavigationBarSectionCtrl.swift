//
//  NavigationBarSectionCtrl.swift
//  Demo
//
//  Created by EnolaGay on 2023/8/10.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import IGListKit
import EnolaGay

/// section 控制器
class NavigationBarSectionCtrl: ListSectionController {

    var entry: NavigationBarDataSourceLoader.Model!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        supplementaryViewSource = self
        scrollDelegate = self
        
    }
    
    override func numberOfItems() -> Int { 3 }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        // 固定宽度，自动高度，切记 label 的 line 一定要设为 zero.
        return CGSize(width: context.containerSize.width, height: .zero)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: "Cell", for: self, at: index)

        let label = cell.viewWithTag(101) as! UILabel
        switch index {
        case 1:
            label.text = entry.msg
            cell.backgroundColor = .blue
        case 2:
            label.text = entry.user
            cell.backgroundColor = .gray
        default:
            label.text = entry.date
            cell.backgroundColor = .red
        }
        label.font = UIFont(name: "OCRAStd", size: 16)
        
        // 由于先设置的 sizeForItem，后赋值，所以赋值后需要调用 layoutIfNeeded() 更新布局。
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        entry = object as? NavigationBarDataSourceLoader.Model
    }
    
    override func didSelectItem(at index: Int) {
        log("点击了\(index)")
    }

}

extension NavigationBarSectionCtrl: ListSupplementaryViewSource {
    
    func supportedElementKinds() -> [String] { [UICollectionView.elementKindSectionHeader] }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        
        return collectionContext!.dequeueReusableSupplementaryView(fromStoryboardOfKind: UICollectionView.elementKindSectionHeader, withIdentifier: "Header", for: self, at: index)
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: .zero, height: 28)
    }
    
}

extension NavigationBarSectionCtrl: ListScrollDelegate {
    
    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willBeginDragging sectionController: ListSectionController) {
        
    }
    
    
    //    func listAdapter(_ listAdapter: ListAdapter, didScroll sectionController: ListSectionController) {
    //        log("滚动：\(listAdapter.collectionView?.contentOffset.y)")
    //        listAdapter.collectionView?.contentInset =
    //        UIEdgeInsets(top: -128, left: 0, bottom: 0, right: 0)
    //    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDragging sectionController: ListSectionController, willDecelerate decelerate: Bool) {
        
    }
    
}
