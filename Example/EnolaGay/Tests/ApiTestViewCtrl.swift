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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setApi() {
        super.setApi()

//         requestConfig.api = Actions.YouLikeByLiveFinish
//         requestConfig.parameters?["userid"] = 323430
    }
    
    @IBAction func reqApiAction(_ sender: Any) {
        // reqApi()
        let requestConfig = ApiRequestConfig()
        requestConfig.api = Actions.createUserChatToken
        requestConfig.method = .get
        requestConfig.parameters?["userid"] = "323430"

        requestConfig.request { json in
           
        }

    }

    @IBAction func showTipViewCtrl(_ sender: Any) {
        let tip = Tip(host: self)
        tip.show(msg: "")
    }
    
    override func reqNotApi() {
        //JudyTip.message(text: apiData.stringValue)
    }
    
    override func reqOver() {
        Judy.log("请求完毕：\n\(apiData)")
    }
    
}

public enum Actions: String, ApiAction {
    public var value: String { rawValue }
    
    /// 生成融云token get
    case createUserChatToken = "/api/liveapp/GetToken"
    /// 猜你喜欢。 get
    case YouLikeByLiveFinish = "/api/liveapp/YouLikeByLiveFinish"

}

