//
//  CircularProgressViewCtrl.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 2021/1/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 演示按住一个按钮使圆环的进度条递增
class CircularProgressViewCtrl: UIViewController {
    
    /// 圆环 View
    @IBOutlet weak var circleView: CircularProgressLiveView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        circleView.lineLayer.strokeEnd = 0.2
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
