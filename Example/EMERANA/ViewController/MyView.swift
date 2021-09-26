//
//  MyView.swift
//  emerana
//
//  Created by 王仁洁 on 2019/12/3.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

class MyView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //当前绘制区域（上下文）
        let context = UIGraphicsGetCurrentContext()
        //开启一个新路径，放弃旧路径
        context?.beginPath();
        //设置线条粗细
        context?.setLineWidth(1.0);
        
        //设置描边颜色
        let strokeColor = UIColor.red
        context?.setStrokeColor(strokeColor.cgColor)
        //设置起始点
        context?.move(to: CGPoint(x: 28, y: 28))
        context?.addLine(to: CGPoint(x: 28, y: 60))
        context?.addLine(to: CGPoint(x: 60, y: 60))
        //路径描边
        context?.strokePath()
    }

}
