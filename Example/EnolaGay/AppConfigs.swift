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
        case .scrollView, .view:
            color = .white
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
extension UIApplication: EMERANA_ApiRequestConfig {    
    
    public func domain() -> String { "https://www.baidu.com" }
    
}


extension UIApplication: EMERANA_UIFont {
    
    public func configFontStyle(_ style: UIFont.FontStyle) -> (UIFont.FontName, CGFloat) {
        // 通过判断原始值为奇数使用加粗字体
        var fontName: UIFont.FontName = style.rawValue%2 == 0 ? .苹方_简_常规体:.苹方_简_中黑体
        var fontSize: CGFloat = 24
        switch style {
            
        case .xxxs, .xxxs_B: // 最小码
            fontSize = 8
        case .xxs, .xxs_B: // 极小码
            fontSize = 9
            
        case .XS, .XS_B: // 超小码
            fontSize = 10
        case .S, .S_B:   // 小码
            fontSize = 11
        case .M, .M_B:   // 均码
            fontSize = 12
        case .L, .L_B:   // 大码
            fontSize = 13
        case .XL, .XL_B: // 超大码
            fontSize = 14
        case .xxl, .xxl_B:
            fontSize = 16
        case .xxxl, .xxxl_B:
            fontSize = 18

        case .Nx1:
            fontSize = 24
            fontName = .苹方_简_中黑体
        /// 当前用于提现界面
        case .Nx2:
            fontSize = 30
            fontName = .苹方_简_中黑体
        case .Nx3:
            fontSize = 36
            fontName = .HelveticaNeue
        case .Nx4:
            fontSize = 40
            fontName = .HelveticaNeue
        case .Nx5:
            fontSize = 46
            fontName = .HelveticaNeue
            
        }
        
        return (fontName, fontSize)
    }

}

    
enum Actions: String, EMERANA_ApiActionEnums {
    var value: String { rawValue }
    
    case testAction = "/test"
}
    

