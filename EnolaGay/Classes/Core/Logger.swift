//
//  Logger.swift
//
//  日志文件、调试打印输出系统
//
//  Created by 醉翁之意 on 2023/3/17.
//  Copyright © 2023年 EnolaGay All rights reserved.
//

/*
 如果发现不能正常打印……
 请在 Build Settings -> Active Compilation Conditions 的 Debug 项中添加一个 DEBUG 即可。
 */

/// log 函数打印的可选级别。通过该级别可能更好地区分打印的信息等级以便于调试。
public enum LogLevel {
    /// 默认级别，通常代表普通信息
    case 🟡
    /// 该级别通常表示警告、错误等需要重视的信息
    case 🔴
    /// 该级别通常代表好消息或令人愉悦的信息
    case 🟢
    /// 其他可选的级别，没有特别定义，用于强调、区分日志信息等级而已。
    case 🟣, 🕸, 🔘, 📀, 😀, 🦠, 😜, 💧, 🤪, 🧯, 😎, 🕘, 🍑, 🚫, 🔆, 🌐, 👑, 🔔
}


/// 常规打印函数，将依次打印文件名、触发函数所在行及函数名的信息。打印格式为**文件 [行] 函数 消息体**
public func log<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(type) \((file as NSString).lastPathComponent) [\(line)] \(method): \(message())")
    #endif
}

/// 该函数主要打印所在行信息，较于 log 仅仅不打印函数。打印格式为**文件 [行] 消息体**
public func logl<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg, file: String = #file, line: Int = #line) {
    #if DEBUG
    print("\(type) \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    #endif
}

/// 该函数包含打印时间。打印格式为**时间 文件 [行] 消息体**
///
/// - Parameters:
///   - format: 打印时间的格式化，该值默认为 "HH:mm:ss.SSS".
public func logTime<msg>(type: LogLevel = .🕘, format: String = "HH:mm:ss.SSS", file: String = #file, line: Int = #line, _ message: @autoclosure () -> msg) {
    #if DEBUG
    let date = stringValue(format: format)
    print("\(type) \(date) \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    #endif
}

/// 极简打印，该函数仅输出要打印的消息体。
public func logs<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg) {
    #if DEBUG
    print("\(type) \(message())")
    #endif
}

/// 换行打印，此函数打印时将消息体另起一行打印。
public func logn<msg>(type: LogLevel = .🟡, _ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(type) \((file as NSString).lastPathComponent) [\(line)] \(method):\n\(message())")
    #endif
}

/// 该函数用于打印好消息级别的输出。打印格式为**文件 [行] 函数 消息体**
public func logHappy<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(LogLevel.🟢) \((file as NSString).lastPathComponent) [\(line)] \(method): \(message())")
    #endif
}

/// 该函数用于打印警告或错误级别的输出。打印格式为**文件 [行] 函数 消息体**
public func logWarning<msg>(_ message: @autoclosure () -> msg, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(LogLevel.🔴) \((file as NSString).lastPathComponent) [\(line)] \(method): \(message())")
    #endif
}

/// 该函数用于打印线程相关输出。打印格式为**线程 [行] 函数 消息体**
public func logt<msg>(type: LogLevel = .🟣, _ message: @autoclosure () -> msg, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(type) \(Thread.current) [\(line)] \(method): \(message())")
    #endif
}


/// 获取当前 Date 值并转换成北京时区的目标格式 String 值。
///
/// 如 Date() 为 2022-11-18 06:08:47 +0000 ，此函数将转成 2022-11-18 06:08:47.
///
/// - Parameter format: date 值的目标样式，默认值为 "yyyy-MM-dd HH:mm:ss".
/// - Returns: String 格式的目标样式。
private func stringValue(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let timeZone = TimeZone(identifier: "UTC")
    let formatter = DateFormatter()
    formatter.timeZone = timeZone
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = format
    
    /// 获取当前时区和 GMT 的时间间隔，当前时区和格林威治时区的时间差 8小时 = 28800秒。
    let secondFromGMT = TimeInterval(TimeZone.current.secondsFromGMT(for: Date()))
    let nowDate = Date().addingTimeInterval(secondFromGMT)
    
    let date = formatter.string(from: nowDate)
    // return date.components(separatedBy: "-").first!
    return date
}
