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

