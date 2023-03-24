//
//  JudyPopBubble.swift
//  飘动的气泡动画类
//
//  Created by 王仁洁 on 2018/9/20.
//  Copyright © 2018年 EMERANA. All rights reserved.
//

import UIKit

/// 一个气泡动画发射台
///
/// 通过在运行循环中不断调度 popBubble 函数以达到不断有气泡往上升的动画效果，可参考如下代码：
///
/// ```
/// /// 动画计时器
/// private var animateTimer: Timer?
///
/// /// 启动爱心飘动的动画
/// func startAnimateTimer() {
///     let imageNames = ["icon_点赞1", "icon_点赞2", "icon_点赞3", "icon_点赞4", "icon_点赞5", ]
///     let judyPopBubble = JudyPopBubble(inView: self.view, belowSubview: self.likeButton)
///     /// 计时器两次触发之间的秒数。如果 interval 小于或等于0.0，则该方法选择 0.0001 秒的非负值。
///     let interval = Double(1+arc4random_uniform(3))/10
///     // 创建计时器，并以默认模式在当前运行循环中调度它。
///     animateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
///         // 随机挑选一张图片
///         let image = UIImage(named: imageNames[NSInteger(arc4random_uniform( UInt32((imageNames.count)) ))])
///         judyPopBubble.popBubble(withImage: image)
///     }
/// }
/// ```
/// - Warning: 需要注意 animateTimer 的管理
///
/// ```
/// override func viewDidAppear(_ animated: Bool) {
///     super.viewDidAppear(animated)
///     // 恢复计时器
///     animateTimer?.fireDate = Date()
/// }
///
/// override func viewWillDisappear(_ animated: Bool) {
///     super.viewWillDisappear(animated)
///     // 暂停计时器
///     animateTimer?.fireDate = Date.distantFuture
/// }
///
/// deinit {
///     // 销毁计时器
///     animateTimer?.invalidate()
///     animateTimer = nil
/// }
/// ```
public class JudyPopBubble {
    
    /// 气泡冒出过程动画所需时长，该值默认为 0.2.
    public var bubble_animate_showDuration = 0.2
    /// 气泡旋转过程动画所需时长，该值默认为 2.
    public var bubble_animate_rotatedDuration: TimeInterval = 2
    /// 气泡从起点往上飘到终点所需时长，该值默认为 3.
    public var bubble_animate_windUp: TimeInterval = 3
    /// 气泡从出现到消失的时长，该值确保不小于1。气泡能见度随着该时长逐渐变低，直到完全不可见。该值默认为 2.
    public var bubble_animate_dissmiss: TimeInterval = 2
    /// 气泡动画路径最长距离，默认取 bubbleParentView 的高度（同时减去了 bubbleBelowView 的高度）。
    public var bubble_animate_height: CGFloat = 0
    
    /// 气泡执行所在的 View。气泡将被插入到该 View 中，并同时在 belowSubview 的下面。
    private(set) public var bubbleParentView: UIView
    /// 气泡将放在该 View 下面，且该 View 决定了气泡的起始位置。
    private(set) public var bubbleBelowView: UIView
    
    
    /// 实例化放烟花的 JudyPopBubble
    /// - Parameters:
    ///   - parentView: 执行气泡动画的 View
    ///   - belowView: 气泡最开始时将被该 View 挡住，且该 View 决定了气泡的起始位置。
    public init(inView parentView: UIView, belowSubview belowView: UIView) {
        bubbleParentView = parentView
        bubbleBelowView = belowView
        // 设置最高能够飘到的高度
        bubble_animate_height = bubbleParentView.frame.height - bubbleBelowView.frame.height
    }
    
    /// 飘出一个气泡动画
    /// - Parameters:
    ///   - bubbleImage: 气泡图片对象
    public func popBubble(_ bubbleImage: UIImage) {
        /// 气泡图片
        let bubbleImageView = UIImageView(image: bubbleImage)
        
        // 设置气泡图片的起始位置
        if bubbleBelowView.superview == bubbleParentView {
            bubbleImageView.center = CGPoint(x: bubbleBelowView.center.x, y: bubbleBelowView.frame.origin.y)
            bubbleParentView.insertSubview(bubbleImageView, belowSubview: bubbleBelowView)
        } else {
            bubbleImageView.center = bubbleBelowView.convert(bubbleBelowView.center, to: bubbleParentView)
            bubbleImageView.center.x -= bubbleBelowView.frame.origin.x
            bubbleImageView.center.y -= bubbleBelowView.frame.origin.y
            bubbleParentView.insertSubview(bubbleImageView, belowSubview: bubbleBelowView.superview!)
        }
        
        // 初始为完全透明
        bubbleImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        bubbleImageView.alpha = 0
        
        // 气泡冒出动画
        UIView.animate(withDuration: bubble_animate_showDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveEaseOut) {
            bubbleImageView.transform = CGAffineTransform.identity
            bubbleImageView.alpha = 1
        } completion: { isCompletion in }
        
        // 随机偏转角度 control 点
        let j = CGFloat(arc4random_uniform(2))
        /// 随机方向，-1 OR 1 代表了顺时针或逆时针
        let travelDirection = CGFloat(1 - (2*j))
        
        // 旋转气泡
        UIView.animate(withDuration: bubble_animate_rotatedDuration) {
            var transform = bubbleImageView.transform
            let rs = Double.pi/4 //(4+Double(rotationFraction)*0.2)
            // 顺时针或逆时针旋转
            transform = transform.rotated(by: travelDirection*CGFloat(rs))
            // transform = transform.translatedBy(x: 0, y: 200)//平移
            // transform = transform.scaledBy(x: 0.5, y: 0.5)//缩放
            bubbleImageView.transform = transform
        }
        
        // 气泡运动的终点位置
        let ViewX = bubbleImageView.center.x
        let ViewY = bubbleImageView.center.y
        let endPoint = CGPoint(x: ViewX + travelDirection*10, y: ViewY - bubble_animate_height)
        
        let m1 = ViewX + CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
        let n1 = ViewY - CGFloat(60 + travelDirection*CGFloat(arc4random_uniform(20)))
        // control 根据自己动画想要的效果做灵活的调整
        let controlPoint1 = CGPoint(x: m1, y: n1)
        
        let m2 = ViewX - CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
        let n2 = ViewY - CGFloat(90 + travelDirection*CGFloat(arc4random_uniform(20)))
        let controlPoint2 = CGPoint(x: m2, y: n2)
        
        /// 气泡移动轨迹路径
        let travelPath = UIBezierPath()
        travelPath.move(to: bubbleImageView.center)
        //根据贝塞尔曲线添加动画
        travelPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        // 关键帧动画,实现整体图片位移
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = travelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        keyFrameAnimation.duration = bubble_animate_windUp // 往上飘动画时长,可控制速度
        bubbleImageView.layer.add(keyFrameAnimation, forKey: "positionOnPath")
        
        // 消失动画
        UIView.animate(withDuration: max(bubble_animate_dissmiss, 1) ) {
            bubbleImageView.alpha = 0.0
        } completion: { finished in
            bubbleImageView.removeFromSuperview()
        }
        
    }
    
}
