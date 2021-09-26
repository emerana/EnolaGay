//
//  SectionControllerType_1.swift
//  emerana
//
//  Created by 王仁洁 on 2019/12/19.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import IGListKit
import EnolaGay

class SectionControllerType_1: ListSectionController {
    
    var entry: Model!
    
    override init() {
        super.init()
        
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    
}

extension SectionControllerType_1 {

    override func numberOfItems() -> Int {
        return 3
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }

        // 固定宽度，自动高度
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
        
        
        return cell
        
        //        let cellClass: AnyClass = index == 0 ? JournalEntryDateCell.self : JournalEntryCell.self
        //
        //        let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index)
        //
        //        if let cell = cell as? JournalEntryDateCell {
        //            cell.label.text = entry.date
        //        } else if let cell = cell as? JournalEntryCell {
        //            cell.label.text = entry.msg
        //        }
        //        return cell
    }
    
    override func didUpdate(to object: Any) {
        entry = object as? Model
    }
    
    override func didSelectItem(at index: Int) {
        Judy.log("点击了\(index)")
    }

}
