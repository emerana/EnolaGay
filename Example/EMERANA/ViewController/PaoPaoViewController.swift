//
//  PaoPaoViewController.swift
//  emerana
//
//  Created by 王仁洁 on 2020/11/12.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 泡泡测试
class PaoPaoViewController: UIViewController {

    @IBOutlet weak var emitBtn: EmitterButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emitBtn.blingImage = #imageLiteral(resourceName: "ping-pong-racket-1")
//        emitBtn.emit(count: 10)
//        emitBtn.addTarget(self, action: #selector(EmitterButton.emitterAction), for: .touchUpInside)
        
    }
    
    
    // 按钮点击事件
    @IBAction private func buttonAction(_ sender: Any) {
        //        (sender as? UIView)?.judy_blingBling()
        //        return
        // 设置发射出去的 View
        let blingImageView = UIImageView(image: UIImage(named: "paopao1"))
        blingImageView.frame.size = CGSize(width: 18, height: 18)
        blingImageView.center = (sender as! UIView).center
        view.addSubview(blingImageView)
        
        // 发射
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            // blingImageView.center = self.view.center
            blingImageView.center = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.view.bounds.width-128))+88), y: CGFloat(arc4random_uniform(UInt32(self.view.bounds.height-220))+88))
            
        }) { _ in
            // 烟花爆炸
            // (sender as? UIView)?.judy_blingBling()
            blingImageView.judy.blingBling {
                blingImageView.removeFromSuperview()
            }
            
        }
    }
    
}



extension UIImage {
    
    /// 剪辑图像
    /// - Returns: 目标图像
    func clips() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        path.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let clipsImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return clipsImage
    }
    
}

class EmitterButton: UIButton {

    /// 发射过程的图片
    var blingImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        addTarget(self, action: #selector(EmitterButton.emitterAction), for: .touchUpInside)
    }
  
    // MARK: - Events
    
    /// 发射事件
    @objc fileprivate func emitterAction() {
        
        let blingImage = self.blingImage?.clips() ?? (imageView?.image?.clips() ?? #imageLiteral(resourceName: "paopao0"))
        let blingImageView = UIImageView(image: blingImage)
        blingImageView.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        blingImageView.center = CGPoint(x: bounds.width/2, y: 0)
        addSubview(blingImageView)
        
        let upDuration = 0.2 // 向上发射的过程所需时长
        UIView.animate(withDuration: upDuration, delay: 0, options: .curveLinear, animations: {
            blingImageView.center = CGPoint(x: self.bounds.width/2+CGFloat(arc4random_uniform(80))-40, y: self.bounds.size.height/2-120)
        }) { _ in
            UIView.animate(withDuration: upDuration, delay: 0, options: .curveLinear, animations: {
                self.blingBling(blingImageView)
            }, completion: { (finished) in
                blingImageView.removeFromSuperview()
                self.bubbleAnimation(start: CGPoint(x: blingImageView.center.x, y: blingImageView.center.y), isAuto: false)
            })
        }
    }
    
    
    
    // MARK: - Animations
    
    /// blingbling 发光动画
    ///
    /// - Parameter view: 发光的view
    fileprivate func blingBling(_ view: UIView) {
        // 放大倍数
        view.transform = CGAffineTransform(scaleX: 2, y: 2)
        let anim = CABasicAnimation(keyPath: "strokeStart")
        anim.fromValue = 0.5
        anim.toValue = 1
        anim.beginTime = CACurrentMediaTime()
        anim.repeatCount = 1    // 执行次数
        anim.duration = 0.2
        anim.fillMode = .forwards
//        anim.isRemovedOnCompletion = true
        
        let count = 12 // 发光粒子数量
        let spacing: Double = Double(view.bounds.width) + 5 // 发光粒子与 view 间距
        for i in 0..<count {
            let path = CGMutablePath()
            /*
             x1=x+s·cosθ
             y1=y+s·sinθ
             */
            path.move(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
            path.addLine(to: CGPoint(
                            x: Double(view.bounds.midX)+spacing*cos(2*Double.pi*Double(i)/Double(count)),
                            y: Double(view.bounds.midY)+spacing*sin(2*Double.pi*Double(i)/Double(count))
            ))
            
            let trackLayer = CAShapeLayer()
            trackLayer.strokeColor = UIColor.orange.cgColor
            trackLayer.lineWidth = 1
            trackLayer.path = path
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.strokeStart = 1
            view.layer.addSublayer(trackLayer)
            trackLayer.add(anim, forKey: nil)
        }
    }
    
    
    /// 上升动画
    ///
    /// - Parameters:
    ///   - start: 起点
    ///   - isAuto:
    fileprivate func bubbleAnimation(start: CGPoint, isAuto: Bool) {
        let path = UIBezierPath()
        path.move(to: start)
        let endPointX: CGFloat = bounds.width/2+CGFloat(arc4random_uniform(80))-40
        let endPointY: CGFloat = -400
        let endPoint = CGPoint(x: endPointX, y: endPointY)
        
        if isAuto {
            path.addCurve(to: endPoint, controlPoint1: CGPoint(x: CGFloat(arc4random_uniform(80))-40, y: endPointY/3.0), controlPoint2: CGPoint(x: 0, y: endPointY*2/3.0))
        } else {
            path.addCurve(to: endPoint, controlPoint1: CGPoint(x: start.x, y: endPointY/3.0), controlPoint2: CGPoint(x: 0, y: endPointY*2/3.0))
        }
        
        let bubble = UIImageView(image: UIImage(named: "paopao\(arc4random_uniform(3))"))
        bubble.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        if isAuto {
            bubble.bounds = CGRect(x: 0, y: 0, width: 5, height: 5)
            
            UIView.animate(withDuration: 0.1, animations: {
                bubble.transform = CGAffineTransform(scaleX: 6, y: 6)
            }) { _ in }
        }
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.cgPath
        anim.duration = 2
        anim.repeatCount = 1
        anim.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)]
        anim.isRemovedOnCompletion = true
        bubble.layer.add(anim, forKey: nil)
        layer.addSublayer(bubble.layer)
        
        UIView.animate(withDuration: 1, delay: 1, options: UIView.AnimationOptions.curveLinear, animations: {
            bubble.alpha = 0
        }) { (finished) in
            if finished {
                bubble.removeFromSuperview()
            }
        }
    }
}


// MARK: - Public
extension EmitterButton {
    
    /// 立即发射泡泡。Emit bubbles immediately
    ///
    /// - Parameter count: 泡泡的数量，count of bubbles
    func emit(count: Int) {
        guard count > 0 else { return }
        
        var bubbleCount = count
        // 速度调整
        let interval = Double(arc4random_uniform(3)+1)/15
        
        // 创建计时器，并以默认模式在当前运行循环中调度它。
        Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { timer  in
            self.bubbleAnimation(start: CGPoint(x: self.bounds.width/2, y: 0), isAuto: true)
            bubbleCount = bubbleCount - 1
            if bubbleCount == 0 { timer.invalidate() }
        }
    }
}
