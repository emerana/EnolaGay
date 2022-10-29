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
    
    /// 该账号所对应的附加信息数据，如备注信息、分组信息
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
    
    /// 背景色值数据源。元素为16进制的 Int 形式数值。但打印值会自动转换成10进制，如 15493441.
    ///
    /// 使用 UIColor(rgbValue:) 函数直接通过元素生成颜色。
    static let backgroundColorValues: [Int] = [
        /// 淡红色
        0xec6941,
        /// 浅红橙
        0xf19149,
        /// 浅黄橙
        0xf8b551,
        /// 浅青豆绿
        0xb3d465,
        /// 浅黄绿
        0x80c269,
        /// 浅绿
        0x32b16c,
        /// 浅绿青
        0x13b5b1,
        /// 浅青
        0x00b7ee,
        /// 浅洋红
        0xea68a2,
        /// 浅蓝紫
        0x5f52a0,
        /// 浅紫洋红
        0xae5da1
    ]
    
    /// 该 id 由数据库自动生成，一般情况下无需人为赋值
    let id: Int
    /// 组名
    var name: String
    /// 该组图标名
    var icon: String?
    
    /// 该组的背景颜色,内容为16进制值，如“f19149”.
    ///
    /// 可通过 String(15493441,radix:16) 函数将某个10进制的值转成 16 进制的 String.
    var backgroundColor: String = String(backgroundColorValues.first!,radix:16)
    
    init(id: Int, name: String, icon: String? = nil, backgroundColor: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.backgroundColor = backgroundColor
    }
    
    /// 当前分组中的账号数量，该值并非存储于数据库中，需单独查询。
    var count = 0
}

