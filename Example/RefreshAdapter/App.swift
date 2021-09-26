//
//  App.swift
//  Semaphore
//
//  Created by 王仁洁 on 2021/9/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIApplication: EnolaGayAdapter {
    public func defaultFontName() -> UIFont { UIFont(name: "PingFangSC-Medium", size: 12)! }
    
}

import MJRefresh

/// 刷新控件适配器实现。
extension UIApplication: RefreshAdapter {
    public var pageSizeParameter: String { "SIZE" }

    public var pageIndexParameter: String { "INDEX" }
    
    
    public func initHeaderRefresh(scrollView: UIScrollView?, callback: @escaping (() -> Void)) {
        scrollView?.mj_header = MJRefreshNormalHeader(refreshingBlock: callback)
    }
    
    public func initFooterRefresh(scrollView: UIScrollView?, callback: @escaping (() -> Void)) {
        scrollView?.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: callback)
    }
    
    public func endRefresh(scrollView: UIScrollView?) {
        scrollView?.mj_header?.endRefreshing()
        scrollView?.mj_footer?.endRefreshing()
    }
    
    public func endRefreshingWithNoMoreData(scrollView: UIScrollView?) {
        scrollView?.mj_footer?.endRefreshingWithNoMoreData()
    }
    
    public func resetNoMoreData(scrollView: UIScrollView?) {
        scrollView?.mj_footer?.resetNoMoreData()
    }
}

import Alamofire
import SwiftyJSON

extension UIApplication: ApiAdapter {
    public var domain: String { "https://livepretest.jingmaiwang.com" }
    
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

enum Actions: String, ApiAction {
    public var value: String { rawValue }
    
    /// 生成融云token get
    case createUserChatToken = "/api/liveapp/GetToken"
    /// 猜你喜欢。 get
    case YouLikeByLiveFinish = "/api/liveapp/YouLikeByLiveFinish"

}

