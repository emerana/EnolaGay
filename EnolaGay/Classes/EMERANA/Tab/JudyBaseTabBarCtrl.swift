//
//  TabBarCtrl.swift
//  TabBarCtrl 基类
//
//  Created by Judy-王仁洁 on 2017/6/21.
//  Copyright © 2017年 Judy.ICBC. All rights reserved.
//

import UIKit

/// TabBarCtrl 基类
/// * 支持 tabBar.items 小 icon 使用原图功能，该功能默认为 false，需要手动在 Storyboard 中开启。
open class JudyBaseTabBarCtrl: UITabBarController {
    
    /// 是否使 tabBar.items 中的图标使用原图，默认 false，若需要此功能请在 storyboard 手动开启
    /// # 初始值必须为 false
    @IBInspectable public private(set) var isItemOriginal: Bool = false

    // MARK: - tabBar中间按钮
    
    /// 重写 tabBar，返回一个 JudyTabBar
    //    override var tabBar: JudyTabBar {
    //        return JudyTabBar()
    //    }
    
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
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    
}



// MARK: - UITabBarControllerDelegate

extension JudyBaseTabBarCtrl: UITabBarControllerDelegate {
    
    /// tabBarCtrl 切换前的触发事件，询问委托是否应该激活指定的视图控制器，如果视图控制器的标签应该被选中，为 true;如果当前标签应该保持活动，为 false。
    /// 标签栏控制器调用这个方法来响应用户点击一个标签栏项目。您可以使用此方法来动态地决定是否应该将给定的选项卡设置为活动选项卡。
    /// - Parameters:
    ///   - tabBarController: tabBarCtrl
    ///   - viewController: 要激活的目标视图
    /// - Returns: 是否切换
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        tabBar.isHidden = false
        
        return true
    }
    
    
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

