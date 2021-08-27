//
//  Api.swift
//
//  Api 管理层
//
//  Created by Judy-王仁洁 on 2017/7/29.
//  Copyright © 2017年 8891.com.tw. All rights reserved.
//

import SwiftyJSON

@available(*, unavailable, message: "此类以弃用！")
public final class JudyApi {
    /*
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

/// API 层代理协议
///
/// ApiRequestConfig 专用初始化协议，该协议定义了 ApiRequestConfig 部分属性的初值，及通用的请求接口
/// - Warning: 该协议主要针对 ApiRequestConfig 进行全局性的配置，可单独设置其属性
public protocol ApiAdapter where Self: UIApplication {
    
    /// 询问请求的主要（默认）域名
    /// - Warning: 该函数主要针对全局配置，如需变更请单独设置 apiConfig.domain.
    func domain() -> String
    
    /// 询问全局默认的请求方法是否为 POST? 该函数默认实现为 true.
    func globalMethodPOST() -> Bool
    
    /// 询问 apiRequestConfig 请求的响应方式是否为 responseJSON？默认实现为 true，否则为 responseString.
    func responseJSON() -> Bool
    
    /// 确认 apiRequestConfig 最终配置，此函数为触发请求（调用 request() ）前的最后操作
    /// - Parameter requestConfig: 当前 apiConfig 对象
    /// - Warning: 发生请求时，若请求头/请求参数的初值发生改变应该在此函数中更新/覆盖对应信息，如用户登录的 token.
    func apiRequestConfigAffirm(requestConfig: ApiRequestConfig)
    
    /// 实现发起请求
    ///
    /// 该函数中需要实现网络请求，requestConfig 对象中包含了所有的请求相关信息，在得到响应后应通过 callback 函数将相应数据返回。严格地说，无论是否响应成功最终都应该触发 callback.
    /// - Parameters:
    ///   - requestConfig: 配置好的 ApiRequestConfig 对象
    ///   - callback: 发起请求后的响应函数，该函数要求传入响应的数据
    func request(requestConfig: ApiRequestConfig, callback: @escaping ((JSON) -> Void))
    
    /// 询问代理响应一个经过质检后的 JSON 数据
    ///
    /// 该函数要求对响应的 JSON 数据进行质检，若包含错误信息请通过 JSON.setQCApiERROR() 函数完成错误信息设置
    /// - Parameters:
    ///   - requestConfig: 发起请求的配置信息对象
    ///   - apiData: 响应的原始 JSON 数据
    /// - Returns: 经过质检后的 JSON 数据，JSON.setQCApiERROR() 函数即可得到目标 JSON.
    func responseQC(apiData: JSON) -> JSON
}

// ApiAdapter 的部分默认实现，使其变成可选协议函数
public extension ApiAdapter {
    func domain() -> String {
        Judy.logWarning("ApiAdapter.domain() 未实现，默认域名将使用 www.baidu.com")
        return "https://www.baidu.com"
    }
    
    func globalMethodPOST() -> Bool { true }
    
    func responseJSON() -> Bool { true }
    
    func apiRequestConfigAffirm(requestConfig: ApiRequestConfig) { }
    
    func responseQC(apiData: JSON) -> JSON {
        Judy.logWarning("ApiAdapter.responseQC() 未实现，将直接使用服务器响应的原始数据")
        return apiData
    }
}

/// api 接口规范协议
///
/// 该协议规定了 api 的定义过程，参考如下：
/// ```
/// enum Apis: String, ApiAction {
///     var value: String { rawValue }
///     case action = "/api/login"
/// }
/// ```
public protocol ApiAction {
    /// api 的可访问性原始值
    var value: String { get }
}

public extension ApiAction {
    /// 验证当前 api 是否为目标 api.
    /// - Parameter apiAction: 匹配的目标 ApiAction.
    /// - Returns: 若目标 Api 与之匹配，返回 true.
    func `is`(_ apiAction: ApiAction) -> Bool { apiAction.value == value }
}

/// JudyApi 中的请求配置类
///
/// ApiRequestConfig 对象在初始化时就已经通过 ApiAdapter 协议中的函数配置好了必须属性，关于 domain 和 api 属性的使用请参考其自身说明
/// - Warning: 请 extension UIApplication: ApiAdapter 并覆盖指定函数以配置属性的初始值
final public class ApiRequestConfig {
    
    /// 请求的 api.
    ///
    /// 该值为用于与 domain 拼接的部分，初值为 nil. 定义Api接口详见 ApiAction.
    public lazy var api: ApiAction? = nil
    
    /// 请求域名，默认为 Domain.default，该值将与 api 属性拼接成最终请求的完整 URL.
    ///
    /// 配置默认值、其它多个域名详见 Domain.
    public var domain: Domain = .default
    
    /// 请求方式 HTTPMethod.
    ///
    /// 请通过实现 ApiAdapter.globalMethodPOST() 以配置全局通用值
    public var method: Method = (EMERANA.apiAdapter?.globalMethodPOST() ?? true) ? .post:.get
    
    /// 请求参数，初值是一个空数组
    public var parameters: [String: Any]? = [String: Any]()
    
    /// 请求参数的编码方式 ParameterEncoding，默认值为 URLEncoding.
    public lazy var encoding: Encoding = .URLEncoding
    
    @available(*, unavailable, message: "请重命名", renamed: "header")
    public lazy var headers: [String: String]? = [String: String]()
    
    /// 请求头信息，该值默认为一个空字典
    public lazy var header = [String: String]()
    
    /// 请求的响应数据格式是否为 responseJSON，默认值为 true.反之响应为 responseString.
    ///
    /// 请通过实现 ApiAdapter.responseJSON() 以修改默认值
    public var isResponseJSON: Bool = EMERANA.apiAdapter?.responseJSON() ?? true
    
    /// 最终的请求 URL. 该值为 domain、api 拼接而成
    public var reqURL: String { domain.rawValue + (api?.value ?? "") }
    
    /// HTTPMethod 请求方式
    public enum Method {
        case get, post
    }
    
    /// 请求参数可选编码方式 encoding.
    public enum Encoding {
        /// 将请求参数打包成 JSON.
        case JSONEncoding
        /// 将请求参数拼接到请求 URL 上，常用于 get 请求
        case URLEncoding
        /// 将参数放在请求 body 中而不是 URL 里面
        case URLEncodingHttpBody
    }
    
    public init() {}
    
    /// 确认配置信息
    ///
    /// 请通过实现 ApiAdapter.apiRequestConfigAffirm() 确认 ApiRequestConfig 对象的准确性
    ///
    /// - Warning: 在 apiRequestConfig 不通过 request 函数发起请求时请务必调用此函数以便确认配置信息的正确性
    public func configAffirm() {
        EMERANA.apiAdapter?.apiRequestConfigAffirm(requestConfig: self)
    }
    
    /// 由当前对象向 Api 层发起请求
    ///
    /// * 该函数中将触发 configAffirm() 确认函数
    /// * 该函数在得到响应数据后会对该数据进行质检，并通过 callback 响应经过质检的 json.
    /// - Warning: 请确认实现 extension UIApplication: ApiAdapter.
    /// - Parameter callback: 请求的回调函数，你可以通过 JSON.ApiERROR 来判断是否存在错误信息。
    public func request(withCallBack callback: @escaping ((JSON) -> Void)) {
        guard EMERANA.apiAdapter != nil else {
            let msg = "未实现 extension UIApplication: ApiAdapter，ApiRequestConfig 拒绝发起网络请求"
            let json = JSON([APIERRKEY.error.rawValue:
                                [APIERRKEY.msg.rawValue: msg,
                                 APIERRKEY.code.rawValue: EMERANA.Code.default]
            ])
            Judy.logWarning(msg)
            callback(json)
            return
        }
        // 确认配置信息
        configAffirm()
        
        guard api != nil else {
            let msg = "api 为空，取消本次请求！"
            let jsonWithERROR = JSON([APIERRKEY.error.rawValue:
                                        [APIERRKEY.msg.rawValue: msg,
                                         APIERRKEY.code.rawValue: EMERANA.Code.notSetApi]
            ])
            Judy.logWarning(msg)
            callback(jsonWithERROR)
            return
        }
        
        EMERANA.apiAdapter!.request(requestConfig: self) { json in
            // 说明 json 存在 SwiftyJSONError，没有其他任何值。
            if json.error != nil {
                // 直接设置一个质检失败的数据
                callback(json.setQCApiERROR(code: json.error!.errorCode,
                                            msg: "响应数据解析失败: \(json.error!.localizedDescription)"))
                return
            }
            // 若原始 JSON 已包含 Api 响应数据质检失败信息，则无需质检直接返回该数据。
            if json.ApiERROR != nil {
                callback(json)
                return
            }
            // 要求完成质检
            let QCJSON = EMERANA.apiAdapter!.responseQC(apiData: json)
            callback(QCJSON)
        }
    }
    
    /// ApiRequestConfig 中的域名配置模块
    ///
    /// ApiRequestConfig 中所有域名均通过此 structure 配置，通过实现 ApiAdapter.domain() 配置默认值；
    ///
    /// # 配置多个域名参考如下代码：
    /// ```
    /// static let domain = ApiRequestConfig.Domain(rawValue: "https://www.baidu.com")
    /// ```
    public struct Domain: Hashable, Equatable, RawRepresentable {
        /// 域名的实际可访问性字符串
        private(set) public var rawValue: String
        
        public init(rawValue: String) { self.rawValue = rawValue }
        
        /// 项目中默认使用的主要域名，其值为 ApiAdapter.domain().
        /// - Warning: 请确认实现 ApiAdapter 协议并覆盖 domain() 方法。
        public static let `default` = Domain(rawValue: EMERANA.apiAdapter?.domain() ?? "https://www.baidu.com")
    }
    
}

/// 在 Api 请求中常用到的 JSONKey，主要用于访问错误信息。
public enum APIERRKEY: String {
    /// 该字段通常用于访问包含错误信息集合的 json
    case error = "EMERANA_KEY_API_ERROR"
    /// 访问 json 中的语义化响应消息体
    case msg = "EMERANA_KEY_API_MSG"
    /// 访问 json 中保存的响应错误代码
    case code = "EMERANA_KEY_API_CODE"
}

public extension JSON {
    /// 便携式访问 JSON 中 APIERRKEY 的对应信息
    subscript(key: APIERRKEY) -> JSON { self[key.rawValue] }
    
    /// 访问 json 中的 Api 响应数据质检失败信息
    ///
    /// 其核心是访问"APIJSONKEY.error" key 所对应的字典值。
    var ApiERROR: JSON? { self[.error].isEmpty ? nil:self[.error] }
    
    
    /// 在当前 json 基础上设置一条质检错误信息并返回一个新的 json 对象
    ///
    /// 当拿到服务器响应的数据时，若该数据不符合自己的要求，通过此函数即可得到一个包含错误信息的 json，而后可通过 json.ApiERROR 访问该错误信息。
    /// - Warning: 该函数会给当前 json 新增 APIERRKEY.error 字段，其内容为包含错误码和错误信息的 json. 通常情况下该函数只应该应用在 responseQC 质检函数中。
    /// - Warning: 若当前 json 中已经包含 ApiERROR 错误信息，则返回自身，不做任何操作。
    /// - Parameters:
    ///   - code: 错误码
    ///   - msg: 错误消息体
    /// - Returns: 一个经过质检后的 JSON，该 JSON 中会包含 QCJSON[.error] 数据，可通过 json.ApiERROR 访问该错误信息。
    func setQCApiERROR(code: Int, msg: String) -> JSON {
        guard self.ApiERROR == nil else { return self }
        var QCJSON = self
        if QCJSON.error == nil {
                QCJSON[APIERRKEY.error.rawValue] = JSON([APIERRKEY.code.rawValue: code,
                                                         APIERRKEY.msg.rawValue: msg])
        } else { // 当 json 存在 SwiftyJSONError 时无法直接给其赋值
            QCJSON = [APIERRKEY.error.rawValue: [APIERRKEY.code.rawValue: code,
                                                 APIERRKEY.msg.rawValue: msg]]
        }
        return QCJSON
    }
}
