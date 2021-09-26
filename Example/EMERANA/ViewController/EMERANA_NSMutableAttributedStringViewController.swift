//
//  EMERANA_NSMutableAttributedStringViewController.swift
//  emerana
//
//  Created by 王仁洁 on 2020/10/30.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

class EMERANA_NSMutableAttributedStringViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        label1.judy.setHighlighted(text: "text", color: .red)
        let attri = NSMutableAttributedString(text: "大家好", textColor: .blue, highlightText: "大")
        attri.addAttribute(.font, value: UIFont(size: 16), range: attri.mutableString.range(of: "大"))
        label3.attributedText = attri
    }
    
}
