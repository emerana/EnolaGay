//
//  ViewController.swift
//  MyRxRealm
//
//  Created by 醉翁之意 on 2022/11/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import RxSwift
import RxCocoa
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var queryButton: UIButton!
    
    /// 清除包。订阅管理机制，当清除包被释放的时候，清除包内部所有可被清除的资源（Disposable）都将被清除
    private let disposeBag = DisposeBag()
    
    // Open the local-only default realm
//    let realm = try! Realm()
    var realm: Realm!
    var config = Realm.Configuration.defaultConfiguration

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let now = Date()
        
        createButton.setTitle("date: \(now)", for: .normal)
        updateButton.setTitle("stringFormat: \(now.judy.stringValue())", for: .normal)
        deleteButton.setTitle("dateFromGMT: \(now.judy.dateFromGMT())", for: .normal)
        queryButton.setTitle("stringGMT: \(now.judy.stringDateFormGMT())", for: .normal)

        
        // Open the realm with a specific file URL, for example a username
        let username = "Judy"
        config.schemaVersion = 2
        config.fileURL!.deleteLastPathComponent()
        config.fileURL!.appendPathComponent(username)
        config.fileURL!.appendPathExtension("realm")
        realm = try! Realm(configuration: config)
        
        createButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let todo = Account(hostName: "微信", userName: "王仁洁", password: "123456")
                try! self?.realm.write {
                    self?.realm.add(todo)
                    Judy.logs("添加了一条数据")
                }
            })
            .disposed(by: disposeBag)
        
        updateButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // Get all Accounts in the realm
                let accounts = self.realm.objects(Account.self)
                // All modifications to a realm must happen in a write block.
                let accountToUpdate = accounts[0]
                try! self.realm.write {
                    accountToUpdate.password = "MyPassword"
                }
                Judy.log("更新了一条数据")
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // Get all Accounts in the realm
                let accounts = self.realm.objects(Account.self)
                let accountToUpdate = accounts[0]
                // All modifications to a realm must happen in a write block.
                try! self.realm.write {
                    // Delete the Todo.
                    self.realm.delete(accountToUpdate)
                }
                Judy.log("删除了一条数据")
            })
            .disposed(by: disposeBag)
        

        
        queryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                // Get all Accounts in the realm
                let accounts = self?.realm.objects(Account.self)
                Judy.logs(type: .🤪, "当前 accounts: \(String(describing: accounts))")
            })
            .disposed(by: disposeBag)
        

    }
    
    
}

