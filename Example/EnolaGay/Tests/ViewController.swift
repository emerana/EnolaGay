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
    private let segmentedCtrlDataSoruce = SegmentedViewTitleDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        Judy.log("太爽了")
        
        segmentedView.dataSource = segmentedCtrlDataSoruce
        segmentedView.delegate = self

        let indicator1 = IndicatorView()
        indicator1.indicatorPosition = .top
        indicator1.indicatorHeight = 2
        let indicator2 = IndicatorLineView()
        indicator2.indicatorHeight = 6

        // 配置指示器
        segmentedView.indicators = [indicator1, indicator2]
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


// MARK: - SegmentedViewDelegate
extension ViewController: SegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        print("当前选中:\(index)")

        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

/// 抖音双击点赞动画。
class DoubleClickThumbUpViewCtrl: UIViewController {
   
    @IBAction func popAction(_ sender: Any) {
        let blingImageView = UIImageView(image: UIImage(named: "双击点赞爱心.jpg"))
        blingImageView.center = view.center
        view.addSubview(blingImageView)

        blingImageView.judy.doubleClickThumbUp()
    }
    
}
