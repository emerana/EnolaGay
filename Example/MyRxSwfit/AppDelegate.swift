//
//  AppDelegate.swift
//  MyRxSwfit
//
//  Created by 王仁洁 on 2021/9/2.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }


}

extension UIApplication: EnolaGayAdapter {
    
    public func defaultFontName() -> UIFont {
        UIFont(name: .苹方_中粗体, size: 18)
    }
    
}

/// 用于查询是否强制更新的接口
enum Version: String, ApiAction {
    var value: String { rawValue }
    /// 获取App版本号 post
    case GetAppVersion = "/system/Version/GetAppVersion"
}

import Alamofire
import SwiftyJSON

extension UIApplication: ApiAdapter {
    public var domain: String { "https://jmwapi.jingmaiwang.com" }
    
    public func apiRequestConfigAffirm(requestConfig: ApiRequestConfig) {
        
        if requestConfig.method == .get { requestConfig.encoding = .URLEncoding }
        
        if requestConfig.method == .post { requestConfig.encoding = .JSONEncoding }

    }

    public func responseQC(apiData: JSON) -> JSON {
        var rs: (error: Bool, code: Int, message: String) = (false, 0, "尚未发现错误")
        // 兼容活动中心的接口响应格式
        if apiData["Success"].exists() && !apiData["Success"].boolValue {
            rs.error = true
            rs.code = 250
            rs.message = apiData["Msg"].stringValue
        }
        
        if apiData["code"].exists() {
            if apiData["code"].intValue != 0 {
                rs.error = true
                rs.code = apiData["code"].intValue
                rs.message = apiData["msg"].stringValue
            }
        } else {
            rs.error = true
            rs.code = apiData["status"].intValue
            rs.message = apiData["title"].stringValue
        }

        // 设置错误信息。
        if rs.error {
            return apiData.setQCApiERROR(code: rs.1, msg: rs.2)
        } else {
            return apiData
        }
    }

    public func request(requestConfig: ApiRequestConfig, callback: @escaping ((JSON) -> Void)) {

        var method = HTTPMethod.get
        switch requestConfig.method {
        case .get:
            method = .get
        default:
            method = .post
        }
        
        var encoding: ParameterEncoding = JSONEncoding.default
        switch requestConfig.encoding {
        case .JSONEncoding:
            encoding = JSONEncoding.default
        case .URLEncodingHttpBody:
            encoding = URLEncoding.httpBody
        default:
            encoding = URLEncoding.default
        }
            
        /// 请求对象
        let alamofire = Alamofire.request(requestConfig.reqURL,
                                          method: method,
                                          parameters: requestConfig.parameters,
                                          encoding: encoding,
                                          headers: requestConfig.header)

        // 设置请求等待响应时间。
        // 这招已经没用了Modifying a URLSession's properties after it has been assigned to a URLSession isn't supported
        alamofire.session.configuration.timeoutIntervalForRequest = 3
        // alamofire.setValue("application/json", forHTTPHeaderField: "Content-Type")
        /// 响应适配函数
        /// - Parameter response: DataResponse
        func responseAdapter<T>(response: DataResponse<T>) {

            var json = JSON()
            //  Judy.log("收到 \(T.self) 类型响应")
            switch response.result {
            case .success(let value):   // 请求成功
                if value is String {
                    // string 先转成 Data 再转成 JSON
                    let data = (value as! String).data(using: .utf8)!
                    json = JSON(data)
                } else {
                    json = JSON(value)
                }
            case .failure(let error):   // 请求失败
                Judy.log("请求失败:\(error)\n请求地址：\(String(describing: response.request))")
                json = json.setQCApiERROR(code: EMERANA.Code.default, msg: "请求失败")
            }
            callback(json)
        }

         // 服务器响应格式，String 或 JSON。
        if requestConfig.isResponseJSON {
            alamofire.responseJSON {(response: DataResponse<Any>) in responseAdapter(response: response) }
        } else {
            alamofire.responseString { (response: DataResponse<String>) in responseAdapter(response: response) }
        }

    }

}

