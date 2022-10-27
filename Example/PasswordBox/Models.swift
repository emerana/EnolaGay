//
//  Models.swift
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
    /// 该数据的创建时间和最后一次修改的时间
    var createTime: String, updateTime: String
    
    /// 该账号所对应的备注信息表
    var remark: AccountRemark?
    
    init(id: Int, name: String, password: String, createTime: String, updateTime: String) {
        self.id = id
        self.name = name
        self.password = password
        self.createTime = createTime
        self.updateTime = updateTime
    }
}

/// 账号对应的详细信息模型
class AccountRemark {
    /// 该 id 由数据库自动生成，一般情况下无需人为赋值
    let id: Int
    /// 该账号所在分组
    var group: Group?
    /// 该账号备注信息
    var remark: String?
    /// 是否收藏
    var isCollection = false


    init(id: Int, group: Group? = nil, remark: String? = nil) {
        self.id = id
        self.group = group
        self.remark = remark
    }

}

/// 组模型
class Group {
    /// 背景色值数据源
    static let backgroundColors: [Int] = [
        GroupBackgroundColor.淡红色.rawValue,
        GroupBackgroundColor.浅红橙.rawValue,
        GroupBackgroundColor.浅黄橙.rawValue,
        GroupBackgroundColor.浅黄.rawValue,
        GroupBackgroundColor.浅青豆绿.rawValue,
        GroupBackgroundColor.浅黄绿.rawValue,
        GroupBackgroundColor.浅绿.rawValue,
        GroupBackgroundColor.浅绿青.rawValue,
        GroupBackgroundColor.浅青.rawValue,
        GroupBackgroundColor.浅洋红.rawValue,
        GroupBackgroundColor.浅蓝紫.rawValue,
        GroupBackgroundColor.浅紫洋红.rawValue,
    ]
    
    /// 该 id 由数据库自动生成，一般情况下无需人为赋值
    let id: Int
    /// 组名
    var name: String
    /// 该组图标名
    var icon: String?
    /// 该组的背景颜色
    var backgroundColor: String? //= GroupBackgroundColors.first!
    
    init(id: Int, name: String, icon: String? = nil, backgroundColor: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.backgroundColor = backgroundColor
    }
    
    /// 当前分组中的账号数量，该值并非存储于数据库中，需单独赋值。
    var count = 0
}

