//
//  JudyTip.swift
//  PPScience
//
//  Created by 醉翁之意 on 2018/5/18.
//  Copyright © 2018年 GSDN. All rights reserved.
//

import MBProgressHUD

/*
 既然静态方法和实例化方式的区分是为了解决模式的问题，如果我们考虑不需要继承和多态的时候，就可以使用静态方法，但就算不考虑继承和多态，就一概使用静态方法也不是好的编程思想。
 从另一个角度考虑，如果一个方法和他所在类的实例对象无关，那么它就应该是静态的，否则就应该是非静态。因此像工具类，一般都是静态的。
 */

/// 此类依赖MBProgressHUD
public struct JudyTip {
    
    /// 单例
    //    static let judy = JudyTip()
    
    //MARK: 私有化init()，禁止构建对象
    private init() {}
    
    /// 显示一个提示框
    ///
    /// - Parameters:
    ///   - message: 消息体
    ///   - animated: 动画，默认 true
    ///   - parentView: 要将提示框显示在哪个 View？默认是 keyWindow
    ///   - isBottom: 是否显示在底部？false，默认显示在中央。
    ///   - duration: 持续时长(s)，默认2秒。
    @available(*, unavailable, message: "该函数已废弃，请使用新函数", renamed: "message(text:)")
    public static func show(message: String?, animated: Bool = true, parentView: UIView? = nil, isBottom: Bool = false, duration: Double = 2) {
        
        var theParentView: UIView? = UIApplication.shared.keyWindow
        
        if parentView != nil { theParentView = parentView }
        
        guard theParentView != nil else {
            Judy.log("当下没有可显示的 View!")
            return
        }
        hide(for: theParentView!)
        
        if message?.count == 0{ return }
        
        let hud = initHUD(parentView: theParentView!, animated: animated)
        
        hud.mode = .text
        hud.detailsLabel.text = message
        hud.detailsLabel.font = UIFont.init(name: "Helvetica-Bold", size: 14)   //UIFont.systemFont(ofSize: 14)
        hud.detailsLabel.shadowOffset = CGSize(width: 1, height: 1)
        hud.detailsLabel.shadowColor = .black
        hud.margin = 15
        if isBottom { hud.center.y = theParentView!.frame.size.height/7*6 }
        // 设置隐藏时间
        hud.hide(animated: animated, afterDelay: duration)
    }
    
    /// 转圈等待
    /// - Parameters:
    ///   - parentView: 要将提示框显示在哪个 View？默认是 keyWindow
    ///   - animated: 动画，默认 true
    @available(*, unavailable, message: "该函数即将废弃，请使用新函数", renamed: "wait")
    public static func showWait(parentView: UIView = UIApplication.shared.keyWindow!, animated: Bool = true){
        /// 如果设置了 parentView，对应的 hide 方法也要设置，否则 HUD 会一直显示在界面上的。
        hide(for: parentView)
        
        initHUD(parentView: parentView, animated: animated)
        
    }
    
    /// 进度条
    /// ## 如果设置了 parentView，对应的 hide 方法也要设置，否则 HUD 会一直显示在界面上的。
    /// - Parameters:
    ///   - parentView: 要将提示框显示在哪个 View？默认是 keyWindow
    ///   - animated: 动画，默认 true
    public static func barDeterminate(parentView: UIView = UIApplication.shared.keyWindow!, animated: Bool = true){
        
        let hud = initHUD(parentView: parentView, animated: animated)
        
        // 设置bar确定模式以显示任务进度。Set the bar determinate mode to show task progress.
        hud.mode = .determinateHorizontalBar
        // 异步执行
        DispatchQueue.global().async {
            var progress: Float = 0
            while progress < 1 {
                //                var waitTime = Float(drand48())
                //                if waitTime >= 1.0 {
                //                   waitTime -= 0.5
                //                } else {
                //                   waitTime = waitTime/10
                //                }
                progress += 0.0001   //  waitTime
                DispatchQueue.main.async {
                    //                    MBProgressHUD.init(for: parentView)?.progress = progress
                    hud.progress = progress
                    hud.label.text = "当前步数：\(Int(90000*progress))步"
                }
                usleep(888)   // 用 usleep 毫秒级延迟
            }
            DispatchQueue.main.async {
                //                hud.mode = .text
                //                hud.label.text = nil
                //                hud.detailsLabel.text = "搞定"
                hud.label.text = "当前已增加至：\(Int(90000*progress))步"
            }
            sleep(2)
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
            sleep(2)
        }
        
        /*
         arc4random()返回0到4 294 967 295范围内的一个随机数
         
         drand48()返回范围在0.0到1.0之间的随机数
         
         arc4random_uniform(N)返回0到N-1范围内的一个随机数
         
         */
    }
    
    
    public static func getBarDeterminate(parentView: UIView = UIApplication.shared.keyWindow!, animated: Bool = true) -> MBProgressHUD {
        let hud = initHUD(parentView: parentView, animated: animated)
        
        // 设置bar确定模式以显示任务进度。Set the bar determinate mode to show task progress.
        hud.mode = .determinateHorizontalBar
        return hud
    }
    
    
    /// 弹出一张图片
    ///
    /// - Parameters:
    ///   - parentView: 显示 HUD 的父 View，默认 keyWindow
    ///   - animated: 动画，默认 true
    ///   - duration: 持续时长(s)，默认2秒。
    ///   - image: 要显示的图片，默认为一张空图片
    public static func showImage(parentView: UIView = UIApplication.shared.keyWindow!, animated: Bool = true, duration: Double = 2, image: UIImage = UIImage()){
        hide(for: parentView)
        
        let hud = initHUD(parentView: parentView, animated: animated)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.black.withAlphaComponent(0)
        hud.mode = .customView
        hud.customView = UIImageView(image: image)
        
        // 设置隐藏时间
        hud.hide(animated: animated, afterDelay: duration)
    }
    
    
    /// 初始化一个 hud 对象
    @discardableResult
    private static func initHUD(parentView: UIView, animated: Bool) -> MBProgressHUD {
        
        let hud = MBProgressHUD.showAdded(to: parentView, animated: animated)
        hud.isUserInteractionEnabled = false
        hud.removeFromSuperViewOnHide = true
        
        // Judy-mark: 先改变 HUD Style，默认是 .blur,模糊效果
        //        hud.bezelView.style = .solidColor
        // Judy-mark: HUD背景色
        hud.bezelView.color = UIColor.black//.withAlphaComponent(0)
        
        hud.contentColor = UIColor.white
        hud.mode = .indeterminate
        
        return hud
    }
    
}

// MARK: - 进阶版
extension JudyTip {
    
    
    /// 生成一个等待转圈的 HUD 并加载到目标 View 显示，常用于等待耗时操作的过程。
    /// - Parameter view: 要加载该 HUD 的目标视图，默认值为 UIApplication.shared.中显式在最上面的窗口。
    /// # 一般，目标视图 view 可以为：
    /// - Parameter isIgnoreInteraction: 是否忽略用户的交互行为，默认为 true
    /// * self.view
    /// * self.view.window
    /// * self.navigationController!.view
    /// - Returns: 配置好基本信息的目标 HUD 对象，可以直接用来展示，通过该对象调用其 hide() 函数来移除 HUD
    @discardableResult
    public static func wait(to view: UIView? = UIApplication.shared.windows.last, isIgnoreInteraction: Bool = true) -> MBProgressHUD {
        
        hide(for: view)// 必须手动隐藏，否则会产生叠加效果
        guard view != nil else {
            return MBProgressHUD()
        }

        let hud = MBProgressHUD.showAdded(to: view!, animated: true)
        // 设置 HUD 的背景样式
        hud.bezelView.style = .solidColor
        // 设置 HUD 的背景色
        hud.bezelView.color = UIColor.black.withAlphaComponent(0.8)
        // 设置 HUD 的内容颜色
        hud.contentColor = .white
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        
        // 用户事件是否被忽略或从事件队列中删除，默认为 true，即用户无法交互
        hud.isUserInteractionEnabled = isIgnoreInteraction
        
        return hud
    }
    
    
    /// 弹出消息提示 HUD。
    /// - Parameters:
    ///   - text: 消息体
    ///   - parentView: 要加载该 HUD 的目标视图，默认值为 UIApplication.shared.中显式在最上面的窗口。
    ///   - duration: 持续时长，默认值为 2秒。
    ///   - font: 指定显示的字体，该值默认为 UIFont(name: "Helvetica-Bold", size: 14)。
    ///   - isBottom: 是否显示在底部？默认值为 false，显示在中央。
    /// - Returns: 配置好基本信息的目标 HUD 对象，可以直接用来展示，通过该对象调用其 hide() 函数来移除 HUD。
    @discardableResult
    public static func message(text: String, parentView: UIView? = UIApplication.shared.windows.last, duration: Double = 2, font: UIFont? = UIFont(name: "Helvetica-Bold", size: 14), isBottom: Bool = false) -> MBProgressHUD {
        
        guard parentView != nil else {
            return MBProgressHUD()
        }
        
        let hud = wait(to: parentView)
        hud.mode = .text
        // 单行显示
        //        hud.label.text = text
        //        hud.label.font = font
        //        hud.label.shadowOffset = CGSize(width: 1, height: 1)
        //        hud.label.shadowColor = .black
        // 支持多行显示
        hud.detailsLabel.text = text
        hud.detailsLabel.font = font
        hud.detailsLabel.shadowOffset = CGSize(width: 1, height: 1)
        hud.detailsLabel.shadowColor = .black
        
        hud.margin = 16
        
        if isBottom { hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset) }
        // 不忽略用户交互
        hud.isUserInteractionEnabled = false
        
        // 设置自动隐藏时间
        hud.hide(animated: true, afterDelay: duration)
        
        return hud
    }
    
    /// 移除指定目标视图上面的 HUD。
    /// - Parameters:
    ///   - parentView: 显示 HUD 的父 View，默认 keyWindow，对应 wait 函数
    public static func hide(for parentView: UIView? = UIApplication.shared.windows.last) {
        guard parentView != nil else { return }
        MBProgressHUD.hide(for: parentView!, animated: true)
    }
    
}
