//
//  JudyWaterWaveView.swift
//  WaterWave
//
//  Created by 王仁洁 on 2018/9/20.
//  Copyright © 2018年 EMERANA. All rights reserved.
//


// MARK: - JudyWaterWaveView

import UIKit

/// 波浪动画View
@IBDesignable open class JudyWaterWaveView: UIView {
    
    /** 进度，已用容量百分比。默认为60% */
    @IBInspectable public var 进度: CGFloat = 0.6
    /** 曲线(波浪)振幅 */
    @IBInspectable public var 振幅: CGFloat = 6
    /** 是否为正圆，如果该View长宽不等则不会设置正圆。默认为true */
    @IBInspectable public var 正圆: Bool = true
    /** 底层波浪颜色，最先被添加到layer上的波浪的颜色 */
    @IBInspectable public var 底层波浪颜色: UIColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.5)
    /** 覆盖在底层波浪上layer的颜色 */
    @IBInspectable public var 顶层波浪颜色: UIColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.6818011559)
    
    /** 曲线移动速度 */
    public var 速度: CGFloat = 1
    
    /// 两条波浪
    private let 底层Layer = CAShapeLayer(), 顶层Layer = CAShapeLayer()
    
    /// 曲线角速度
    private var wavePalstance = CGFloat()
    /// 曲线初相，默认为0
    private var waveX: CGFloat = 0
    /// 曲线偏距
    private var waveY = CGFloat()
    
    private var disPlayLink = CADisplayLink()
    
    /**
     正弦曲线公式可表示为 y = A*sin(ωx+φ)+k：
     A:振幅，最高和最低的距离
     W:角速度，用于控制周期大小，单位x中的起伏个数
     K:偏距，曲线整体上下偏移量
     φ:初相，左右移动的值
     
     这个效果主要的思路是添加两条曲线 一条正玄曲线、一条余弦曲线 然后在曲线下添加深浅不同的背景颜色，从而达到波浪显示的效果
     */
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // 设定两条波浪的颜色
        底层Layer.fillColor = 底层波浪颜色.cgColor
        底层Layer.strokeColor = 底层波浪颜色.cgColor
        顶层Layer.fillColor = 顶层波浪颜色.cgColor
        顶层Layer.strokeColor = 顶层波浪颜色.cgColor
        
        //初始化波浪
        layer.addSublayer(底层Layer)
        layer.addSublayer(顶层Layer)
        
        //角速度
        /*
         决定波的宽度和周期，比如，我们可以看到上面的例子中是一个周期的波曲线，
         一个波峰、一个波谷，如果我们想在0到2π这个距离显示2个完整的波曲线，那么周期就是π。
         ω常量wavePalstance计算如下 可以根据自己的需求计算
         */
        wavePalstance = CGFloat(Double.pi/Double(bounds.width))
        //偏距
        waveY = bounds.height
        //x轴移动速度
        速度 = wavePalstance * 2
        
        //以屏幕刷新速度为周期刷新曲线的位置
        disPlayLink = CADisplayLink.init(target: self, selector: #selector(waveAnimation(link:)))
        //        disPlayLink.add(to: RunLoop.main, forMode: .commonModes)
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // 正圆设置
        if 正圆 {
            if bounds.width == bounds.height {
                layer.cornerRadius = bounds.size.width/2.0
            }
        }
        layer.masksToBounds = true
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    open override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
}

// MARK: 公开函数

public extension JudyWaterWaveView {
    
    /// 停止动画
    func stop() {
        disPlayLink.invalidate()
    }
    
    /// 开始动画
    func star() {
        disPlayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
}

// MARK: 私有函数

private extension JudyWaterWaveView {
    
    @objc func waveAnimation(link: CADisplayLink){
        waveX += 速度
        
        updateWaveY() // 更新波浪的高度位置
        startWaveAnimation() // 波浪轨迹和动画
    }
    
    // 更新偏距的大小 直到达到目标偏距 让wave有一个匀速增长的效果
    func updateWaveY() {
        let targetY: CGFloat = bounds.height - 进度 * bounds.height
        if (waveY < targetY) {
            waveY += 2
        }
        if (waveY > targetY ) {
            waveY -= 2
        }
    }
    
    /// 开始执行波浪动画
    func startWaveAnimation() {
        //波浪宽度
        let waterWaveWidth: CGFloat = bounds.width
        
        //初始化运动路径
        let path: CGMutablePath = CGMutablePath()
        let maskPath: CGMutablePath = CGMutablePath()
        
        //设置起始位置
        path.move(to: CGPoint(x: 0, y: waveY))
        //设置起始位置
        maskPath.move(to: CGPoint(x: 0, y: waveY))
        
        //初始化波浪,其实Y为偏距
        var y = waveY
        var tempX: CGFloat = 0.0
        while tempX <= waterWaveWidth {
            y = 振幅 * sin(wavePalstance * tempX + waveX) + waveY
            path.addLine(to: CGPoint(x: tempX, y: y))
            
            y = 振幅 * cos(wavePalstance * tempX + waveX) + waveY
            maskPath.addLine(to: CGPoint(x: tempX, y: y))
            tempX += 1.0
        }
        
        updateLayer(layer: 底层Layer, path: path)
        updateLayer(layer: 顶层Layer, path: maskPath)
    }
    
    func updateLayer(layer: CAShapeLayer, path: CGMutablePath) {
        //填充底部颜色
        let waterWaveWidth: CGFloat = bounds.width
        path.addLine(to: CGPoint(x: waterWaveWidth, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.height))
        path.closeSubpath()
        layer.path = path
    }
    
    
}


// MARK: - MarqueeView

public enum MarqueeType {
    case left
    case right
    case reverse
}

/// 跑马灯效果的View
public class MarqueeView: UIView {
    public var marqueeType: MarqueeType = .left
    public var contentMargin: CGFloat = 12                     //两个视图之间的间隔
    public var frameInterval: Int = 1                          //多少帧回调一次，一帧时间1/60秒
    public var pointsPerFrame: CGFloat = 0.5                   //每次回调移动多少点
    public var contentView: UIView? {
        didSet {
            self.setNeedsLayout()
        }
    }
    private let containerView = UIView()
    private var marqueeDisplayLink: CADisplayLink?
    private var isReversing = false

    open override func willMove(toSuperview newSuperview: UIView?) {
        //骚操作：当视图将被移除父视图的时候，newSuperview就为nil。在这个时候，停止掉CADisplayLink，断开循环引用，视图就可以被正确释放掉了。
        if newSuperview == nil {
            self.stopMarquee()
        }
    }

    public init() {
        super.init(frame: CGRect.zero)

        self.initializeViews()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.initializeViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initializeViews()
    }

    func initializeViews() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true

        containerView.backgroundColor = UIColor.clear
        self.addSubview(containerView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let validContentView = contentView else {
            return
        }
        for view in containerView.subviews {
            view.removeFromSuperview()
        }

        //对于复杂的视图，需要自己重写contentView的sizeThatFits方法，返回正确的size
        validContentView.sizeToFit()
        validContentView.frame = CGRect(x: 0, y: 0, width: validContentView.bounds.size.width, height: self.bounds.size.height)
        containerView.addSubview(validContentView)

        if marqueeType == .reverse{
            containerView.frame = CGRect(x: 0, y: 0, width: validContentView.bounds.size.width, height: self.bounds.size.height)
        }else {
            containerView.frame = CGRect(x: 0, y: 0, width: validContentView.bounds.size.width*2 + contentMargin, height: self.bounds.size.height)
        }

        if validContentView.bounds.size.width > self.bounds.size.width {
            if marqueeType != .reverse {
                if #available(iOS 11.0, *) {
                    //骚操作：UIView是没有遵从拷贝协议的。可以通过UIView支持NSCoding协议，间接来复制一个视图
                    //  let otherContentViewData = NSKeyedArchiver.archivedData(withRootObject: validContentView)
                    let otherContentViewData = try! NSKeyedArchiver.archivedData(withRootObject: validContentView, requiringSecureCoding: true)
                    
                    //  let otherContentView = NSKeyedUnarchiver.unarchiveObject(with: otherContentViewData) as! UIView
                    let otherContentView = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIView.classForCoder()], from: otherContentViewData) as! UIView
                    
                    otherContentView.frame = CGRect(x: validContentView.bounds.size.width + contentMargin, y: 0, width: validContentView.bounds.size.width, height: self.bounds.size.height)
                    containerView.addSubview(otherContentView)
                } else {
                    Judy.log("iOS11以下发现的错误，请修复")
                }
            }

            self.startMarquee()
        }
    }

    //如果你的contentView的内容在初始化的时候，无法确定。需要通过网络等延迟获取，那么在内容赋值之后，在调用该方法即可。
    public func reloadData() {
        self.setNeedsLayout()
    }

    fileprivate func startMarquee() {
        self.stopMarquee()

        if marqueeType == .right {
            var frame = self.containerView.frame
            frame.origin.x = self.bounds.size.width - frame.size.width
            self.containerView.frame = frame
        }
        
        self.marqueeDisplayLink = CADisplayLink.init(target: self, selector: #selector(processMarquee))

        if #available(iOS 10.0, *) {
            self.marqueeDisplayLink?.preferredFramesPerSecond = self.frameInterval
        } else {
            self.marqueeDisplayLink?.frameInterval = self.frameInterval
        }

        self.marqueeDisplayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }

   fileprivate  func stopMarquee()  {
        self.marqueeDisplayLink?.invalidate()
        self.marqueeDisplayLink = nil
    }

    @objc fileprivate func processMarquee() {
        var frame = self.containerView.frame

        switch marqueeType {
        case .left:
            let targetX = -(self.contentView!.bounds.size.width + self.contentMargin)
            if frame.origin.x <= targetX {
                frame.origin.x = 0
                self.containerView.frame = frame
            }else {
                frame.origin.x -= pointsPerFrame
                if frame.origin.x < targetX {
                    frame.origin.x = targetX
                }
                self.containerView.frame = frame
            }
        case .right:
            let targetX = self.bounds.size.width - self.contentView!.bounds.size.width
            if frame.origin.x >= targetX {
                frame.origin.x = self.bounds.size.width - self.containerView.bounds.size.width
                self.containerView.frame = frame
            }else {
                frame.origin.x += pointsPerFrame
                if frame.origin.x > targetX {
                    frame.origin.x = targetX
                }
                self.containerView.frame = frame
            }
        case .reverse:
            if isReversing {
                let targetX: CGFloat = 0
                if frame.origin.x > targetX {
                    frame.origin.x = 0
                    self.containerView.frame = frame
                    isReversing = false
                }else {
                    frame.origin.x += pointsPerFrame
                    if frame.origin.x > 0 {
                        frame.origin.x = 0
                        isReversing = false
                    }
                    self.containerView.frame = frame
                }
            }else {
                let targetX = self.bounds.size.width - self.containerView.bounds.size.width
                if frame.origin.x <= targetX {
                    isReversing = true
                }else {
                    frame.origin.x -= pointsPerFrame
                    if frame.origin.x < targetX {
                        frame.origin.x = targetX
                        isReversing = true
                    }
                    self.containerView.frame = frame
                }
            }
        }

    }

}


/// 圆形进度条。
///
/// 支持自定义相关属性的圆形进度条。
/// - Warning: 仅限在 StoryBoard 中使用。
open class CircularProgressView: UIView {
    // MARK: 公开属性

    /// 该属性指定圆环的粗细，默认为 10
    public var lineWith: Float = 10
    /// 基准圆环颜色
    public var unfillColor: UIColor = .lightGray
    
    /// 画的过程动画时长
    public var animationTime: Float = 5
    /// 结束角
    // public var endAngle: Float = 18
    /// 是否顺时针方向，默认为 true
    public var clockwise: Bool = true
    

    // MARK: 私有属性
    
    /// 圆心
    private(set) var circleCenterPoint: CGPoint!
    /// 圆的半径
    private(set) var radius: Float!

    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }
    
    open override func draw(_ rect: CGRect) {
        drawMiddlecircle()
        drawCircle()
    }

    
    // MARK: 私有方法
    
    /// 添加一条 lineLayer
    /// - Parameter circlePath: 用于绘制的路径
    /// - Returns: CAShapeLayer
    @discardableResult
    private func addLineLayer(circlePath: UIBezierPath) -> CAShapeLayer {

        let lineLayer = CAShapeLayer(layer: layer)
        lineLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.lineWidth  = CGFloat(lineWith)
        lineLayer.path = circlePath.cgPath
        // 将该 lineLayer 添加到当前 layer
        layer.addSublayer(lineLayer)
        
        // 添加动画
        let ani = CABasicAnimation(keyPath: "strokeEnd")
        ani.fromValue = 0
        ani.toValue = 1
        ani.duration = Double(animationTime)
        
        lineLayer.add(ani, forKey: "strokeEnd")
        
        return lineLayer
    }


    /// 画辅助圆环
    public final func drawMiddlecircle() {
        // 计算圆的半径
        let x = Float(bounds.size.height/2) - lineWith/2
        let y = Float(bounds.size.width/2) - lineWith/2
        radius = min(x, y)

        // 确定圆心位置
        let center =  min(bounds.size.width/2, bounds.size.width/2)
        circleCenterPoint = CGPoint(x: center, y: center)
        // 用于画圆的贝塞尔曲线
        let circleBezierPath = UIBezierPath(arcCenter: circleCenterPoint,
                                 radius: CGFloat(radius),
                                 startAngle: CGFloat(Double.pi * 0), // 起始位置
                                 endAngle: CGFloat(Double.pi * 2 ), // 终点位置
                                 clockwise: clockwise)
        
        circleBezierPath.lineWidth = CGFloat(lineWith)
        circleBezierPath.lineCapStyle = .round
        circleBezierPath.lineJoinStyle = .round

        unfillColor.setStroke()
        // 使用当前绘图属性沿路径绘制一条线
        circleBezierPath.stroke()
    }
    
    /// 画圆环
    private func drawCircle() {
        let circlePath = UIBezierPath(arcCenter: circleCenterPoint,
                                       radius: CGFloat(radius),
                                       startAngle: 0,// 起始位置
                                       endAngle: CGFloat(Double.pi*2),// 终点位置，Double.pi 为半圈
                                       clockwise: clockwise)
        
        addLineLayer(circlePath: circlePath)
        
    }
    
}


/// 适用于按住按钮递加进度
open class CircularProgressLiveView: CircularProgressView {
    
    /// 主要的 layer
    public let lineLayer = CAShapeLayer()
    

    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // 旋转 View, 将开始点设置在顶部，即（3/2）π 处，必须以重新赋值的方式设置。
        var transform = self.transform
        transform = transform.rotated(by: -CGFloat(Double.pi/2)) // 逆时针旋转90°
        self.transform = transform
        
        lineLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor.purple.cgColor
        lineLayer.lineWidth  = CGFloat(lineWith)
        
        // 用于画圆的贝塞尔曲线(矢量路径)。
        let circleBezierPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size))

        lineLayer.path = circleBezierPath.cgPath
        layer.addSublayer(lineLayer)
        // 设置。
        lineLayer.strokeStart = 0
        lineLayer.strokeEnd = 0
    }

    // 覆盖父类的 draw 函数，使其啥都不做
    open override func draw(_ rect: CGRect) {
        // Drawing code
    }
}

@available(*, unavailable, message: "此类尚未完成测试，请勿使用")
class MyScaleCircle: CircularProgressView {
    
    //中心数据显示标签
    var centerLable : UILabel?
    
    //  四个区域的颜色
    var firstColor: UIColor = .green
    var secondColor:UIColor = .blue
    var thirdColor:UIColor = .brown
    var fourthColor:UIColor = .cyan
    
    //  四个区域所占的百分比
    var firstScale: Float = 0.25
    var secondScale: Float = 0.25
    var thirdScale: Float = 0.25
    var fourthScale: Float = 0.25

    /// 四个区域各自绘制所需时长
    private var first_animation_time: Float!,
                second_animation_time: Float!,
                third_animation_time: Float!,
                fourth_animation_time: Float!
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        initCenterLabel()
    }
    
    open override func draw(_ rect: CGRect) {
        // Drawing code
        
        super.draw(rect)

        let queue = DispatchQueue(label: "ScaleCircleQueue") // 创建队列
        let mainQueue = DispatchQueue.main
        queue.async {
            mainQueue.async {
                self.drawOutCCircle_first()
            }
        }
        queue.async {
            Thread.sleep(forTimeInterval: Double(self.first_animation_time))
            mainQueue.async {
                self.drawOutCCircle_second()
            }
            
        }
        queue.async {
            Thread.sleep(forTimeInterval: Double(self.second_animation_time))
            mainQueue.async {
                self.drawOutCCircle_third()
            }
        }
        queue.async {
            Thread.sleep(forTimeInterval: Double(self.third_animation_time))
            mainQueue.async {
                self.drawOutCCircle_fourth()
            }
        }
    }
    
    /// 参数配置
    func initData(){
        //计算 animation 时间
        first_animation_time = animationTime * firstScale
        second_animation_time = animationTime * secondScale
        third_animation_time = animationTime * thirdScale
        fourth_animation_time = animationTime * fourthScale

        centerLable?.font = UIFont.systemFont(ofSize: CGFloat(radius/3))
    }
    
    /// 创建中心标签
    func initCenterLabel() {
        
        let center = min(bounds.size.width/2, bounds.size.height/2)

        centerLable = UILabel(frame:CGRect(x: 0, y: 0, width: 2*center, height: 2*center))
        centerLable?.textAlignment = .center
        centerLable?.backgroundColor = UIColor.clear
        centerLable?.adjustsFontSizeToFitWidth = true
        centerLable?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        contentMode = .redraw
        addSubview(centerLable!)
        centerLable?.text = "请初始化..."
    }
    
    
    /// 显示圆环 -- first
    func drawOutCCircle_first(){
        let bPath_first:UIBezierPath = UIBezierPath.init(arcCenter: circleCenterPoint, radius: CGFloat(radius), startAngle: CGFloat(Double.pi * 0), endAngle: CGFloat(Double.pi * Double(firstScale * 2)), clockwise: clockwise)
        let lineLayer_first = CAShapeLayer.init(layer: layer)
        lineLayer_first.frame = (centerLable?.frame)!
        lineLayer_first.fillColor = UIColor.clear.cgColor
        lineLayer_first.path = bPath_first.cgPath
        lineLayer_first.strokeColor = firstColor.cgColor
        lineLayer_first.lineWidth  = CGFloat(lineWith)
        let ani:CABasicAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        ani.fromValue = 0
        ani.toValue = 1;
        ani.duration = Double(first_animation_time)
        lineLayer_first.add(ani, forKey: "strokeEnd")
        layer.addSublayer(lineLayer_first)
    }
    
    /// 显示圆环 -- second
    func drawOutCCircle_second(){
        
        let bPath_second:UIBezierPath = UIBezierPath.init(arcCenter: circleCenterPoint, radius: CGFloat(radius), startAngle: CGFloat(Double.pi * Double(2 * firstScale)), endAngle: CGFloat(Double.pi * Double(2 * (firstScale + secondScale))), clockwise: clockwise)
        
        let lineLayer_second = CAShapeLayer.init(layer: layer)
        lineLayer_second.frame = centerLable!.frame
        lineLayer_second.fillColor = UIColor.clear.cgColor
        lineLayer_second.path = bPath_second.cgPath
        lineLayer_second.strokeColor = secondColor.cgColor
        lineLayer_second.lineWidth = CGFloat(lineWith)
        
        let ani = CABasicAnimation(keyPath: "strokeEnd")
        ani.fromValue = 0
        ani.toValue = 1
        ani.duration = Double(second_animation_time)
        lineLayer_second.add(ani, forKey: "strokeEnd")
        layer.addSublayer(lineLayer_second)
    }
    
    /// 显示圆环 -- third
    func drawOutCCircle_third(){
        let bPath_third = UIBezierPath.init(arcCenter: circleCenterPoint, radius: CGFloat(radius), startAngle: CGFloat(Double.pi * Double(2 * (firstScale + secondScale))), endAngle: CGFloat(Double.pi * Double(2 * (firstScale + secondScale + thirdScale))), clockwise: clockwise)
        
        let lineLayer_third = CAShapeLayer.init(layer: layer)
        lineLayer_third.frame = centerLable!.frame
        lineLayer_third.fillColor = UIColor.clear.cgColor
        lineLayer_third.path = bPath_third.cgPath
        lineLayer_third.strokeColor = thirdColor.cgColor
        lineLayer_third.lineWidth = CGFloat(lineWith)
        
        let ani = CABasicAnimation.init(keyPath: "strokeEnd")
        ani.fromValue = 0
        ani.toValue = 1
        ani.duration = Double(third_animation_time)
        lineLayer_third.add(ani, forKey: "strokeEnd")
        layer.addSublayer(lineLayer_third)
    }
    
    /// 显示圆环 -- fourth
    func drawOutCCircle_fourth(){
        let bPath_fourth = UIBezierPath.init(arcCenter: circleCenterPoint, radius: CGFloat(radius), startAngle: CGFloat(Double.pi * Double(2 * (firstScale + secondScale + thirdScale))), endAngle: CGFloat(Double.pi * Double(2 * (firstScale + secondScale + thirdScale + fourthScale))), clockwise: clockwise)
        let lineLayer_fourth = CAShapeLayer.init(layer: layer)
        lineLayer_fourth.frame = centerLable!.frame
        lineLayer_fourth.fillColor = UIColor.clear.cgColor
        lineLayer_fourth.path = bPath_fourth.cgPath
        lineLayer_fourth.strokeColor = fourthColor.cgColor
        lineLayer_fourth.lineWidth = CGFloat(lineWith)
        
        let ani = CABasicAnimation.init(keyPath: "strokeEnd")
        ani.fromValue = 0
        ani.toValue = 1
        ani.duration = Double(fourth_animation_time)
        lineLayer_fourth.add(ani, forKey: "strokeEnd")
        layer.addSublayer(lineLayer_fourth)
    }
    
}


/// 一个气泡动画类。
///
/// 通过在运行循环中不断调度 judy_popBubble 函数以达到不断有气泡往上升的动画效果，可参考如下代码：
///
/// ```
/// let judyPopBubble = JudyPopBubble()
/// // 创建计时器，并以默认模式在当前运行循环中调度它。
/// animateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
///     if let strongSelf = self {
///         let image = UIImage(named: imageNames[NSInteger(arc4random_uniform( UInt32((imageNames.count)) ))])
///         judyPopBubble.judy_popBubble(withImage: image, inView: strongSelf.view, belowSubview: strongSelf.likeButton)
///     }
/// }
/// ```
/// - Warning: 通过调用 judy_popBubble 函数来弹出一个气泡动画。
public class JudyPopBubble {
    
    /// 指定气泡的中心点，默认为 bubble_belowView 的中心点。
    public var bubble_image_Center: CGPoint?
    
    /// 气泡冒出时的动画所需时长。
    public var bubble_animate_showDuration = 0.2
    /// 气泡旋转动画所需时长。
    public var bubble_animate_rotatedDuration: TimeInterval = 2
    /// 气泡往上飘所需时长。
    public var bubble_animate_windUp: TimeInterval = 3
    /// 气泡消失时所需时长。
    public var bubble_animate_dissmiss: TimeInterval = 3
    /// 气泡动画路径高度。
    public var bubble_animate_height: CGFloat = 350
    
    /// 气泡图片。
    private(set) public var bubble_image: UIImage?
    /// 气泡所在的 View。
    private(set) public var bubble_parentView: UIView?
    /// 将该气泡放在该 View 下面，该 view 决定了气泡的起始位置，通常情况下是该对象是触发按钮。
    private(set) public var bubble_belowView: UIView?
    
    
    public init() {}
    
    /// 执行一个气泡图片动画。
    /// - Parameters:
    ///   - image: 气泡图片对象。
    ///   - parentView: 执行气泡动画的 View。
    ///   - belowView: 将该气泡放在该 View 下面，该 view 决定了气泡的起始位置。
    public func judy_popBubble(withImage image: UIImage?, inView parentView: UIView, belowSubview belowView: UIView) {
        guard image != nil else { return }
        
        bubble_image = image!
        bubble_parentView = parentView
        bubble_belowView = belowView
        
        /// 气泡图片。
        let bubbleImageView = UIImageView(image: bubble_image)
        
        // 设置气泡图片的起始位置。
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
        bubbleImageView.alpha = 0 // 初始为完全透明。
        
        // 气泡冒出动画。
        UIView.animate(withDuration: bubble_animate_showDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveEaseOut) {
            bubbleImageView.transform = CGAffineTransform.identity
            bubbleImageView.alpha = 1
        } completion: { isCompletion in }
        
        // 随机偏转角度 control 点。
        let j = CGFloat(arc4random_uniform(2))
        /// 随机方向，-1 OR 1 代表了顺时针或逆时针。
        let travelDirection = CGFloat(1 - (2*j))
        
        // 旋转气泡。
        UIView.animate(withDuration: bubble_animate_rotatedDuration) {
            var transform = bubbleImageView.transform
            let rs = Double.pi/4//(4+Double(rotationFraction)*0.2)。
            transform = transform.rotated(by: travelDirection*CGFloat(rs)) // 顺时针或逆时针旋转。
            // transform = transform.translatedBy(x: 0, y: 200)//平移。
            // transform = transform.scaledBy(x: 0.5, y: 0.5)//缩放。
            bubbleImageView.transform = transform
        }
        
        // 随机终点。
        let ViewX = bubbleImageView.center.x
        let ViewY = bubbleImageView.center.y
        let endPoint = CGPoint(x: ViewX + travelDirection*10, y: ViewY - bubble_animate_height)
        
        let m1 = ViewX + CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
        let n1 = ViewY - CGFloat(60 + travelDirection*CGFloat(arc4random_uniform(20)))
        let m2 = ViewX - CGFloat(travelDirection*(CGFloat(arc4random_uniform(20)) + 50))
        let n2 = ViewY - CGFloat(90 + travelDirection*CGFloat(arc4random_uniform(20)))
        let controlPoint1 = CGPoint(x: m1, y: n1)   //control 根据自己动画想要的效果做灵活的调整
        let controlPoint2 = CGPoint(x: m2, y: n2)
        
        /// 气泡移动轨迹路径。
        let travelPath = UIBezierPath()
        travelPath.move(to: bubbleImageView.center)
        //根据贝塞尔曲线添加动画。
        travelPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        // 关键帧动画,实现整体图片位移。
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = travelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        keyFrameAnimation.duration = bubble_animate_windUp // 往上飘动画时长,可控制速度。
        bubbleImageView.layer.add(keyFrameAnimation, forKey: "positionOnPath")
        
        // 消失动画。
        UIView.animate(withDuration: bubble_animate_dissmiss) {
            bubbleImageView.alpha = 0.0
        } completion: { finished in
            bubbleImageView.removeFromSuperview()
        }
        
    }
    
}


// MARK: - 直播间送礼物功能

/// 直播间送礼物控制面板。
///
/// 通过 profferGiftMessageView() 函数来送出一个礼物，该礼物将显示在当前 View 上。
@IBDesignable open class GiftMessageCtrlPanel: UIView {
    /// 每个 giftView 允许显示的时长，默认 3 秒。
    @IBInspectable public var duringShow = 3
    /// 最多同时显示的 giftView 数量，默认为 3.
    @IBInspectable public var maxGiftViewCount = 3

    /// 询问目标 GiftView 对象成立暴击的条件。
    ///
    /// 通过比较两个 GiftView 判断是否为需要暴击的 GiftView，其中，第一个参数为已存在的 GiftView，第二个参数为要送出去的 GiftView.
    public var critConditionsClosure: ((_ oldGiftView: GiftView, _ showGiftView: GiftView)->(Bool))?
    /// 当发生暴击事件时通过此匿名函数更新被暴击的 giftView（更新已存在的礼物视图）。
    public var criticalStrikeAction: ((GiftView)->Void)?

    /// 同屏显示的礼物间距，默认 10.
    public var giftViewSpace = 10
    /// 出现过程动画时长，默认 1 秒。
    public var entranceDuration: TimeInterval = 1
    /// 往上飘（消失过程的）动画时长，默认 3 秒。
    public var disappearDuration: TimeInterval = 3

    /// 存储所有正在显示的礼物消息视图 view.
    private var giftViews = [GiftView]()
    /// giftView 的桩点，只有存在 giftViewAnchors 里面的桩点才能显示 giftView.
    private var giftViewAnchors = [CGPoint]()

    /// 每个 GiftView 显示的时长，单位为秒，该时间过后即释放该 GiftView.
    private var showGiftViewDuration: Int = 1
    
    /// 最多允许多少个线程同时访问共享资源或者同时执行多少个任务，任务数量取决于 maxGiftViewCount。
    private var semaphore = DispatchSemaphore(value: 1)
    // 一个用于执行礼物动画的并发队列。
     private let giftMessageQueue = DispatchQueue(label: "GiftMessageViewCtrl", attributes: .concurrent)

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// 初始化通用函数。
    open func commonInit() {
        isUserInteractionEnabled = false
        
        showGiftViewDuration = duringShow
        semaphore = DispatchSemaphore(value: maxGiftViewCount)
    }

    open override func didMoveToWindow() {
        // 说明被移除。
        if window == nil {
            Judy.log("window 为 nil，控制面板被移除啦")
        } else {
            Judy.log("控制面板被添加到屏幕上了。")
        }
    }
    
    
    /// 通过该函数送出一个 GiftView，即送出一个礼物。
    ///
    /// 该函数会优先确认暴击条件函数 critConditionsClosure，如果送出的礼物符合暴击条件将不会弹出新 GiftView.
    /// - Parameter giftView: 要显示的 giftView
    public func profferGiftMessageView(giftView: GiftView) {
        
        if critConditionsClosure != nil {
            /// 查找需要暴击的 giftView 索引。
            var critConditionsIndex: Int? = nil
            let existlist = giftViews.enumerated().filter { (index, oldGiftView) -> Bool in
                /// 是否符合暴击条件。
                let isEeligible = critConditionsClosure!(oldGiftView, giftView)
                if isEeligible { critConditionsIndex = index }
                return isEeligible
            }
            // 判断是否存在相同特性的 GiftView,如果存在则直接触发暴击。
            guard existlist.isEmpty else {
                criticalStrikeAction?(giftViews[critConditionsIndex!])
                giftViews[critConditionsIndex!].criticalStrike()
                return
            }
        }
        giftMessageQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.semaphore.wait()
            DispatchQueue.main.async {
                strongSelf.showGiftView(giftView: giftView)
            }
        }
    }

    deinit { Judy.logHappy("GiftMessageCtrlPanel 已经释放。") }
}

private extension GiftMessageCtrlPanel {
    
    /// 将目标 GiftView 以动画方式并排好队列显示在 containerView 容器视图中，此函数请务必在 main 线程运行。
    func showGiftView(giftView: GiftView) {
        // 配置 giftView 基础信息
        giftView.defaultWaitTime = showGiftViewDuration
        giftView.completeHandle = { view in
            self.dismissGiftView(giftView: view)
        }

        // 将 giftView 插入到 containerView 上方，同时存储到 giftViews 中。
        insertSubview(giftView, at: 0)
        giftViews.insert(giftView, at: 0)
        
        // 如果 giftViewAnchors 有桩点就从里面拿一个，否则计算一个新桩点。
        if giftViewAnchors.isEmpty {
            // 根据当前 giftViews 数量计算 giftView 所在桩点。
            var centerY: CGFloat = 0
            // 计算出一个桩点。
            giftViews.enumerated().forEach { (index, giftView) in
                centerY = frame.height - CGFloat(index+1)*giftView.frame.height
                centerY -= CGFloat(index*giftViewSpace)
                centerY += giftView.frame.height/2
            }
            giftView.center.y = centerY
        } else {
            giftView.center = giftViewAnchors.removeFirst()
        }
        
        // 从左往右出现的动画。
        giftView.center.x = -giftView.frame.size.width
        giftView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: entranceDuration, delay: 0.0,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8,
                       options: UIView.AnimationOptions.curveEaseOut) {
            giftView.transform = CGAffineTransform.identity
            
            giftView.center.x = self.frame.width/2
        }
        
    }
    
    /// 动画将指定 giftView 移除。
    func dismissGiftView(giftView: GiftView) {
        // 先释放信号量，不必非得等到 giftView 移除后再释放。
        if let index = giftViews.lastIndex(of: giftView) {
            giftViews.remove(at: index)
            giftViewAnchors.append(giftView.center)
        }
        semaphore.signal()

        /// 往上飘气泡移动轨迹路径。
        let travelPath = UIBezierPath()
        travelPath.move(to: giftView.center)
        //根据贝塞尔曲线添加动画。
        let endPoint = CGPoint(x: giftView.center.x, y: 0)
        travelPath.addQuadCurve(to: endPoint, controlPoint: endPoint)

        // 关键帧动画,实现整体图片位移。
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = travelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        // 往上飘动画时长,可控制速度。
        keyFrameAnimation.duration = disappearDuration
        giftView.layer.add(keyFrameAnimation, forKey: "positionOnPath")

        // 消失动画。
        UIView.animate(withDuration: 1) {
            giftView.alpha = 0.0
        } completion: { finished in
            giftView.removeFromSuperview()
        }
    }

}


/// 适用于直播间送礼物动画弹窗的消息视图控制器。
///
/// 请通过设置 containerView 来确定礼物视图显示的容器 view,若未设置，containerView 默认为 app 启动的窗口。
@available(*, deprecated, message: "请直接使用 GiftMessageCtrlPanel 礼物控制面板")
public final class GiftMessageViewCtrl {
    // FIXME: 当 giftMessageQueue 还有阻塞的任务时 GiftMessageViewCtrl 将无法释放。
    
    /// 礼物视图活动区域的容器 View，默认为当前窗口。
    /// - Warning: 设置该属性时会默认将 isUserInteractionEnabled 设置为 false，请知悉。
    public var containerView: UIView = Judy.appWindow {
        didSet {
            containerView.isUserInteractionEnabled = false
        }
    }
    
    /// 询问目标 GiftView 对象成立暴击的条件。
    ///
    /// 通过比较两个 GiftView 判断是否为需要暴击的 GiftView，其中，第一个参数为已存在的 GiftView，第二个参数为要送出去的 GiftView.
    public var critConditionsClosure: ((_ oldGiftView: GiftView, _ showGiftView: GiftView)->(Bool))?
    /// 当发生暴击事件时通过此匿名函数更新被暴击的 giftView（更新已存在的礼物视图）。
    public var criticalStrikeAction: ((GiftView)->Void)?

    /// 同屏显示的礼物间距，默认 10.
    public var giftViewSpace = 10
    /// 出现过程动画时长，默认 1 秒。
    public var entranceDuration: TimeInterval = 1
    /// 往上飘（消失过程的）动画时长，默认 3 秒。
    public var disappearDuration: TimeInterval = 3

    /// 存储所有正在显示的礼物消息视图 view.
    private var giftViews = [GiftView]()
    /// giftView 的桩点，只有存在 giftViewAnchors 里面的桩点才能显示 giftView.
    private var giftViewAnchors = [CGPoint]()

    /// 每个 GiftView 显示的时长，单位为秒，该时间过后即释放该 GiftView.
    private var showGiftViewDuration: Int
    /// 一次性最多可显示的 giftView 数量。
    // private var maxGiftViewCount: Int
    
    /// 最多允许多少个线程同时访问共享资源或者同时执行多少个任务，任务数量取决于 maxGiftViewCount。
    private var semaphore: DispatchSemaphore
    // 一个用于执行礼物动画的并发队列。
     private let giftMessageQueue = DispatchQueue(label: "GiftMessageViewCtrl", attributes: .concurrent)

    
    /// 通过此构造器实例化一个 GiftMessageViewCtrl.
    /// - Parameters:
    ///   - maxGiftViewCount: 最多同时显示的 giftView 数量，默认为 3.
    ///   - duringShow: 每个 giftView 允许显示的时长，默认 3 秒。
    public init(maxGiftViewCount: Int = 3, duringShow: Int = 3) {
        showGiftViewDuration = duringShow
        semaphore = DispatchSemaphore(value: maxGiftViewCount)
    }
    
    /// 通过此构造器实例化一个 GiftMessageViewCtrl.
    /// - Parameter parentView: 用于显示礼物消息动画的容器，将 giftMessageView 显示在该 View 里面。
    public convenience init(parentView: UIView? = nil, maxGiftViewCount: Int = 3, duringShow: Int = 3) {
        self.init(maxGiftViewCount: maxGiftViewCount, duringShow: duringShow)
        if parentView != nil { containerView = parentView! }
    }
    
    /// 通过该函数送出一个 GiftView，即送出一个礼物。
    ///
    /// 该函数会优先确认暴击条件函数 critConditionsClosure，如果送出的礼物符合暴击条件将不会弹出新 GiftView.
    /// - Parameter giftView: 要显示的 giftView
    public func profferGiftMessageView(giftView: GiftView) {
        
        if critConditionsClosure != nil {
            /// 查找需要暴击的 giftView 索引。
            var critConditionsIndex: Int? = nil
            let existlist = giftViews.enumerated().filter { (index, oldGiftView) -> Bool in
                /// 是否符合暴击条件。
                let isEeligible = critConditionsClosure!(oldGiftView, giftView)
                if isEeligible { critConditionsIndex = index }
                return isEeligible
            }
            // 判断是否存在相同特性的 GiftView,如果存在则直接触发暴击。
            guard existlist.isEmpty else {
                criticalStrikeAction?(giftViews[critConditionsIndex!])
                giftViews[critConditionsIndex!].criticalStrike()
                return
            }
        }
        giftMessageQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.semaphore.wait()
            DispatchQueue.main.async {
                strongSelf.showGiftView(giftView: giftView)
            }
        }
    }
    
    deinit { Judy.logHappy("GiftMessageViewCtrl 已经释放。") }
}

private extension GiftMessageViewCtrl {
    
    /// 将目标 GiftView 以动画方式并排好队列显示在 containerView 容器视图中，此函数请务必在 main 线程运行。
    func showGiftView(giftView: GiftView) {
        // 配置 giftView 基础信息
        giftView.defaultWaitTime = showGiftViewDuration
        giftView.completeHandle = { view in
            self.dismissGiftView(giftView: view)
        }

        // 将 giftView 插入到 containerView 上方，同时存储到 giftViews 中。
        containerView.insertSubview(giftView, aboveSubview: containerView)
        giftViews.insert(giftView, at: 0)
        
        // 如果 giftViewAnchors 有桩点就从里面拿一个，否则计算一个新桩点。
        if giftViewAnchors.isEmpty {
            // 根据当前 giftViews 数量计算 giftView 所在桩点。
            var centerY: CGFloat = 0
            // 计算出一个桩点。
            giftViews.enumerated().forEach { (index, giftView) in
                centerY = containerView.frame.height - CGFloat(index+1)*giftView.frame.height
                centerY -= CGFloat(index*giftViewSpace)
                centerY += giftView.frame.height/2
            }
            giftView.center.y = centerY
        } else {
            giftView.center = giftViewAnchors.removeFirst()
        }
        
        // 从左往右出现的动画。
        giftView.center.x = -giftView.frame.size.width
        giftView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: entranceDuration, delay: 0.0,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8,
                       options: UIView.AnimationOptions.curveEaseOut) {
            giftView.transform = CGAffineTransform.identity
            
            giftView.center.x = self.containerView.frame.width/2
        }
        
    }
    
    /// 动画将指定 giftView 移除。
    func dismissGiftView(giftView: GiftView) {
        // 先释放信号量，不必非得等到 giftView 移除后再释放。
        if let index = giftViews.lastIndex(of: giftView) {
            giftViews.remove(at: index)
            giftViewAnchors.append(giftView.center)
        }
        semaphore.signal()

        /// 往上飘气泡移动轨迹路径。
        let travelPath = UIBezierPath()
        travelPath.move(to: giftView.center)
        //根据贝塞尔曲线添加动画。
        let endPoint = CGPoint(x: giftView.center.x, y: 0)
        travelPath.addQuadCurve(to: endPoint, controlPoint: endPoint)

        // 关键帧动画,实现整体图片位移。
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = travelPath.cgPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        // 往上飘动画时长,可控制速度。
        keyFrameAnimation.duration = disappearDuration
        giftView.layer.add(keyFrameAnimation, forKey: "positionOnPath")

        // 消失动画。
        UIView.animate(withDuration: 1) {
            giftView.alpha = 0.0
        } completion: { finished in
            giftView.removeFromSuperview()
        }
    }
}

// MARK: - 提供的测试函数
public extension GiftMessageViewCtrl {

    static var name : String?
    
    func dismissTest() {
        if let view = giftViews.last {
            dismissGiftView(giftView: view)
        }
    }

}

/* UIView 生命周期
 
 1.UIView生命周期加载阶段。
 在loadView阶段（内存加载阶段），先是把自己本身都加到superView上面，再去寻找自己的subView并依次添加。到此为止，只和addSubview操作有关，和是否显示无关。等到所有的subView都在内存层面加载完成了，会调用一次viewWillAppear，然后会把加载好的一层层view，分别绘制到window上面。然后layoutSubview，DrawRect，加载即完成。
 
 2.UIView生命周期移除阶段。
 会先依次移除本view的moveToWindow，然后依次移除所有子视图，掉他们的moveToWindow，view就在window上消失不见了，然后在removeFromSuperView，然后dealloc，dealloc之后再removeSubview。（但不理解为什么dealloc之后再removeSubview）
 
 3.如果没有子视图，则不会接收到didAddSubview和willRemoveSubview消息。
 
 4.和superView，window相关的方法，可以通过参数（superView/window）或者self.superView/self.window,判断是创建还是销毁，如果指针不为空，是创建，如果为空，就是销毁。这四个方法，在整个view的生命周期中，都会被调用2次，一共是8次。
 
 5.removeFromSuperview和dealloc在view的生命周期中，调且只调用一次，可以用来removeObserver，移除计时器等操作。（layoutSubview可能会因为子视图的调整，多次调用)
 
 6.UIView是在被加到自己的父视图上之后，才开始会寻找添加自己的子视图（数据层面的添加，并不是加到window上面）。UIView是在调用dealloc中，移除自己的子视图，所有子视图移除并销毁内存之后，才会销毁自己的内存，dealloc完成。
 
 */

/// 直播间刷礼物弹出的消息视图。
open class GiftView: UIView {
    /// 计时器完成的事件处理，通过此函数执行将本视图移除的相关操作。
    var completeHandle: ((GiftView)->Void)?
    
    /// 默认倒计时时长，该时长决定触发 completeHandle 前的等待时间。该属性默认值为 3.
    var defaultWaitTime = 3
    /// 实际倒计时时长。
    private var waitTime = 5
    
    /// 计时器对象。
    private var countdownTimer: Timer?
    /// 是否开始计时，默认否。
    private var isCounting = false {
        willSet {
            guard newValue != isCounting else { return }
            if newValue {
                waitTime = defaultWaitTime
                // 初始化计时器对象，每隔1秒执行一次。
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
        // 说明被移除。
        if window == nil {
            removeFromSuperview()
        } else {
            isCounting = true
        }
    }
    
    /// 发生暴击事件（显示相同的已存在礼物视图）时重置 waitTime.
    final func criticalStrike() { waitTime = defaultWaitTime }
    
    /// 结束倒计时，并将计时器设为无效。
    private func endCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    deinit { Judy.logHappy("GiftView 释放。") }
}
