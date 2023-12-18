//___FILEHEADER___

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import SwiftyJSON
import EnolaGay

/// <#请求对象说明#>
struct ___FILEBASENAMEASIDENTIFIER___ {

    let token: String
    /// 当前请求的页码
    let pageNum: Int
    var pageSize: Int = 15
    let searchWord: String

    /// <#数据请求#> publisher（数据源，下一页页码?, 错误提示？）
    var dataPublisher: Observable<Result<(Array<<#Model#>>, Int?), AppError>> {
        // 配置请求 URL
        let reqURL = API.requestURL(action: .searchJoinGroupList)
        
        return json(.post, reqURL, parameters: parameters(), encoding: JSONEncoding.default, headers: header())
            .map { JSON($0) }
            .map { json in
                guard json["code"].intValue == 200 else { return .failure(AppError.requestFailed(json["msg"].stringValue)) }

                let nextPage: Int? = json["data", "haveNextPage"].boolValue ? pageNum+1 : nil
                
                do {
                    // 将 JSON 字符串转成 Data.
                    let jsonData: Data = try json["data", "rows"].rawData()
//                    let jsonArrayString = json["data", "rows"].rawString()
//                    let list = [FansResponseModel].deserialize(from: jsonArrayString)
                    let list = try JSONDecoder().decode(Array<<#Model#>>.self , from: jsonData)
                    return .success((list, nextPage))
                } catch let error {
                    logWarning(error)
                    return .failure(AppError.requestFailed("响应数据格式不正确"))
                }
            }
//            .do(onError: { error in
//                print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
//            })
            .catchAndReturn(.failure(AppError.requestFailed("请求失败")))

    }

    /// 获取请求参数
    func parameters() -> [String: Any] {
        var parameters = [String: Any]()
        parameters["pageNum"] = pageNum
        parameters["pageSize"] = pageSize
        parameters["searchWord"] = searchWord
        return parameters
    }
    
    /// 获取请求头
    func header() -> HTTPHeaders { HTTPHeaders(["pqtoken": token]) }
    
}


/// <#响应数据的模型#>
struct SearchCircleModel: Codable {
    
    let circleId: String
    let circleImgs: [String]?
    let content: String?
    let currentNumber: Int?
    /// 圈主名字
    let manageName: String?
    /// 圈子标题+备注
    let tileAndAliansName: String?

}
