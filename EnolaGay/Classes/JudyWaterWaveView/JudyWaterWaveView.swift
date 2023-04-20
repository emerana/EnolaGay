//
//  JudyWaterWaveView.swift
//  WaterWave
//
//  Created by 王仁洁 on 2018/9/20.
//  Copyright © 2018年 EMERANA. All rights reserved.
//

import UIKit


/// 波浪动画 View
@IBDesignable open class JudyWaterWaveView: UIView {
    
    /** 进度，已用容量百分比。默认为 60% */
    @IBInspectable public var 进度: CGFloat = 0.6
    /** 曲线(波浪)振幅 */
    @IBInspectable public var 振幅: CGFloat = 6
    /** 是否为正圆，如果该 View 长宽不等则不会设置正圆。默认为 true */
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
        
//        #colorLiteral(red: 0.9019607843, green: 0, blue: 0.07058823529, alpha: 1)
        backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.68)
        // 设定两条波浪的颜色
        底层Layer.fillColor = 底层波浪颜色.cgColor
        底层Layer.strokeColor = 底层波浪颜色.cgColor
        顶层Layer.fillColor = 顶层波浪颜色.cgColor
        顶层Layer.strokeColor = 顶层波浪颜色.cgColor
        
        //初始化波浪
        layer.addSublayer(底层Layer)
        layer.addSublayer(顶层Layer)
        
        // 角速度
        /*
         决定波的宽度和周期，比如，我们可以看到上面的例子中是一个周期的波曲线，
         一个波峰、一个波谷，如果我们想在0到2π这个距离显示2个完整的波曲线，那么周期就是π
         ω常量wavePalstance计算如下 可以根据自己的需求计算
         */
        wavePalstance = CGFloat(Double.pi/Double(bounds.width))
        //偏距
        waveY = bounds.height
        //x轴移动速度
        速度 = wavePalstance * 2
        
        //以屏幕刷新速度为周期刷新曲线的位置
        disPlayLink = CADisplayLink.init(target: self, selector: #selector(waveAnimation(link:)))
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
    
    /// 开始动画
    func star() {
        disPlayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    /// 暂停动画
    func paused() {
        disPlayLink.isPaused = true
    }

    /// 继续动画
    func `continue`() {
        disPlayLink.isPaused = false
    }

    /// 停止动画
    func stop() {
        disPlayLink.invalidate()
    }
    
}

// MARK: 私有函数

private extension JudyWaterWaveView {
    
    @objc func waveAnimation(link: CADisplayLink){
        waveX += 速度
        
        updateWaveY() // 更新波浪的高度位置
        startWaveAnimation() // 波浪轨迹和动画
    }
    
    // 更新偏距的大小 直到达到目标偏距 让 wave 有一个匀速增长的效果
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
