//
//  GroupCtrl.swift
//  PasswordBox
//
//  数据分组管理
//
//  Created by 醉翁之意 on 2022/10/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

/// 账号模型
class Account {
    /// 账号实体的 id,该值由数据库自动生成，一般情况下无需人为赋值
    let id: Int
    /// 账号实体的完整属性
    var name: String, password: String
    
    init(id: Int, name: String, password: String) {
        self.id = id
        self.name = name
        self.password = password
    }
}

/// 账号对应的详细信息模型
class AccountRemark {
    /// 该 id 由数据库自动生成，一般情况下无需人为赋值
    let id: Int
    /// 该账号所在分组
    var group: String?
    /// 该账号备注信息
    var remark: String?
    /// 该数据的创建时间和最后一次修改的时间
    var createTime: String, updateTime: String
    
    init(id: Int, group: String? = nil, remark: String? = nil, createTime: String, updateTime: String) {
        self.id = id
        self.group = group
        self.remark = remark
        self.createTime = createTime
        self.updateTime = updateTime
    }

}

/// 组模型
class Group {
    /// 背景色值数据源
    static let GroupBackgroundColors: [Int] = [GroupBackgroundColor.淡红色.rawValue]
    /// 该 id 由数据库自动生成，一般情况下无需人为赋值
    let id: Int
    /// 组名
    var name: String
    /// 该组图标名
    var icon: String? // = "placeholder"
    /// 该组的背景颜色
    var backgroundColor: Int? //= GroupBackgroundColors.first!
    
    init(id: Int, name: String, icon: String? = nil, backgroundColor: Int? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.backgroundColor = backgroundColor
    }
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
