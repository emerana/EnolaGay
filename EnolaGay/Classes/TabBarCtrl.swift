//
//  JudyBaseTabBarCtrl.swift
//  建议作为所有 UITabBarController 的基类
//
//  Created by 王仁洁 on 2017/6/21.
//  Copyright © 2017年 数睿科技（深圳）. All rights reserved.
//

import UIKit

/// TabBarCtrl 基类
/// * 支持 tabBar.items 小 icon 使用原图功能，该功能默认为 false，需要手动在 Storyboard 中开启。
open class JudyBaseTabBarCtrl: UITabBarController {
    
    /// 是否使 tabBar.items 中的图标使用原图，默认 false，若需要此功能请在 storyboard 手动开启
    /// - warning: 初始值必须为 false
    @IBInspectable
    public private(set) var isItemOriginal: Bool = false
    
    
    // MARK: - tabBarCtrl 生命周期
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 变更 tabBar icon 的呈现模式（原色彩）
        if isItemOriginal, let items = tabBar.items {
            for item in items {
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            }
        }
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
}



// MARK: - UITabBarControllerDelegate

extension JudyBaseTabBarCtrl: UITabBarControllerDelegate {
    
    // 询问委托是否应该激活指定的视图控制器。
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        tabBar.isHidden = false
        
        return true
    }
    
    // 告诉委托用户在选项卡栏中选择了一个项。
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

