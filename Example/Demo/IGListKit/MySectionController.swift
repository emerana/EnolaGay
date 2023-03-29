//
//  SectionController.swift
//  emerana
//
//  Created by 王仁洁 on 2019/12/19.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import IGListKit
import EnolaGay

class SectionController: ListSectionController {
    
    var entry: Model!
    
    override init() {
        super.init()
        
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
}

extension SectionController {

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
        
        // 由于先设置的 sizeForItem，后赋值，所以复制后需要调用 layoutIfNeeded() 更新布局。
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        entry = object as? Model
    }
    
    override func didSelectItem(at index: Int) {
        log("点击了\(index)")
    }

}
