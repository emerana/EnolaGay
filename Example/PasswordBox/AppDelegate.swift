//
//  AppDelegate.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
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
    
    public func defaultFontName() -> UIFont { UIFont(name: .苹方_常规体, size: 12) }
    
    public func viewBackgroundColor() -> UIColor { UIColor(rgbValue: 0xdfe7f2)    }
    
}
