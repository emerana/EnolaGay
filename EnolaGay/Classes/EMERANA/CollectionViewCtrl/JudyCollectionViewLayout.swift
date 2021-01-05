//
//  JudyCollectionViewLayout.swift
//  emerana
//
//  Created by 醉翁之意 on 2020/8/6.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
 
public extension UICollectionViewLayoutAttributes {
    
    func leftAlignFrameWithSectionInset(sectionInset: UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }

}


/// UICollectionViewFlowLayout 自定义版
class JudyCollectionViewLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        // 设置一个非0的 size 以自动计算 Cell 大小
        estimatedItemSize = CGSize(width: 100, height: 28)

    }

    /*
     返回 UICollectionViewLayoutAttributes 类型的数组，UICollectionViewLayoutAttributes 对象包含 cell 或 view 的布局信息。
     子类必须重载该方法，并返回该区域内所有元素的布局信息，包括 cell,追加视图和装饰视图。
     */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let originalAttributes = super.layoutAttributesForElements(in: rect)!
        var updatedAttributes: [UICollectionViewLayoutAttributes]? = originalAttributes
        
        for attributes in originalAttributes {
            if attributes.representedElementKind == nil {
                let index = updatedAttributes!.firstIndex(of: attributes)!
                updatedAttributes?[index] = layoutAttributesForItem(at: attributes.indexPath)!
            }
        }
        
        return updatedAttributes
    }
    
    /*
     返回指定 indexPath 的 item 的布局信息。子类必须重载该方法,该方法只能为 cell 提供布局信息，不能为补充视图和装饰视图提供。
     */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
                
        let currentItemAttributes: UICollectionViewLayoutAttributes = super.layoutAttributesForItem(at: indexPath)!
        
        let sectionInset = evaluatedSectionInsetForItemAtIndex(index: indexPath.section)
        
        let isFirstItemInSection = indexPath.item == 0
        let layoutWidth: CGFloat = (collectionView?.frame.width)! - sectionInset.left - sectionInset.right
        // 如果是第一个
        if isFirstItemInSection {
            currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset: sectionInset)
            return currentItemAttributes
        }

        let previousIndexPath = IndexPath(item: indexPath.item-1, section: indexPath.section)
        
        let previousFrame: CGRect = layoutAttributesForItem(at: previousIndexPath)!.frame
        
        let previousFrameRightPoint: CGFloat = previousFrame.origin.x + previousFrame.size.width
        let currentFrame: CGRect = currentItemAttributes.frame
        
        let strecthedCurrentFrame: CGRect = CGRect(x: sectionInset.left,
                                                   y: currentFrame.origin.y,
                                                   width: layoutWidth,
                                                   height: currentFrame.size.height)
        
        // if the current frame, once left aligned to the left and stretched to the full collection view
        // width intersects the previous frame then they are on the same line
        let isFirstItemInRow = !previousFrame.intersects(strecthedCurrentFrame)

        if isFirstItemInRow {
            // 确保一行中的第一项左对齐
            currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset: sectionInset)
            return currentItemAttributes
        }

        var frame: CGRect = currentItemAttributes.frame
        frame.origin.x = previousFrameRightPoint + evaluatedMinimumInteritemSpacingForSectionAtIndex(sectionIndex: indexPath.section)
        
        currentItemAttributes.frame = frame
        
        return currentItemAttributes
    }
        
}

private extension JudyCollectionViewLayout {
    
    /// 计算 Cell 间最小项间距
    func evaluatedMinimumInteritemSpacingForSectionAtIndex(sectionIndex: NSInteger) -> CGFloat {

        if collectionView?.delegate?.responds(to: #selector((collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) ?? false {
            let itemSpacing = (collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView!(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: sectionIndex)
            
            return itemSpacing
        } else {
            return minimumInteritemSpacing
        }
    }
    
    /// 计算 Section 的 UIEdgeInsets
    func evaluatedSectionInsetForItemAtIndex(index: NSInteger) -> UIEdgeInsets {
        
        if collectionView?.delegate?.responds(to: #selector((collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView(_:layout:insetForSectionAt:))) ?? false {
            let edgeInsets = (collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView!(collectionView!, layout: self, insetForSectionAt: index)
            
            return edgeInsets
        } else {
            return sectionInset
        }
    }
    
    
}
