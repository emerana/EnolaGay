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
        
        let attrs1 = NSMutableAttributedString(text: "只要￥9.9还包邮！", textFont: UIFont(style: .M))
        
        label1?.attributedText = attrs1
        
        let attrs2 = NSMutableAttributedString(text: "只要￥9.9还包邮！", textFont: UIFont(style: .M), highlightText: "￥", highlightTextColor: .red)
        
        label2?.attributedText = attrs2
        
        let attrs3 = NSMutableAttributedString(text: "只要￥9.9还包邮！", textColor: .green, textFont: UIFont(style: .M), highlightText: "￥", highlightTextColor: .red, highlightTextFont: UIFont(style: .xxxl_B))
        
        label3?.attributedText = attrs3

    }
    
    /// UILabel judy_setHighlighted 测试。
    func judy_setHighlightedTest() {
        let labelTest = "￥9.9"
        label1.text = labelTest
        label2.text = labelTest
        label3.text = labelTest

        label1.judy_setHighlighted(text: "￥", color: .red)
        label2.judy_setHighlighted(text: "￥", color: .red, font: UIFont(style: .S_B))
        label3.judy_setHighlighted(text: "￥", color: .red)

    }
    
    func bljudy_setHighlightedTest() {
        let labelTest = "￥9.9"
        label1.text = labelTest

        

        let attrs = NSMutableAttributedString(text: labelTest, highlightText: "￥", highlightTextFont: UIFont(style: .S_B))
//            judy_setHighlighted(text: "￥", font: UIFont(style: .S_B))
        
        label1.attributedText = attrs
//        for _ in 0...100 {
//            label1.judy_setHighlighted(text: "￥", font: UIFont(style: .S_B))
//        }
        
    }


    func judy_mutableAttributedStringInitTest() {
        let labelTest = "￥9.9"
        
        label1.attributedText = NSMutableAttributedString(text: labelTest, highlightText: "￥", highlightTextFont: UIFont(style: .S_B))

        label2.attributedText = NSMutableAttributedString(text: labelTest, highlightText: "￥", highlightTextColor: .red, highlightTextFont: UIFont(style: .S_B))
        
        label3.attributedText = NSMutableAttributedString(text: labelTest, textColor: .blue, highlightText: "￥", highlightTextFont: UIFont(style: .S_B))
        
        label4.attributedText = NSMutableAttributedString(text: labelTest, textColor: .blue, textFont: UIFont(style: .Nx1), highlightText: "￥", highlightTextFont: UIFont(style: .S_B))

        label5.attributedText = NSMutableAttributedString(text: labelTest, textColor: .blue, textFont: UIFont(style: .Nx1), highlightText: "￥", highlightTextColor: .red, highlightTextFont: UIFont(style: .S_B))
    }

}
