//
//  Models.swift
//  MyRxRealm
//
//  Created by 醉翁之意 on 2022/11/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import EnolaGay
import RealmSwift

/// 账号模型
class Account: Object {
    /// 账号实体 id
    @Persisted(primaryKey: true) var id: ObjectId
    /// 账号名称
    @Persisted var hostName = ""
    /// 用户名
    @Persisted var userName = ""
    /// 密码
    @Persisted var password = ""
    /// 该账号的创建时间
    @Persisted private(set) var createTime = Date().judy.dateFromGMT()
    /// 该账号最近修改的时间
    @Persisted var updateTime = Date()
    /// 账号图标名
    @Persisted var icon: String?
    /// 该账号备注信息
    @Persisted var remark: String?
    /// 该账号是否已收藏
    @Persisted var isCollection = false
    /// 该账号所在的分组信息
    @Persisted(originProperty: "accounts") var group: LinkingObjects<Group>

    /// 该构造函数便捷地构建一个基础的 Account 对象
    convenience init(hostName: String = "", userName: String = "", password: String = "") {
        self.init()
        self.hostName = hostName
        self.userName = userName
        self.password = password
    }

}

/// 组模型
class Group: Object {
    /// 组 ID
    @Persisted(primaryKey: true) var id: ObjectId
    /// 组名
    @Persisted var groupName = ""
    /// 该组图标名
    @Persisted var icon: String?
    /// 组的背景颜色
    @Persisted var backgroundColor: String?
    /// 当前组中含有的账号
    @Persisted var accounts: List<Account>

    /// 当前分组中的账号数量，该值并非存储于数据库中，需单独查询。
    var count: Int { accounts.count }
}




// MARK: - 官方模型
/*
class DogToy: Object {
    @Persisted var id: ObjectId
    @Persisted var name = ""
}

class Dog: Object {
    @Persisted var name = ""
    @Persisted var age = 0
    @Persisted var color = ""
    @Persisted var currentCity = ""
    @Persisted var citiesVisited: MutableSet<String>
    @Persisted var companion: AnyRealmValue

    // To-one relationship
    @Persisted var favoriteToy: DogToy?

    // Map of city name -> favorite park in that city
    @Persisted var favoriteParksByCity: Map<String, String>
    
    // Computed variable that is not persisted, but only
    // used to section query results.
    var firstLetter: String {
        return name.first.map(String.init(_:)) ?? ""
    }
}
class Person: Object {
    @Persisted(primaryKey: true) var id = 0
    @Persisted var name = ""

    // To-many relationship - a person can have many dogs
    @Persisted var dogs: List<Dog>

    // Inverse relationship - a person can be a member of many clubs
    @Persisted(originProperty: "members") var clubs: LinkingObjects<DogClub>

    // Embed a single object.
    // Embedded object properties must be marked optional.
    @Persisted var address: Address?

    convenience init(name: String, address: Address) {
        self.init()
        self.name = name
        self.address = address
    }
}

class DogClub: Object {
    @Persisted var name = ""
    @Persisted var members: List<Person>

    // DogClub has an array of regional office addresses.
    // These are embedded objects.
    @Persisted var regionalOfficeAddresses: List<Address>

    convenience init(name: String, addresses: [Address]) {
        self.init()
        self.name = name
        self.regionalOfficeAddresses.append(objectsIn: addresses)
    }
}

class Address: EmbeddedObject {
    @Persisted var street: String?
    @Persisted var city: String?
    @Persisted var country: String?
    @Persisted var postalCode: String?
}
*/
