//
//  WeiChatViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/9/20.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 微信运动步数增加
class WeiChatViewCtrl: JudyBaseViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet weak private var waterView: JudyWaterWaveView!

    // MARK: - public var property - 公开var

    override var viewTitle: String? {
        return "微信运动步数增加"
    }

    // MARK: - private var property - 私有var
    
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        waterView.star()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件

    // MARK: - Event response - 响应事件
    
    @IBAction func getStartAction(_ sender: Any) {
        
        
        // 异步执行
        DispatchQueue.global().async {
            var progress: Float = 0
            while progress < 1 {
                progress += 0.0001   //  waitTime
                DispatchQueue.main.async {
//                    hud.progress = progress
//                    hud.label.text = "当前步数：\(Int(90000*progress))步"
                }
                usleep(888)   // 用 usleep 毫秒级延迟
            }
            DispatchQueue.main.async {
//                hud.label.text = "当前已增加至：\(Int(90000*progress))步"
                self.waterView.进度 = 0.8//CGFloat(progress)
            }
            sleep(2)
            DispatchQueue.main.async {
//                hud.hide(animated: true)
            }
        }
        
    }
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}
