//
//  LogViewController.swift
//  Demo
//
//  Created by 醉翁之意 on 2023/3/16.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class LogViewController: UIViewController {

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
//        let second = Int((Int(timeInt)-days*24*3600-hours*3600)-60*minute)
//        let timeString = String(format: "%d:%d",hours,minute)

        debugPrint("测试")
    }

    @IBAction func logAction(_ sender: Any) {
        let button = sender as! UIButton
//        button.judy.setImage
        
        Logger.info("哈哈哈")
    }

    @IBAction func loglAction(_ sender: Any) {
        Logger.info("哈哈哈")
    }

    @IBAction func logTimeAction(_ sender: Any) {
        Logger.info("哈哈哈")
    }

    @IBAction func logsAction(_ sender: Any) {
        Logger.info("哈哈哈")
    }

    @IBAction func lognAction(_ sender: Any) {
        Logger.info("哈哈哈")
    }

    @IBAction func happyAction(_ sender: Any) {
        Logger.happy("哈哈哈")
    }

    @IBAction func errorAction(_ sender: Any) {
        Logger.error("哈哈哈")
    }

    @IBAction func logtAction(_ sender: Any) {
        Logger.time("哈哈哈")
    }

}

