//
//  JudyWaterWaveView.swift
//  WaterWave
//
//  Created by 王仁洁 on 2018/9/20.
//  Copyright © 2018年 EMERANA. All rights reserved.
//

import UIKit


/// 一个气泡动画类
///
/// 通过在运行循环中不断调度 judy_popBubble 函数以达到不断有气泡往上升的动画效果，可参考如下代码：
///
/// ```
/// let judyPopBubble = JudyPopBubble()
/// // 创建计时器，并以默认模式在当前运行循环中调度它
/// animateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
///     if let strongSelf = self {
///         let image = UIImage(named: imageNames[NSInteger(arc4random_uniform( UInt32((imageNames.count)) ))])
///         judyPopBubble.judy_popBubble(withImage: image, inView: strongSelf.view, belowSubview: strongSelf.likeButton)
///     }
/// }
/// ```
/// - Warning: 通过调用 judy_popBubble 函数来弹出一个气泡动画
public class JudyPopBubble {
    
    /// 指定气泡的中心点，默认为 bubble_belowView 的中心点
    public var bubble_image_Center: CGPoint?
    
    /// 气泡冒出时的动画所需时长
    public var bubble_animate_showDuration = 0.2
    /// 气泡旋转动画所需时长
    public var bubble_animate_rotatedDuration: TimeInterval = 2
    /// 气泡往上飘所需时长
    public var bubble_animate_windUp: TimeInterval = 3
    /// 气泡消失时所需时长
    public var bubble_animate_dissmiss: TimeInterval = 3
    /// 气泡动画路径高度
    public var bubble_animate_height: CGFloat = 350
    
    /// 气泡图片
    private(set) public var bubble_image: UIImage?
    /// 气泡所在的 View
    private(set) public var bubble_parentView: UIView?
    /// 将该气泡放在该 View 下面，该 view 决定了气泡的起始位置，通常情况下是该对象是触发按钮
    private(set) public var bubble_belowView: UIView?
    
    
    public init() {}
    
    /// 执行一个气泡图片动画
    /// - Parameters:
    ///   - image: 气泡图片对象
    ///   - parentView: 执行气泡动画的 View
    ///   - belowView: 将该气泡放在该 View 下面，该 view 决定了气泡的起始位置
    public func judy_popBubble(withImage image: UIImage?, inView parentView: UIView, belowSubview belowView: UIView) {
        guard image != nil else { return }
        
        bubble_image = image!
        bubble_parentView = parentView
        bubble_belowView = belowView
        
        /// 气泡图片
        let bubbleImageView = UIImageView(image: bubble_image)
        
        // 设置气泡图片的起始位置
        if bubble_image_Center == nil {
            if bubble_belowView!.superview == bubble_parentView {
                bubbleImageView.center = CGPoint(x: bubble_belowView!.center.x, y: bubble_belowView!.frame.origin.y)
                bubble_parentView?.insertSubview(bubbleImageView, belowSubview: bubble_belowView!)
            } else {
                bubbleImageView.center = bubble_belowView!.convert(bubble_belowView!.center, to: bubble_parentView)
                bubbleImageView.center.x -= bubble_belowView!.frame.origin.x
                bubbleImageView.center.y -= bubble_belowView!.frame.origin.y
                bubble_parentView?.insertSubview(bubbleImageView, belowSubview: bubble_belowView!.superview!)
            }
        } else {
            bubbleImageView.center = bubble_image_Center!
        }
        
        bubbleImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        bubbleImageView.alpha = 0 // 初始为完全透明
        
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
        
        // 随机终点
        let ViewX = bubbleImageView.center.x
        let ViewY = bubbleImageView.center.y
        let endPoint = CGPoint(x: ViewX + travelDirection*10, y: ViewY - bubble_animate_height)
        
        let m1 = ViewX + CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
        let n1 = ViewY - CGFloat(60 + travelDirection*CGFloat(arc4random_uniform(20)))
        let m2 = ViewX - CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
        let n2 = ViewY - CGFloat(90 + travelDirection*CGFloat(arc4random_uniform(20)))
        let controlPoint1 = CGPoint(x: m1, y: n1)   //control 根据自己动画想要的效果做灵活的调整
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
        UIView.animate(withDuration: bubble_animate_dissmiss) {
            bubbleImageView.alpha = 0.0
        } completion: { finished in
            bubbleImageView.removeFromSuperview()
        }
        
    }
    
}
