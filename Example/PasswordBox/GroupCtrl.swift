//
//  GroupCtrl.swift
//  PasswordBox
//
//  数据分组管理
//
//  Created by 醉翁之意 on 2022/10/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//
                
import FMDB

class Group {
    /// 背景色值数据源
    static let GroupBackgroundColors: [Int] = [GroupBackgroundColor.淡红色.rawValue]
    /// 组名
    var name = "全部账号"
    /// 该组图标名
    var icon = "placeholder"
    /// 该组的背景颜色
    var backgroundColor: Int = GroupBackgroundColors.first!
    /// 该组下的数量
    var count = 0
    
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
