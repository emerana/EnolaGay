//
//  KeyboardViewController.swift
//  Demo
//
//  Created by 醉翁之意 on 2023/3/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class KeyboardViewController: UIViewController {

    private let keyboardHelper = KeyboardHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardHelper.registerKeyBoardListener(forView: view)
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
