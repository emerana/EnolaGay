//
//  Api.swift
//
//  Api层
//  Created by Judy-王仁洁 on 2017/7/29.
//  Copyright © 2017年 8891.com.tw. All rights reserved.
//


/// Api层网络请求协议。**请求阶段的映射，需要将 emeranaRequestDelegate 实例化。**
public protocol EMERANA_Api_Request {
    
    /// 网络请求映射，实现此方法以替换原有请求。
    ///
    /// - Parameters:
    ///   - action: 请求接口
    ///   - param: 请求参数消息体
    /// - Returns: 返回一个标准的JSON
//    func requestMap(action: ApiRequestConfig.ApiAction, param: JudyApiParam?) -> JSON
    
}

/// Api层进行网络请求后的响应协议。*响应阶段的映射，需要将 emeranaResponseDelegate 实例化。*
public protocol EMERANA_Api_Response {
    
    /// 网络请求后的响应映射，实现此方法以替换服务器返回的数据。
    ///
    /// - Parameters:
    ///   - action: 请求接口
    ///   - param: 请求参数消息体
    /// - Returns: 返回一个标准的JSON.默认值 JSON(["ERROR":["msg": "系统错误!"]])
//    func responseMap(action: ApiRequestConfig.ApiAction, param: JudyApiParam?) -> JSON
    
}


import Alamofire

// MARK: - typealias

/// 参数类型别名
public typealias JudyApiParam = Parameters
/// 请求头类型别名
public typealias JudyApiHeader = HTTPHeaders

// MARK: - Api 协议

//  where Self: JudyApi
/// JudyApi 响应数据验证协议
/// * author: 王仁洁
/// * warning: 请实现该协议中的函数 responseErrorValidation
/// * since: V2.0 2020年12月31日13:27:18
public protocol EMERANA_JudyApi where Self: UIApplication {
    
    /// 校验服务器响应消息
    ///
    /// 此函数仅在 Alamofire response.result.success 时执行
    /// * warning: 此方法中将对服务器返回的消息（请求成功响应的消息）进行进一步校验，排查是否有错误
    /// - Parameter json: 服务器返回的原始 JSON 数据
    /// - Returns: (Bool：是否有错误, Int：错误码，String: 消息体)
    /// * since: V1.2 2020年11月20日14:05:22
    func responseErrorValidation(json: JSON) -> (isError: Bool, errorCode: Int, message: String)
}
/*
 // 默认实现 where Self: JudyApi
public extension EMERANA_JudyApi  {

    func responseErrorValidation(json: JSON) -> (isError: Bool, errorCode: Int, message: String) {
        return (isError: false, errorCode: 0, message: "尚未发现错误")
    }
    
}
*/

/// Api 管理层
///
/// public extension JudyApi 并覆盖 EMERANA_JudyApi 中的函数以配置数据校验
/// * warning: 此类依赖 Alamofire
/// * since: V1.1 2020年11月20日14:03:12
public final class JudyApi {

    // 私有化init()，禁止构建对象
    private init() {}
    
    /// api 数据校验配置代理
    static let dataValidationDelegate: EMERANA_JudyApi? = UIApplication.shared as? EMERANA_JudyApi

            
    /// 请求映射代理
    /// 此代理将替换所有使用JudyApi的请求，需自行实现模拟服务器返回数据
    /// # 实现此代理后 emeranaResponseDelegate 将无效
    public static var emeranaRequestDelegate: EMERANA_Api_Request? = nil
    
    /// 响应映射代理
    /// 此代理将会替换所有使用JudyApi的响应消息体，需自行实现模拟服务器返回数据
    /// # 如果实现了 emeranaRequestDelegate，此代理将无效
    public static var emeranaResponseDelegate: EMERANA_Api_Response? = nil
    
    /// Api 配置相关代理
    @available(*, unavailable, message: "该代理已弃用！")
    private static let emeranaApiConfigDelegate: EMERANA_Api? = Judy.app as? EMERANA_Api
    
    // MARK: 公开的网络请求方法
    
    /// 发起网络请求
    ///
    /// 唯一发起请求的函数，closure 中的 JSON 已经处理好，可直接使用
    ///  * since: V1.1
    ///  * author: 王仁洁 2020年12月04日09:25
    ///  * note: 暂无
    /// - Parameters:
    ///   - requestConfig: ApiRequestConfig 请求配置对象
    ///   - closure: 回调函数，通过 [EMERANA.Key.Api.error].isEmpty 验证是否成功
    public static func req(requestConfig: ApiRequestConfig, closure: @escaping ((JSON)->Void)) {
        
        guard requestConfig.api != nil else { fatalError("请给 requestConfig.api 赋值！") }
        
//        guard emeranaRequestDelegate == nil else {
//            emeranaResponseDelegate = nil   // 将响应代理设为nil
//            closure(emeranaRequestDelegate!.requestMap(action: requestConfig.api!, param: requestConfig.parameters))
//            return
//        }
        
        /// 请求对象
        let alamofire = Alamofire.request(requestConfig.reqURL,
                                          method: requestConfig.method,
                                          parameters: requestConfig.parameters,
                                          encoding: requestConfig.alamofireEncoding,
                                          headers: requestConfig.headers)

        // 设置请求等待响应时间。
        // 这招已经没用了Modifying a URLSession's properties after it has been assigned to a URLSession isn't supported
        alamofire.session.configuration.timeoutIntervalForRequest = 10
        // alamofire.setValue("application/json", forHTTPHeaderField: "Content-Type")
        /// 响应适配函数
        /// - Parameter response: DataResponse
        func responseAdapter<T>(response: DataResponse<T>) {
//
//            guard emeranaResponseDelegate == nil else {
//                closure(emeranaResponseDelegate!.responseMap(action: requestConfig.api!, param: requestConfig.parameters))
//                return
//            }

            var json = JSON([EMERANA.Key.Api.error:[EMERANA.Key.Api.msg: "系统错误!", EMERANA.Key.Api.code: 250]])
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
                
                // 数据校验
                if dataValidationDelegate != nil {
                    let result = dataValidationDelegate!.responseErrorValidation(json: json)
                    if result.isError {   // 配置错误信息
                        json[EMERANA.Key.Api.error] = [EMERANA.Key.Api.code: result.1, EMERANA.Key.Api.msg: result.2]
                    }
                } else {
                    Judy.log("未实现 extension UIApplication: EMERANA_JudyApi，服务器响应的数据将不会进行校验！")
                }
            case .failure(let error):   // 请求失败
                Judy.log("请求失败:\(error)\n请求地址：\(String(describing: response.request))")
                json[EMERANA.Key.Api.error] = [
                    EMERANA.Key.Api.code: response.response?.statusCode ?? 250,
                    EMERANA.Key.Api.msg: error.localizedDescription,
                ]
            }
            
            closure(json)
        }
        
        // 服务器响应格式，String 或 JSON
        if requestConfig.isResponseJSON {
            alamofire.responseJSON {(response: DataResponse<Any>) in responseAdapter(response: response) }
        } else {
            alamofire.responseString { (response: DataResponse<String>) in responseAdapter(response: response) }
        }

    }
    
    
    /**
     正确地上传图片方式
     // 正确地上传图片
     let imgData = newImage.jpegData(compressionQuality: 0.75)
     Alamofire.upload(multipartFormData: { (multipartFormData) in
         multipartFormData.append(imgData!, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
     }, to: "http://192.168.0.110:8762/myUserInfo/addSingleImg", method: .post, headers: apiRequestConfig.headers) { [weak self] multipartFormDataEncodingResult in
         Judy.log("multipartFormDataEncodingResult……")
         switch multipartFormDataEncodingResult {
         case .success(let upload,_,_):
             upload.responseJSON { response in
                 switch response.result {
                 case .success(let value):
                     let json = JSON(value)
                     self?.headerImageView.sd_setImage(with: URL(string: json["entity"].stringValue), placeholderImage: UIImage(named: "default_header"))
                     
                 case .failure(let error):
                     Judy.log(error)
                 }
             }
             break
         case .failure(let error):
             
             break
         }
     }

     */
    
}


// MARK: - ApiRequestConfig

// where Self: ApiRequestConfig
/// ApiRequestConfig 专用初始化协议，该协议定义了 ApiRequestConfig 部分属性的初值
/// * author: 王仁洁
/// * warning: 该协议主要针对 ApiRequestConfig 进行全局性的配置，可单独设置其属性
/// * since: V2.0 2020年12月31日13:27:18
public protocol EMERANA_ApiRequestConfig where Self: UIApplication {
        
    /// 询问请求的主要（默认）域名
    /// * warning: 该函数主要针对全局配置，如需变更请单独设置 apiConfig.domain
    /// * since: V1.3 2020年12月31日13:27:18
    func domain() -> String
    
    /// 询问请求方法是否为 POST 请求？默认实现为 true
    /// * warning: 该函数主要针对全局配置，如需变更请单独设置 apiConfig.method
    /// * since: V1.3 2020年12月31日13:27:18
    func globalMethodPOST() -> Bool

    /// 询问 apiRequestConfig 请求的响应方式是否为 responseJSON？默认实现为 true，否则为 responseString
    /// * since: V1.3 2020年12月31日13:27:18
    func responseJSON() -> Bool

    /// apiRequestConfig 对象初始化扩展
    ///
    /// 一般在此函数中设置全局 headers、parameters 的初值或其它通用信息
    /// * warning: token 需要注意是否存在变更，如登录新用户变更了 token，则应在 apiRequestConfig_last() 配置
    ///
    /// # 部分参考代码
    /// * 请求头设置
    /// ```
    /// headers?["token"] = Defaults.token
    /// ```
    /// * 请求参数设置
    /// ```
    /// parameters?["userName"] = "Judy"
    /// ```
    /// * since: V1.3 2020年12月31日13:27:18
    /// - Parameter apiConfig: 当前 apiConfig 对象
    func apiRequestConfig_init(apiConfig: ApiRequestConfig)
    
    /// apiRequestConfig 最终阶段配置
    ///
    /// 该函数为触发请求前的最后操作，发生在访问 reqURL 属性时。
    /// * warning: 发生请求时，若请求头/请求参数的初值发生改变应该在此函数中更新/覆盖对应信息，如用户登录的 token
    /// * since: V1.3 2020年12月31日13:27:18
    /// - Parameter apiConfig: 当前 apiConfig 对象
    func apiRequestConfig_end(apiConfig: ApiRequestConfig)
    
}

// 默认实现 EMERANA_ApiRequestConfig，当代理对象没有实现对应函数时使用此处已实现
public extension EMERANA_ApiRequestConfig {

    func domain() -> String {
        Judy.log("⚠️ 默认域名未配置，将使用 www.baidu.com，请确认此函数的实现")
        return "https://www.baidu.com"
    }

    func globalMethodPOST() -> Bool { true }

    func responseJSON() -> Bool { true }

    func apiRequestConfig_init(apiConfig: ApiRequestConfig) { }

    func apiRequestConfig_end(apiConfig: ApiRequestConfig) { }

}

/// api 协议，该协议规定了 api 的定义过程
public protocol EMERANA_ApiActionEnums {
    /// 该 api 接口的原始值，通常为 public enum 的 rawValue
    var value: String { get }
}

public extension EMERANA_ApiActionEnums {
    
    /// 判断 Api 对象是否为指定的 public enum 中的成员
    /// - Parameter apiEnum: 用于比较的 public enum 成员
    /// - Returns: 若为相同，返回 true，反之 false
    func `is`(_ apiEnum: EMERANA_ApiActionEnums) -> Bool {
        
        return apiEnum.value == value
    }
}

/// JudyApi 中的请求配置类
///
/// ApiRequestConfig 对象在初始化时就已经通过 EMERANA_ApiRequestConfig 协议中的函数配置好了必须属性，关于 domain 和 api 属性的使用请参考其自身说明
/// * warning: 请 public extension ApiRequestConfig 并覆盖 EMERANA_ApiRequestConfig 中指定函数以配置属性的初始值
/// * since: V1.3 2020年11月20日10:39:58
final public class ApiRequestConfig {

    /// api 配置代理
    static let apiConfigDelegate: EMERANA_ApiRequestConfig? = UIApplication.shared as? EMERANA_ApiRequestConfig
    
    /// 当前界面请求的 Api ，用于与 domain 拼接的部分，初值 nil
    /// * warning: 配置 api 请通过创建实现 EMERANA_ApiActionEnums 协议的 public enum
    /// * since: V1.0 2020年11月21日16:57:45
    public lazy var api: EMERANA_ApiActionEnums? = nil

    /// 请求域名，如: https://www.baidu.com，默认值为静态函数 domain()
    ///
    /// 通常为项目中使用频率最高的域名。若需要多个域名，请 public extension ApiRequestConfig.Domain 新增
    /// * warning: 扩展并覆盖 static func domain() 以配置全局域名，该值将与 api 拼接成最终请求的完整 URL
    /// * since: V1.0 2020年11月19日16:51:59
    public var domain: Domain = .default
        
    /// 请求方式，默认 POST。通过覆盖 globalMethodPOST() 以配置全局通用值
    public var method: HTTPMethod = ((apiConfigDelegate?.globalMethodPOST() ?? true) ? .post : .get)

    
    /// 请求参数，初值是一个空数组
    public var parameters: JudyApiParam? = JudyApiParam()

    /// 请求参数的编码方式，默认值为 URLEncoding
    /// # 其他可选值如下：
    /// * URLEncoding.default（将参数拼接在请求的 URL 里面）
    /// * URLEncoding.httpBody（将参数放在请求 body 中而不是 URL 里面）
    /// * JSONEncoding.default
    /// * ……
    public lazy var encoding: JudyApiEncoding = .URLEncoding

    /// 请求头信息，初值非 nil
    public lazy var headers: JudyApiHeader? = JudyApiHeader()
    
    /// 请求的响应数据格式是否为 responseJSON，默认 true，反之响应为 responseString。通过覆盖 responseJSON() 以配置全局通用值
    public var isResponseJSON: Bool = apiConfigDelegate?.responseJSON() ?? true

    /// 发生请求时的最终完整 URL，访问该属性即触发 apiRequestConfig_end() 函数
    public var reqURL: String {
        ApiRequestConfig.apiConfigDelegate?.apiRequestConfig_end(apiConfig: self)
        guard api != nil else {
            Judy.log("ApiRequestConfig 的 api 为 nil!")
            return domain.rawValue
        }
        return domain.rawValue + api!.value
    }
    
    /// 内部使用的参数编码方式(ParameterEncoding)
    fileprivate var alamofireEncoding: ParameterEncoding {
        switch encoding {
        case .JSONEncoding:
            return JSONEncoding.default
        case .URLEncoding:
            // get 请求时需要将参数拼接到 URL 上必须选择此编码
            return URLEncoding.default
        case .URLEncodingHttpBody:
            return URLEncoding.httpBody
        }
    }

    /// encoding 的枚举
    public enum JudyApiEncoding {
        case JSONEncoding
        case URLEncoding
        case URLEncodingHttpBody
    }

    public init() {
        ApiRequestConfig.apiConfigDelegate?.apiRequestConfig_init(apiConfig: self)
    }

    /// ApiRequestConfig 中的域名模块
    ///
    /// ApiRequestConfig 中所有域名均通过此 structure 配置，通常扩展并覆盖 static func domain() 即为项目配置了主要域名，若需要多个域名，请 public extension ApiRequestConfig.Domain 新增即可
    /// * warning: 通过 public extension 的方式新增域名，请务必参考如下代码
    /// ```
    /// static let masterDomain = ApiRequestConfig.Domain(rawValue: "https://www.baidu.com")
    /// ```
    /// * since: V1.0 2020年11月19日16:51:59
    public struct Domain: Hashable, Equatable, RawRepresentable {
        
        private(set) public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
            
            if apiConfigDelegate == nil {
                //  Judy.log("未配置 apiConfigDelegate，所有请求将使用默认值！")
                Judy.log("未实现 extension UIApplication: EMERANA_ApiRequestConfig，所有请求将使用默认值！")
                
            }
        }
        
        /// 项目中默认使用的主要域名，值为 domain() 函数
        static let `default` = Domain(rawValue: apiConfigDelegate?.domain() ?? "https://www.baidu.com")
    }

    
    @available(*, unavailable, message: "通过该值标记使用备用域名的方式已废弃，请直接修改 domain 属性", renamed: "domain")
    var isUseStandbyURL: Bool? = nil
    @available(*, unavailable, message: "该属性已废弃！", renamed: "reqURL")
    var requestURL: String {return ""}
}


@available(*, deprecated, message: "该 public enum 已更新，请使用 struct", renamed: "EMERANA.Key.Api")
public enum ApiKey {}
@available(*, unavailable , message: "请更新属性名", renamed: "ApiAction")
typealias EMERANA_Action = String
@available(*, unavailable, message: "请更新属性名", renamed: "EMERANA_Action")
typealias EMERANAAction = String

