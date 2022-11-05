//
//  FontExtensionViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/7/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class FontExtensionViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "字体扩展" }

    // MARK: - let property and IBOutlet
    
    // MARK: - public var property

    // MARK: - private var property
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let timeInt: Double = 21609.2710269

        ///天
        let days = Int(timeInt/(3600*24))
        ///时
        let hours = Int((Int(timeInt) - days*24*3600)/3600)
        ///分
        let minute = Int((Int(timeInt) - days*24*3600-hours*3600)/60)
        ///秒
        let second = Int((Int(timeInt)-days*24*3600-hours*3600)-60*minute)
        let timeString = String(format: "%d:%d",hours,minute)
    }

    // MARK: - override
    
    // MARK: - event response

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - private methods

private extension FontExtensionViewCtrl {

}
