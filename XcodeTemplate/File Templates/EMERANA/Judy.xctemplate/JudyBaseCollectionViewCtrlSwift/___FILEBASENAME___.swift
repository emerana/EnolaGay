//___FILEHEADER___

import UIKit
import EnolaGay

class ___FILEBASENAMEASIDENTIFIER___: JudyBaseCollectionViewCtrl {
    override var viewTitle: String? { "<#title#>" }
    
    // MARK: - let property and IBOutlet
    
    // MARK: - public var property
    
    override var itemSpacing: CGFloat { <#8#> }
    
    // MARK: - private var property
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSource()
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
private extension ___FILEBASENAMEASIDENTIFIER___ {
    /// 设置 JSON 数据源
    func setDataSource() {
        dataSource = [
            [EMERANA.Key.title: "模拟数据", ],
            [EMERANA.Key.title: "模拟数据", ],
            [EMERANA.Key.title: "模拟数据", ],
        ]
    }
    
}

// MARK: - UICollectionViewDataSource
extension ___FILEBASENAMEASIDENTIFIER___ {
    /*
     /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例。

     override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
     }
     */

}


// MARK: - UICollectionViewDelegate
extension ___FILEBASENAMEASIDENTIFIER___ {
    /// 选中事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("选中\(indexPath)")
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ___FILEBASENAMEASIDENTIFIER___ {
    /// 询问 cell 大小，在此函数中计算好对应的 size.
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// 在一个 line 中需要显示的 cell 数量
        let countOfCells: CGFloat = <#3#>
        /// cell 参与计算的边长，初值为 line 的长度（包含间距）
        /// 
        /// 一个 line 中需要显示的所有 cell. 宽度（或高度）及他们之间所有间距的总和，以此来确定单个 cell 的边长
        /// - Warning: 请注意在此处减去不参与计算 cell 边长的部分，比如 collectionView.contentInset 的两边
        var lineWidthOfCell = collectionView.frame.width
        // var lineWidthOfCell = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 collectionView 的 Estimate Size，将其设置为 None.
        lineWidthOfCell = (lineWidthOfCell + itemSpacing)/countOfCells - itemSpacing
        
        let heightForCell: CGFloat = <#88#>
        
        return CGSize(width: lineWidthOfCell, height: heightForCell)
    }
    
}
