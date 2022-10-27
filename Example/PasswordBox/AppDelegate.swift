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
        
        // 创建表
        DataBaseCtrl.judy.create_group()
        DataBaseCtrl.judy.create_remarks()
        DataBaseCtrl.judy.create_Password()

        return true
    }

}

extension UIApplication: EnolaGayAdapter {
    
    public func defaultFontName() -> UIFont { UIFont(name: .苹方_常规体, size: 12) }
    
    public func viewBackgroundColor() -> UIColor { UIColor.view }
    
    public func scrollViewBackGroundColor() -> UIColor { UIColor.view }
    
    public func navigationBarItemsColor() -> UIColor { UIColor.浅蓝紫}
    
}

extension EMERANA.Key {
    /// 数据库名
    static let dataBaseName = "AccountDB"

}

/// 背景色模块
enum GroupBackgroundColor: Int {
    case 淡红色 = 0xec6941
    case 浅红橙 = 0xf19149
    case 浅黄橙 = 0xf8b551
    case 浅黄 = 0xfff45c
    case 浅青豆绿 = 0xb3d465
    case 浅黄绿 = 0x80c269
    case 浅绿 = 0x32b16c
    case 浅绿青 = 0x13b5b1
    case 浅青 = 0x00b7ee
    case 浅洋红 = 0xea68a2
    case 浅蓝紫 = 0x5f52a0
    case 浅紫洋红 = 0xae5da1
}

extension UIColor {
    /// 用于 View、scrollView 的背景色, // #DFE7F2
    static let view = #colorLiteral(red: 0.8672423959, green: 0.9071726203, blue: 0.9536811709, alpha: 1)

    static let x333333 = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)   // #333333
    /// 纯白色，透明度为 5%.
    static let xFFFFFF5 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.05)
    static let xEEEEEE = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)

    static let xFF395E = #colorLiteral(red: 1, green: 0.2235294118, blue: 0.368627451, alpha: 1)
    
    /// RGB#000000 透明度 50%
    static let x00000050 = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
    static let x666666 = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static let x999999 = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    /// 直播结束的黑色背景。
    static let x202020 = #colorLiteral(red: 0.1674376428, green: 0.1674425602, blue: 0.167439878, alpha: 1)
    static let selected = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // 0x333333
    static let colorStyle2 = #colorLiteral(red: 1, green: 0.0431372549, blue: 0.2862745098, alpha: 1) // 0xFF0B49
    static let colorStyle3 = #colorLiteral(red: 0.9843137255, green: 0.1333333333, blue: 0.3411764706, alpha: 1) // 0xFB2257
    static let colorStyle5 = #colorLiteral(red: 0.4196078431, green: 0.6705882353, blue: 0.7725490196, alpha: 1) // 0x6BABC5
    
}
