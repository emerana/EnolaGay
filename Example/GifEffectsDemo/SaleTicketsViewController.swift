//
//  SaleTicketsViewController.swift
//  GifEffectsDemo
//
//  Created by 醉翁之意 on 2023/3/20.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

/// 模拟多线程卖火车票场景
class SaleTicketsViewController: UIViewController {

    @IBOutlet weak private var likeButton: UIButton!

    /// 爱心动画计时器。
    private var animateTimer: Timer?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 恢复计时器
        animateTimer?.fireDate = Date()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 暂停计时器
        animateTimer?.fireDate = Date.distantFuture
    }

    deinit {
        animateTimer?.invalidate()
        animateTimer = nil
    }

    /// 开始购买事件
    @IBAction private func startAction(_ sender: Any) {
        startAnimateTimer()
    }
    
    // 烟花爆炸效果
    @IBAction private func emitAction(_ sender: Any) {
        emitFireworks(launcher: sender as! UIView)
    }

}

private extension SaleTicketsViewController {
    
    /// 启动爱心飘动的动画
    func startAnimateTimer() {
        let imageNames = ["icon_点赞1", "icon_点赞2", "icon_点赞3", "icon_点赞4", "icon_点赞5", ]
        let judyPopBubble = JudyPopBubble(inView: view, belowSubview: likeButton)
        judyPopBubble.bubble_animate_dissmiss = 5
        judyPopBubble.bubble_animate_windUp = 6
        judyPopBubble.bubble_animate_height = view.frame.height - 68
        
        /// 计时器两次触发之间的秒数。如果 interval 小于或等于0.0，则该方法选择 0.0001 秒的非负值。
        let interval = Double(1+arc4random_uniform(3))/10
        // 创建计时器，并以默认模式在当前运行循环中调度它。
        animateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            // 随机挑选一张图片
            if let image = UIImage(named: imageNames[NSInteger(arc4random_uniform( UInt32((imageNames.count)) ))]) {
                judyPopBubble.popBubble(image)
            }
        }
    }
    
    /// 发射一朵烟花
    /// - Parameter launcher: 发射台。此 View 表示烟花从哪个位置发射的。
    func emitFireworks(launcher: UIView) {
        let blingImageView = UIImageView(image: UIImage(named: "button_喜欢"))
        blingImageView.frame.size = CGSize(width: 18, height: 18)
        // 设置烟花的起始中心位置为发射台的中心位置。
        // 转换规则为发射台的父 View 将发射台的位置转换成指定 View 上的坐标。
        blingImageView.center = launcher.superview!.convert(launcher.center, to: view)
        view.addSubview(blingImageView)
        
        // 发射并爆炸
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { [weak self] in
            guard let `self` = self else { return }
            // 用动画的方式移动烟花的位置，位置为屏幕中的随机点
            blingImageView.center = CGPoint(
                x: CGFloat(arc4random_uniform(UInt32(self.view.bounds.width))),
                y: CGFloat(arc4random_uniform(UInt32(self.view.bounds.height)))
            )
        }) { _ in
            // 执行烟花爆炸，并在爆炸效果完成后从父视图中移除。
            blingImageView.judy.blingBling {
                blingImageView.removeFromSuperview()
            }
        }
    }
}
