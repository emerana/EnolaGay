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
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let color = UIColor.judy(.navigationBarTint)

        Judy.log("太爽了")

    }


    @IBAction func goAction(_ sender: Any) {
        
        if theButton.isHidden {
            theButton.show()
        } else {
            theButton.isHidden = true
        }
    }
    
}

