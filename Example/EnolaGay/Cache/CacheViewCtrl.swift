//
//  CacheViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/8/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import Cache

class CacheViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "Cache 使用" }
    
    /// Storage<String, User>
    private let storage: Storage? = { () -> (Storage<String, User>?) in
        let diskConfig = DiskConfig(name: "MyUsers")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

        return try? Storage<String, User>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: User.self))
    }()

    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// 保存一个对象
    @IBAction private func saveActin(_ sender: Any) {
        let user = User()
        user.userName = "醉翁之意"
        // 10 秒后过期
        try? storage?.setObject(user, forKey: "user", expiry: .date(Date().addingTimeInterval(10)))
        Judy.logHappy("保存了 user 对象")
    }

    /// 删除对象
    @IBAction private func deleteActin(_ sender: Any) {
        try? storage?.removeObject(forKey: "user")
        Judy.logWarning("删除了 user 对象")
    }

    @IBAction private func showActin(_ sender: Any) {
        do {
            let user = try storage?.object(forKey: "user")
            view.toast.makeToast(user?.userName)
        } catch StorageError.notFound {
            Judy.log("没有找到文件")
        } catch StorageError.typeNotMatch {
            Judy.log("类型不匹配")
        } catch StorageError.malformedFileAttributes {
            Judy.log("畸形的文件属性")
        } catch StorageError.decodingFailed {
            Judy.log("解码")
        } catch StorageError.encodingFailed {
            Judy.log("转码失败")
        } catch StorageError.deallocated {
            Judy.log("已释放")
        } catch StorageError.transformerFail {
            Judy.log("转换失败")
        } catch {
            Judy.log(error.localizedDescription)
            view.toast.makeToast(error.localizedDescription)
        }
    }
    
    /// 删除所有对象
    @IBAction private func removeAllActin(_ sender: Any) {
        try? storage?.removeAll()
        Judy.logWarning("删除所有对象")
    }

    /// 删除所有过期对象
    @IBAction private func removeExpiredObjectsActin(_ sender: Any) {
        try? storage?.removeExpiredObjects()
        Judy.log("删除所有过期对象")
    }

    /// entry 获取对象的元数据和过期信息
    @IBAction private func entryAction(_ sender: Any) {
        let user = try? storage?.entry(forKey: "user")
        view.toast.makeToast(user?.object.userName)
    }
}

class User: Codable {
    var userName = ""
}
