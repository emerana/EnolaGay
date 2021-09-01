//
//  FuckerView.swift
//  JudySail
//
//  Created by 醉翁之意 on 2018/6/17.
//  Copyright © 2018年 醉翁之意.王仁洁. All rights reserved.
//

import UIKit
import SwiftMessages
import YYImage
import EnolaGay

class FuckerView: MessageView {

    /// 图片名
    var imageName: String = "Fuck_Can'tUse" {
        didSet{
            imageView.image = YYImage(named: imageName)
        }
    }

    @IBOutlet private weak var imageView: YYAnimatedImageView!

    @IBOutlet weak var scrollTitle: MarqueeView!
    
}
