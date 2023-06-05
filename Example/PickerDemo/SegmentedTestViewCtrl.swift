//
//  SegmentedTestViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/3/22.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class SegmentedTestViewCtrl: UIViewController {

    @IBOutlet weak private(set) var segmentedView: SegmentedView!
    
    private(set) var segmentedViewDataSource =  SegmentedViewTitleDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setSegmentedView()
        logs("哈哈")
    }
    
    private func setSegmentedView() {
        segmentedViewDataSource.titles = ["作欢品", "喜欢欢欢欢", "收藏","收",]
//        segmentedViewDataSource.isItemWidthZoomEnabled = true
        segmentedViewDataSource.isItemSpacingAverageEnabled = false
        segmentedViewDataSource.itemSpacing = 12

        segmentedViewDataSource.titleSelectedFont = UIFont(size: 15)
        segmentedViewDataSource.titleNormalFont = UIFont(size: 15)

        segmentedView.dataSource = segmentedViewDataSource
        segmentedView.delegate = self
        
        let indicatorTop = IndicatorView()
        indicatorTop.indicatorPosition = .top
        indicatorTop.indicatorHeight = 4
        indicatorTop.indicatorColor = .red
        
        let indicatorBottom = IndicatorLineView()
        indicatorBottom.indicatorPosition = .bottom
        indicatorBottom.indicatorColor = .blue

        segmentedView.indicators = [indicatorTop, indicatorBottom]
    }
}

extension SegmentedTestViewCtrl: SegmentedViewDelegate {
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        log("segmentedView:\(index)")
    }
}
