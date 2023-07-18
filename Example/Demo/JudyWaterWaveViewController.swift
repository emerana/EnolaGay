//
//  JudyWaterWaveViewController.swift
//  Demo
//
//  Created by 醉翁之意 on 2023/4/20.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

/// 水波纹动画
class JudyWaterWaveViewController: UIViewController {
    
    @IBOutlet weak var wateerView: JudyWaterWaveView!
    
    /// 太极图
    @IBOutlet weak private var imageView: UIImageView!
    
    // 1. 创建动画
    private let rotationAnim = CABasicAnimation(keyPath: EMERANA.Key.keypath.rotation)

    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rotateText()
        wateerView.star()
        
        let imageView1 = UIImageView(image: UIImage(named: "icon_点赞1"))
        let imageView2 = UIImageView(image: UIImage(named: "icon_点赞2"))
        let imageView3 = UIImageView(image: UIImage(named: "icon_点赞3"))
        let imageView4 = UIImageView(image: UIImage(named: "icon_点赞4"))
        let imageView5 = UIImageView(image: UIImage(named: "icon_点赞5"))
        stackView.addArrangedSubview(imageView1)
        stackView.addArrangedSubview(imageView2)
        stackView.addArrangedSubview(imageView3)
        stackView.addArrangedSubview(imageView4)
        stackView.addArrangedSubview(imageView5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        wateerView.continue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        wateerView.paused()
    }
    
    deinit {
        wateerView.stop()
    }
    
    @IBAction private func speedChanged(_ sender: Any) {
        let value = CFTimeInterval((sender as! UISlider).value)
        
        // 更新转速，即转一圈所需要的时间
        rotationAnim.duration = 1/value
        imageView.layer.add(rotationAnim, forKey: EMERANA.Key.keypath.rotation) // 给需要旋转的 view 增加动画
        
    }
    
    /// 转速变更事件
    @IBAction func rpmChanged(_ sender: Any) {
        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 1:
            rotationAnim.duration = 1/60
        case 2:
            rotationAnim.duration = 1/90
        case 3:
            rotationAnim.duration = 1/120
        default:
            rotationAnim.duration = 10
        }
        imageView.layer.add(rotationAnim, forKey: EMERANA.Key.keypath.rotation)
    }
    
    // 开关事件
    @IBAction private func switchAction(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            imageView.layer.resumeAnimation()

        } else {
            imageView.layer.pauseAnimation()
        }
        
    }
    
}

private extension JudyWaterWaveViewController {
    
    func rotateText() {
        // 1. 创建动画
        // let rotationAnim = CABasicAnimation(keyPath: EMERANA.Key.keypath.rotation)
        
        // 2. 设置动画属性
        rotationAnim.fromValue = 0 // 开始角度
        rotationAnim.toValue = Double.pi * 2 // 结束角度

        // 将这个属性设置为 greatestFiniteMagnitude 会导致动画一直重复下去
        rotationAnim.repeatCount = .greatestFiniteMagnitude
        
        // 一个可选的定时函数，定义动画的节奏
        // rotationAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)

        rotationAnim.duration = 6 // 转一圈所需要的时间
        // 默认是true，切换到其他控制器再回来，动画效果会消失，需要设置成false，动画就不会停了
        rotationAnim.isRemovedOnCompletion = false
        
        rotationAnim.delegate = self
        // 还原动画
        // imageView.transform = .identity
        // imageView.transform = CGAffineTransform.identity
        imageView.layer.add(rotationAnim, forKey: EMERANA.Key.keypath.rotation) // 给需要旋转的 view 增加动画
    }
    
}

extension JudyWaterWaveViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        log("动画开始")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        log("动画停止: finished - \(flag)")
    }
    
}

// MARK: - 直接给 Layer 添加一个分类 外界可以通过 layer 很方便的调用对应的方法
extension CALayer {

    /// 暂停动画
    func pauseAnimation() {
        let pauseTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pauseTime
    }
    
    /// 从暂停中恢复动画
    func resumeAnimation() {
        // 1.取出时间
        let pauseTime = timeOffset
        // 2.设置动画的属性
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        // 3.设置开始动画
        let startTime = convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        beginTime = startTime
    }
    
}
