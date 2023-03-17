//
//  ViewController.swift
//  Demo
//
//  Created by 醉翁之意 on 2023/3/16.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("测试")

    }

    @IBAction func logAction(_ sender: Any) {
        log("哈哈哈")
    }

    @IBAction func loglAction(_ sender: Any) {
        logl("哈哈哈")
    }

    @IBAction func logTimeAction(_ sender: Any) {
        logTime("哈哈哈")
    }

    @IBAction func logsAction(_ sender: Any) {
        logs("哈哈哈")
    }

    @IBAction func lognAction(_ sender: Any) {
        logn("哈哈哈")
    }

    @IBAction func logHappyAction(_ sender: Any) {
        logHappy("哈哈哈")
    }

    @IBAction func logWarningAction(_ sender: Any) {
        logWarning("哈哈哈")
    }

    @IBAction func logtAction(_ sender: Any) {
        logt("哈哈哈")
    }

}

