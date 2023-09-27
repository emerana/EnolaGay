//
//  CircularProgressViewController.swift
//  Demo
//
//  Created by 醉翁之意 on 2023/3/20.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

class CircularProgressViewController: UIViewController {
    /// 圆形进度条
    @IBOutlet weak private var progressLiveView: CircularProgressLiveView!
    /// 录制按钮
    @IBOutlet weak private var recorderButton: UIButton!
    /// 录制状态信息 label.
    @IBOutlet weak private var recorderStateLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        progressLiveView.unfillColor = .red
        // progressLiveView.lineLayer.strokeColor = UIColor.red.cgColor
        // progressLiveView.lineLayer.strokeEnd = 0.68
    }
    
    
    // touch Cancel
    @IBAction private func touchCancelAction(_ sender: Any) {
        log("取消？")
    }

    // touch Down
    // 手指碰到按钮即响应
    @IBAction private func touchDownAction(_ sender: Any) {
        log("手指碰到按钮了")
    }

    // touch Down Repeat
    @IBAction private func touchDownRepeatAction(_ sender: Any) {
        log(" 按钮重复点击")
    }

    // touch Drag Enter
    @IBAction private func touchDragEnterAction(_ sender: Any) {
        log("手指在按钮之外又回来了")
    }
    
    // 松开或手指滑到按钮之外即响应。
    @IBAction private func touchDragExitAction(_ sender: Any) {
        logHappy("手指移动到按钮之外")
    }

    // touch Drag Inside
    @IBAction private func touchDragInsideAction(_ sender: Any) {
        logWarning("手指在按钮里面移动……")
    }

    // touch Drag Outside
    @IBAction private func touchDragOutsideAction(_ sender: Any) {
        logWarning("手指在按钮之外移动……")
    }

    // touch Up Inside
    // 手指按压按钮并再按钮内部离开按钮即响应。
    @IBAction private func touchUpInsideAction(_ sender: Any) {
        logHappy("手指从按钮内部离开")
    }

    // touch Up Outside
    // 手指按压按钮并移动到按钮外部再离开按钮即响应。
    @IBAction private func touchUpOutsideAction(_ sender: Any) {
        logHappy("手指从按钮外部离开")
    }

}
