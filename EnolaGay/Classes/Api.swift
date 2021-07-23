//
//  Api.swift
//
//  Api 管理层。
//
//  Created by Judy-王仁洁 on 2017/7/29.
//  Copyright © 2017年 8891.com.tw. All rights reserved.
//


import SwiftyJSON

/// Api 管理层
///
/// public extension JudyApi 并覆盖 EMERANA_ApiDataValidation 中的函数以配置数据校验
@available(*, unavailable, message: "此类以弃用！")
public final class JudyApi {
    // 私有化init()，禁止构建对象。
    private init() {}
    
    // MARK: 公开的网络请求方法
    
    /// 发起网络请求。
    ///
    /// 唯一发起请求的函数，closure 中的 JSON 已经处理好，可直接使用
    ///  - since: V1.1
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
        /*
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
                
                // 数据校验。
                if EMERANA.apiAdapter != nil {
                    let result = EMERANA.apiAdapter!.responseErrorValidation(json: json)
                    // 配置错误信息。
                    if result.error {
                        json[EMERANA.Key.Api.error] = [EMERANA.Key.Api.code: result.1, EMERANA.Key.Api.msg: result.2]
                    }
                } else {
                    Judy.logWarning("未实现 extension UIApplication: EMERANA_ApiDataValidation，服务器响应的数据将不会进行校验！")
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
         */

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

// MARK: - Api 层

/// API 层代理协议。
///
/// ApiRequestConfig 专用初始化协议，该协议定义了 ApiRequestConfig 部分属性的初值，及通用的请求接口。
/// - Warning: 该协议主要针对 ApiRequestConfig 进行全局性的配置，可单独设置其属性。
public protocol ApiAdapter where Self: UIApplication {
        
    /// 询问请求的主要（默认）域名。
    /// - Warning: 该函数主要针对全局配置，如需变更请单独设置 apiConfig.domain.
    func domain() -> String
    
    /// 询问全局默认的请求方法是否为 POST? 该函数默认实现为 true.
    func globalMethodPOST() -> Bool

    /// 询问 apiRequestConfig 请求的响应方式是否为 responseJSON？默认实现为 true，否则为 responseString.
    func responseJSON() -> Bool
    
    /// 确认 apiRequestConfig 最终配置，此函数为触发请求（调用 request() ）前的最后操作。
    /// - Parameter requestConfig: 当前 apiConfig 对象。
    /// - Warning: 发生请求时，若请求头/请求参数的初值发生改变应该在此函数中更新/覆盖对应信息，如用户登录的 token.
    func apiRequestConfigAffirm(requestConfig: ApiRequestConfig)
    
    /// 实现发起请求。
    ///
    /// 该函数中需要实现网络请求，requestConfig 对象中包含了所有的请求相关信息，在得到响应后应通过 callback 函数将相应数据返回。严格地说，无论是否响应成功最终都应该触发 callback.
    /// - Parameters:
    ///   - requestConfig: 配置好的 ApiRequestConfig 对象。
    ///   - callback: 发起请求后的响应函数，该函数要求传入响应的数据。
    func request(requestConfig: ApiRequestConfig, callback: @escaping ((JSON) -> Void))

    /// 询问代理响应一个经过质检后的 JSON 数据，代理应针对服务器响应的 JSON 数据进行质检，若包含错误信息请通过 JSON.setQCApiERROR() 函数完成错误信息设置。
    /// - Parameters:
    /////   - requestConfig: 发起请求的配置信息对象。
    ///   - apiData: 响应的原始 JSON 数据。
    /// - Returns: 经过质检后的 JSON 数据，apiData.setQCApiERROR() 函数即可得到目标 JSON.
    func responseQC(apiData: JSON) -> JSON
}

// 默认实现 ApiDelegate，使其变成可选协议函数。
public extension ApiAdapter {
    func domain() -> String {
        Judy.logWarning(" 默认域名未配置，将使用 www.baidu.com，请确认 extension UIApplication: ApiAdapter 中 domain 函数的实现")
        return "https://www.baidu.com"
    }
    
    func globalMethodPOST() -> Bool { true }
    
    func responseJSON() -> Bool { true }
    
    func apiRequestConfigAffirm(requestConfig: ApiRequestConfig) { }
    
    func responseQC(apiData: JSON) -> JSON {
        Judy.logWarning("未实现 responseQC 质检函数，apiData 将直接使用服务器响应的原始数据。")
        return apiData
    }
}

/// api 接口规范协议，该协议规定了 api 的定义过程，如 enum Actions: String, ApiAction.
public protocol ApiAction {
    /// api 的原始值。
    var value: String { get }
}

public extension ApiAction {
    /// 此函数用于验证当前 api 是否为指定目标 api。
    /// - Parameter apiAction: 匹配目标 ApiAction。
    /// - Returns: 比对结果。
    func `is`(_ apiAction: ApiAction) -> Bool { apiAction.value == value }
}

/// JudyApi 中的请求配置类。
///
/// ApiRequestConfig 对象在初始化时就已经通过 ApiAdapter 协议中的函数配置好了必须属性，关于 domain 和 api 属性的使用请参考其自身说明。
/// - Warning: 请 extension UIApplication: ApiAdapter 并覆盖指定函数以配置属性的初始值。
final public class ApiRequestConfig {

    /// 请求的 api.
    ///
    /// 该值为用于与 domain 拼接的部分，初值 nil，每次请求都会有一个 api.
    /// - Warning: 配置 api 请通过创建实现 ApiAction 协议的 public enum，参考如下代码：
    /// ```
    /// enum Apis: String, ApiAction {
    ///     var value: String { rawValue }
    ///     case testAction = "test"
    /// }
    /// ```
    public lazy var api: ApiAction? = nil

    /// 请求域名。
    ///
    /// 该值将与 api 属性拼接成最终请求的完整 URL。若存在多个域名，请通过 UIApplication: ApiAdapter 新增。
    public var domain: Domain = .default
        
    /// 请求方式 HTTPMethod，请通过 extension UIApplication: ApiAdapter 配置全局通用值。
    public var method: Method = ((EMERANA.apiAdapter?.globalMethodPOST() ?? true) ? .post : .get)

    /// 请求参数，初值是一个空数组。
    public var parameters: [String: Any]? = [String: Any]()

    /// 请求参数的编码方式 ParameterEncoding，默认值为 URLEncoding.
    public lazy var encoding: Encoding = .URLEncoding

    /// 请求头信息字典。
    /// - Warning: 该值可以设置为 nil，但初值非 nil.
    public lazy var headers: [String: String]? = [String: String]()
    
    /// 请求的响应数据格式是否为 responseJSON，默认 true，反之响应为 responseString.
    /// 通过覆盖 responseJSON() 以配置全局通用值。
    public var isResponseJSON: Bool = EMERANA.apiAdapter?.responseJSON() ?? true

    /// 完整的请求 URL.
    public var reqURL: String { domain.rawValue + (api?.value ?? "") }

    /// HTTPMethod.
    public enum Method {
        case options
        case get
        case head
        case post
        case put
        case patch
        case delete
        case trace
        case connect
    }
    
    /// 请求参数可选编码方式 encoding.
    public enum Encoding {
        /// 将参数打包成 JSON。
        case JSONEncoding
        /// 一般在 get 请求时需要将参数拼接到 URL 上选择此编码。
        case URLEncoding
        /// 将参数放在请求 body 中而不是 URL 里面。
        case URLEncodingHttpBody
    }

    public init() {}
    
    /// 主动确认配置信息，此函数将触发 ApiAdapter 的 apiRequestConfigAffirm 函数。
    ///
    /// - Warning: 在 apiRequestConfig 不通过 request 函数发起请求时请务必调用此函数以便确认配置信息的正确性。
    public func configAffirm() {
        EMERANA.apiAdapter?.apiRequestConfigAffirm(requestConfig: self)
    }
    
    /// 由当前对象向 Api 层发起请求，该函数中将触发 configAffirm() 确认函数，并且在得到响应数据后要求对该数据进行质检。
    ///
    /// 在 callback 函数中，可以通过 JSON.ApiERROR 来判断是否存在错误信息。
    /// - Parameter callback: 请求的回调函数。
    public func request(withCallBack callback: @escaping ((JSON) -> Void)) {
        guard EMERANA.apiAdapter != nil else {
            let msg = "未实现 extension UIApplication: ApiAdapter，ApiRequestConfig 拒绝发起网络请求"
            let json = JSON([APIERRKEY.error.rawValue:
                                [APIERRKEY.msg.rawValue: msg,
                                 APIERRKEY.code.rawValue: EMERANA.ErrorCode.default]
            ])
            Judy.logWarning(msg)
            callback(json)
            return
        }
        // 确认配置信息。
        configAffirm()

        guard api != nil else {
            let msg = "api 为空，取消已请求!"
            let json = JSON([APIERRKEY.error.rawValue:
                                [APIERRKEY.msg.rawValue: msg,
                                 APIERRKEY.code.rawValue: EMERANA.ErrorCode.notSetApi]
            ])
            Judy.logWarning(msg)
            callback(json)
            return
        }

        EMERANA.apiAdapter!.request(requestConfig: self) { json in
            // 若原始 JSON 已包含一个错误信息，则无需质检直接返回该数据。
            if json.ApiERROR != nil {
                callback(json)
                return
            }
            // 要求完成质检。
            let QCJSON = EMERANA.apiAdapter!.responseQC(apiData: json)
            callback(QCJSON)
        }
    }
    
    /// ApiRequestConfig 中的域名模块。
    ///
    /// ApiRequestConfig 中所有域名均通过此 structure 配置，通常扩展并覆盖 static func domain() 即为项目配置了主要域名，若需要多个域名，请 extension ApiRequestConfig.Domain 新增即可。
    /// - Warning: 新增域名请务必参考如下代码:
    /// ```
    /// static let masterDomain = ApiRequestConfig.Domain(rawValue: "https://www.baidu.com")
    /// ```
    public struct Domain: Hashable, Equatable, RawRepresentable {
        
        private(set) public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
            
            if EMERANA.apiAdapter == nil {
                Judy.logWarning("未实现 extension UIApplication: ApiAdapter，所有请求将使用默认值！")
            }
        }
        
        /// 项目中默认使用的主要域名，值为 domain() 函数。
        static let `default` = Domain(rawValue: EMERANA.apiAdapter?.domain() ?? "https://www.baidu.com")
    }
    
}

/// 在 Api 请求中常用到的 JSONKey，主要用于访问错误信息。
public enum APIERRKEY: String {
    /// 该字段通常用于访问包含错误信息集合的 json.
    case error = "EMERANA_KEY_API_ERROR"
    /// 访问 json 中的语义化响应消息体。
    case msg = "EMERANA_KEY_API_MSG"
    /// 访问 json 中保存的响应错误代码。
    case code = "EMERANA_KEY_API_CODE"
}

public extension JSON {
    /// 便携式访问 JSON 中的错误信息。
    subscript(key: APIERRKEY) -> JSON { self[key.rawValue] }
    
    /// 访问 json 中是否包含访问 Api 请求中响应失败的信息。其核心是访问"APIJSONKEY.error" key.
    var ApiERROR: JSON? { self[.error].isEmpty ? nil:self[.error] }

    /// 在质检 apiData 发现错误信息时调用此函数来设置相关信息，并返回包含该错误信息的新 JSON.
    /// - Parameters:
    ///   - code: 错误码。
    ///   - msg: 错误消息体。
    /// - Returns: 一个经过质检后的 JSON，若存在错误，该 JSON 中会包含 QCJSON[.error] 数据。
    /// - Warning: 该函数会给当前 json 新增 APIERRKEY.error 字段，其内容为包含错误码和错误信息的 json. 通常情况下该函数只应该应用在 responseQC 质检函数中。
    func setQCApiERROR(code: Int, msg: String) -> JSON {
        var QCJSON = self
        if QCJSON.error == nil {
            QCJSON[APIERRKEY.error.rawValue] = JSON([APIERRKEY.code.rawValue: code,
                                                       APIERRKEY.msg.rawValue: msg])
        } else {
            // 请求阶段就失败的质检信息。
            QCJSON = [APIERRKEY.error.rawValue: [APIERRKEY.code.rawValue: EMERANA.ErrorCode.default,
                                                   APIERRKEY.msg.rawValue: "请求失败"]]
        }
        return QCJSON
    }
}
