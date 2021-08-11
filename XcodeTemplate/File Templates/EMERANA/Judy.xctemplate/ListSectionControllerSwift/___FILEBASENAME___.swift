//___FILEHEADER___

import UIKit
import IGListKit
import SwiftyJSON
import EnolaGay

class ___FILEBASENAMEASIDENTIFIER___: ListSectionController {
    
    var entrys: [JSON]!
    
    override init() {
        super.init()
        
        // 配置当前 section 相关属性
        inset = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
    }

}


// MARK: - 数据源

extension ___FILEBASENAMEASIDENTIFIER___ {
    override func numberOfItems() -> Int { entrys.count }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        
        /// 在一个 line 中需要显示的 cell 数量
        let countOfCells: CGFloat = <#3#>
        /// cell 参与计算的边长，初值为 line 的长度（包含间距）
        /// 一个 line 中需要显示的所有 cell. 宽度（或高度）及他们之间所有间距的总和，以此来确定单个 cell 的边长
        /// - Warning: 请注意在此处减去不参与计算 cell 边长的部分，比如 collectionView.contentInset 的两边
        var lineWidthOfCell = collectionView.frame.width
        // var lineWidthOfCell = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 collectionView 的 Estimate Size，将其设置为 None.
        lineWidthOfCell = (lineWidthOfCell + itemSpacing)/countOfCells - itemSpacing

        let heightForCell: CGFloat = <#88#>
        
        return CGSize(width: lineWidthOfCell, height: heightForCell)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCellFromStoryboard(withIdentifier: <#"Cell"#>, for: self, at: index)
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        entrys = (object as? SectionData)?.datas
    }
    
    override func didSelectItem(at index: Int) {
        Judy.log("点击了\(index)")
    }
}
