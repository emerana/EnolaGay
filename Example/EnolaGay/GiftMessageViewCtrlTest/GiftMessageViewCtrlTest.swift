//
//  GiftMessageViewCtrlTest.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/5/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

class GiftMessageViewCtrlTest: JudyBaseViewCtrl {
    
     override var viewTitle: String? { "送礼测试" }
    
    /// 送礼物弹窗消息 View。
    @IBOutlet weak var giftMessageViews: UIView!
    private let giftMessageViewCtrl = GiftMessageViewCtrl()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        giftMessageViewCtrl.containerView = giftMessageViews
        giftMessageViewCtrl.critConditionsClosure = { (oldGiftView, showGiftView) in
            return false
        }
        var index = 1
        giftMessageViewCtrl.criticalStrikeAction = { gifView in
            index += 1
            let label = gifView.viewWithTag(1101) as! UILabel
            label.text = "值为：\(index)"
        }
    }
    
    /// 发送一个礼物事件。
    @IBAction private func sendGiftAction(_ sender: Any) {
        let view = GiftView()
        view.frame = .zero
        view.frame.size = CGSize(width: 188, height: 88)
        let label = UILabel()
        label.tag = 1101
        label.frame.size = CGSize(width: 100, height: 58)
        label.text = "1"
        label.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(label)
        label.center = view.center
        view.backgroundColor = .red
        giftMessageViewCtrl.profferGiftMessageView(giftView: view)
    }

}
