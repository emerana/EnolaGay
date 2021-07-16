//
//  AppConfigs.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/1/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import EnolaGay
import SwiftyJSON

// 颜色配置
extension UIColor {
    static let myColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
}

import Alamofire

// ApiRequestConfig。

extension UIApplication: ApiAdapter {
    
    
    public func domain() -> String { "https://livepretest.jingmaiwang.com" }

    public func globalMethodPOST() -> Bool { false }
    
    public func responseErrorValidation(json: JSON) -> (error: Bool, code: Int, message: String) {
        
        var rs: (error: Bool, code: Int, message: String) = (false, 0, "尚未发现错误")
        // 兼容活动中心的接口响应格式
        if json["Success"].exists() && !json["Success"].boolValue {
            rs.error = true
            rs.code = 250
            rs.message = json["Msg"].stringValue
        }
        
        if json["code"].exists() {
            if json["code"].intValue != 0 {
                rs.error = true
                rs.code = json["code"].intValue
                rs.message = json["msg"].stringValue
            }
        } else {
            rs.error = true
            rs.code = json["status"].intValue
            rs.message = json["title"].stringValue
        }
        
        return rs
    }

    public func request(withRequestConfig requestConfig: ApiRequestConfig, callback: @escaping ((JSON) -> Void)) {

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
                                          headers: requestConfig.headers)

        // 设置请求等待响应时间。
        // 这招已经没用了Modifying a URLSession's properties after it has been assigned to a URLSession isn't supported
        alamofire.session.configuration.timeoutIntervalForRequest = 10
        // alamofire.setValue("application/json", forHTTPHeaderField: "Content-Type")
        /// 响应适配函数
        /// - Parameter response: DataResponse
        func responseAdapter<T>(response: DataResponse<T>) {

            var json = JSON([JSONApiKey.error: [JSONApiKey.msg: "系统错误!", JSONApiKey.code: 250]])
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
                
                // 数据校验。
                let result = responseErrorValidation(json: json)
                // 配置错误信息。
                if result.error {
                    json.ApiERROR = [JSONApiKey.code.rawValue: result.1,
                                     JSONApiKey.msg.rawValue: result.2]
                }
            case .failure(let error):   // 请求失败
                Judy.log("请求失败:\(error)\n请求地址：\(String(describing: response.request))")
                
                json.ApiERROR = [
                    JSONApiKey.code.rawValue: response.response?.statusCode ?? 250,
                    JSONApiKey.msg.rawValue: error.localizedDescription]
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

extension UIApplication: EMERANA_UIFont {
    
    public func configFontStyle(_ style: UIFont.FontStyle) -> (UIFont.FontName, CGFloat) {
        // 通过判断原始值为奇数使用加粗字体
        var fontName: UIFont.FontName = style.rawValue%2 == 0 ? .苹方_简_常规体:.苹方_简_中黑体
        var fontSize: CGFloat = 24
        switch style {
            
        case .xxxs, .xxxs_B: // 最小码
            fontSize = 8
        case .xxs, .xxs_B: // 极小码
            fontSize = 9
            
        case .XS, .XS_B: // 超小码
            fontSize = 10
        case .S, .S_B:   // 小码
            fontSize = 11
        case .M, .M_B:   // 均码
            fontSize = 12
        case .L, .L_B:   // 大码
            fontSize = 13
        case .XL, .XL_B: // 超大码
            fontSize = 14
        case .xxl, .xxl_B:
            fontSize = 16
        case .xxxl, .xxxl_B:
            fontSize = 18

        case .Nx1:
            fontSize = 24
            fontName = .苹方_简_中黑体
        /// 当前用于提现界面
        case .Nx2:
            fontSize = 30
            fontName = .苹方_简_中黑体
        case .Nx3:
            fontSize = 36
            fontName = .HelveticaNeue
        case .Nx4:
            fontSize = 40
            fontName = .HelveticaNeue
        case .Nx5:
            fontSize = 46
            fontName = .HelveticaNeue
            
        }
        
        return (fontName, fontSize)
    }

}

import MJRefresh

/// 刷新控件适配器实现。
extension UIApplication: RefreshAdapter {
    
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
    
    public func pageParameterStrings() -> (String, String) { ("pageIndexAOO","pageSizeAOO") }
}
