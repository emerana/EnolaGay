//
//  FunctionListViewCtrl.swift
//  emerana
//
//  Created by 艾美拉娜 on 2018/10/5.
//  Copyright © 2018 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 功能列表
class FunctionListViewCtrl: JudyBaseTableViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet

    // MARK: - public var property - 公开var

    override var viewTitle: String? {
        return "功能列表"
    }

    // MARK: - private var property - 私有var
    
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件

    // MARK: - Event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - tableView  dataSource
extension FunctionListViewCtrl {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断cell == nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.json = dataSource[indexPath.row]
        cell.textLabel?.text = dataSource[indexPath.row][EMERANA.Key.title].stringValue
        cell.detailTextLabel?.text = dataSource[indexPath.row][EMERANA.Key.subtitle].stringValue

        return cell
    }
    
}

// MARK: - tableView  delegate
extension FunctionListViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identfy = dataSource[indexPath.row][EMERANA.Key.segue].string else {
            return
        }
        performSegue(withIdentifier: identfy, sender: nil)
    }

}
