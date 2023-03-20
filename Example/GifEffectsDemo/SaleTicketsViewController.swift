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

    /// 爱心烟花动画计时器。
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
        setAnimateTimer()
    }
    
    // 点赞的烟花爆炸效果
    @IBAction private func emitAction(_ sender: Any) {
        let blingImageView = UIImageView(image: UIImage(named: "button_喜欢"))
        blingImageView.frame.size = CGSize(width: 18, height: 18)
        blingImageView.center = (sender as! UIView).superview!.convert((sender as! UIView).center, to: view)
        view.addSubview(blingImageView)
        
        // 发射
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            blingImageView.center = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.view.bounds.width-128))+88), y: CGFloat(arc4random_uniform(UInt32(self.view.bounds.height-220))+88))
        }) { _ in
            // 烟花爆炸
            blingImageView.judy.blingBling {
                blingImageView.removeFromSuperview()
            }
        }
    }

}

private extension SaleTicketsViewController {
    
    /// 设置烟花动画
    func setAnimateTimer() {
        let imageNames = ["icon_点赞1", "icon_点赞2", "icon_点赞3", "icon_点赞4", "icon_点赞5", ]
        let interval = Double(arc4random_uniform(3)+1)/10
        let judyPopBubble = JudyPopBubble()
        // 创建计时器，并以默认模式在当前运行循环中调度它。
        animateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            if let strongSelf = self {
                let image = UIImage(named: imageNames[NSInteger(arc4random_uniform( UInt32((imageNames.count)) ))])
                judyPopBubble.judy_popBubble(withImage: image, inView: strongSelf.view, belowSubview: strongSelf.likeButton)
            }
        }
    }
}
