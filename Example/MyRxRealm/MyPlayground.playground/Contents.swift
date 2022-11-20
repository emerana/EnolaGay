import Foundation
import EnolaGay
//import UIKit
//import RxSwift
//import RxCocoa
//import RealmSwift
//
//var config = Realm.Configuration.defaultConfiguration
//
//let username = "TestEnolaGay"
//config.fileURL!.deleteLastPathComponent()
//config.fileURL!.appendPathComponent(username)
//config.fileURL!.appendPathExtension("realm")
//
//let realm = try! Realm(configuration: config)
//// 组操作
//
//let accounts = realm.objects(Account.self)
//let groups = realm.objects(Group.self)
//
//let account = accounts.first
//try! realm.write {
//    if let indexAccount = account?.group.first?.accounts.firstIndex(of: account!) {
//        account?.group.first?.accounts.remove(at: indexAccount)
//        Judy.log(indexAccount)
//    }
//}
let date = Date()

Judy.logTime(date)
Judy.logTime(format: "HH:mm:ss.SSS", date)
