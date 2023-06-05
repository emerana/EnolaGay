//
//  JudyBaseTabBarCtrl.swift
//  建议作为所有 UITabBarController 的基类
//
//  Created by 王仁洁 on 2017/6/21.
//  Copyright © 2017年 数睿科技（深圳）. All rights reserved.
//

import UIKit

/// TabBarCtrl 基类
open class JudyBaseTabBarCtrl: UITabBarController {

    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
}


// MARK: - UITabBarControllerDelegate

extension JudyBaseTabBarCtrl: UITabBarControllerDelegate {
    
    // 询问委托是否应该激活指定的视图控制器
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        tabBar.isHidden = false
        
        return true
    }
    
    // 告诉委托用户在选项卡栏中选择了一个项
    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        /*
        // 在子类中重写此方法
        Judy.log("当前选中\(tabBarController.selectedIndex)")
        let items = tabBarController.tabBar.items
        
        for item in items! {
            if item == tabBarController.tabBar.selectedItem {
                item.image = nil
            } else {
                item.image = #imageLiteral(resourceName: "airplan")
            }
        }
        */
        
    }

}
