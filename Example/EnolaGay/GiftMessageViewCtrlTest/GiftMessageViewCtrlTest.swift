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
    
    // override var viewTitle: String? { "送礼测试" }
    
    /// 送礼物弹窗消息 View。
    @IBOutlet weak var giftMessageViews: UIView!
    private let giftMessageViewCtrl = GiftMessageViewCtrl()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        giftMessageViewCtrl.containerView = giftMessageViews
    }
    
    
    /// 发送一个礼物事件。
    @IBAction private func sendGiftAction(_ sender: Any) {

        DispatchQueue.main.async {
            let view = GiftView()
            self.giftMessageViewCtrl.profferGiftMessageView(giftView: view) { (giftView) -> (Bool) in
                return false
            }
        }

    }

}
