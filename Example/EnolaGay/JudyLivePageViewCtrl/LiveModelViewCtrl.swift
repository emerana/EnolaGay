//
//  LiveModelViewCtrl.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 2021/1/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class LiveModelViewCtrl: UIViewController {
    
    var tagDataSource = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (view.viewWithTag(101) as? UILabel)?.text = "当前 tagDataSource = \(tagDataSource)"
        let colors: [UIColor] = [.red, .green, .blue, .brown, .cyan, .purple]
         
        view.backgroundColor = colors[Int(arc4random_uniform(UInt32(colors.count-1)))]
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
