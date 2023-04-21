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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        rotateText()
        wateerView.star()

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
//        textView.layer.duration = rotationAnim.duration
        // imageView.layer.animation(forKey: "Judy")?.repeatDuration = CFTimeInterval((sender as! UISlider).value)
//        CABasicAnimation
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension JudyWaterWaveViewController {
    
    func rotateText() {
//        // 1. 创建动画
//        let rotationAnim = CABasicAnimation(keyPath: EMERANA.Key.keypath.rotation)
        
        // 2. 设置动画属性
        rotationAnim.fromValue = 0 // 开始角度
        rotationAnim.toValue = Double.pi * 2 // 结束角度
        rotationAnim.repeatCount = MAXFLOAT // 重复次数,无限次

        rotationAnim.duration = 6 // 转一圈所需要的时间
        rotationAnim.isRemovedOnCompletion = false // 默认是true，切换到其他控制器再回来，动画效果会消失，需要设置成false，动画就不会停了
        // 还原动画
        // imageView.transform = .identity//CGAffineTransformIdentity

        imageView.layer.add(rotationAnim, forKey: "Judy") // 给需要旋转的 view 增加动画
    }
}
