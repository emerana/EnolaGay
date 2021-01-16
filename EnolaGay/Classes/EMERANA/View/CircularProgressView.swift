//
//  MyCircle.swift
//  JingMaiWang
//
//  Created by 王仁洁 on 2021/1/12.
//  Copyright © 2021 鲸世科技. All rights reserved.
//


import UIKit


/// 圆形进度条
///
/// 支持自定义相关属性的圆形进度条
/// - version: 1.0
/// - since: 2021年01月12日15:05:46
/// - warning: 仅限在 StoryBoard 中使用
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
        // Drawing code
        
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
        
        // 旋转 View, 将开始点设置在顶部，即（3/2）π 处，必须以重新赋值的方式设置
        var transform = self.transform
        transform = transform.rotated(by: -CGFloat(Double.pi/2)) // 逆时针旋转90°
        self.transform = transform
        
        lineLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size)
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor.purple.cgColor
        lineLayer.lineWidth  = CGFloat(lineWith)
        
        // 用于画圆的贝塞尔曲线(矢量路径)
        let circleBezierPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y: 0), size: frame.size))

        lineLayer.path = circleBezierPath.cgPath
        layer.addSublayer(lineLayer)
        // 设置
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
    
    
    // } private extension MyScaleCircle {
    
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
