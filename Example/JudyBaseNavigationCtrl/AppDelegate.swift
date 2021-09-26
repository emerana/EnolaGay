//
//  AppDelegate.swift
//  JudyBaseNavigationCtrl
//
//  Created by 王仁洁 on 2021/9/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

extension UIApplication: EnolaGayAdapter {
    public func defaultFontName() -> UIFont { UIFont(name: .苹方_中黑体, size: 16) }
    
    public func viewBackgroundColor() -> UIColor { .placeholderText }
    
    public func navigationBarItemsColor() -> UIColor { .purple }
}
