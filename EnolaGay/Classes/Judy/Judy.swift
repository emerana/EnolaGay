//
//  Judy.swift
//  通用文件。常用但又繁琐的方法，在这里做了一些简化。
//
//  Created by Judy-王仁洁 on 2017/6/6.
//  Copyright © 2017年 Judy.ICBC All rights reserved.
//
//  JudySDK

import UIKit
import SwiftyJSON

/* 主类需要加上 public，extension 前面加了 public，则该分类里面的方法默认都是公开的 */
/* FIXME: 制作 framework 时当闭包参数大于1个时注释将会多余 -No description. */


/// 常用系统级相关工具类
///
/// 在 EnolaGay 中最早的工具类，后演变成 struct，起源于 2017 年，在深圳数睿科技 8891 部门，极具收藏意义，非必要不移除任何成员。
public struct Judy {
    
    /// 私有init,不允许构建对象
    private init() {}
    
    /// 获取最顶层的 ViewController，不包含 navigationCtrl。
    ///
    /// - Warning: 调用时请注意在 App 启动后再调用，否则有可能出现 keyWindow 为空，就会返回一个新的 UIViewController。
    public static var topViewCtrl: UIViewController {
        //  UIApplication.shared.windows.last!.rootViewController
        guard Judy.keyWindow?.rootViewController != nil else {
            logWarning("topViewCtrl 调用太早，此时 keyWindow 为 nil，只能返回一个 UIViewController()")
            return UIViewController()
        }
        return getTopViewCtrl(rootVC: Judy.keyWindow!.rootViewController!)
    }
    
    /// 获取 App 中最开始使用的 tabBarController。
    ///
    /// - warning: 请在 App 启动后再调用，否则可能出现 keyWindow 为空并返回 UITabBarController()
    public static var tabBarCtrl: UITabBarController? {
        if appWindow.rootViewController != nil {
            return appWindow.rootViewController as? UITabBarController
        }
        logWarning("appWindow.rootViewController 为 nil！")
        return Judy.keyWindow?.rootViewController as? UITabBarController
    }
    
    /// 获取 App 的 window 而不是 keyWindow，也就是呈现故事板时用到的 window。
    ///
    /// 在呈现故事板时使用的 Window。该属性包含用于在设备主屏幕上显示应用程序的可视内容的窗口。（UIApplication.shared.delegate!.window!!）
    /// - Warning: 如果调用太早（如程序刚启动）这个 window 可能正被隐藏中，并不活跃。
    public static var appWindow: UIWindow {
        guard UIApplication.shared.delegate?.window! != nil else {
            logWarning("app?.window 为 nil，调用太早！")
            if Judy.keyWindow != nil {
                return Judy.keyWindow!
            } else {
                logWarning("keyWindow 为 nil")
            }
            return UIWindow()
        }
        return UIApplication.shared.delegate!.window!!
    }
    
    /// 获取当前活跃的 window，如 alertview、键盘等关键的 Window。
    public static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.first
    }
    
    /// 获取 App 代理对象。即 UIApplication.shared.delegate。
    @available(*, unavailable, message: "此属性已废弃重命名", renamed: "UIApplication.shared.delegate")
    public static var app: UIApplicationDelegate { UIApplication.shared.delegate! }

    /// 当前是否有alert弹出，主要是提醒更新版本的Alert。
    fileprivate static var isAlerting = false {
        didSet{
            logWarning("哎呀，isAlerting 被设置为\(isAlerting)")
        }
    }
    
    /// 从指定故事板中获取 ViewCtrl 实例。
    ///
    /// - Parameters:
    ///   - storyboardName: 故事板 name。
    ///   - ident: viewCtrl ident
    /// - Returns: UIViewController
    public static func getViewCtrl(storyboardName: String, ident: String) -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: nil)
            .instantiateViewController(withIdentifier: ident)
    }
    
    /// 获取屏幕宽度
    ///
    /// - Returns: 屏幕宽度
    public static func getScreenWidth() -> CGFloat { UIScreen.main.bounds.size.width }
    
    
    // MARK: 系统、常用事件
    
    /// 打开路由/浏览器，若不需要闭包请使用 openSafari 函数。
    ///
    /// - Parameters:
    ///   - urlStr: 要转成 URL 的 String,如果该 String 无法转成 URL 将不会打开。
    ///   - closure: 闭包,(success: Bool)。
    public static func openURL(_ urlStr: String, completionHandler closure: @escaping ((Bool) -> Void)) {
        guard let url = URL(string: urlStr) else {
            logWarning("无效 URL ->\(urlStr)")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            logHappy("正在打开：\(url)")
            // UIApplication.shared.open(url, options: [:], completionHandler: nil)
            UIApplication.shared.open(url, completionHandler: { (success: Bool) in
                closure(success)
            })
        } else {
            //  入口协议：从其他App跳转到当前App的协议。在配置文件的URL Types中URL Schemes设定，如：tc。
            //  出口协议：当前App跳转到其他App的协议。需要将目标App的入口协议添加到当前App中配置文件的LSApplicationQueriesSchemes白名单里。
            logWarning("未安装路由->\(url)或没有在plist文件中添加LSApplicationQueriesSchemes白名单(出口失败)")
            closure(false)
        }
    }
    
    /// 在浏览器中打开该地址，此函数不带完成闭包，若有需要请使用 openURL 函数。
    /// - Parameter urlStr: 目标 url。
    public static func openSafari(urlStr: String) {
        openURL(urlStr) { rs in }
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
        logWarning("不合法的电话号码：\(phoneNo)")
        return false
    }
    
    /// 毫秒转时间。
    ///
    /// - Parameters:
    ///   - time: 时间的毫秒数，如：1525653777000.
    ///   - format: 输出格式，默认为 "yyyy/MM/dd HH:mm:ss".
    /// - Returns: 如："2018/05/07 08:42:57".
    public static func timer(time: Int, format: String = "yyyy/MM/dd HH:mm:ss") -> String {
        let time: Int64 = Int64(time)  //1525653777000
        let d = Date(timeIntervalSince1970: Double(time) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let timeString = formatter.string(from: d)
        
        return timeString
    }
    
    /// 时间长度单位转化，将毫秒数转换为具体时间长度的时分秒。
    /// - Parameter ms: 具体秒数。
    /// - Returns: 格式化后的 string, 如："01:01:38"
    public static func timeMillisecond(secondValue: Int) -> String {
        let format_time = String(format: "%@:%@:%@",
                                 timeMilliseconds(secondValue: secondValue).0,
                                 timeMilliseconds(secondValue: secondValue).1,
                                 timeMilliseconds(secondValue: secondValue).2)
        return format_time
    }
    
    /// 时间长度单位转化，将毫秒数转换为具体时间长度的时分秒。
    /// - Parameter secondValue: 具体秒数。
    /// - Returns: 格式化后的单个 string, 如：("01", "01", "38")
    public static func timeMilliseconds(secondValue: Int) -> (String, String, String) {
        let str_hour = String(format: "%02d", timeCount(secondValue: secondValue).0)
        let str_minute = String(format: "%02d", timeCount(secondValue: secondValue).1)
        let str_second = String(format: "%02d", timeCount(secondValue: secondValue).2)
        return (str_hour, str_minute, str_second)
    }

    /// 时间长度单位转化，将毫秒数转换为具体时间长度的时分秒。
    /// - Parameter secondValue: 具体秒数。
    /// - Returns: (时，分，秒)
    public static func timeCount(secondValue: Int) -> (Int,Int,Int) {
        let hour = secondValue/3600
        let minute = secondValue%3600/60
        let second = secondValue%60
        return (hour, minute, second)
    }

    /// dictionary 转成 String。服务器需要 String 类型的参数时使用此方法方便地转换数据。
    @available(*, unavailable, message: "此函数已禁用，请使用 SwiftyJSON 的 json.rawString() ")
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
    
    /// log 函数打印的可选级别。通过该级别可能更好地区分打印的信息等级以便于调试。
    enum LogLevel: String {
        /// 默认级别，通常代表普通信息。
        case 🟡
        /// 该级别通常表示警告、错误等需要重视的信息。
        case 🔴
        /// 该级别通常代表好消息、令人愉悦的信息。
        case 🟢
        /// 没有特别定义，用于强调、区分日志信息等级而已。
        case 🟠, 🔵, 🟣, 🟤, 🔘, 🟦, 🟪, 🅰️, 🅱️, 🅾️, 📀,
             💧, 💙, 💜, 🤎, 🍑, 🥭, 🍅, 🖼, 🔱, 🚫, 🔆, 🌐, 👑, 🔔, 🦠
    }
    
    /**
     - 如果发现不能正常打印，请在Build Settings -> Active Compilation Conditions 的 Debug 项中添加一个 DEBUG 即可。
     */

    /// 该打印函数将依次打印文件名、触发函数所在行及函数名的信息，最常用的日志式的信息输出。
    static func log<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        print("\(type) \((file as NSString).lastPathComponent) [\(line)] \(method) ⚓️ \(message())")
        #endif
    }
    
    /// 极简打印，该函数仅输出要打印的消息体。
    static func logs<msg>(type: LogLevel = .🔘, _ message: @autoclosure () -> msg) {
        #if DEBUG
        print("\(type) \(message())")
        #endif
    }
    
    /// 该函数强制以换行的方式将消息体打印，打印消息体等同于 log() 函数。
    static func logn<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        print("\(type) \((file as NSString).lastPathComponent) [\(line)] \(method) \n \(message())")
        #endif
    }

    /// 该打印函数仅输出文件名及所在行信息。
    static func logl<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg, file: String = #file, line: Int = #line) {
        #if DEBUG
        print("\(type) \((file as NSString).lastPathComponent)[\(line)] ⚓️ \(message())")
        #endif
    }

    /// 该函数仅输出线程相关信息，所在函数名及所在行。
    static func logt<msg>(type: LogLevel = .🟣, _ message: @autoclosure () -> msg, method: String = #function, line: Int = #line) {
        #if DEBUG
        print("\(type) \(Thread.current) [\(line)] \(method) ⚓️ \(message())")
        #endif
    }
    
    /// 该函数强制打印好消息级别的标识符输出，打印消息体等同于 log() 函数，但消息体放在最前面。
    static func logHappy<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        print("\(LogLevel.🟢) \(message()) ⚓️ \((file as NSString).lastPathComponent) [\(line)] \(method)")
        #endif
    }
    
    /// 该函数强制打印警告或错误级别的标识符输出，打印消息体等同于 log() 函数。
    static func logWarning<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
        #if DEBUG
        print("\(LogLevel.🔴) \((file as NSString).lastPathComponent) [\(line)] \(method) ⚓️ \(message())")
        #endif
    }

    // MARK: 自定义方法输入
    
    /// 对要输入的数值进行小数验证。比如只能输入2.1之类的，用于价格、里程数等。
    ///
    /// - warning: 此方法限textField shouldChangeCharactersInRange代理方法中调用。
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
                logWarning("小数点前只能输入\(prefix)位")
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
            logWarning("请输入正确的小数")
            return false
        }
        
        if num != 0 && NSNotFound != nDotLoc && range.location > nDotLoc + num {
            logWarning("小数点后只能保留\(num)位")
            return false
        }
        return true
    }
    
    /// 验证正整型输入，确保当下输入的值符合所需数值要求
    ///
    /// - warning: 此方法限 textField shouldChangeCharactersInRange 代理方法中调用
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
        guard string as String == filtered  else { logWarning("请输入正确的数值"); return false }
        
        // Step2：位数校验，验证小数点前所允许的位数
        let textFieldText = textField.text! as NSString
        if num != 0 && string != ""  {
            // 小数点前面位数验证
            guard textFieldText.length < num else { logWarning("只能输入\(num)位"); return false }
        }

        // Step3：数值校验，验证最终输入框中的字符是否符合要求
        let textFieldString = (textFieldText as String) + string
        let numberValue = Int(textFieldString) ?? 0
        // 最大值校验
        if maxNumber != 0 && numberValue > maxNumber && string != "" {
            logWarning("只能输入小于\(maxNumber)的值")
            return false
        }
        // 最小值校验
        if minNumber != 0 && numberValue < minNumber && string != "" {
            logWarning("只能输入>=\(minNumber)的值")
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
            logWarning("仅限输入数值")
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
    
    /// 获取 version,即 CFBundleShortVersionString
    ///
    /// - Returns: 如：2.5.8
    static func versionShort() -> String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    /// 获取 Build 版本号
    ///
    /// - Returns: 如：1
    static func versionBuild() -> String {
        Bundle.main.infoDictionary!["CFBundleVersion"] as! String
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
    ///
    /// - warning: 此方法会在闭包参数里传入一个JSON字典，字段如下
    ///     - newVersion: Bool    是否有新版本
    ///     - msg: String 消息体
    ///     - URL: String?    AppStore URL:(AppStore URL只在有新版本时有值，默认没有此字段)
    ///     - status: Int 当前App状态，-4:data转json失败，-3:版本检查失败，-2:没有找到，-1:审核状态，0：最新版本，1:有新版本，请更新
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
        
        // 得到CFBundleIdentifier
        let bundleIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        //设置请求地址
        var requestURLStr = "https://itunes.apple.com/cn/lookup?bundleId=\(bundleIdentifier)"
        
        //解决UTF-8乱码问题
        requestURLStr = requestURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // 独立版更新方式
        let storeURL = URL(string: requestURLStr)
        
        // timeoutInterval: 网络请求超时时间(单位：秒)
        // var request = URLRequest(url: storeURL!)
        var request = URLRequest.init(url: storeURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 8)
        
        // 设置请求方式为POST，默认是GET
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
            // log("发现AppStore的版本:\(versionOnLine)")
        }
        task.resume()
    }
    
}

/****************************************  ****************************************/

// MARK: - 测试类
extension Judy {

    public static func test(){
        logWarning("这是来自测试类的打印")
        testPrivate()
    }
    
    fileprivate static func testPrivate(){
        logWarning("这是私有打印")
    }
    
    public static func testStaticVar(){
        isAlerting = !isAlerting
        logWarning("此时，temp=\(isAlerting)")
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
        return Judy.keyWindow?.rootViewController as? UITabBarController
    }
    
}


/*
 既然静态方法和实例化方式的区分是为了解决模式的问题，如果我们考虑不需要继承和多态的时候，就可以使用静态方法，但就算不考虑继承和多态，就一概使用静态方法也不是好的编程思想。
 从另一个角度考虑，如果一个方法和他所在类的实例对象无关，那么它就应该是静态的，否则就应该是非静态。因此像工具类，一般都是静态的。
 */

/// 对 ProgressHUD 的封装，常用于活动指示器的管理工具类。
public struct JudyTip {
    
    /// HUD 消息类型。
    public enum MessageType {
        /// 静态效果显示。
        case success,error
        /// 支持动画显示。
        case successed, failed
    }
    
    
    // 私有化 init()，禁止构建对象。
    private init() {}
    
    /// 设置 HUD 的颜色，此函数已经调用将该改变所有 HUD 的颜色。
    public static func setColorForHUD(color: UIColor) {
        ProgressHUD.colorAnimation = color
        ProgressHUD.colorProgress = color
    }
    
    /// 弹出一个等待的转圈 HUD，通常用于执行某个耗时过程，请调用 dismiss() 或弹出其他 HUD 使其消失。
    /// - Parameter animationType: 等待指示器类型，默认为常见的系统转圈。
    public static func wait(animationType: AnimationType = .systemActivityIndicator) {
        ProgressHUD.animationType = animationType
        ProgressHUD.show()
    }
    
    /// 等待的消息提示 HUD。
    /// - Parameters:
    ///   - animationType: 等待类型，默认为常见的系统转圈等待。
    ///   - text: 消息体。
    ///   - interaction: 是否允许用户交互，默认 true。
    public static func wait(animationType: AnimationType = .systemActivityIndicator, text: String, interaction: Bool = true) {
        ProgressHUD.animationType = animationType
        ProgressHUD.show(text, interaction: interaction)
    }

    /// 弹出一个消息体。
    /// - Parameters:
    ///   - messageType: 该 HUD 类型，默认为 failed。
    ///   - text: 消息内容，默认为 nil。
    public static func message(messageType: MessageType = .failed, text: String? = nil) {
        
        switch messageType {
        case .success:
            ProgressHUD.showSuccess(text)
        case .error:
            ProgressHUD.showError(text)
        case .successed:
            ProgressHUD.showSucceed(text)
        case .failed:
            ProgressHUD.showFailed(text)
        }

    }
    
    /// 弹出显示一个进度条的等待指示器，该函数支持暴力调用。
    /// - Parameters:
    ///   - text: 要显示的文本，默认为 nil。
    ///   - fractionCompleted: 当前完成的进度，该值大于或等于1时即代表完成了。
    ///   - completed: 事件完成的回调，默认为 nil，在该回调中请注意需要在 DispatchQueue.main UI 线程处理。
    public static func progress(text: String? = nil, fractionCompleted: CGFloat, completed: ()? = nil) {
        
        ProgressHUD.showProgress(text, fractionCompleted)
        if (fractionCompleted >= 1) {
            if completed == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    ProgressHUD.showSucceed(interaction: false)
                }
            } else {
                completed
            }
        }
    }

    /// 使 HUD 消失。
    public static func dismiss() { ProgressHUD.dismiss() }
    
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
