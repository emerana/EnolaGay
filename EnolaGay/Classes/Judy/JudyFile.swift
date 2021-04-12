//
//  JudyFile.swift
//  EMERANA
//  文件管理
//  Created by Judy-王仁洁 on 2017/6/30.
//  Copyright © 2017年 Judy.ICBC. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 *  - 文件操作类。
 *      - !!! 默认操作都是在documents文件夹下。
 */
public class JudyFile: NSObject {
    /// 单例
    public static let judy = JudyFile()
    
    private override init() {} // 这可以防止其他人使用默认的()对这个类的初始化。
    
    private let manager = FileManager.default
    
    /// 沙盒根目录
    private let home: String = NSHomeDirectory()
    
    /// documents文件夹
    private let documents: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // MARK: - 文件夹操作
    
    /// 在Documents下遍历指定文件夹
    ///
    /// - Parameter folder: 要遍历的文件夹名称，如果传入nil，遍历documents
    @discardableResult
    public func queryDocuments(folder: String?) -> [String] {
        // 浅搜索，返回指定路径下的子目录、文件、及符号链接列表
        var contentsOfPath = try? manager.contentsOfDirectory(atPath: documents.path)
        if folder == nil {
            Judy.log("Documents目录详情: \(String(describing: contentsOfPath))")
        }else {
            let exist = verfiryExist(path: folder!)
            
            if exist {
                contentsOfPath = try? manager.contentsOfDirectory(atPath: getfilePath(fileName: folder!))
                Judy.log("\(folder!)目录详情: \(String(describing: contentsOfPath))")
            }else {
                Judy.log("在Documents下并没有发现\(String(describing: folder))目录")
                contentsOfPath = [String]()
            }
        }
        return contentsOfPath ?? [String]()
    }
    
    /// 新建文件夹
    ///
    /// - Parameter folder: 文件夹名称
    /// - Returns: 创建结果，true:创建成功,false:已经存在
    @discardableResult
    public func createFloder(folder: String) -> Bool {
        var createRS = false
        let dir = documents.appendingPathComponent(folder, isDirectory: true)
        let exist = manager.fileExists(atPath: dir.path)
        if exist {
            Judy.log("已经存在\(dir.path)")
        } else {
            do{
                try manager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
                Judy.log("\(dir)创建成功")
            }catch{
                createRS = false
                Judy.log("\(dir)创建失败")
            }
        }
        return createRS
    }
    
    // TODO: 重命名文件夹
    
    /// 删除。如果是删除文件夹，会将该文件夹内所有数据都删除
    ///
    /// - Parameter str: 文件夹或文件名
    public func remove(str: String) {
        let dir = documents.appendingPathComponent(str, isDirectory: true)
        do{
            try manager.removeItem(at: dir)
            Judy.log("成功删除\(str)")
        }catch{
            Judy.log("删除操作失败")
        }
    }
    
    // MARK: - 文件操作
    
    /// 从项目文件中读取json
    ///
    /// - Parameters:
    ///   - fileName: 不带后缀的文件名
    ///   - fileType: 文件后缀，如plist、json、txt，默认为.json文件
    /// - Returns: 一个标准的JSON
    public func jsonFormFile(fileName: String, fileType: String = "json") -> JSON {
        guard fileName.clean() != "" else {
            return JSON([EMERANA.Key.JSON.error: [EMERANA.Key.JSON.msg: "请传入文件名"]])
        }
        var json = JSON()
        //读取Json数据
        do {
            // Judy-mark: 如果 fileName 为""，则会返回上一次使用成功的文件名
            let path = Bundle.main.path(forResource: fileName, ofType: fileType)
            guard path != nil else {
                return JSON([EMERANA.Key.JSON.error: [EMERANA.Key.JSON.msg: "没有找到文件：\"\(fileName).\(fileType)\""]])
            }
            let nsUrl = NSURL.fileURL(withPath: path!)
            let data: Data = try Data(contentsOf: nsUrl as URL)
            if data.count == 0 {
                return json
            }
            json = try! JSON(data: data)
        } catch {
            Judy.log("读取文件发生异常")
            json = JSON([EMERANA.Key.JSON.error: [EMERANA.Key.JSON.msg: "读取文件发生异常", "file": fileName]])
        }
        
        return json
    }
    
    /// 从项目中读取plist文件，明确文件内容为数组
    ///
    /// - Parameter fileName: 文件名，不包含后缀
    /// - Returns: 数组
    public func readPlist(fileName: String) -> [Any] {
        var dataList = [Any]()
        let path: String = Bundle.main.path(forResource: fileName, ofType: "plist")!
        if NSArray.init(contentsOfFile: path) != nil {
            dataList = NSArray.init(contentsOfFile: path) as! [Any]
            Judy.log("\(fileName)文件数据 = \(dataList)")
        } else {
            Judy.log("\(fileName)不包含数组内容")
        }
        return dataList
    }
    
    /// 从项目中读取plist文件，明确文件内容为字典
    ///
    /// - Parameter fileName: 文件名，不包含后缀
    /// - Returns: 字典
    public func readPlistDic(fileName: String) -> [String: Any] {
        var dataDic = [String: Any]()

        let path: String = Bundle.main.path(forResource: fileName, ofType: "plist")!
        if NSDictionary.init(contentsOfFile: path) != nil {
            dataDic = NSDictionary.init(contentsOfFile: path)as! [String: Any]
            Judy.log("\(fileName)文件数据 = \(dataDic)")
        } else {
            Judy.log("\(fileName)不包含字典内容")
        }
        return dataDic
    }
    
    /// 新建文件,注意，一定要在一个已存在的文件夹下创建文件
    ///
    /// - Parameter fileName: 文件路径
    /// - Returns: 创建结果，false:已经存在，true:创建成功
    @discardableResult
    public func createFile(fileName: String) -> Bool {
        var createRS = false
        
        let exist = verfiryExist(path: fileName)
        if !exist {
            createRS = manager.createFile(atPath: getfilePath(fileName: fileName), contents: nil, attributes: nil)
            Judy.log("文件创建结果: \(createRS)")
        } else {
            Judy.log("已经存在\(fileName)")
        }
        
        return createRS
    }
    
    // 重命名文件
    // 删除文件
    
    /// 读取数组文件，明确是个数组文件
    ///
    /// - Parameter fileName: 文件名，如"Judy/test.plist"
    /// - Returns: 数组
    public func readFile(fileName: String) -> [Any]{
        var dataList = [Any]()
        
        if !verfiryExist(path: fileName){
            return dataList
        }
        
        if NSArray(contentsOfFile: getfilePath(fileName: fileName)) != nil {
            dataList = NSArray(contentsOfFile: getfilePath(fileName: fileName)) as! [Any]
            Judy.log("读取数组结果\(dataList)")
        } else {
            Judy.log("不包含数组内容:\(dataList)")
        }
        
        return dataList
    }
    
    /// 读取字典文件，明确是个字典文件
    ///
    /// - Parameter fileName: 文件名，如"Judy/test.plist"
    /// - Returns: 字典
    public func readFileDic(fileName: String) -> [String: Any]{
        var data = [String: Any]()
        if !verfiryExist(path: fileName){
            return data
        }
        
        if NSDictionary(contentsOfFile: getfilePath(fileName: fileName)) != nil {
            data = NSDictionary(contentsOfFile: getfilePath(fileName: fileName)) as! [String: Any]
            Judy.log("读取字典结果\(data)")
        } else {
            Judy.log("不包含字典内容:\(data)")
        }
        
        return data
    }
    
    // MARK: - 写入文件
    
    /// 写入数组到文件
    ///
    /// - Parameters:
    ///   - fileName: 文件名
    ///   - array: 数组
    /// - Returns: 写入结果
    @discardableResult
    public func writeArray(fileName: String, array: NSArray) -> Bool {
        if !verfiryExist(path: fileName) { return false }
        
        return array.write(toFile: getfilePath(fileName: fileName), atomically: true)
    }
    
    /// 写入字典到文件
    ///
    /// - Parameters:
    ///   - fileName: 文件名
    ///   - dic: 字典数据
    /// - Returns: 写入结果
    @discardableResult
    public func writeDic(fileName: String, dic: NSDictionary) -> Bool {
        if !verfiryExist(path: fileName){
            Judy.log("因不存在该文件而没有写入")
            return false
        }
        let rs = dic.write(toFile: getfilePath(fileName: fileName), atomically: true)
        Judy.log(rs ? "写入成功" : "写入失败")
        
        return rs
    }
    
    /// 验证文件或文件夹是否存在，当前操作在Documents下
    ///
    /// - Parameter path: 只需传入文件或文件夹名
    /// - Returns: 是否存在
    public func verfiryExist(path: String) -> Bool{
        let exist = manager.fileExists(atPath: getfilePath(fileName: path))
        if exist {
            return true
        } else {
            Judy.log("不存在\(path)")
            return false
        }
    }
    
    // MARK: - 私有方法
    
    /// 获取文件URL,以Documents来拼接传入的字符
    ///
    /// - Parameter fileName: 文件名
    /// - Returns: 文件URL
    private func getfileURL(fileName: String) -> URL{
        return documents.appendingPathComponent(fileName)
    }
    
    /// 获取文件URL的paht,以Documents来拼接传入的字符
    ///
    /// - Parameter fileName: 文件名
    /// - Returns: URL.path
    private func getfilePath(fileName: String) -> String{
        return getfileURL(fileName: fileName).path
    }
    
    // MARK: - 测试
    
    /// 不加public，默认只能当前库中能访问
    func test(){
        // 在Judy文件夹下创建history.json文件
        //        let file = documents.appendingPathComponent("Judy/history.json")
        /*
         1:创建文件夹内的文件database/Judy.plist
         2:写入数据
         4:删除文件
         */
        
        self.queryDocuments(folder: nil)
        self.createFloder(folder: "data/bb")
        self.createFile(fileName: "data/bb/Judy.plist")
        self.queryDocuments(folder: nil)
        self.queryDocuments(folder: "data")
        self.writeDic(fileName: "data/bb/Judy.plist", dic: ["name": "Judy-王仁洁"])
        let _ = self.readFileDic(fileName: "data/bb/Judy.plist")
        let _ = self.readFile(fileName: "data/bb/Judy.plist")
        // 试试删除文件夹或文件
        self.remove(str: "data")
        self.queryDocuments(folder: nil)
        
        
    }
    
}
