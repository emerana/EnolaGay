//
//  TransparentViewCtrl.swift
//  Demo
//
//  Created by EnolaGay on 2023/8/11.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

/// 全透明的导航条
class TransparentViewCtrl: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /// 持续显示导航条
    @IBAction func resetNavigationBar(_ sender: Any) {
        judy.navigationBarWithAppearance()
    }
    
    /// 全透明导航条
    @IBAction func navigationBarResetGroundGlassEffect(_ sender: Any) {
        judy.navigationBarWithTransparentBackground()
    }

    @IBAction func navigationBarOpaque(_ sender: Any) {
        judy.navigationBarDefault()
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
