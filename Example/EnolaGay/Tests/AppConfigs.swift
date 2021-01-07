//
//  AppConfigs.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/1/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import EnolaGay


// 颜色配置
extension UIApplication: EMERANA_UIColor {

    public func configColorStyle(_ style: UIColor.ColorStyle) -> UIColor {
        var color = UIColor.red
        switch style {

        case .navigationBarTint:
            color = #colorLiteral(red: 1, green: 0.2274509804, blue: 0.3725490196, alpha: 0)
        case .navigationBarTitle, .navigationBarItems:
            color = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // 0x333333
        case .text:
            if #available(iOS 13, *) {
                color = .label
            } else {
                color = .black
            }
        default:
            break
        }
        return color
    }

}

// ApiRequestConfig
//extension UIApplication: EMERANA_ApiRequestConfig {
//    
//    public func domain() -> String { "https://www.baidu.com" }
//    
//    
//}

    
enum Actions: String, EMERANA_ApiActionEnums {
    var value: String { rawValue }
    
    case testAction = "/test"
}
    

