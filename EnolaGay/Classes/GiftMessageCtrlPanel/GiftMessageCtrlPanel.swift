//
//  GiftMessageCtrlPanel.swift
//  直播间送礼物控制系统
//
//  Created by 王仁洁 on 2018/9/20.
//  Copyright © 2018年 EMERANA. All rights reserved.
//

import UIKit

/// 直播间刷礼物控制面板
///
/// 通过 profferGiftMessageView() 函数送出一个礼物，该礼物将显示在当前 View 上。
open class GiftMessageCtrlPanel: UIView {
    
    // MARK: IBInspectables
    
    /// 每个 GiftView 显示的时长，默认为 3 秒，该时间过后即释放该 GiftView.
    @IBInspectable public var duringShow: Int = 3
    /// 最多同时显示的 giftView 数量，默认为 3.
    @IBInspectable public var maxShowCount: Int = 3 {
        didSet {
            if maxShowCount > 0 {
                semaphore = DispatchSemaphore(value: maxShowCount)
            }
        }
    }

    /// 询问目标 GiftView 对象是否成立暴击
    ///
    /// 通过比较两个 GiftView 判断是否为需要暴击的 GiftView，其中，第一个参数为已存在的 GiftView，第二个参数为要送出去的 GiftView，若需要暴击请实现 criticalStrikeAction 函数
    public var critConditionsClosure: ((_ oldGiftView: GiftView, _ showGiftView: GiftView) -> (Bool))?
    /// 暴击动作，当发生暴击事件时通过此匿名函数更新被暴击的 giftView（更新已存在的礼物视图）。
    public var criticalStrikeAction: ((GiftView) -> Void)?
    
    /// 同屏显示的礼物间距，默认 10.
    public var giftViewSpace = 10
    /// 出现过程动画时长，默认 1 秒
    public var entranceDuration: TimeInterval = 1
    /// 往上飘（消失过程的）动画时长，默认 3 秒
    public var disappearDuration: TimeInterval = 3
    
    /// 当前队列中的礼物对象数量
    private(set) var queueCount = 0

    /// 存储所有正在显示的礼物消息视图 view.
    private var giftViews = [GiftView]()
    /// giftView 的桩点，只有存在 giftViewAnchors 里面的桩点才能显示 giftView.
    private var giftViewAnchors = [CGPoint]()
    
    /// 最多允许多少个线程同时访问共享资源或者同时执行多少个任务，任务数量取决于 maxGiftViewCount
    /// - Warning: semaphore 处于 wait() 时， 若释放引起崩溃(EXC_BAD_INSTRUCTION)，需在释放前将确保当前信号量值大于等于初始信号量值
    private var semaphore = DispatchSemaphore(value: 3)
    // 一个用于执行礼物动画的并发队列
    private let giftMessageQueue = DispatchQueue(label: "GiftMessageCtrlPanel", qos: DispatchQoS.default, attributes: .concurrent)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// 初始化通用函数
    open func commonInit() {
        isUserInteractionEnabled = false
    }

    open override func didMoveToWindow() {
        // window 为 nil，说明控制面板被移除啦
        if window == nil {
            guard queueCount > 0 else { return }
            for _ in 1...queueCount {
                semaphore.signal()
            }
        } else {
            // 控制面板被添加到屏幕上了
        }
    }

    
    /// 该函数将送出一个 GiftView，即送出一个礼物。
    ///
    /// 该函数会优先确认暴击条件函数 critConditionsClosure，如果送出的礼物符合暴击条件将不会弹出新 GiftView.
    /// - Parameter giftView: 要显示的 giftView
    public func profferGiftMessageView(giftView: GiftView) {
        
        if critConditionsClosure != nil {
            /// 查找需要暴击的 giftView 索引
            var critConditionsIndex: Int? = nil
            let existList = giftViews.enumerated().filter { (index, oldGiftView) -> Bool in
                /// 是否符合暴击条件
                let isEeligible = critConditionsClosure!(oldGiftView, giftView)
                if isEeligible { critConditionsIndex = index }
                return isEeligible
            }
            // 判断是否存在相同特性的 GiftView,如果存在则直接触发暴击
            guard existList.isEmpty else {
                criticalStrikeAction?(giftViews[critConditionsIndex!])
                giftViews[critConditionsIndex!].criticalStrike()
                return
            }
        }
        giftMessageQueue.async { [weak self] in
            guard let `self` = self else { return }
            self.queueCount += 1
            self.semaphore.wait()   // 此处等待信号量 +1 后放行下面的代码
            DispatchQueue.main.async {
                self.showGiftView(giftView: giftView)
            }
        }
    }
    
    /*
     deinit {
        // 需要集成 Logger
        logHappy("GiftMessageCtrlPanel 已经释放")
     }
     */
}

// MARK: - 私有扩展函数
private extension GiftMessageCtrlPanel {
    
    /// 弹出一个 GiftView 对象，将以动画方式并排好队列显示在控制面板视图中，此函数请务必在 main 线程运行
    func showGiftView(giftView: GiftView) {
        // 配置 giftView 基础信息
        giftView.defaultWaitTime = duringShow
        giftView.completeHandle = { [weak self] view in
            self?.dismissGiftView(giftView: view)
        }

        // 将 giftView 插入到 containerView 上方，同时存储到 giftViews 中
        insertSubview(giftView, at: 0)
        giftViews.insert(giftView, at: 0)
        
        // 如果 giftViewAnchors 有桩点就从里面拿一个，否则计算一个新桩点
        if giftViewAnchors.isEmpty {
            // 根据当前 giftViews 数量计算 giftView 所在桩点
            var centerY: CGFloat = 0
            // 计算出一个桩点
            giftViews.enumerated().forEach { (index, giftView) in
                centerY = frame.height - CGFloat(index+1)*giftView.frame.height
                centerY -= CGFloat(index*giftViewSpace)
                centerY += giftView.frame.height/2
            }
            giftView.center.y = centerY
        } else {
            giftView.center = giftViewAnchors.removeFirst()
        }
        
        // 从左往右出现的动画
        giftView.center.x = -giftView.frame.size.width
        giftView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: entranceDuration, delay: 0.0,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8,
                       options: UIView.AnimationOptions.curveEaseOut) {
            giftView.transform = CGAffineTransform.identity
            
            giftView.center.x = self.frame.width/2
        }
        
    }
    
    /// 移除一个指定的 GiftView 对象
    func dismissGiftView(giftView: GiftView) {
        // 先释放信号量，不必非得等到 giftView 移除后再释放
        if let index = giftViews.lastIndex(of: giftView) {
            giftViews.remove(at: index)
            giftViewAnchors.append(giftView.center)
        }
        semaphore.signal()
        queueCount -= 1

        /// 往上飘气泡移动轨迹路径
        let travelPath = UIBezierPath()
        travelPath.move(to: giftView.center)
        //根据贝塞尔曲线添加动画
        let endPoint = CGPoint(x: giftView.center.x, y: 0)
        travelPath.addQuadCurve(to: endPoint, controlPoint: endPoint)

        // 关键帧动画,实现整体图片位移
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = travelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        // 往上飘动画时长,可控制速度
        keyFrameAnimation.duration = disappearDuration
        giftView.layer.add(keyFrameAnimation, forKey: "positionOnPath")

        // 消失动画
        UIView.animate(withDuration: 1) {
            giftView.alpha = 0.0
        } completion: { finished in
            giftView.removeFromSuperview()
        }
    }

}


/* UIView 生命周期
 
 1.UIView生命周期加载阶段
 在loadView阶段（内存加载阶段），先是把自己本身都加到superView上面，再去寻找自己的subView并依次添加。到此为止，只和addSubview操作有关，和是否显示无关。等到所有的subView都在内存层面加载完成了，会调用一次viewWillAppear，然后会把加载好的一层层view，分别绘制到window上面。然后layoutSubview，DrawRect，加载即完成
 
 2.UIView生命周期移除阶段
 会先依次移除本view的moveToWindow，然后依次移除所有子视图，掉他们的moveToWindow，view就在window上消失不见了，然后在removeFromSuperView，然后dealloc，dealloc之后再removeSubview。（但不理解为什么dealloc之后再removeSubview）
 
 3.如果没有子视图，则不会接收到didAddSubview和willRemoveSubview消息
 
 4.和superView，window相关的方法，可以通过参数（superView/window）或者self.superView/self.window,判断是创建还是销毁，如果指针不为空，是创建，如果为空，就是销毁。这四个方法，在整个view的生命周期中，都会被调用2次，一共是8次
 
 5.removeFromSuperview和dealloc在view的生命周期中，调且只调用一次，可以用来removeObserver，移除计时器等操作。（layoutSubview可能会因为子视图的调整，多次调用)
 
 6.UIView是在被加到自己的父视图上之后，才开始会寻找添加自己的子视图（数据层面的添加，并不是加到window上面）。UIView是在调用dealloc中，移除自己的子视图，所有子视图移除并销毁内存之后，才会销毁自己的内存，dealloc完成
 
 */

/// 直播间刷礼物弹出的具体消息视图（即礼物视图）
open class GiftView: UIView {
    /// 计时器完成的事件处理，通过此函数执行将本视图移除的相关操作。
    var completeHandle: ((GiftView)->Void)?
    
    /// 默认倒计时时长，该时长决定触发 completeHandle 前的等待时间。该属性默认值为 3.
    var defaultWaitTime = 3
    /// 实际使用的倒计时时长
    private var waitTime = 5
    
    /// 计时器对象
    private var countdownTimer: Timer?
    /// 是否开始计时，默认否
    private var isCounting = false {
        willSet {
            guard newValue != isCounting else { return }
            if newValue {
                waitTime = defaultWaitTime
                // 初始化计时器对象，每隔1秒执行一次
                countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    if let strongSelf = self {
                        strongSelf.waitTime -= 1
                        if strongSelf.waitTime <= 0  {
                            strongSelf.isCounting = false
                        }
                    }
                }
            } else {
                completeHandle?(self)
            }
        }
    }
    
    
    open override func didMoveToWindow() {
        // 说明被移除
        if window == nil {
            removeFromSuperview()
        } else {
            isCounting = true
        }
    }
    
    /// 发生暴击事件（显示相同的已存在礼物视图）时必须调用此函数以重置 waitTime.
    final func criticalStrike() { waitTime = defaultWaitTime }
    
    /// 结束倒计时，并将计时器设为无效
    private func endCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    /*
     deinit {
        // Judy.logHappy("GiftView 释放。")
     }
     */
}
