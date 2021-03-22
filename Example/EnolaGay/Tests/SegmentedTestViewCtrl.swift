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

    @IBOutlet weak private(set) var segmentCtrl: JudySegmentedCtrl!

    @IBOutlet weak private(set) var segmentedView: SegmentedView!
    
    private(set) var segmentedViewDataSource =  SegmentedViewTitleDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setSegmentedCtrl()
        setSegmentedView()
    }
    
    private func setSegmentedView() {
        segmentedViewDataSource.titles = ["作品", "喜欢", "收藏",]
        segmentedViewDataSource.titleSelectedFont = UIFont(style: .XL_B)
        segmentedViewDataSource.titleNormalFont = UIFont(style: .XL)

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
    
    /// 设置 segmentedCtrl
    private func setSegmentedCtrl() {
        
        segmentCtrl.judy_configSegmentedCtrl(withIndicatorHeight: 4)
        segmentCtrl.judy_configNormolStyle(color: .judy(.colorStyle1), font: UIFont(style: .XL))
        segmentCtrl.judy_configSelectedStyle(color: .judy(.selected), font: UIFont(style: .XL_B))
        segmentCtrl.addTarget(self, action: #selector(segmentedCtrlValueChangeAction(segmentedCtrl:)), for: .valueChanged)

        segmentCtrl.segmentWidthStyle = .fixed
        segmentCtrl.selectionIndicatorColor = .judy(.colorStyle2)
        segmentCtrl.sectionTitles = ["作品", "喜欢", "收藏",]
        segmentCtrl.selectionIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 48)
        segmentCtrl.backgroundColor = .white

    }
    
    
    @objc private func segmentedCtrlValueChangeAction(segmentedCtrl: JudySegmentedCtrl) {
        
        Judy.log(segmentedCtrl.selectedSegmentIndex)
    }

}

extension SegmentedTestViewCtrl: SegmentedViewDelegate {
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        Judy.log("segmentedView:\(index)")
    }
}
