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
import Kingfisher

/// Fuck控制器
class FuckerCtrl {
    /// 静态图片名数组
    private let imageList = ["001.jpg", "002.jpg", "003.jpg", "004.jpg", "005.jpg", "006.jpg", "007.jpg", "008.jpg", "009.jpg", "010.jpg", "011.jpg", "012.jpg", "013.jpg", "014.jpg", "015.jpg", "016.jpg", "017.jpg", "018.jpg", "019.jpg", "020.jpg", "021.jpg", "022.jpg", "023.jpg", "024.jpg", "025.jpg", "026.jpg", "027.jpg", "banner", "266.jpg", "Fuck_Can'tUse", "Fuck_JB", "Fuck_YellowImage", "CX_YH", "CX_YH", "CX_YH", "CX_YH", "CX_YH"]
    
    // MARK: 计时器相关属性
    
    /// 计时器对象
    private var countdownTimer: Timer?
    /// 剩余秒数
    private var remainingSeconds = 0 {
        didSet {
            if remainingSeconds <= 0 { alertFuckerView(isAutoHide: true) }
        }
    }
    
    /// 是否开始计时，默认否
    private var isCounting = false {
        willSet {
            if newValue {
                // 创建一个计时器对象，每隔1秒递减
                countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
                    self?.remainingSeconds -= 1
                })
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
    func star() {
        // 随机弹出自动隐藏的、永久停留的、聊天界面的 Fuck.
        let fuckType = Int(arc4random_uniform(UInt32(100)))
        if fuckType <= 20 { // 自动隐藏的 Fuck
            // 会自动隐藏的 FuckerView()
            alertFuckerView(isAutoHide: true)
            isCounting = true
        } else if fuckType <= 50 { // 不隐藏的 Fuck
            alertFuckerView()
        } else { // 聊天界面
            let chatVC = ChatViewCtrl()
            let root = UINavigationController(rootViewController: chatVC)
            Judy.appWindow.rootViewController = root
        }
    }
    
    /// 弹出一个 fuckView
    /// - Parameter isAutoHide: 是否需要自动隐藏，该值默认为 false.
    private func alertFuckerView(isAutoHide: Bool = false) {
        let fuckerView: FuckerView = try! SwiftMessages.viewFromNib(named: "FuckerView")

        fuckerView.configureDropShadow()
        
        // 随机决定使用 gif 还是静态图
        let flag = CGFloat(arc4random_uniform(2))
        /// 使结果确定为 -1 OR 1
        let useGIF = CGFloat(1 - (2*flag))
        
        if useGIF > 0 { // 用 gif
            // 设置动图
            let path = Bundle.main.path(forResource:"睡你麻痹起来嗨", ofType:"gif")
            let url = URL(fileURLWithPath: path!)
            let provider = LocalFileImageDataProvider(fileURL: url)
            fuckerView.imageView.kf.setImage(with: provider)

        } else { // 用静态图
            // 随机使用一张图片
            let imgName = imageList[Int(arc4random_uniform(UInt32(imageList.count)))]
            fuckerView.imageView.image = UIImage(named: imgName)
        }
        
        // step2: 配置并显示 FuckerView
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .forever
        config.presentationStyle = .center

        config.dimMode = .gray(interactive: false)
        
        if isAutoHide {
            // 显示时长
            let showTime = Int(arc4random_uniform(UInt32(8)))
            config.duration = .seconds(seconds: TimeInterval(showTime))
            // 在此设置下一次弹出的等待时长
            let waitTime = Int(arc4random_uniform(UInt32(16))) + showTime
            remainingSeconds = waitTime
        }
        
        SwiftMessages.show(config: config, view: fuckerView)
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
