//
//  DataBaseCtrl.swift
//  数据库操作控制器
//
//  Created by 醉翁之意 on 2022/10/25.
//  Copyright © 2022 艾美拉娜.王仁洁. All rights reserved.
//

import EnolaGay
import FMDB

/// 数据库操作控制器
class DataBaseCtrl {
    /// 单例
    static let judy = DataBaseCtrl()
    
    /// 数据操作队列
    private var dbQueue: FMDatabaseQueue? = nil
    
    /// 数据库所在的沙盒完整路径
    var dataBaseSandboxPath: String {
        /*
         NSSearchPathForDirectoriesInDomains 方法用于查找目录，返回指定范围内的指定名称的目录的路径集合。有三个参数：
         
         directory:
         NSSearchPathDirectory类型的enum值，表明我们要搜索的目录名称，比如这里用NSDocumentDirectory表明我们要搜索的是Documents目录。
         如果我们将其换成NSCachesDirectory就表示我们搜索的是Library/Caches目录。
         
         domainMask:
         NSSearchPathDomainMask类型的enum值，指定搜索范围，这里的NSUserDomainMask表示搜索的范围限制于当前应用的沙盒目录。
         还可以写成NSLocalDomainMask（表示/Library）、NSNetworkDomainMask（表示/Network）等。
         
         expandTilde:
         BOOL值，表示是否展开波浪线。我们知道在iOS中的全写形式是/User/userName，该值为YES即表示写成全写形式，为NO就表示直接写成“~”。
         该值为NO: Caches目录路径    ~/Library/Caches
         该值为YES: Caches目录路径
         /var/mobile/Containers/Data/Application/E7B438D4-0AB3-49D0-9C2C-B84AF67C752B/Library/Caches
         */
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = documentsPath.appending("/\(EMERANA.Key.dataBaseName).db")
        return dbPath
    }
    
    /// 私有init,不允许构建对象
    private init() {}
    
}

// MARK: - 数据库操作
/*
 主要对象
 
 FMDatabase：一个单一的SQLite数据库，用于执行SQL语句。
 数据库对象，一个对象代表一个数据库，通过sqlite可进行增删改查。
 是一个提供 SQLite 数据库的类，用于执行 SQL 语句。这个类线程是不安全的，如果在多个线程中同时使用一个FMDatabase实例，会造成数据混乱等问题。
 
 FMResultSet：执行一个FMDatabase结果集。
 用在 FMDatabase 中执行查询的结果的类。
 返回操作数据库后的结果集

 FMDatabaseQueue：在多个线程中执行查询和更新时会用到这个类。
 多线程安全操作数据库 保证数据安全。
 在多线程下查询和更新数据库用到的类。
 */

extension DataBaseCtrl {
    /// 获取 FMDatabaseQueue 对象，该过程会自动创建数据库。
    func getDBQueue() -> FMDatabaseQueue {
        if dbQueue == nil {
            // 当 dbQueue 为空时从 Documents 目录获取完整路径。
            Judy.log("数据库 \(EMERANA.Key.dataBaseName) 沙盒路径：\(dataBaseSandboxPath)")
            // 该过程会自动创建数据库
            dbQueue = FMDatabaseQueue(path: dataBaseSandboxPath)
        } else {
            Judy.logHappy("dbQueue 当前不为空")
        }
        
        return dbQueue!
    }

}

// MARK: DDL-数据库定义
extension DataBaseCtrl {
    /// 所有数据表枚举
    private enum account_tables {
        /// 账号密码表
        case t_password
        /// 备注信息表
        case t_remarks
        /// 分组信息表
        case t_group
    }

    /**
     ！建表无先后顺序
     ！要注意主键约束写法
     ！主键不要设置外键
     */
    
    /// 创建密码信息表
    func create_Password() {
        let dbQueue = getDBQueue()
        dbQueue.inDatabase { (dataBase) in
            // ！！！注意：主键的SQL语句必须这样写，否则失效！
            let sql = "CREATE TABLE IF NOT EXISTS '\(account_tables.t_password)' (" +
            "'id_account' INTEGER PRIMARY KEY AUTOINCREMENT," +
            "'userName' TEXT NOT NULL," +
            "'password' TEXT NOT NULL," +
            "'createTime' TEXT NOT NULL," +
            "'updateTime' TEXT NOT NULL)"
            
            let result = dataBase.executeUpdate(sql, withArgumentsIn: [])
            if !result {
                JudyTip.message(text: "\(account_tables.t_password)创建失败！")
            }
        }
        
    }
    
    /// 创建备注信息表
    func create_remarks() {
        let dbQueue = getDBQueue()
        dbQueue.inDatabase { (dataBase) in
            let sql = "CREATE TABLE IF NOT EXISTS '\(account_tables.t_remarks)' (" +
            "'id_account' INTEGER NOT NULL UNIQUE," +
            "'icon' TEXT," +
            "'remark' TEXT," +
            "'id_group' INTEGER," +
            "'collection' BLOB DEFAULT 0," +
            "FOREIGN KEY('id_group') REFERENCES '\(account_tables.t_group)'('id_group')," +
            "FOREIGN KEY('id_account') REFERENCES '\(account_tables.t_password)'('id_account'))"
            
            let result = dataBase.executeUpdate(sql, withArgumentsIn: [])
            if !result {
                JudyTip.message(text: "\(account_tables.t_remarks)创建失败！")
            }
        }
        
    }
    
    /// 创建分组信息表
    func create_group() {
        let dbQueue = getDBQueue()
        dbQueue.inDatabase { (dataBase) in
            let sql = "CREATE TABLE IF NOT EXISTS '\(account_tables.t_group)' (" +
            "'id_group' INTEGER PRIMARY KEY AUTOINCREMENT," +
            "'groupName' TEXT NOT NULL UNIQUE," +
            "'icon' TEXT," +
            "'backgroundColor' TEXT)"
            
            let result = dataBase.executeUpdate(sql, withArgumentsIn: [])
            if !result {
                JudyTip.message(text: "\(account_tables.t_group)创建失败！")
            }
        }
        
    }

}

// MARK: DML - 数据操作
extension DataBaseCtrl {
    
    /// 新增一条账号数据
    ///
    /// 该函数仅操作密码表
    /// - Parameters:
    ///   - account: 账号模型实体，其中的 id、createTime、updateTime 可随意传入
    ///   - callback: 回调,告知是否成功
    @available(*, unavailable, message: "请使用 addNewData 泛型函数", renamed: "addNewData(model:)")
    func addNewAccount(account: Account, callback: ((Bool) -> Void)) {
        let queue = getDBQueue()
        queue.inTransaction { dataBase, rollback in
            do {
                // 密码表新增一条记录 SQL
                let sqlPassword = "INSERT INTO \(account_tables.t_password) (userName, password, createTime, updateTime)" +
                " VALUES (?, ?, DATETIME('now','localtime'), DATETIME('now','localtime'))"
                try dataBase.executeUpdate(sqlPassword, values: [account.name, account.password])
            } catch {
                Judy.logWarning("新增数据:\(account.name),\(account.password) 写入失败！==\(error.localizedDescription)")
                
                rollback.pointee = true
            }

            callback(!rollback.pointee.boolValue)
        }

    }
        
    /// 通过该函数向数据库添加一条数据
    ///
    /// 根据传入的 model 类型向指定的表插入数据，该函数仅作用于 t_account、t_group、t_remarks 这三张表。
    ///
    /// - Parameters:
    ///   - model: 要添加的对象，其中的 id 或部分属性可随意传入，根据实际传入类型决定。
    ///   - callback:  该回调函数通过传入一个 Bool 值告知是否添加成功，并伴随消息体。
    /// - Warning: 传入的 model 仅支持 Account、Group 模型。
    func addNewData<T>(model: T, callback: ((Bool, String?) -> Void)) {
        let queue = getDBQueue()
        var callbackMessage: String?
        queue.inTransaction { dataBase, rollback in
            do {
                /* 顺便插入 t_remarks
                if account.remark != nil {
                    let sqlRemark = "INSERT INTO \(account_tables.t_remarks) (id_account, id_group, remark, collection) VALUES (?,?,?,?)"
                    try dataBase.executeUpdate(sqlRemark, values: [account.id])
                }*/
                /// 操作的 SQL
                let execSQL: String
                switch model {
                case is Group:
                    // 分组表新增一条记录 SQL
                    execSQL = "INSERT INTO \(account_tables.t_group) (groupName, icon, backgroundColor)" +
                    " VALUES (?, ?, ?)"
                    
                    let group = model as! Group
                    try dataBase.executeUpdate(execSQL, values: [group.name, group.icon ?? NSNull(), group.backgroundColor])

                case is Account:
                    // 密码表新增一条记录 SQL
                    execSQL = "INSERT INTO \(account_tables.t_password) (userName, password, createTime, updateTime)" +
                    " VALUES (?, ?, DATETIME('now','localtime'), DATETIME('now','localtime'))"
                    let account = model as! Account
                    try dataBase.executeUpdate(execSQL, values: [account.name, account.password])
                default:
                    Judy.logWarning("传入了无用的模型。")
                }
            } catch {
                callbackMessage = error.localizedDescription
                Judy.logWarning("新增数据:\(model) 写入失败！==\(String(describing: callbackMessage))")
                rollback.pointee = true
            }

            callback(!rollback.pointee.boolValue, callbackMessage)
        }
    }
    
    /// 删除一个账号
    /// - Parameters:
    ///   - account: 要删除的账号对象
    ///   - callback: 该回调函数通过传入一个 Bool 值告知是否添加成功，并伴随消息体。
    func deleteAccount(account: Account, callback: ((Bool, String?) -> Void)) {
        let queue = getDBQueue()
        var callbackMessage: String?
        queue.inTransaction { dataBase, rollback in
            do {
                /// 操作的 SQL
                let deleteRemark: String = "DELETE FROM \(account_tables.t_remarks) WHERE id_account = ?"
                let deletePassword: String = "DELETE FROM \(account_tables.t_password) WHERE id_account = ?"
                
                try dataBase.executeUpdate(deleteRemark, values: [account.id])
                try dataBase.executeUpdate(deletePassword, values: [account.id])
            } catch {
                callbackMessage = error.localizedDescription
                Judy.logWarning("删除数据id:\(account.id) 失败！==\(String(describing: callbackMessage))")
                rollback.pointee = true
            }

            callback(!rollback.pointee.boolValue, callbackMessage)
        }
    }
    
    /// 修改账号信息
    /// - Parameters:
    ///   - account: 目标账号
    ///   - callback: 该回调函数通过传入一个 Bool 值告知是否添加成功，并伴随消息体。
    func modifyAccount(account: Account, callback: ((Bool, String?) -> Void)) {
        let queue = getDBQueue()
        var callbackMessage: String?
        queue.inTransaction { dataBase, rollback in
            do {
                /// 修改 password
                let passwordSQL = "UPDATE \(account_tables.t_password) SET userName=?, password=?, updateTime=DATETIME('now','localtime')  WHERE id_account=?"
                try dataBase.executeUpdate(passwordSQL, values: [account.name, account.password, account.id])
                
                /// 修改 remark
                let remarkSQL = "SELECT * FROM \(account_tables.t_remarks)" +
                " WHERE \(account_tables.t_remarks).id_account = ?"
                let resultSet = dataBase.executeQuery(remarkSQL, withArgumentsIn: [account.id])
                
                if (resultSet?.next() ?? false) { // 说明已存在 remark
                    Judy.log("存在 remark，执行修改操作") // 修改
                    let remarkSQL = "UPDATE \(account_tables.t_remarks) SET icon=?, id_group=?, remark=?, collection=0  WHERE id_account=?"
                    try dataBase.executeUpdate(remarkSQL,
                                               values: [account.remark?.icon ?? NSNull(),
                                                        account.remark?.group?.id ?? NSNull(),
                                                        account.remark?.remark ?? NSNull(),
                                                        account.id])
                } else {
                    Judy.log("不存在 remark，执行添加操作") // 插入
                    let remarkSQL = "INSERT INTO \(account_tables.t_remarks) (id_account, icon, id_group, remark)" +
                    " VALUES (?, ?, ?, ?)"
                    try dataBase.executeUpdate(remarkSQL,
                                               values: [account.id,
                                                        account.remark?.icon ?? NSNull(),
                                                        account.remark?.group?.id ?? NSNull(),
                                                        account.remark?.remark ?? NSNull()])
                }

            } catch {
                callbackMessage = error.localizedDescription
                Judy.logWarning("修改数据id:\(account.id) 失败！==\(String(describing: callbackMessage))")
                rollback.pointee = true
            }

            callback(!rollback.pointee.boolValue, callbackMessage)
        }
    }

}

// MARK: DQL - 数据查询
extension DataBaseCtrl {
    
    /// 获取数据库中的账号数量
    func getAccountsCount() -> Int {
        let db = getDBQueue()
        var count = 0
        db.inTransaction { (dataBase, rollback) in
            let sql = "SELECT COUNT(*) FROM \(account_tables.t_password)"
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                Judy.logWarning("没有这张表：\(account_tables.t_password)")
                return
            }
            if resultSet!.next() {
                // 查询 COUNT(*) 要用这样的方式获取具体数值
                count = resultSet?.resultDictionary?.first?.value as? Int ?? 0
            }
        }
        return count
    }
    
    /// 获取数据库中的分组数量
    func getGroupCount() -> Int {
        let db = getDBQueue()
        var count = 0
        db.inTransaction { (dataBase, rollback) in
            let sql = "SELECT COUNT(*) FROM \(account_tables.t_group)"
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            if resultSet!.next() {
                // 查询 COUNT(*) 要用这样的方式获取具体数值
                count = resultSet?.resultDictionary?.first?.value as? Int ?? 0
            }
        }
        return count
    }

    /// 获取数据库中所有的 account 数据
    /// - Parameter group: 查询指定组下的 account 数据，该值默认为 nil，即查询所有。
    /// - Returns: 目标 account 列表
    func getAccountList(group: Group? = nil) -> [Account] {
        var accounts = [Account]()

        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            let sql: String
            if group == nil {
                // 默认按数据库顺序排序
                sql = "SELECT * FROM \(account_tables.t_password)" // ORDER BY name DESC
            } else {
                // 查询指定组下所有数据，此处需三表查询。
                sql = "SELECT * FROM \(account_tables.t_password)" +
                 " LEFT JOIN t_remarks" +
                 " on \(account_tables.t_password).id_account = \(account_tables.t_remarks).id_account" +
                 " LEFT JOIN \(account_tables.t_group)" +
                 " on \(account_tables.t_remarks).id_group = \(account_tables.t_group).id_group" +
                " WHERE \(account_tables.t_group).id_group = \(group!.id)" // ORDER BY userName
            }
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "数据查询失败！")
                return
            }

            while(resultSet!.next()) {
                let account = resultSetToAccount(resultSet: resultSet!)
                accounts.append(account)
            }
        }
        return accounts
    }
    
    /// 获取所有分组数据
    /// - Returns: 分组列表
    func getGroupList() -> [Group] {
        let db = getDBQueue()
        var groups = [Group]()
        db.inTransaction { (dataBase, rollback) in
            let sql = "SELECT * FROM \(account_tables.t_group)" // ORDER BY name DESC
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                Judy.logWarning("没有这张表：\(account_tables.t_group)")
                return
            }
            
            while(resultSet!.next()) {
                let gr = Group(id: Int(resultSet!.int(forColumn: "id_group")),
                               name: resultSet!.string(forColumn: "groupName") ?? "组名缺失",
                               icon: resultSet!.string(forColumn: "icon"),
                               backgroundColor: resultSet!.string(forColumn: "backgroundColor") ?? "362e2b")
                // 查询当前 group 中的账号数量
                let sql_GroupInfo = "SELECT COUNT(*) FROM \(account_tables.t_remarks)" +
                " LEFT JOIN \(account_tables.t_group)" +
                " ON \(account_tables.t_remarks).id_group = \(account_tables.t_group).id_group" +
                " WHERE \(account_tables.t_remarks).id_group = \(gr.id)"
                // 查询
                let groupInfoRs = dataBase.executeQuery(sql_GroupInfo, withArgumentsIn: [])
                guard groupInfoRs != nil else {
                    Judy.logWarning("查询组成员信息失败，结果为0")
                    return
                }
                if groupInfoRs!.next() {
                    // 查询 COUNT(*) 要用这样的方式获取具体数值
                    gr.count = groupInfoRs?.resultDictionary?.first?.value as? Int ?? 0
                    Judy.log("组“\(gr.name)”有 \(gr.count) 人")
                }
                
                groups.append(gr)
            }
        }
        return groups
    }

    @available(*, unavailable, message: "该函数已被优化，请使用 getAccountList 函数", renamed: "getAccountList(group:)")
    func getGroupDataList(group: Group) -> [Account] {
        var accounts = [Account]()
        
        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            // 查询指定组下所有数据，此处需三表查询。
            let sql = "SELECT * FROM \(account_tables.t_password)" +
             " LEFT JOIN t_remarks" +
             " on \(account_tables.t_password).id_account = \(account_tables.t_remarks).id_account" +
             " LEFT JOIN \(account_tables.t_group)" +
             " on \(account_tables.t_remarks).id_group = \(account_tables.t_group).id_group" +
            " WHERE \(account_tables.t_group).id_group = \(group.id)" // ORDER BY userName
            
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "组下数据查询失败！")
                return
            }
            
            while(resultSet!.next()) {
                let account = resultSetToAccount(resultSet: resultSet!)
                accounts.append(account)
            }
        }
        return accounts
    }
    
    /// 查询 account 的附加信息 AccountRemark.
    /// - Parameter account: 要查询的目标 account
    /// - Returns: 目标 AccountRemark
    func getAccountRemark(account: Account) -> AccountRemark? {
        var remark: AccountRemark?
        
        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            // 查询指定组下所有数据，此处查询 t_remarks 和 t_group。
            let sql = "SELECT * ," +
            " \(account_tables.t_remarks).icon AS account_icon," +
            " \(account_tables.t_group).icon AS group_icon" +
            " FROM \(account_tables.t_remarks)" +
            " LEFT JOIN \(account_tables.t_group)" +
            " on \(account_tables.t_remarks).id_group = \(account_tables.t_group).id_group" +
            " WHERE \(account_tables.t_remarks).id_account = \(account.id)"
            
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "备注信息数据查询失败！")
                return
            }
            
            if resultSet!.next() {
                remark = AccountRemark(id: Int(resultSet!.int(forColumn: "id_account")),
                                       group: nil,
                                       remark: resultSet!.string(forColumn: "remark"))
                remark?.icon = resultSet!.string(forColumn: "account_icon")
                remark?.isCollection = Int(resultSet!.int(forColumn: "collection")) == 1
                
                // 查询组信息
                let group: Group?
                if resultSet!.int(forColumn: "id_group") != 0 {
                    group = Group(id: Int(resultSet!.int(forColumn: "id_group")),
                                      name: resultSet!.string(forColumn: "groupName") ?? "数据库缺失值",
                                      backgroundColor: resultSet!.string(forColumn: "backgroundColor") ?? "数据库缺失值")
                    
                    group?.icon = resultSet!.string(forColumn: "group_icon")
                } else {
                    group = nil
                }
                remark?.group = group
            }
        }
        
        return remark
    }
    
    /// 查询指定 Account 主要信息
    /// - Parameter accountID: 要查询的目标
    /// - Returns: password 表中的 Account 对象，不包含 AccountRemark 信息。
    func getAccountDetail(accountID: Int) -> Account? {
        var account: Account?
        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            // 默认按数据库顺序排序
            let sql = "SELECT * FROM \(account_tables.t_password) WHERE id_account = ?"
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [accountID])
            guard resultSet != nil else {
                JudyTip.message(text: "查无此表！")
                return
            }
            
            if resultSet!.next() {
                account = resultSetToAccount(resultSet: resultSet!)
            }
            
        }
        return account
    }
    
}

// MARK: - 私有函数
private extension DataBaseCtrl {
    
    /// 将数据库查询结果转换成 Account 对象
    /// - Parameter resultSet: 查询结果集
    /// - Returns: 目标 Account.
    func resultSetToAccount(resultSet: FMResultSet) -> Account {
        let account = Account(id: Int(resultSet.int(forColumn: "id_account")),
                              name: resultSet.string(forColumn: "userName") ?? "数据库缺失值",
                              password: resultSet.string(forColumn: "password") ?? "数据库缺失值",
                              createTime: resultSet.string(forColumn: "createTime") ?? "数据库缺失值",
                              updateTime: resultSet.string(forColumn: "updateTime") ?? "数据库缺失值")
        
        return account
    }
    
}
/*
extension DataBaseCtrl {
    /// 按关键字检索基金信息表。
    /// - Parameter keywords: 要搜索的关键字，将通过该关键字匹配基金名称和基金代码
    /// - Parameter isAllColumn: 是否全字段匹配搜索，默认 false。如果该值传入 true，则通过keywords匹配所有字段
    func searchFundListBy(keywords: String, isAllColumn: Bool = false) -> [Fund] {
        var searchText = ""
        var index = keywords.startIndex
        while index != keywords.endIndex {
            searchText += "\(keywords[index])%"
            index = keywords.index(after: index)
        }
        Judy.log("搜索关键字：" + searchText)

        var fundList = [Fund]()
        
        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            /*
             排序查询。原理是先对这个表进行排序再取出结果
             SELECT * FROM Consult ORDER BY add_time DESC LIMIT %d,%d  按add_time  减序排列
             SELECT * FROM Consult ORDER BY add_time ASC LIMIT %d,%d 按add_time 升序排列，默认值
             
             搜索语句
             SELECT * FROM t_fundInfoList WHERE fundName like "%1%" OR fundID like "%1%"
             */
            var sql = "SELECT * FROM \(fund_tables.t_fundInfoList) WHERE fundName like '%\(searchText)' OR fundID like '%\(searchText)'"
            
            if isAllColumn {
                sql += " OR similarRanking like '%\(searchText)'"
                sql += " OR institutionalView like '%\(searchText)'"
                sql += " OR institutionalPotential like '%\(searchText)'"
                sql += " OR institutionalFeatured like '%\(searchText)'"
                sql += " OR fundType like '%\(searchText)'"
                sql += " OR remark like '%\(searchText)'"
            }
            
//            sql += " ORDER BY isStarManager DESC"
            let resultSet = db.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "查无此表！")
                return
            }
            
            fundList.removeAll()
            while(resultSet!.next()) {
                let fund = resultSetToFund(resultSet: resultSet!)
                fundList.append(fund)
            }
        }

        return fundList
    }
    
    
}
*/
/*
 /*倒序查询*/
 SELECT * FROM t_fundInfoList ORDER BY isStarManager DESC

 /*两表联接查询*/
 SELECT * FROM t_fundInfoList INNER JOIN t_fundOptional on t_fundInfoList.fundID = t_fundOptional.fundID

 /*多表联接查询*/
 SELECT * FROM t_fundInfoList INNER JOIN t_fundOptional on t_fundInfoList.fundID = t_fundOptional.fundID INNER JOIN t_investment on t_fundInfoList.fundID = t_investment.fundID
 
  SELECT * FROM t_fundInfoList LEFT JOIN t_fundOptional on t_fundInfoList.fundID = t_fundOptional.fundID LEFT JOIN t_investment on t_fundInfoList.fundID = t_investment.fundID

 */

/*
extension DataBaseCtrl {
    
    /// 创建基金自选表
    func createOptionalTable() {
        
        let dbQueue = getDBQueue()
        dbQueue.inDatabase { (dataBase) in
            //  创建基金信息表
            let sql = "CREATE TABLE IF NOT EXISTS '\(fund_tables.t_fundOptional)' (" +
                "'fundID' TEXT PRIMARY KEY," +
                "'fundName' TEXT NOT NULL)"
            
            let result = dataBase.executeUpdate(sql, withArgumentsIn: [])
            
            if !result {
                JudyTip.message(text: "\(fund_tables.t_fundOptional)创建失败！")
            }
        }
    }
    
}
*/

// MARK: - 定投基金表操作
/*
extension DataBaseCtrl {
    
    /// 创建定投表
    func createInvestmentTable() {
        
        let dbQueue = getDBQueue()
        dbQueue.inDatabase { (dataBase) in
            //  创建基金信息表
            let sql = "CREATE TABLE IF NOT EXISTS '\(fund_tables.t_investment)' (" +
                "'fundID' TEXT PRIMARY KEY," +
                "'fundName' TEXT NOT NULL," +
                "'amount' INTEGER DEFAULT 188," + //  投资金额
                "'investmentType' TEXT NOT NULL," + //  投资类型
                "'dayForInvestmentType' TEXT NOT NULL," + //  投资日期
            "'remark' TEXT)"  // 备注
            
            let result = dataBase.executeUpdate(sql, withArgumentsIn: [])
            
            if !result {
                JudyTip.message(text: "\(fund_tables.t_investment)创建失败！")
            }
        }
    }
    
    
    /// 查询已购/定投基金列表
    func getInvestmentList() -> [FundPurchased] {
        /// 本类数据源
        var fundPurchasedList = [FundPurchased]()

        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            /*
             排序查询。原理是先对这个表进行排序再取出结果
             SELECT * FROM Consult ORDER BY add_time DESC LIMIT %d,%d  按add_time  减序排列
             SELECT * FROM Consult ORDER BY add_time ASC LIMIT %d,%d 按add_time 升序排列，默认值
             
             SELECT t_fundInfoList.*, t_investment.amount, t_investment.investmentType, t_investment.dayForInvestmentType, t_investment.remark as investmentRemark FROM t_fundInfoList INNER JOIN t_investment ON t_fundInfoList.fundID = t_investment.fundID
             */

            let sql = "SELECT \(fund_tables.t_fundInfoList).*, \(fund_tables.t_investment).amount, \(fund_tables.t_investment).investmentType, \(fund_tables.t_investment).dayForInvestmentType, \(fund_tables.t_investment).remark as investmentRemark FROM \(fund_tables.t_fundInfoList) INNER JOIN \(fund_tables.t_investment) ON \(fund_tables.t_fundInfoList).fundID = \(fund_tables.t_investment).fundID ORDER by \(fund_tables.t_investment).ROWID"
            let resultSet = db.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "查无此表！")
                return
            }
            
            while(resultSet!.next()) {
                let fundPurchased = resultSetToFundPurchased(resultSet: resultSet!)
                fundPurchasedList.append(fundPurchased)
            }
        }
        return fundPurchasedList
    }

    
    /// 添加一条定投/已购基金记录
    /// - Parameter fundPurchased: 定投基金对象
    func addInvestment(fundPurchased: FundPurchased, callback:((Bool) -> Void)) {

        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            let sql = "INSERT INTO \(fund_tables.t_investment) (fundID, fundName, amount, investmentType, dayForInvestmentType, remark) VALUES (?,?,?,?,?,?)"
            
            let result = db.executeUpdate(sql, withArgumentsIn: [fundPurchased.fund.fundID, fundPurchased.fund.fundName, fundPurchased.amount, fundPurchased.investmentType.rawValue, fundPurchased.dayForInvestmentType, fundPurchased.remark ?? ""])
            if result {
                Judy.log("\(fundPurchased.fund.fundID)写入定投成功")
            } else {
                Judy.log("\(fund_tables.t_fundOptional)-基金：\(fundPurchased.fund.fundName)信息写入失败！")
                rollback.pointee = true
            }
            callback(!rollback.pointee.boolValue)
        }
    }

}
*/
/*
 SELECT *,order.id AS oid,farmer.id AS fid,farmer.name AS fname,farmer.type AS ftype FROM `order` LEFT JOIN farmer ON order.fid = farmer.id WHERE ( order.id = '10000067' ) LIMIT 1

 SELECT * FROM t_fundInfoList LEFT JOIN t_fundOptional ON t_fundInfoList.fundID = t_fundOptional.fundID LEFT JOIN t_investment ON t_fundInfoList.fundID = t_investment.fundID;
 
 同名字段别名查询法
 SELECT *, t_investment.fundID as testID FROM t_fundInfoList LEFT JOIN  t_investment ON t_fundInfoList.fundID = t_investment.fundID WHERE ( t_fundInfoList.fundID = '161226' )

 */

// MARK: - Similar Ranking table operating - 同类排名表操作
/*
extension DataBaseCtrl {
    
    /// 创建同类排名表
    func createSimilarTable() {
        
        let dbQueue = getDBQueue()
        dbQueue.inDatabase { (dataBase) in
            //  创建基金信息表
            let sql = "CREATE TABLE IF NOT EXISTS '\(fund_tables.t_similar)' (" +
                "'fundID' TEXT PRIMARY KEY," +
                "'grade' TEXT NOT NULL," +
                "'amount' INTEGER DEFAULT 188," + //  投资金额
                "'investmentType' TEXT NOT NULL," + //  投资类型
                "'dayForInvestmentType' TEXT NOT NULL," + //  投资日期
            "'remark' TEXT)"  // 备注
            
            let result = dataBase.executeUpdate(sql, withArgumentsIn: [])
            
            if !result {
                JudyTip.message(text: "\(fund_tables.t_investment)创建失败！")
            }
        }
    }
    
}

*/
// MARK: - 导出

import  SQLite3
/*
extension DataBaseCtrl {

    func exportCSV() {
//        sqlite3_finalize
//        SQLITE_ROW
//        sqlite3_prepare_v2
//        sqlite3_stmt
//        sqlite3_step(<#T##OpaquePointer!#>)
    }
    
    // 上传到 iCloud
    func exportiCloud() {
    
    }
    
    /// 导出文件
//    #warning("该方法未证实有效……")
    @available(*, unavailable, message: "请勿使用该函数")
    func export() {

        let docuPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbPath = docuPath.appending("/\(dataBaseName).db")

        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        
        do{
            try FileManager.default.copyItem(atPath: dbPath, toPath: cachePath!)
            print("Success to copy file.")
            let documentController = UIDocumentInteractionController(url: NSURL(fileURLWithPath: dbPath) as URL)
            //        documentController.uti = "-"
            documentController.presentOpenInMenu(from: .zero, in: Judy.topViewCtrl.view, animated: true)
        }catch{
            print("Failed to copy file.")
        }
        
    }
    
}*/
