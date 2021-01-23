//
//  ApiTestViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/1/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class ApiTestViewCtrl: JudyBaseViewCtrl {
    
    override var viewTitle: String? { return "Api测试" }

    // MARK: - let property and IBOutlet

    
    // MARK: - public var property
    

    // MARK: - private var property
    
    
    // MARK: - life cycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    // MARK: - override
    
    // MARK: Api 相关
    
    override func setApi() {
        super.setApi()

        requestConfig.api = Actions.testAction
        
    }
    
    override func reqSuccess() {
        super.reqSuccess()
        
        Judy.log("请求成功-\(apiData)")
        /*
         if isAddMore {
         dataSource += apiData["data", "<#rows#>"].arrayValue
         } else {
         dataSource = apiData["data", "<#rows#>"].arrayValue
         }
         tableView?.reloadSections(IndexSet(integer: <#0#>), with: .fade)
         或
         tableView?.reloadData()
         
         */
    }


    // MARK: - event response
        

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - private methods

private extension ApiTestViewCtrl {

}
