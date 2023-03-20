//
//  PoPViewController.swift
//  GifEffectsDemo
//
//  Created by 醉翁之意 on 2023/3/20.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

class PoPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 点赞的烟花爆炸效果
    @IBAction func emitAction(_ sender: Any) {
        let blingImageView = UIImageView(image: UIImage(named: "button_喜欢_H"))
        blingImageView.frame.size = CGSize(width: 18, height: 18)
        blingImageView.center = (sender as! UIView).superview!.convert((sender as! UIView).center, to: view)
        view.addSubview(blingImageView)
        
        // 发射
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            blingImageView.center = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.view.bounds.width-128))+88), y: CGFloat(arc4random_uniform(UInt32(self.view.bounds.height-220))+88))
        }) { _ in
            // 烟花爆炸
            blingImageView.judy.blingBling {
                blingImageView.removeFromSuperview()
            }
        }
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
