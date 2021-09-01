//
//  FuckerCtrl.swift
//  JudySail
//
//  Created by 醉翁之意 on 2018/6/15.
//  Copyright © 2018年 醉翁之意.王仁洁. All rights reserved.
//


import UIKit
import EnolaGay
import SwiftMessages
import YYImage

/// Fuck控制器
class FuckerCtrl {
    
    
    private let fuckImageList = ["Fuck_Can'tUse", "Fuck_JB", "Fuck_YellowImage", "CX_YH", "CX_YH", "CX_YH", "CX_YH", "CX_YH"]
    
    private let imageList = ["001.jpg", "002.jpg", "003.jpg", "004.jpg", "005.jpg", "006.jpg", "007.jpg", "008.jpg", "009.jpg", "010.jpg", "011.jpg", "012.jpg", "013.jpg", "014.jpg", "015.jpg", "016.jpg", "017.jpg", "018.jpg", "019.jpg", "020.jpg", "021.jpg", "022.jpg", "023.jpg", "024.jpg", "025.jpg", "026.jpg", "027.jpg", "板砖.gif", "banner", "睡你麻痹起来嗨.jpg", "266.jpg"]
    
    
    // MARK: 计时器相关属性
    
    /// 计时器对象
    private var countdownTimer: Timer?
    
    /// 剩余秒数
    private var remainingSeconds = 0 {
        didSet {
            if remainingSeconds <= 0 {
                // isCounting = false
                // 显示FuckView
                alertFuckerViewAutoHide()
            }
        }
    }
    
    /// 是否开始计时，默认否
    private var isCounting = false {
        willSet {
            if newValue {
                // 创建一个计时器对象，每隔1秒执行一次 updateTime 方法
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(timer:)), userInfo: nil, repeats: true)
                
            } else {
                countdownTimer?.invalidate() // 计时器设为无效
                countdownTimer = nil
            }
        }
    }
    
    static let judy = FuckerCtrl()
    private init() {}
    
    // MARK: - Intial Methods - 初始化的方法
    
    /// 开始执行 Fuck 操作
    func star(todo: Bool = true) {
        // 在此弹出 Fucker
        let fuckType = Int(arc4random_uniform(UInt32(100)))
        if fuckType <= 20 {  // 自动隐藏的Fuck
            // 会自动隐藏的FuckerView()
            self.alertFuckerViewAutoHide()
            self.isCounting = true
        } else if fuckType <= 50 {   // 不隐藏的Fuck
            self.alertFuckerView()
        } else {      // 聊天界面
            let chatVC = ChatViewCtrl()
            let root = UINavigationController.init(rootViewController: chatVC)
            Judy.appWindow.rootViewController = root
        }
        
    }
    
    
    func star(withCallBack: () -> Void) {
        withCallBack()
    }
    
    /// 弹出一个fuckView，持续显示
    private func alertFuckerView(){
        let payView: FuckerView = try! SwiftMessages.viewFromNib(named: "FuckerView")

        payView.configureDropShadow()
        // 随机使用一张图片
        let imgName = fuckImageList[Int(arc4random_uniform(UInt32(fuckImageList.count)))]
        payView.imageName = imgName   //"板砖.gif"
        
        // step2:   配置并显示payView
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue))
        config.duration = .forever
        config.presentationStyle = .center
        //  interactive: 交互性:指定是否单击变暗区域将取消消息视图。
        config.dimMode = .blur(style: .dark, alpha: 0.8, interactive: false) //.gray(interactive: false)
        SwiftMessages.show(config: config, view: payView)
        
//        let waitTimeForHide = Int(arc4random_uniform(UInt32(14)))
//        if waitTimeForHide > 10 {
//            let waitTime = Int(arc4random_uniform(UInt32(18)))
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(waitTime), execute: {
//                SwiftMessages.hide()
//            })
//        }
        
    }
    
    /// 弹出一个 fuckView，自动隐藏
    private func alertFuckerViewAutoHide(){
        let payView: FuckerView = try! SwiftMessages.viewFromNib(named: "FuckerView")

//        var frame: CGRect = payView.label.frame
//        frame.origin.x = -180
//        payView.label.frame = frame
//        UIView.beginAnimations("testAnimation", context: nil)
//        UIView.setAnimationDuration(8.8)
//        UIView.setAnimationCurve(.linear)
//        UIView.setAnimationDelegate(self)
//        UIView.setAnimationRepeatAutoreverses(false)
//        UIView.setAnimationRepeatCount(999999)
//        frame = payView.label.frame
//        frame.origin.x = 350
//        payView.label.frame = frame
//        UIView.commitAnimations()

        ///
        
        
        payView.configureDropShadow()
        // 随机使用一张图片
        let imgName = imageList[Int(arc4random_uniform(UInt32(imageList.count)))]
        payView.imageName = imgName
//        payView.imageName = "banner"
        //        payView.imageName = "266"
        

        // step2: 配置并显示payView
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue))
        // 显示时长
        let showTime = Int(arc4random_uniform(UInt32(8)))
        config.duration = .seconds(seconds: TimeInterval(showTime))
        config.presentationStyle = .center
        //  interactive: 交互性:指定是否单击变暗区域将取消消息视图。
        config.dimMode = .blur(style: .dark, alpha: 0.8, interactive: false) //.gray(interactive: false)
        SwiftMessages.show(config: config, view: payView)
        
        //滚动文字
        let label = UILabel()
        label.textColor = .yellow
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.text = "坑爹吾诺瀚卓，还我血汗钱！！！！！！"
        
        payView.scrollTitle.contentView = label
        payView.scrollTitle.contentMargin = 50
        payView.scrollTitle.marqueeType = .left
        
        
        // 在此设置下一次弹出的等待时长
        let waitTime = Int(arc4random_uniform(UInt32(16))) + showTime
        remainingSeconds = waitTime
    }
    
    /// 逐秒递减
    ///
    /// - Parameter timer: timer
    @objc private func updateTime(timer: Timer) {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    
    
    /// 获取审核状态状态，已明确是否需要展示FuckView
    ///
    /// - Returns: 是否展示: Bool
    @available(*, unavailable)
    private func refreshReviewFlag() -> Bool {
        
//        let rs = Defaults.isReviewed
//        if rs {
//            return true
//        }
//
//        Judy.version { res in
//            Judy.log("当前的版本状态码为:\(res)")
//            if res == 0 || res == 1 {
//                Defaults.isReviewed = true
//            } else {
//                Defaults.isReviewed = false
//            }
//        }
//
        return false
    }
}
