//
//  Judy.swift
//  通用文件。常用但又繁琐的方法，在这里做了一些简化
//
//  Created by Judy-王仁洁 on 2017/6/6.
//  Copyright © 2017年 Judy.ICBC All rights reserved.
//
//  JudySDK

import UIKit
import SwiftyJSON

/* 主类需要加上 public，extension 前面加了public，则该分类里面的方法默认都是公开的，只有加 fileprivate 才能实现文件内私有  */


/// 常用系统级相关工具类
///
/// 在 EnolaGay 中最早的工具类，后演变成 struct，起源于 2017 年，在深圳数睿科技 8891 部门，极具收藏意义，非必要不移除任何成员。
/// - version: 1.2
/// - since: 2021年01月09日09:12:33
public struct Judy {
    
    /// 私有init,不允许构建对象
    private init() {}
    
    /// 获取最顶层的 ViewController，不包含 navigationCtrl
    ///
    /// - version: 1.2
    /// - since: 2021年01月13日14:24:46
    /// - warning: 调用时请注意在 App 启动后再调用，否则有可能出现 keyWindow 为空，就会返回一个新的 UIViewController
    public static var topViewCtrl: UIViewController {
        //  UIApplication.shared.windows.last!.rootViewController
        guard keyWindow?.rootViewController != nil else {
            logWarning("topViewCtrl 调用太早，此时 keyWindow 为 nil，只能返回一个 UIViewController()")
            return UIViewController()
        }
        return getTopViewCtrl(rootVC: keyWindow!.rootViewController!)
    }
    
    /// 获取 App 中的 最开始使用的 tabBarController
    ///
    /// - version: 1.2
    /// - since: 2021年01月13日14:05:19
    /// - warning: 请在 App 启动后再调用，否则可能出现 keyWindow 为空并返回 UITabBarController()
    public static var tabBarCtrl: UITabBarController? {
        if appWindow.rootViewController != nil {
            return appWindow.rootViewController as? UITabBarController
        }
        logWarning("appWindow.rootViewController 为 nil！")
        return keyWindow?.rootViewController as? UITabBarController
    }
    
    /// 获取 App 的 window 而不是 keyWindow,也就是呈现故事板时用到的 window
    ///
    /// 在呈现故事板时使用的Window。该属性包含用于在设备主屏幕上显示应用程序的可视内容的窗口。（UIApplication.shared.delegate!.window!!）
    /// - version: 1.1
    /// - since: 2021年01月08日21:19:23
    /// - warning: 如果调用太早（如程序刚启动）这个 window 可能正被隐藏中，并不活跃。
    public static var appWindow: UIWindow {
        guard app.window! != nil else {
            logWarning("app?.window 为 nil，调用太早！")
            if keyWindow != nil {
                return keyWindow!
            } else {
                logWarning("keyWindow 为 nil")
            }
            return UIWindow()
        }
        return app.window!!
    }
    
    /// 获取当前活跃的 window，如 alertview、键盘等关键的 Window。
    ///
    /// 该属性保存 windows 数组中的 UIWindow 对象，该对象最近发送了 makeKeyAndVisible 消息。
    /// - version: 1.1
    /// - since: 2021年01月08日21:21:31
    /// - warning: 注意要在视图加载到视图树后在调用以免为 nil，一般是在 viewDidAppear 后使用
    public static var keyWindow: UIWindow? { UIApplication.shared.keyWindow }
    
    /// 获取 App 代理对象。即 UIApplication.shared.delegate
    public static var app: UIApplicationDelegate {
//        if UIApplication.shared.delegate == nil {
//            judyLog("我操！UIApplication.shared.delegate 竟然为 nil !")
//        }
        return UIApplication.shared.delegate!
    }

    /// 当前是否有alert弹出，主要是提醒更新版本的Alert。
    fileprivate static var isAlerting = false {
        didSet{
            judyLog("哎呀，isAlerting 被设置为\(isAlerting)")
        }
    }
    
    /// 从指定故事板中获取 ViewCtrl 实例
    ///
    /// - Parameters:
    ///   - storyboardName: 故事板 name
    ///   - ident: viewCtrl ident
    /// - Returns: UIViewController
    /// - version: 1.1
    /// - since: 2021年01月08日21:23:42
    public static func getViewCtrl(storyboardName: String, ident: String) -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: nil)
            .instantiateViewController(withIdentifier: ident)
    }
    
    /// 获取屏幕宽度
    ///
    /// - Returns: 屏幕宽度
    public static func getScreenWidth() -> CGFloat { UIScreen.main.bounds.size.width }
    
    
    // MARK: 系统、常用事件
    
    /// 打开路由
    ///
    /// - Parameters:
    ///   - urlStr: 要转成 URL 的 String,如果该 String 无法转成 URL 将不会打开
    ///   - closure: 闭包,(success: Bool)
    public static func openURL(_ urlStr: String, completionHandler closure: @escaping ((Bool) -> Void)) {
        guard NSURL.init(string: urlStr) != nil  else {
            Judy.judyLog("无效URL--->\(urlStr)")
            return
        }
        let url: URL = NSURL.init(string: urlStr)! as URL
        
        openURL(url: url, completionHandler: closure)
    }
    
    // FIXME: 制作 framework 时当闭包参数大于1个时注释将会多余 -No description.
    
    /// 打开路由
    ///
    /// - Parameters:
    ///   - url: 一个正确的URL链接
    ///   - closure: 闭包,(success: Bool)
    public static func openURL(url: URL, completionHandler closure: @escaping ((Bool) -> Void)) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, completionHandler: { (success: Bool) in
                    closure(success)
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            //  入口协议：从其他App跳转到当前App的协议。在配置文件的URL Types中URL Schemes设定，如：tc。
            //  出口协议：当前App跳转到其他App的协议。需要将目标App的入口协议添加到当前App中配置文件的LSApplicationQueriesSchemes白名单里。
            judyLog("未安装路由->\(url)或没有在plist文件中添加LSApplicationQueriesSchemes白名单(出口失败)")
            closure(false)
        }
    }
    
    /// 拨打电话
    /// - Parameter phoneNo: 要拨打的号码，如：18612345678
    /// - Returns: 是否成功触发
    /// - version: 1.1
    /// - since: 2021年01月08日21:30:08
    @discardableResult
    public static func call(phoneNo: String) -> Bool{
        if let url = URL(string: "tel://\(phoneNo)") {
            UIApplication.shared.open(url)
            return true
        }
        log("不合法的电话号码：\(phoneNo)")
        return false
    }
    
    
    /// 毫秒转时间
    ///
    /// - Parameters:
    ///   - time: 时间的毫秒数，如：1525653777000
    ///   - format: 输出格式，默认为 "yyyy/MM/dd HH:mm:ss"
    /// - Returns: 如："2018/05/07 08:42:57"
    public static func timer(time: Int, format: String = "yyyy/MM/dd HH:mm:ss") -> String {
        let time: Int64 = Int64(time)  //1525653777000
        let d = Date(timeIntervalSince1970: Double(time) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let timeString = formatter.string(from: d)
        
        return timeString
    }
    
    /// dictionary 转成 String。服务器需要 String 类型的参数时使用此方法方便地转换数据。
    /// # 在有 JSON 的时候直接使用json.rawString()即可。
    /// - Parameter withDictionary: 比如：["userName": "Judy", "age": 23]
    /// - Returns: "{\"userName\": \"Judy\", \"age\": 23}"
    /// - version: 1.0
    /// - since: 2021年01月08日21:30:08
    @available(*, unavailable, message: "此函数一起用，请使用 SwiftyJSON 的 json.rawString() ")
    public static func string(withDictionary: [String: Any]) -> String { "" }

}

/****************************************  ****************************************/
// MARK: - Base64加密、解密
public extension Judy {
    
    /// 编码
    static func base64Encoding(plainString: String) -> String {
        let plainData = plainString.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    
    /// 解码
    static func base64Decoding(encodedString: String) -> String {
        let decodedData = NSData(base64Encoded: encodedString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
    
}

/****************************************  ****************************************/
// MARK: - 自定义输出、限制输入
public extension Judy {
    
    /**
     - 如果发现不能正常打印，请在Build Settings -> Active Compilation Conditions 的 Debug 项中添加一个 DEBUG 即可。
     */
    
    /// 自定义打印,如果有"，"分隔，则打印出来的东西是["abc","abc"]
    ///
    /// - Parameter items: 允许传入多个要打印的对象
    static func judyLog(_ items: Any...) {
        #if DEBUG
        print("Judy:\(items)")
        #endif
    }
    
    /// 简单输出
    ///
    /// - Parameter item: 只能传入一个字符
    static func judyLog(item: @autoclosure () -> Any) {
        #if DEBUG
        print("Judy:\(item())")
        #endif
    }
    
    /// 打印TODO。此方法用于在控制台输入提醒需要做的事。如：TODO: 实现 JudyConfigDelegate.
    ///
    /// - Parameter item: 只能传入一个字符
    static func judyLogTODO(_ item: Any) {
        #if DEBUG
        print("TODO:\n\(item)\n")
        #endif
    }

    /// 详细的 Log 控制台输出，此函数只在 DEBUG 下执行，请放心随处使用，
    /// ## 若需要关闭此函数所有打印，在 Swift Compiler - Custom Flags 中 Active Compilation Conditions 下增加 NOLOG 即可禁用此函数打印。
    /// ## 使用此函数时只需要传入要输出的 msg 即可，系统会自动传入除 msg 以外的参数
    /// - Parameters:
    ///   - message: 要输出的消息体
    ///   - file: 调用此函数所在的文件名
    ///   - method: 调用此函数所在的方法
    ///   - line: 调用此函数所在的行
    static func log<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        // 🚥❤️🧡💛💚💙💜💟🎇♒️🚦🚖🚘🚔🚙
        print("🚘 \((file as NSString).lastPathComponent)[\(line)] 💟 \(method)\n\(message())\n🚥")
        #endif
    }
    
    /// 在输出函数 log 的基础上增加警告标识符输出
    static func logWarning<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        // 🚥❤️🧡💛💚💙💜💟🎇♒️🚦🚖🚘🚔🚙⚠️
        print("🚔 \((file as NSString).lastPathComponent)[\(line)] 🔎 \(method)\n⚠️\(message())\n🚥")
        #endif
    }
    
    
    
    /// 此函数在 log() 函数的基础上同时在控制台打印线程相关信息
    ///
    /// * note: 此函数基于 log() 函数
    /// * date: 2020年12月04日09:40:08
    static func logt<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        // 🚥❤️🧡💛💚💙💜💟🎇♒️🚦🚖🚘🚔🚙
        print("🚘 Thread\(Thread.current) \((file as NSString).lastPathComponent)[\(line)] 💟 \(method)\n\(message())\n🚥")
        #endif
    }

    // MARK: 自定义方法输入
    
    /// 对要输入的数值进行小数验证。比如只能输入2.1之类的，用于价格、里程数等
    ///
    /// **此方法限textField shouldChangeCharactersInRange代理方法中调用**
    ///
    /// - Parameters:
    ///   - textFieldText: 代理方法的 textField.text! as NSString
    ///   - range: 代理方法的range
    ///   - string: 代理方法的string
    ///   - num: 限制输入小数点后几位？0为不限制，默认为两位。
    ///   - prefix: 限制小数点前面只能输入的位数，默认0，不限制。
    /// - Returns: 是否验证通过
    static func decimal(textFieldText: NSString, range: NSRange, string: String, num: Int = 2, prefix: Int = 0) -> Bool {
        
        var cs: CharacterSet!
        // 小数点前面的数位
        let nDotLoc: Int = textFieldText.range(of: ".").location
        
        // 没有输入小数点
        if prefix != 0 && NSNotFound == nDotLoc && string != "" && string != "." {
            // 小数点前面位数验证
            if textFieldText.length >= prefix {
                judyLog("小数点前只能输入\(prefix)位")
                return false
            }
        }
        
        if NSNotFound == nDotLoc && 0 != range.location {   // 没有输入小数点时匹配这里
            cs = CharacterSet(charactersIn: "0123456789.\n").inverted
        } else {    // 当已输入的内容中有小数点，则匹配此处。
            cs = CharacterSet(charactersIn: "0123456789\n").inverted
        }
        
        let filtered: String = (string.components(separatedBy: cs!) as NSArray).componentsJoined(by: "")
        
        if string as String != filtered {
            judyLog("请输入正确的小数")
            return false
        }
        
        if num != 0 && NSNotFound != nDotLoc && range.location > nDotLoc + num {
            judyLog("小数点后只能保留\(num)位")
            return false
        }
        return true
    }
    
    /// 验证正整型输入，确保当下输入的值符合所需数值要求
    ///
    /// **此方法限 textField shouldChangeCharactersInRange 代理方法中调用**
    /// - Parameters:
    ///   - textField: UITextField 对象
    ///   - range: 代理方法的range
    ///   - string: 代理方法中的的string，即输入的字符
    ///   - num: 限制输入的位数。默认为0，不限制。
    ///   - maxNumber: 允许输入的最大值，比如1000，那么该输入框就无法输入大于1000的值。默认为0，不限制
    ///   - minNumber: 允许输入的最小值，比如1，那么该输入框就无法输入小于1的值且不能输入0。默认为0，不限制
    /// - Returns: 是否验证通过
    static func numberInputRestriction(textField: UITextField, range: NSRange, string: String, num: Int = 0, maxNumber: Int = 0, minNumber: Int = 0) -> Bool {
        
        // Step1：输入数值校验，仅允许输入指定的字符
        let cs: CharacterSet = CharacterSet.init(charactersIn: "0123456789\n").inverted
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        guard string as String == filtered  else { judyLog("请输入正确的数值"); return false }
        
        // Step2：位数校验，验证小数点前所允许的位数
        let textFieldText = textField.text! as NSString
        if num != 0 && string != ""  {
            // 小数点前面位数验证
            guard textFieldText.length < num else { judyLog("只能输入\(num)位"); return false }
        }

        // Step3：数值校验，验证最终输入框中的字符是否符合要求
        let textFieldString = (textFieldText as String) + string
        let numberValue = Int(textFieldString) ?? 0
        // 最大值校验
        if maxNumber != 0 && numberValue > maxNumber && string != "" {
            judyLog("只能输入小于\(maxNumber)的值")
            return false
        }
        // 最小值校验
        if minNumber != 0 && numberValue < minNumber && string != "" {
            judyLog("只能输入>=\(minNumber)的值")
            return false
        }
        
        // 空字符校验
        if string == "" && numberValue <= minNumber {
            textField.text = String(minNumber)
            return false
        }
        
        return true
    }
    
    /// 仅限整型输入。可输入的字符[0123456789\n]
    /// - Parameters:
    ///   - textField: UITextField 对象
    ///   - range: 代理方法的range
    ///   - string: 代理方法中的的string，即输入的字符
    static func numberInput(textField: UITextField, range: NSRange, string: String) -> Bool {
        let cs: CharacterSet = CharacterSet.init(charactersIn: "0123456789\n").inverted
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        guard string as String == filtered  else {
            judyLog("仅限输入数值")
            return false
        }

        return !numberisZero(textField: textField, string: string)
    }
    
    /// 对输入框中的值进行转换为Int 0 验证，若输入框中的值结果为0，则返回 true，反之返回 false，并将该输入框的值改为 0
    /// - Parameters:
    ///   - textField: UITextField 对象
    ///   - string: 代理方法中的的string，即输入的字符
    private static func numberisZero(textField: UITextField, string: String) -> Bool {
        // 首位去0验证
        if (textField.text ?? "" == "0") && string != "0" {
            textField.text = ""
        }
        // 最终输入的值
        let textFieldString = (textField.text ?? "") + string
        let textFieldNumber = Int(textFieldString)
        if textFieldNumber == 0 {
            textField.text = "0"
            return true
        }
        return false
    }
    
}

/****************************************  ****************************************/
// MARK: - App版本相关
public extension Judy {
    
    /// 获取version,即CFBundleShortVersionString
    ///
    /// - Returns: 如：2.5.8
    static func versionShort() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    /// 获取Build版本号
    ///
    /// - Returns: 如：1
    static func versionBuild() -> String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    /// 检查是否有新版本,如果有新版本则会弹出一个AlertController,引导用户去更新App
    ///
    /// - Parameters:
    ///   - alertTitle: 弹出视图的标题
    ///   - alertMsg: 弹出视图的消息体,如果nil则为AppStore更新文字
    ///   - btnText: 更新按钮文字信息
    ///   - cancel: 取消按钮文字信息
    static func versionNormal(alertTitle: String = "发现新版本", alertMsg: String?, btnText: String = "前往更新", cancel: String = "不，谢谢") {
        versionCheck { (status:Int, newVersion:Bool, msg:String, appStroeUrl:String?) in
            if newVersion {
                if appStroeUrl != nil {
                    // 更新时的提示消息
                    alertOpenURL(force: false, alertTitle: alertTitle, alertMsg: alertMsg ?? msg,
                                 btnText: btnText, cancel: cancel, trackURL: appStroeUrl!)
                } else {
                    Judy.log("有新版本，但appStoreURL为nil导致没有弹出更新提示")
                }
            } else {
                Judy.log("没有发现新版本->\(msg)")
            }
        }
    }
    
    /// 检测新版本并强制式要求用户进行版本更新，只有一个按钮，用户只能点击跳转到AppStore
    ///
    /// - Parameters:
    ///   - alertTitle: 弹出视图的标题
    ///   - alertMsg: 弹出视图的消息体,如果传入nil则为AppStore的更新文字
    ///   - btnText: 更新按钮文字信息
    static func versionForce(alertTitle: String = "请更新版本", alertMsg: String?, btnText: String = "好的") {
        versionCheck { (status:Int, newVersion:Bool, msg:String, appStroeUrl:String?) in
            if newVersion && appStroeUrl != nil {
                // 更新时的提示消息
                alertOpenURL(force: true, alertTitle: alertTitle, alertMsg: alertMsg ?? msg,
                             btnText: btnText, cancel: "无用", trackURL: appStroeUrl!)
            }
        }
    }
    
    
    /// 从AppStore检查当前App状态,此方法将会在闭包里传入一个status:Int
    ///
    /// - Parameter closure: 传入回调函数，里面只有一个Int
    ///     - status 当前App状态，-4:data转json失败，-3:版本检查失败，-2:没有找到，-1:审核状态，0：最新版本，1:有新版本，请更新
    static func version(status closure: @escaping ((Int) -> Void)){
        versionCheck { (status: Int, newVersion: Bool, msg: String, url: String?) in
            closure(status)
        }
    }
    
    /// 同步请求检查当前App状态,此方法将返回一个status:Int
    ///
    /// - Returns: status 当前App状态，-4:data转json失败，-3:版本检查失败，-2:没有找到，-1:审核状态，0：最新版本，1:有新版本，请更新
    static func versionSynchronous() -> Int{
        var rs = 0
        // Judy-mark: 创建信号量
        let semaphore = DispatchSemaphore(value: 0)
        
        versionCheck { (status: Int, newVersion: Bool, msg: String, url: String?) in
            rs = status
            // Judy-mark: 发送信号量
            semaphore.signal()
        }
        // Judy-mark: 等待信号量
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return rs
    }
    
    /// 从AppStore检查当前App状态
    ///## 此方法会在闭包参数里传入一个JSON字典，字段如下
    ///- newVersion: Bool    是否有新版本
    ///- msg: String 消息体
    ///- URL: String?    AppStore URL:(AppStore URL只在有新版本时有值，默认没有此字段)
    ///- status: Int 当前App状态，-4:data转json失败，-3:版本检查失败，-2:没有找到，-1:审核状态，0：最新版本，1:有新版本，请更新
    /// - Parameter closure: 回调函数
    static func versionCheck(completionHandler closure: @escaping ((JSON) -> Void)){
        versionCheck { (status: Int, newVersion: Bool, msg: String, url: String?) in
            var json = JSON(["status":0])
            if newVersion {
                json["URL"] = JSON(url ?? "")
            }
            json["newVersion"] = JSON(newVersion)
            json["msg"] = JSON(msg)
            json["status"] = JSON(status)
            
            closure(json)
        }
    }
    
    /// 当前App版本状态
    ///
    /// - latest: 当前为最新版本
    /// - older: 当前使用的为较旧版本，可以更新到新版本
    /// - review: 当前使用的为审核版本
    /// - notFound: 没有找到该应用
    enum AppVersionStatus {
        /// 最新版本
        case latest
        /// 当前使用的为较旧版本，可以更新到新版本
        case older
        /// 当前使用的为审核版本
        case review
        /// 当前App尚未出现在AppStore
        case notFound
    }
    
    /// 检查当前App版本状态，通过传入一个线上版本号与当前版本进行比较
    ///
    /// - Parameter versionOnLine: 线上版本号，如:2.6.0
    /// - Returns: App版本状态
    static func versionCompare(versionOnLine: String) -> AppVersionStatus {
        var versionStatus = AppVersionStatus.latest
        
        // Judy-mark: 以""切割字符串并返回数组
        var versionLocalList = versionShort().components(separatedBy: ".")
        var versionOnLineList = versionOnLine.components(separatedBy: ".")
        
        // 当要比较的两个数组长度不一致
        if versionLocalList.count != versionOnLineList.count {
            // 得到差值并补齐使之数组长度相等
            let s = versionLocalList.count - versionOnLineList.count
            for _ in 1...abs(s) {
                if versionLocalList.count > versionOnLineList.count {
                    versionOnLineList.append("0")
                } else {
                    versionLocalList.append("0")
                }
            }
        }
        var verL: Int = 0, verS: Int = 0
        // 比较版本
        for i in 0..<versionLocalList.count {
            guard (Int(versionLocalList[i]) != nil), (Int(versionOnLineList[i]) != nil) else {
                Judy.log("错误：版本号中存在非Int字符！")
                return .latest
            }
            verL = Int(versionLocalList[i])!
            verS = Int(versionOnLineList[i])!
            if verL == verS {
                versionStatus = .latest
                continue
            }
            if verL < verS{  // 有更新
                versionStatus = .older
                break
            }
            if verL > verS {
                versionStatus = .review
                break
            }
        }
        return versionStatus
    }
    
    /// 弹出更新提示框，或用以询问用户打开链接的UIAlertController
    ///
    /// **isAlerting 会被设置成true两遍为正常现象**
    /// - Parameters:
    ///   - force: 是否强制更新
    ///   - alertTitle: 弹出视图的标题
    ///   - alertMsg: 弹出视图的消息体
    ///   - btnText: 主要(更新)按钮文字
    ///   - cancel: 取消按钮文字，当force为true时此按钮不会显示
    ///   - trackURL: URL，点击红色按钮后打开的链接
    static func alertOpenURL(force: Bool,
                             alertTitle: String,
                             alertMsg: String,
                             btnText: String,
                             cancel: String,
                             trackURL: String){
        if isAlerting {
            return
        }
        isAlerting = true
        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMsg,
                                                preferredStyle: .alert)
        // 创建UIAlertAction空间， style: .destructive 红色字体
        let okAction = UIAlertAction(title: btnText, style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
            
            openURL(trackURL, completionHandler: { rs in })
            isAlerting = false
            
            if force {
                topViewCtrl.present(alertController, animated: true, completion: {
                    isAlerting = true
                })
            }
        })
        
        if !force { // 不强制，加上取消按钮
            let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                isAlerting = false
            })
            alertController.addAction(cancelAction)
        }
        
        alertController.addAction(okAction)
        topViewCtrl.present(alertController, animated: true, completion: {
            isAlerting = true
        })
    }
    
    // MARK: private method
    
    /// 从AppStore检查版本状态
    /// - status: Int    当前App状态，-4:data转json失败，-3:版本检查失败，-2:没有找到，-1:审核状态，0：最新版本，1:有新版本，请更新
    /// - newVersion: Bool   是否有新版本，是=true
    /// - msg: String    对应消息体
    /// - url: String    AppStore链接,只有发现新版本时候有值
    /// - Parameter callBack: 需传入闭包
    private static func versionCheck(callBack: @escaping ((Int, Bool,String,String?) -> Void)) {
        
        //得到CFBundleIdentifier
//        let bundleId = "com.gymj.kepu.xj"  // "com.Addcn.car8891" "com.gymj.kepu.xj"
        let bundleId = (Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String)
        //设置请求地址
        var requestURLStr = "https://itunes.apple.com/cn/lookup?bundleId=\(bundleId)"
        
        //解决UTF-8乱码问题
        requestURLStr = requestURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // 独立版更新方式
        let storeURL = URL(string: requestURLStr)
        
        // timeoutInterval: 网络请求超时时间(单位：秒)
        //        var request = URLRequest(url: storeURL!)
        var request = URLRequest.init(url: storeURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 8)
        
        // 3、设置请求方式为POST，默认是GET
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, res: URLResponse?, err: Error?) in

            if (data?.count == nil) || (err != nil) {
                callBack(-3, false, "App版本检查失败", nil)
                return
            }
            
            // Success  返回data转json
            let dataDic: [String: Any]? = try! JSONSerialization.jsonObject(with: data!,
                                                                            options: .allowFragments) as? [String : Any]
            
            if dataDic == nil {
                callBack(-4, false, "data转json失败", nil)
                return
            }
            
            let resultCount = dataDic!["resultCount"] as? Int
            if resultCount == 0 {
                callBack(-2, false, "并没有在AppStore上找到该应用", nil)
                return
            }
            
            let array: [Any] = dataDic!["results"]as! [Any]
            let dic: [String: Any] = array[0] as! [String: Any]
            
            // 得到服务器的版本
            let versionOnLine: String = dic["version"] as! String
            
            var bNewVersion = false // 是否有新版本的标志，默认false
            var msg = "Judy", appStoreUrl: String? = nil, status: Int = 0
            
            let rs = versionCompare(versionOnLine: versionOnLine)
            switch rs {
            case .latest:
                msg = "当前使用的版本为最新版本"
                break
            case .older:
                bNewVersion = true
                // 得到服务器的地址 ---> 将URL decode
                //                    appStoreUrl = (dic["trackViewUrl"] as! String).removingPercentEncoding ?? "URL为空"
                appStoreUrl = dic["trackViewUrl"] as? String
                //得到服务器新版本消息
                msg = dic["releaseNotes"] as! String
                status = 1
                break
            case .review:
                status = -1
                msg = "当前为审核版本"
                break
            case .notFound:
                status = -2
                msg = "并没有在AppStore上找到该应用"
            }
            
            // 回调
            callBack(status, bNewVersion, msg, appStoreUrl)
//            judyLog("发现AppStore的版本:\(versionOnLine)")
        }
        task.resume()
    }
    
}

/****************************************  ****************************************/
// MARK: - 测试类
extension Judy {

    public static func test(){
        judyLog("这是来自测试类的打印")
        testPrivate()
    }
    
    fileprivate static func testPrivate(){
        judyLog("这是私有打印")
    }
    
    public static func testStaticVar(){
        isAlerting = !isAlerting
        judyLog("此时，temp=\(isAlerting)")
    }
}

/****************************************  ****************************************/
// MARK: - 私有方法
fileprivate extension Judy {
    
    /// 获取最顶层的 ViewCtrl
    /// - Parameter rootVC: 以该 ViewCtrl 为基础查找最顶层的 ViewCtrl
    /// - Returns: 可能是 NavigationCtrl、UIViewCtrl
    static func getTopViewCtrl(rootVC: UIViewController) -> UIViewController {
        let topVC = rootVC
        if (topVC.presentedViewController != nil) {
            return getTopViewCtrl(rootVC: topVC.presentedViewController!)
        }
        if topVC.isKind(of: UINavigationController.classForCoder()) {
            return getTopViewCtrl(rootVC: (topVC as! UINavigationController).viewControllers.last!)
        }
        if topVC.isKind(of: UITabBarController.classForCoder()) {
            return getTopViewCtrl(rootVC: (topVC as! UITabBarController).selectedViewController!)
        }
        return topVC
    }
    
    static func getTabBarController() -> UITabBarController? {
        return UIApplication.shared.keyWindow?.rootViewController as? UITabBarController
    }
    
}



/*

 
 func checkVersion() {
 var bFlg = true
 
 // Judy-mark: 信号量
 let semaphore = DispatchSemaphore(value: 0)
 
 // Judy-mark: GCD异步执行耗时操作
 DispatchQueue.global().async {
 sleep(8)
 print("bFlg = \(bFlg),bFlg即将被改变")
 bFlg = false
 print("bFlg = \(bFlg)了")
 
 // Judy-mark: 信号量
 semaphore.signal()
 // Judy-mark: 回到主线程执行
 //            DispatchQueue.main.async {
 //
 //            }
 }
 
 // Judy-mark: 信号量
 _ = semaphore.wait(timeout: DispatchTime.distantFuture)
 print("结束", bFlg)
 //        return bFlg
 
 // Judy-mark: GCD延时执行
 let delay = DispatchTime.now() + .seconds(10)
 DispatchQueue.main.asyncAfter(deadline: delay, execute: {
 Judy.log("延迟执行完毕")
 })
 
 
 }
 */

/*
 在Swift中URL编码
 
 在swift中URL编码用到的是String的方法
 
 func addingPercentEncoding(withAllowedCharacters allowedCharacters: CharacterSet) -> String?
 
 用法：
 
 let str = "{urlencode}"
 print(str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
 
 编码后的结果：%7burlencode%7d
 
 在Swift中URL解码
 
 在Swift中URL解码用到的是String的属性
 
 var removingPercentEncoding: String? { get }
 
 用法：
 
 let str = "%7burldecode%7d"
 print(str.removingPercentEncoding)
 
 解码后得到的结果是：{urldecode}
 */


// MARK: - 废弃的方法
extension Judy {
    @available(*, deprecated, message: "使用 UIColor.EMERANA 的扩展")
    public static func colorByRGB(rgbValue: Int, alpha: CGFloat = 1) -> UIColor {return .red}
    @available(*, deprecated, message: "使用 UIColor.EMERANA 的扩展")
    public static func colorByRGB(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) -> UIColor {return .red}
    @available(*, deprecated, message: "使用 UIImage.EMERANA 的扩展")
    public static func image(with color: UIColor) -> UIImage {return UIImage()}
    @available(*, deprecated, message: "使用 UIImage.EMERANA 的扩展")
    public static func image(fromLayer layer: CALayer) -> UIImage {return UIImage()}
    @available(*, deprecated, message: "使用 UIView.EMERANA 的扩展")
    public static func viewRound (view: UIView, border: CGFloat = 0, color: UIColor = .darkGray) {}
    @available(*, deprecated, message: "使用 UIView.EMERANA 的扩展")
    public static func viewRadiu (view: UIView, radiu: CGFloat = 10, border: CGFloat = 0, color: UIColor = .darkGray) {}
    @available(*, deprecated, message: "该函数已废弃")
    public static func saveUserDefault(value: Any, key: String) {}
    @available(*, deprecated, message: "该函数已废弃")
    public static func getUserDefault(key: String) -> Any {return ""}
    @available(*, deprecated, message: "该函数已废弃")
    public static func removeUserDefault(key: String) {}
    /// 详细的输出 Log 方式，只有在 DeBug 模式下会打印
    @available(*,deprecated, message: "该函数已支持重命名，请使用新的函数名。", renamed: "log")
    public static func judy<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        // 🚥❤️🧡💛💚💙💜💟🎇♒️🚦🚖🚘🚔🚙
        print("🚘\((file as NSString).lastPathComponent)[\(line)]💟\(method)\n\(message())\n🚥")
        #endif
    }
    @available(*, unavailable, renamed: "numberInputRestriction", message: "此函数已重命名")
    public static func number(textField: UITextField, range: NSRange, string: String, num: Int = 0, maxNumber: Int = 0, minNumber: Int = 0) -> Bool {
        return false
    }

    
}
