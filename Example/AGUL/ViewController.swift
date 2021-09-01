//
//  ViewController.swift
//  AGUL
//
//  Created by 王仁洁 on 2021/9/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FuckerCtrl.judy.star()
    }
    
}

import SwiftMessages
import EnolaGay

class FuckerView: MessageView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollTitle: MarqueeView!
    
}
