//
//  PushTest_ViewCtrl_B.swift
//  emerana
//
//  Created by 醉翁之意 on 2020/7/24.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

class PushTest_ViewCtrl_B: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.

    }

    override func pushAction(current viewCtrl: UIViewController, pushTo targetViewCtrl: UIViewController) {
        
        if viewCtrl === self {
            //  NavigationCtrl 移除指定的 ViewCtrl
            let newViewCtrls = navigationController?.viewControllers.filter({ (viewCtrl) -> Bool in
                return viewCtrl !== self
            })
            
            navigationController?.viewControllers = newViewCtrls!

        }
    }
    
}
