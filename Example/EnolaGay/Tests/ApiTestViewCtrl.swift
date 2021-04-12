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
        
    }

    
    // MARK: - override
    
    // MARK: Api 相关
    
    override func setApi() {
        super.setApi()

        requestConfig.api = Actions.createUserChatToken
        requestConfig.parameters?["userid"] = 323430
                
    }
    
    @IBAction func reqApiAction(_ sender: Any) {
        reqApi()
    }
    
    override func reqOver() {
        Judy.log("请求完毕：\n\(apiData)")
    }
    
}

enum Actions: String, EMERANA_ApiActionEnums {
    var value: String { rawValue }
    
    /// 生成融云token get
    case createUserChatToken = "/api/liveapp/GetToken"
}
    
