//
//  JudyFileManage.swift
//  RouteFlight
//
//  Created by Judy-王仁洁 on 2017/6/17.
//  Copyright © 2017年 ICBC. All rights reserved.
//
//  JudySDK

import UIKit

/// 文件管理类。为 car8891 专用，不推荐使用。
class JudyFileManage: NSObject {
    
    private let fileManager = FileManager.default
    private let home: String = NSHomeDirectory()
    private let documents: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // 操作类
    func main() {
        //        print("沙盒根目录:\(home)")
        queryDocuments(directory: nil)
        createFloder(floderName: "Judy")
        queryDocuments(directory: nil)
        
        // 在Judy文件夹下创建history.json文件
        let file = documents.appendingPathComponent("Judy/history.json")
        
        createFile(file: file)
        queryDocuments(directory: "Judy")
        readFile(file: file)
        writeFileByArray(fileName: "Judy/history.json")
        
        readFile(file: file)
        //        removeFile(file: file)
        removerFloder(floderName: "Judy")
        queryDocuments(directory: "Judy")
        
    }
    
    /// 数据源类型
    ///
    /// - history: 历史记录
    /// - fixed: 固定路由
    public enum DataType {
        case history
        case fixed
    }
    
    /// 读取数据
    ///
    /// - Parameter type: 数据类型
    /// - Returns: list
    func readData(byType type: DataType) -> [String] {
        var dataList = [String]()
        var filePath = home
        
        if type == .history {
            filePath = home + "/Documents/" + "history.plist"
        } else {
            filePath = home + "/Documents/" + "fixed.plist"
        }
        
        let exist = fileManager.fileExists(atPath: filePath)
        if exist {
            dataList = NSArray(contentsOfFile: filePath)as! [String]
        } else {
            print("fuck!------\(filePath)根本不存在！")
            if type == .history {
                let file = documents.appendingPathComponent("history.json")
                
                createFile(file: file)
            } else {
                dataList = readFromPlist()
            }
        }
        
        return dataList
    }
    
    /// 写入数组
    ///
    /// - Parameters:
    ///   - array: 数据
    ///   - dataType: 写入数据的类型
    /// - Returns: 写入结果
    @discardableResult // Judy-mark: 可以不接收返回值
    func writeArray(array: [String], dataType: DataType) -> Bool{
        var fileName = ""
        if dataType == .history {
            fileName = "history.plist"
        } else {
            fileName = "fixed.plist"
        }
        
        let filePath:String = home + "/Documents/" + fileName
        let array = array as NSArray
        let rs = array.write(toFile: filePath, atomically: true)
        if rs {
            print("写入成功")
        } else {
            print("写入失败")
        }
        return rs
    }
    
    /// 插入一项纪录到历史记录
    ///
    /// - Parameter content: 内容
    func addItemToHistory(content: String)  {
        var list = readData(byType: .history)
        list.insert(content, at: 0)
        writeArray(array: list, dataType: .history)
    }
    
    /// (还原)，从bundle fixed.plisy读取数据
    func readFromPlist() -> [String] {
        var dataList = [String]()
        //读取Json数据
        do {
            let path: String = Bundle.main.path(forResource: "fixed", ofType: "plist")!
            let nsUrl = NSURL.fileURL(withPath: path)
            let data: Data = try Data(contentsOf: nsUrl as URL)
            if data.count == 0 {
                return ["bundle都没有数据！"]
            }
            dataList = NSArray.init(contentsOf: nsUrl as URL) as! [String]
            
            print("json: \(dataList)")
            // 这里需要写入文件
            writeArray(array: dataList, dataType: .fixed)
            
        } catch {
            print("Error: (data: contentsOf: url)")
            dataList = ["异常！"]
        }
        return dataList
    }
    
    /// 从plist文件读取数组
    ///
    /// - Parameter fileName: 文件名(不带后缀)
    /// - Returns: list
    func readByPlist(fileName: String) -> [[String: String]] {
        var list = [[String: String]]()
        //读取Json数据
        do {
            let path: String = Bundle.main.path(forResource: fileName, ofType: "plist")!
            let nsUrl = NSURL.fileURL(withPath: path)
            let data: Data = try Data(contentsOf: nsUrl as URL)
            if data.count == 0 {
                return list
            }
            list = NSArray.init(contentsOf: nsUrl as URL) as! [[String: String]]
        } catch {
            list = [["Error": "发生异常"]]
        }
        return list
    }
    
    // MARK: - 封装好的公用方法
    /****************************************  ****************************************/
    
    // MARK: - private method
    
    // MARK: - ####################################################################################
    
    /// 遍历Documents文件夹
    ///
    /// - Parameter directory: 文件夹名称，如果为nil则遍历documents文件夹
    private func queryDocuments(directory: String?) {
        // Documents目录详情
        var floder = home + "/Documents/"
        if directory != nil {
            floder += directory!
        }
        let exist = fileManager.fileExists(atPath: floder)
        if exist {
            let contentsOfPath = try? fileManager.contentsOfDirectory(atPath: floder)
            print("\(floder)目录详情: \(String(describing: contentsOfPath))")
        } else {
            print("\(floder)目录压根不存在")
        }
        
    }
    
    /// 创建文件夹
    ///
    /// - Parameter floderName: 文件夹名称
    private func createFloder(floderName: String) {
        // 判断文件或文件夹是否存在
        let judyFloder = home + "/Documents/" + floderName
        let exist = fileManager.fileExists(atPath: judyFloder)
        if exist {
            print("不好意思，Documents/Judy已经存在")
        } else {
            print("Documents下没有找到Judy文件夹，即将创建")
            try! fileManager.createDirectory(atPath: judyFloder, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// 删除文件夹
    ///
    /// - Parameter floderName: 文件夹名
    private func removerFloder(floderName: String) {
        let judyFloder = home + "/Documents/" + floderName
        try! fileManager.removeItem(atPath: judyFloder)
        queryDocuments(directory: nil)
    }
    
    
    /// 创建文件
    ///
    /// - Parameter fileName: 文件名
    private func createFile(file: URL) {
        print("文件: \(file)")
        let exist = fileManager.fileExists(atPath: file.path)
        if !exist {
            //            let data = Data(base64Encoded:"Hello Judy!" ,options:.ignoreUnknownCharacters)
            let createSuccess = fileManager.createFile(atPath: file.path, contents: nil, attributes: nil)
            print("文件创建结果: \(createSuccess)")
        } else {
            print("已经存在\(file)")
        }
    }
    
    /// 读取文件
    ///
    /// - Parameter fileName: 文件名
    private func readFile(file: URL) {
        
        //方法1
        let readHandler = try! FileHandle(forReadingFrom:file)
        let data = readHandler.readDataToEndOfFile()
        let readString = String(data: data, encoding: String.Encoding.utf8)
        print("文件内容: \(String(describing: readString))")
        
        //方法2
        let data2 = fileManager.contents(atPath: file.path)
        let readString2 = String(data: data2!, encoding: String.Encoding.utf8)
        print("文件内容: \(String(describing: readString2))")
        
        let tfArray = NSArray(contentsOfFile: home + "/Documents/Judy/" + "history.json")
        
        print("文件内容: \(String(describing: tfArray))")
    }
    
    /// 将信息写入文件
    ///
    /// - Parameter fileName: 文件名
    private func writeFile(fileName: String) {
        let filePath:String = home + "/Documents/" + fileName
        let info = "欢迎来到Judy"
        try! info.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    /// 写入array
    ///
    /// - Parameter fileName: 文件名
    private func writeFileByArray(fileName: String) {
        let array = NSArray(objects: "Judy1","Judy2","Judy3")
        let filePath:String = home + "/Documents/" + fileName
        array.write(toFile: filePath, atomically: true)
    }
    
    /// 删除指定文件
    ///
    /// - Parameter fileName: 文件名
    private func removeFile(file: URL) {
        try! fileManager.removeItem(at: file)
    }
    
}
