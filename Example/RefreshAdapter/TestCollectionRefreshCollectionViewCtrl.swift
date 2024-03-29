//
//  TestCollectionRefreshCollectionViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 醉翁之意 on 2021/4/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class TestCollectionRefreshCollectionViewCtrl: JudyBaseCollectionRefreshViewCtrl {
    override var viewTitle: String? { return "CollectionView" }
    
    override var pageSizeParameter: String {"thisSIZE"}
    override var pageIndexParameter: String {"thisINDEZX"}

    override var itemSpacing: CGFloat { return 8 }
        
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - override
    
    override func setApi() {
        super.setApi()
        
        requestConfig.api = Actions.createUserChatToken
        requestConfig.parameters?["userid"] = 323430
    }
    
    override func reqSuccess() {
        super.reqSuccess()
        
        Judy.log("请求成功-\(apiData)")
    }
    
}

// MARK: - UICollectionViewDataSource
extension TestCollectionRefreshCollectionViewCtrl {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
}


// MARK: - UICollectionViewDelegate
extension TestCollectionRefreshCollectionViewCtrl {
   
    // 选中事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("选中\(indexPath)")
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TestCollectionRefreshCollectionViewCtrl {
    
    // 配置 Cell 尺寸
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        var widthForCell: CGFloat = collectionView.frame.width

        let heightForCell: CGFloat = 88
        // 在同一个 Line 中需要显示的 Cell 数量
        let numForCellInRow: CGFloat = 3
        
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 CollectionView 的 Estimate Size，将其设置为 None.
        widthForCell = (widthForCell + itemSpacing)/numForCellInRow - itemSpacing

        return CGSize(width: widthForCell, height: heightForCell)
    }
    
}
