//
//  GiftMessageViewCtrlTest.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/5/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 送礼物控制面板
class GiftMessageViewCtrlTest: UIViewController {
        
    @IBOutlet weak var giftMessageViewPanel: GiftMessageCtrlPanel!

    override func viewDidLoad() {
        super.viewDidLoad()

        giftMessageViewPanel.critConditionsClosure = { (oldGiftView, showGiftView) in
            return true
        }
        
        var index = 1
        giftMessageViewPanel.criticalStrikeAction = { gifView in
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
        
        giftMessageViewPanel.profferGiftMessageView(giftView: view)
    }

}



/// 信号量崩溃测试。
class CrashTestViewCtrl: UIViewController {

    private var semaphore = DispatchSemaphore(value: 2)

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().async { [weak self] in
            sleep(6)
            // do something ......
            self?.semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    deinit {
        print("释放")
    }
}
