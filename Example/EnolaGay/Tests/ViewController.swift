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
    private let segmentedCtrlDataSoruce = SegmentedTitleDataSource()

    
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


// MARK: - SegmentedViewDelegate
extension ViewController: SegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        print("当前选中:\(index)")

        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

