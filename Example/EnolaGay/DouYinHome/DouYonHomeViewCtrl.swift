//
//  DouYonHomeViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/6/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class DouYonHomeViewCtrl: JudyBaseViewCtrl {

    private var pageViewCtrl: JudyBasePageViewCtrl!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titles = ["附近", "关注", "推荐"]
        pageViewCtrl.onStart(dataSource: titles)
    }

    // MARK: - override
    
    // MARK: - event response


    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
        pageViewCtrl = segue.destination as? JudyBasePageViewCtrl
        pageViewCtrl.enolagay = self
        
        
     }
    
}


extension DouYonHomeViewCtrl: EMERANA_JudyBasePageViewCtrlModel {
    
    func viewCtrl(for index: Int, at title: String) -> UIViewController {
        let viewCtrl = storyboard!.instantiateViewController(withIdentifier: "contentViewCtrl")
        switch index {
        case 0:
            viewCtrl.view.backgroundColor = .red
        case 1:
            viewCtrl.view.backgroundColor = .brown
        case 2:
            viewCtrl.view.backgroundColor = .cyan
        default:
            viewCtrl.view.backgroundColor = .green
        }
        return viewCtrl
    }

}
