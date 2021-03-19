//
//  ViewController.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 01/05/2021.
//  Copyright (c) 2021 醉翁之意. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var theButton: JudyBaseButton!
    @IBOutlet weak var segmentedView: SegmentedView!
    private let segmentedCtrlDataSoruce = SegmentedTestSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let color = UIColor.judy(.navigationBarTint)

        Judy.log("太爽了")
        
        segmentedView.dataSource = segmentedCtrlDataSoruce
        segmentedView.delegate = self

        let indicator = IndicatorView()
        // 配置指示器
        segmentedView.indicators = [indicator]
    }


    @IBAction func goAction(_ sender: Any) {
        
        if theButton.isHidden {
            theButton.show()
        } else {
            theButton.isHidden = true
        }
    }
    
    
    @IBAction func selectedAction(_ sender: Any) {
        segmentedView.selectItem(at: 6)
    }
    
}

// 用于测试用例的一个数据源对象，SegmentedTitleDataSource 融合 SegmentedBaseDataSource
class SegmentedTestSource {
    
    // MARK: - 协议属性
    
    // MARK: - 自有属性
    
    /// 该 title 数组用于确定 dataSource
    open var titles = ["猴哥", "青蛙王子", "旺财", "大家好我是王仁洁", "粉红猪", "喜羊羊", "黄焖鸡", "小马哥", "牛魔王", "大象先生", "神龙"]

    /// 真实的 item 宽度 = itemWidth + itemWidthIncrement。
    open var itemWidthIncrement: CGFloat = 0
    /// 如果将 SegmentedView 嵌套进 UITableView 的 cell，每次重用的时候，SegmentedView 进行 reloadData 时，会重新计算所有的 title 宽度。所以该应用场景，需要 UITableView 的 cellModel 缓存 titles 的文字宽度，再通过该闭包方法返回给 SegmentedView。
    open var widthForTitleClosure: ((String)->(CGFloat))?

    /// title普通状态时的字体
    open var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)

}

// MARK: - SegmentedViewDataSource
extension SegmentedTestSource: SegmentedViewDataSource {
    
    var itemSpacing: CGFloat { 8 }
    var isItemSpacingAverageEnabled: Bool { true }
    var isItemWidthZoomEnabled: Bool { false }
    var selectedAnimationDuration: TimeInterval { 0.25 }


    func segmentedView(registerCellForCollectionViewAt collectionView: UICollectionView) -> Bool {
        collectionView.register(SegmentedTitleCell.self, forCellWithReuseIdentifier: "Cell")
        return true
    }

    func numberOfItems(in segmentedView: SegmentedView) -> Int { titles.count }
    
    func segmentedView(_ segmentedView: SegmentedView, entityForItem entity: SegmentedItemModel?, entityForItemAt index: Int, selectedIndex: Int) -> SegmentedItemModel {
    
        var model = SegmentedItemTitleModel()
        if entity as? SegmentedItemTitleModel != nil {
            model = entity as! SegmentedItemTitleModel
        }
        

        model.isItemTransitionEnabled = true
        model.isSelectedAnimable = false
                
        model.title = titles[index]

        model.titleNumberOfLines = 1
        model.titleNormalColor = .black
        model.titleSelectedColor = .red
        model.titleNormalFont = titleNormalFont
        model.titleSelectedFont = titleNormalFont
        
        model.isTitleZoomEnabled = false
        
        model.isTitleStrokeWidthEnabled = false
        model.isTitleMaskEnabled = false
        
        model.titleNormalZoomScale = 1
        model.titleSelectedZoomScale = 1.2
        model.titleSelectedStrokeWidth = -2
        model.titleNormalStrokeWidth = 0
        // 确定选中的模型
        if index == selectedIndex {
            model.titleCurrentColor = .red
            model.titleCurrentZoomScale = 1.2
            model.titleCurrentStrokeWidth = -2
        }else {
            model.titleCurrentColor = .black
            model.titleCurrentZoomScale = 1
            model.titleCurrentStrokeWidth = 0
        }
        
        return model
    }
    
    func segmentedView(_ segmentedView: SegmentedView, widthForItem entity: SegmentedItemModel) -> CGFloat {

        return itemWidthIncrement + (entity as! SegmentedItemTitleModel).textWidth
    }
    
    func segmentedView(_ segmentedView: SegmentedView, widthForItemContent item: SegmentedItemModel) -> CGFloat {
        let model = item as! SegmentedItemTitleModel
        if model.isTitleZoomEnabled {
            return model.textWidth*model.titleCurrentZoomScale
        } else {
            return model.textWidth
        }
    }
    
    func segmentedView(_ segmentedView: SegmentedView, cellForItemAt index: Int) -> SegmentedCell {
        return segmentedView.dequeueReusableCell(withReuseIdentifier: "Cell", at: index)
    }

}

// MARK: - SegmentedViewDelegate
extension ViewController: SegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        print("当前选中:\(index)")

        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

