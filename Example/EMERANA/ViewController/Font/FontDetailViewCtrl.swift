//
//  FontDetailViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/30.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 字体详情界面
class FontDetailViewCtrl: JudyBaseViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet weak var fontNameLabel: JudyBaseLabel!
    
    // MARK: - public var property - 公开var
    
    var fontName = ""

    // MARK: - private var property - 私有var
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: fontName, size: 18)
        titleLabel.text = fontName
        navigationItem.titleView = titleLabel
        
        fontNameLabel.pasteboardText = fontName
        fontNameLabel.altTitle = "复制 '\(fontName)'"
        
        titleLabels.forEach { label in
            label.font = UIFont(name: fontName, size: 18)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件

    // MARK: - Event response - 响应事件
    
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
