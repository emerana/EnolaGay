//
//  AttributedStringViewController.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/3/27.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class AttributedStringViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        bljudy_setHighlightedTest()
    }
}

private extension AttributedStringViewController {

    /// NSMutableAttributedString 初始化函数测试。
    func mutableAttributedStringInitTest() {
        let attrs1 = NSMutableAttributedString(text: "只要￥9.9还包邮！", textFont: UIFont(size: 16))
        label1?.attributedText = attrs1
        let attrs2 = NSMutableAttributedString(text: "只要￥9.9还包邮！", textFont: UIFont(size: 16), highlightText: "￥", highlightTextColor: .red)
        label2?.attributedText = attrs2
        let attrs3 = NSMutableAttributedString(text: "只要￥9.9还包邮！", textColor: .green, textFont: UIFont(size: 16), highlightText: "￥", highlightTextColor: .red, highlightTextFont: UIFont(size: 16))
        
        label3?.attributedText = attrs3
    }
    
    /// UILabel judy_setHighlighted 测试。
    func judy_setHighlightedTest() {
        let labelTest = "￥9.9"
        label1.text = labelTest
        label2.text = labelTest
        label3.text = labelTest

        label1.judy.setHighlighted(text: "￥", color: .red)
        label2.judy.setHighlighted(text: "￥", color: .red, font: UIFont(size: 16))
        label3.judy.setHighlighted(text: "￥", color: .red)

    }
    
    func bljudy_setHighlightedTest() {
        let labelTest = "￥9.9"
        label1.text = labelTest

        let attrs = NSMutableAttributedString(text: labelTest, highlightText: "￥", highlightTextColor: .red)
//            judy_setHighlighted(text: "￥", font: UIFont(style: .S_B))
        
        label1.attributedText = attrs
//        for _ in 0...100 {
//            label1.judy_setHighlighted(text: "￥", font: UIFont(style: .S_B))
//        }
    }

    func judy_mutableAttributedStringInitTest() {
        let labelTest = "￥9.9"
        
        label1.attributedText = NSMutableAttributedString(text: labelTest, highlightText: "￥", highlightTextFont: UIFont(size: 16))

        label2.attributedText = NSMutableAttributedString(text: labelTest, highlightText: "￥", highlightTextColor: .red, highlightTextFont: UIFont(size: 16))
        
        label3.attributedText = NSMutableAttributedString(text: labelTest, textColor: .blue, highlightText: "￥", highlightTextFont: UIFont(size: 16))
        
        label4.attributedText = NSMutableAttributedString(text: labelTest, textColor: .blue, textFont: UIFont(size: 16), highlightText: "￥", highlightTextFont: UIFont(size: 16))

        label5.attributedText = NSMutableAttributedString(text: labelTest, textColor: .blue, textFont: UIFont(size: 16), highlightText: "￥", highlightTextColor: .red, highlightTextFont: UIFont(size: 16))
    }
}
