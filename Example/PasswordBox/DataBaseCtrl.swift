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
            "'id_group' INTEGER," +
            "'remark' TEXT," +
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
    
    /// 添加一条账号数据
    ///
    /// 该函数同时操作密码表和备注表。
    /// - Parameter callback: 回调
    func addNewAccount(callback: ((Bool) -> Void)) {
        let queue = getDBQueue()
        queue.inTransaction { db, rollback in
            do {
                // 密码表新增一条记录 SQL
                let sqlPassword = "INSERT INTO \(account_tables.t_password) (institutionalFeatured) VALUES (?,?,,?,?,?)"
                // 备注新增一条记录 SQL
                let sqlRemark = "INSERT INTO \(account_tables.t_remarks) (institutionalFeatured) VALUES (?,?,?,?,?,?,?,?)"
                try db.executeUpdate(sqlPassword, values: [1])
                try db.executeUpdate(sqlRemark, values: [2])
            } catch {
                rollback.pointee = true
            }
//            callback()
        }

//        db.inTransaction { (db, rollback) in
//            let sql = "INSERT INTO \(account_tables.t_password) (fundID, fundName, similarRanking, fundstarRating, fundRating, isStarManager, institutionalView, institutionalPotential, institutionalFeatured, fundType, remark) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
            
//            for fund in funds {
//                let result = db.executeUpdate(sql, withArgumentsIn: [fund.fundID, fund.fundName, "\(fund.similarRanking)", fund.fundStarRating, fund.fundRating, fund.isStarManager, fund.institutionalView.rawValue, fund.institutionalPotential.rawValue, fund.institutionalFeatured.rawValue, fund.fundType.rawValue, fund.remark])
//                if result {
//                    print("\(fund.fundID)写入成功")
//                } else {
//                    print("新插入基金信息：\(fund.fundID)写入失败！")
//                    rollback.pointee = true
//
//                    break
//                }
//            }
//            callback(!rollback.pointee.boolValue)
//        }
        
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

    /// 获取数据库中所有的 account 并转换成模型
    func getAccountList() -> [Account] {
        var accounts = [Account]()

        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            /*
             排序查询。原理是先对这个表进行排序再取出结果
             SELECT * FROM Consult ORDER BY add_time DESC LIMIT %d,%d  按add_time  减序排列
             SELECT * FROM Consult ORDER BY add_time ASC LIMIT %d,%d 按add_time 升序排列，默认值
             
             三张表一块查询
             SELECT *, t_fundOptional.fundID AS isOption, t_investment.fundID AS isInvestment FROM t_fundInfoList LEFT JOIN  t_fundOptional ON t_fundInfoList.fundID = t_fundOptional.fundID LEFT JOIN t_investment ON t_fundInfoList.fundID = t_investment.fundID ORDER BY isStarManager DESC
             
             SELECT t_fundInfoList.*, t_fundOptional.fundID AS isOption, t_investment.fundID AS isInvestment FROM t_fundInfoList LEFT JOIN  t_fundOptional ON t_fundInfoList.fundID = t_fundOptional.fundID LEFT JOIN t_investment ON t_fundInfoList.fundID = t_investment.fundID ORDER BY isStarManager DESC
             */
            
            //  三张表一块查询
            //            let sql = "SELECT \(fund_tables.t_fundInfoList).*, \(fund_tables.t_fundOptional).fundID AS isOption, \(fund_tables.t_investment).fundID AS isInvestment FROM \(fund_tables.t_fundInfoList) LEFT JOIN  \(fund_tables.t_fundOptional) ON \(fund_tables.t_fundInfoList).fundID = \(fund_tables.t_fundOptional).fundID LEFT JOIN \(fund_tables.t_investment) ON \(fund_tables.t_fundInfoList).fundID = \(fund_tables.t_investment).fundID ORDER BY isStarManager DESC"
            // 默认按数据库顺序排序
            let sql = "SELECT * FROM \(account_tables.t_password)" // ORDER BY name DESC
            let resultSet = dataBase.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "查无此表！")
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
    /// - Returns: 所有的分组信息
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
                               backgroundColor: resultSet!.string(forColumn: "backgroundColor"))
                // 查询当前 group 中的账号数量
//                let sql_GroupInfo = "SELECT \(account_tables.t_remarks).id_account, \(account_tables.t_remarks).id_group, \(account_tables.t_group).groupName" +
//                 " FROM \(account_tables.t_remarks)" +
//                 " LEFT JOIN \(account_tables.t_group)" +
//                 " ON \(account_tables.t_remarks).id_group = \(account_tables.t_group).id_group" +
//                 " WHERE \(account_tables.t_remarks).id_group = \(gr.id)"
                let sql_GroupInfo = "SELECT COUNT(*) FROM \(account_tables.t_remarks)" +
                " LEFT JOIN \(account_tables.t_group)" +
                " ON \(account_tables.t_remarks).id_group = \(account_tables.t_group).id_group" +
                " WHERE \(account_tables.t_remarks).id_group = \(gr.id)"

                let groupInfoRs = dataBase.executeQuery(sql_GroupInfo, withArgumentsIn: [])
                guard groupInfoRs != nil else {
                    Judy.logWarning("查询组成员信息失败，结果为0")
                    return
                }
                if groupInfoRs!.next() {
                    // 查询 COUNT(*) 要用这样的方式获取具体数值
                    gr.count = groupInfoRs?.resultDictionary?.first?.value as? Int ?? 0
                    Judy.log("\(gr.name) 有 \(gr.count) 人")
                }
                
                groups.append(gr)
            }
        }
        return groups
    }
    
    /// 获取指定组下的所有账号数据
    /// - Parameter group: 目标组
    /// - Returns: 该组下对应的账号数据
    func getGroupDataList(group: Group) -> [Account] {
        var accounts = [Account]()
        
        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            // 查询指定组下所有数据
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

}

// MARK: - 私有函数
private extension DataBaseCtrl {
    
    /// 将数据库查询结果转换成 Account 对象
    /// - Parameter resultSet: 查询结果集
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

    /// 修改基金信息
    /// - Parameter fund: 基金模型
    func updateFundInfo(fund: Fund, callback:((Bool) -> Void)) {
        
        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            let sql = "UPDATE \(fund_tables.t_fundInfoList) SET fundName = ?, similarRanking = ?, fundstarRating = ?, fundRating = ?, isStarManager = ?, institutionalView = ?, institutionalPotential = ?, institutionalFeatured = ?, fundType = ?, remark = ? WHERE fundID = ?"
            
            let result = db.executeUpdate(sql, withArgumentsIn: [fund.fundName, "\(fund.similarRanking)", fund.fundStarRating, fund.fundRating, fund.isStarManager, fund.institutionalView.rawValue, fund.institutionalPotential.rawValue, fund.institutionalFeatured.rawValue, fund.fundType.rawValue, fund.remark, fund.fundID])
            if result {
                print("\(fund.fundID)修改成功")
            } else {
                print("基金：\(fund.fundName)信息修改失败！")
                rollback.pointee = true
            }
            
            callback(!rollback.pointee.boolValue)
        }
        
    }
    

    /// 删除一条基金信息记录
    /// - 此操作将同步删除自选基金表和定投基金表
    /// - Parameter fundID: 基金ID
    /// - Parameter callback: 回调函数
    func deleteFundInfo(fundID: String, callback:((Bool) -> Void)) {
        let db = getDBQueue()
        db.inTransaction { (dataBase, rollback) in
            let sqls = [
                "delete from \(fund_tables.t_fundInfoList) where fundID = ?",
                "delete from \(fund_tables.t_investment) where fundID = ?",
                "delete from \(fund_tables.t_fundOptional) where fundID = ?"
            ]
            
            sqls.forEach { (sql) in
                let result = dataBase.executeUpdate(sql, withArgumentsIn: [fundID])
                
                if result {
                    print("\(sql)---\(fundID)删除成功")
                } else {
                    print("\(fund_tables.t_fundInfoList)-基金：\(fundID)信息删除失败！")
                    rollback.pointee = true
                    return
                }
            }
            
            callback(!rollback.pointee.boolValue)
            
        }
    }
    
    
    /// 获取基金详情
    /// - Parameter fundID: fund ID
    func getFundDetail(fundID: String) -> Fund? {
        var fund: Fund? = nil
        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            /*
SELECT t_fundInfoList.*, t_fundOptional.fundID AS isOption, t_investment.fundID AS isInvestment FROM t_fundInfoList LEFT JOIN  t_fundOptional ON t_fundInfoList.fundID = t_fundOptional.fundID LEFT JOIN t_investment ON t_fundInfoList.fundID = t_investment.fundID WHERE t_fundInfoList.fundID = '163402'             */
            let sql = "SELECT \(fund_tables.t_fundInfoList).*, \(fund_tables.t_fundOptional).fundID AS isOption, \(fund_tables.t_investment).fundID AS isInvestment FROM \(fund_tables.t_fundInfoList) LEFT JOIN  \(fund_tables.t_fundOptional) ON \(fund_tables.t_fundInfoList).fundID = \(fund_tables.t_fundOptional).fundID LEFT JOIN \(fund_tables.t_investment) ON \(fund_tables.t_fundInfoList).fundID = \(fund_tables.t_investment).fundID WHERE \(fund_tables.t_fundInfoList).fundID = ?"
            let resultSet = db.executeQuery(sql, withArgumentsIn: [fundID])
            guard resultSet != nil else {
                JudyTip.message(text: "数据库结果集为nil！")
                return
            }
            while(resultSet!.next()) {
                fund = resultSetToFund(resultSet: resultSet!, isDetail: true)
            }
            
        }
        return fund
        
    }
    
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
    
    
    /// 添加一条自选基金记录
    /// - Parameter fund: 基金对象
    func addOptional(fund: Fund, callback:((Bool) -> Void)) {
        
        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            let sql = "INSERT INTO \(fund_tables.t_fundOptional) (fundID, fundName) VALUES (?,?)"
            
            let result = db.executeUpdate(sql, withArgumentsIn: [fund.fundID, fund.fundName])
            if result {
                Judy.log("\(fund.fundID)写入成功")
            } else {
                Judy.log("\(fund_tables.t_fundOptional)-基金：\(fund.fundName)信息写入失败！")
                rollback.pointee = true
            }
            callback(!rollback.pointee.boolValue)
        }
    }
    
    /// 删除一条自选基金记录或定投记录
    /// - Parameter fundID: 基金代码
    /// - Parameter isInvestment: 是否操作定投基金表，默认false
    /// - Parameter callback: 回调函数，将传入操作结果值
    func deleteOptionalOrInvestment(fundID: String, isInvestment: Bool = false, callback:((Bool) -> Void)) {
        
        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            let sql = "delete from \(isInvestment ?fund_tables.t_investment:fund_tables.t_fundOptional) where fundID = ?"
            let result = db.executeUpdate(sql, withArgumentsIn: [fundID])
            if result {
                print("\(fundID)删除成功")
            } else {
                print("\(fund_tables.t_fundOptional)-基金：\(fundID)信息删除失败！")
                rollback.pointee = true
            }
            callback(!rollback.pointee.boolValue)
        }
    }
    
    /// 查询自选基金列表
    func getOptionList() -> [Fund] {
        /// 本类数据源
        var fundList = [Fund]()

        let db = getDBQueue()
        db.inTransaction { (db, rollback) in
            /*
             排序查询。原理是先对这个表进行排序再取出结果
             SELECT * FROM Consult ORDER BY add_time DESC LIMIT %d,%d  按add_time  减序排列
             SELECT * FROM Consult ORDER BY add_time ASC LIMIT %d,%d 按add_time 升序排列，默认值
             */

            let sql = "SELECT \(fund_tables.t_fundInfoList).*, \(fund_tables.t_fundOptional).fundID FROM \(fund_tables.t_fundInfoList) INNER JOIN \(fund_tables.t_fundOptional) on \(fund_tables.t_fundInfoList).fundID = \(fund_tables.t_fundOptional).fundID ORDER by \(fund_tables.t_fundOptional).ROWID"
            let resultSet = db.executeQuery(sql, withArgumentsIn: [])
            guard resultSet != nil else {
                JudyTip.message(text: "查无此表！")
                return
            }
            
            while(resultSet!.next()) {
                let fund = resultSetToFund(resultSet: resultSet!)
                fundList.append(fund)
            }
        }
        return fundList
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
    
}
*/
// MARK: - 其它私有函数
/*
private extension DataBaseCtrl {
    
    /// 将查询结果转换成 FundPurchased 模型
    /// - Parameter resultSet: 查询结果集
    func resultSetToFundPurchased(resultSet: FMResultSet) -> FundPurchased {
        var fundPurchased = FundPurchased()
        fundPurchased.amount = Int(resultSet.string(forColumn: "amount") ?? "0") ?? 0
        fundPurchased.dayForInvestmentType = resultSet.string(forColumn: "dayForInvestmentType") ?? "缺失"
        fundPurchased.fund = resultSetToFund(resultSet: resultSet)
        fundPurchased.remark = resultSet.string(forColumn: "investmentRemark")

        switch resultSet.string(forColumn: "investmentType") ?? "" {
        case "每周":
            fundPurchased.investmentType = .weekly
        case "每两周":
            fundPurchased.investmentType = .everyTwoWeeks
        case "每月":
            fundPurchased.investmentType = .monthly
        default:
            fundPurchased.investmentType = .daily
        }

        return fundPurchased
    }

}
*/
