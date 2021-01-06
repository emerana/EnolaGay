//
//  JudyNavigationCtrl.swift
//  JudySail
//
//  Created by 醉翁之意 on 2018/12/11.
//  Copyright © 2018 醉翁之意.王仁洁. All rights reserved.
//

import UIKit

/// 很酷的右划返回手势，当点击左上角返回按钮则是标准的返回样式
class JudyNavigationCtrl: JudyBaseNavigationCtrl {
    
    /// 触摸的起点
    private lazy var startTouch = CGPoint(x: 0, y: 0)
    /// push前最后的屏幕快照
    private lazy var lastScreenShotView: UIImageView? = nil
    /// 黑色遮罩 View
    private lazy var blackMask: UIView? = nil
    private lazy var backgroundView: UIView? = nil
    /// 截图列表
    private var screenShotsList = [UIImage]()
    
    /// 是否正在移动
    private lazy var isMoving = false
    /// 平移手势
    private var recognizer: UIPanGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 平移手势
        recognizer = UIPanGestureRecognizer.init(target: self, action: #selector(paningGestureReceive(recoginzer:)))
        view.addGestureRecognizer(recognizer)
        reOpenRecognizer()
        
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {

        // push 之前截取当前屏幕
        let capturedImage = judy_captureScreenImage(targetView: topView, complete: true)
        screenShotsList.append(capturedImage!)
        
        super.pushViewController(viewController, animated: animated)
    }
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        // pop 之前将最后一个截图删除
        screenShotsList.removeLast()
        return super.popViewController(animated: animated)
    }
    
    deinit {
        backgroundView?.removeFromSuperview()
        backgroundView = nil
        Judy.log("JudyNavigation 释放！")
    }
    
}

// MARK: - 公开方法
extension JudyNavigationCtrl {
    
    /// 关闭向右滑动 Pop 事件，调用此函数后将失去全屏 Pop 手势能力，请调用 reOpenRecognizer() 函数重新开启该能力
    final func closeRecognizer() {
        recognizer.delegate = nil
        // 开启系统自带返回手势
        interactivePopGestureRecognizer?.isEnabled = true

    }
    
    /// 重新开启向右滑动 Pop 能力
    final func reOpenRecognizer() {
        recognizer.delegate = self
        // 禁用系统自带返回手势，因为系统自带返回手势 pop 时机不一样
        interactivePopGestureRecognizer?.isEnabled = false
    }

    
    /// 人工模拟手势全屏返回
    ///
    /// - Parameter duration: pop 持续时长，默认0.3
    final func doPopAction(duration: Double = 0.3) {

        UIView.animate(withDuration: duration, animations: {
            self.panBeganAction(startTouchPoint: CGPoint(x: 0, y: 0))
            if self.isMoving {
                self.moveViewWithX(x: self.view.frame.width)
            }
        }) { (rs) in
            self.popActionWithAnimate()
        }
        
    }
    
}

// MARK: - 私有事件
private extension JudyNavigationCtrl {
    
    var keyWindow: UIWindow { return Judy.keyWindow! }
    var topView: UIView { return Judy.keyWindow!.rootViewController!.view }
    
    
    /// 移动 topView 的位置
    ///
    /// - Parameter x: frame 的 x ，跟随手指移动实时刷新
    func moveViewWithX(x: CGFloat){
        var x = x
        // 最大最小值限制
        x = x > view.frame.width ? view.frame.width:x
        x = x < 0 ? 0:x
        
        //        Judy.log("当前移动X:\(x)")
        
        // 移动顶层 View 的 X
        topView.frame.origin.x = x
        
        // 规模为1时表示不缩放
        var scale: CGFloat = (x/6800) + 0.95
        scale = scale > 1 ? 1:scale
        // 滑动过程中的遮罩 View 能见度
        let alpha = 0.68*(1 - x/view.frame.width)
        
        lastScreenShotView?.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        blackMask?.alpha = alpha
        
    }
    
    /// 手指离开屏幕，拖动结束事件，此事件未达到 navigationCtrl pop 条件，还原 topView 位置
    func panEndedReductionAction() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.moveViewWithX(x: 0)
        }) { (finished) in
            self.isMoving = false
            self.backgroundView?.isHidden = true
        }
        
    }
    
    /// 手指开始拖动事件
    ///
    /// - Parameter startTouchPoint: 触摸的起点
    func panBeganAction(startTouchPoint: CGPoint) {
        isMoving = true
        startTouch = startTouchPoint
        
        if backgroundView == nil {
            let frame = topView.frame
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            topView.superview?.insertSubview(backgroundView!, belowSubview: topView)
            
            blackMask = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            blackMask?.backgroundColor = .black
            backgroundView?.addSubview(blackMask!)
        }
        
        backgroundView?.isHidden = false
        
        if lastScreenShotView != nil {
            lastScreenShotView?.removeFromSuperview()
            lastScreenShotView = nil
        }
        
        let lastScreenShot = screenShotsList.last
        lastScreenShotView = UIImageView(image: lastScreenShot)
        backgroundView?.insertSubview(lastScreenShotView!, belowSubview: blackMask!)
    }

    /// 以动画的方式触发 Pop 事件
    func popActionWithAnimate() {
        UIView.animate(withDuration: 0.3, animations: {
            self.moveViewWithX(x: self.view.frame.width)
        }) { (finished) in
            // 触发 pop
            self.popViewController(animated: false)
            
            self.topView.frame.origin.x = 0
            self.isMoving = false
            self.backgroundView?.isHidden = true
            // 将遮罩层恢复为不透明
            self.blackMask?.alpha = 1
        }
    }
    
    
    /// 平移手势事件，不断的执行
    @objc func paningGestureReceive(recoginzer: UIPanGestureRecognizer){
        if viewControllers.count <= 1 {
            return
        }
        
        // 平移时将window背景设为黑色
        keyWindow.backgroundColor = .black
        
        let touchPoint = recoginzer.location(in: keyWindow)
        
        // 开始拖动屏幕触发
        if recoginzer.state == .began {
            //            Judy.log("began")
            panBeganAction(startTouchPoint: touchPoint)
            
            // 结束，手指离开屏幕触发
        } else if recoginzer.state == .ended {
            //            Judy.log("ended")
            // 设置滑动多少距离就可以触发pop
            if touchPoint.x - startTouch.x > 28 {
                popActionWithAnimate()
            } else {
                panEndedReductionAction()
            }
            return
        } else if recoginzer.state == .cancelled {  // 取消了
            //            Judy.log("cancelled")
            panEndedReductionAction()
            return
        }
        
        if isMoving {
            moveViewWithX(x: touchPoint.x - startTouch.x)
        }
        
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension JudyNavigationCtrl: UIGestureRecognizerDelegate {
    
    // 接收事件代理方法
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return children.count > 1
    }
    
}
