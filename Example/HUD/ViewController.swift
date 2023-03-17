//
//  ViewController.swift
//  HUD
//
//  Created by 醉翁之意 on 2023/3/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        JudyTip.message(messageType: .success, text: "Judy")
    }

}

