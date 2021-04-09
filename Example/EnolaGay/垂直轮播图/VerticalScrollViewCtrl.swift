
//
//  VerticalScrollViewCtrl.swift
//  PinHaha
//
//  Created by 醉翁之意 on 2020/7/7.
//  Copyright © 2020 推易网红电商学院. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON


class VerticalScrollViewCtrl: UIViewController {
    

    // MARK: - let property and IBOutlet

    @IBOutlet weak var verticalScrollView: JudyVerticalScrollView!
    
    // MARK: - public var property
    

    // MARK: - private var property
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    // MARK: - override
    deinit {
        print("已经完全释放")
    }

}



/// 垂直广告轮播图（自动滚动）
public class JudyVerticalScrollView: UIView {
        
    /// 数据源
    var dataSource = ["String", "String", "String",]
    
    /// 用于展示内容的两个 View
    private let views = [UIView(), UIView()]
    
    /// 计时器
    private var timer: Timer?
    /// 当前展示的索引，一般用于数据源中
    private var index: Int = 0
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        // 将两个内容 View 设置好 frame 并显示出来
        views.enumerated().forEach { (index, view) in
            view.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(index)*frame.size.height), size: frame.size)
            if index == 0 {
                view.backgroundColor = .red
                // TODO: 设置初始页内容
                
            } else {
                view.backgroundColor = .green
            }
            addSubview(view)
        }
        
        clipsToBounds = true
        // 启动计时器
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateViews(timer:)), userInfo: nil, repeats: true)

    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        // 如果新的父视图为 nil 说明被移除了，此时需要释放 timer
        if newSuperview == nil { timer?.invalidate() }
    }
    
    
    /// 逐秒递减
    ///
    /// - Parameter timer: timer
    @objc private func updateViews(timer: Timer) {
        // 对应的索引
        index += 1
        index = index >= dataSource.count ? 0:index
        
        UIView.animate(withDuration: 1, animations: { [weak self] in
            // 移动所有内容 View
            self?.views.forEach { view in
                view.frame.origin.y -= self!.frame.height
            }
            
        }) { [weak self] (isFinish) in

            self?.views.forEach { view in
                if view.frame.origin.y == -self!.frame.height {
                    // TODO: 为即将要出现的View设置位置及内容
                    view.frame.origin.y = self!.frame.height
                }
            }
            
        }
    }
        
    deinit { Judy.log("JudyVerticalScrollView 已释放") }

}
