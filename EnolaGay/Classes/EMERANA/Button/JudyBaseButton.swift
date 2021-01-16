//
//  JudyBaseButton.swift
//  Chain
//
//  Created by 艾美拉娜 on 2018/10/12.
//  Copyright © 2018 杭州拓垦网络科技. All rights reserved.
//

import UIKit

/// EMERANA框架中所用到的Button，默认 FontStyle 为均码。
@IBDesignable open class JudyBaseButton: UIButton, EMERANA_FontStyle {

    /// 图像方位
    private enum ImageDirection: Int {
        case left = 0
        case up = 1
        case right = 2
        case down = 3
    }
    

    /// 图像所在方位，默认0，对应 enum ImageDirection, left = 0, up = 1, right = 2, down = 3
    @IBInspectable private(set) var imageDirection: Int = 0

    // MARK: - EMERANA 字体
    
    @IBInspectable private(set) public var initFontStyle: Int = 0

    public var fontStyle: UIFont.FontStyle = .M {
        didSet{
            titleLabel?.font = UIFont(style: fontStyle)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.font = UIFont(style: UIFont.FontStyle.new(rawValue: initFontStyle))
        
        guard let tempImageDirection = JudyBaseButton.ImageDirection(rawValue: imageDirection) else {
            return
        }
        switch tempImageDirection {
        case .up:
            setImageTop(spacing: 8)
        case .right:
            setImageRight()
        default:break
        }
    
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

    }
    
}

// MARK: - 显示的效果
public extension UIButton {
    /*
     常用的keypath值：

     transform.scale = 大小比例
     transform.scale.x = 宽的比例转换
     transform.scale.y = 高的比例转换
     transform.rotation.z = 平面的旋转
     opacity = 透明度
     margin = 布局
     zPosition = 翻转
     backgroundColor = 背景颜色
     cornerRadius = 圆角
     borderWidth = 边框宽
     bounds = 大小
     contents = 内容
     contentsRect = 内容大小
     cornerRadius = 圆角
     frame = 大小位置
     hidden = 显示隐藏
     mask
     masksToBounds
     opacity
     position
     shadowColor
     shadowOffset
     shadowOpacity
     shadowRadius
     
     */
    
    /// 以动画的方式显示该按钮
    func show() {

        guard isHidden == true else { return }
        
        isHidden = false
        // 大小比例
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 5
        scaleAnimation.toValue = 1
        scaleAnimation.duration = 0.3
        // 渐变透明度
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.duration = 0.3

        layer.add(scaleAnimation, forKey: "scale")
        layer.add(opacityAnimation, forKey: "opacity")

    }
}


// MARK: - UIButton扩展，支持调整图片和文字的排序及间距
public extension UIButton {

    /// 设置文字在左，图片在右
    ///
    /// - version: 1.1
    /// - since: 2021年01月16日10:47:37
    /// - warning: 直接在 Storyboard 使用 semanticContentAttribute 属性设为从右向左即可
    /// - Parameter spacing: 间距
    func setImageRight(spacing: CGFloat = 0) {
        semanticContentAttribute = .forceRightToLeft
        setImageTextSpacing(spacing: spacing)
        /* 已废弃的方式
         guard imageView != nil, titleLabel != nil else {
         return
         }
         // let titleWidth: CGFloat = Judy.getTextSize(text: titleLabel!.text!, font: titleLabel!.font).width
         
         // 先设置 title，图片的x由 title 宽度决定
         titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -imageView!.frame.size.width - spacing/2, bottom: 0, right: imageView!.frame.size.width  + spacing/2)
         imageEdgeInsets = UIEdgeInsets.init(top: 0, left: titleLabel!.frame.width + spacing/2, bottom: 0, right: -titleLabel!.frame.width - spacing/2)
         */
    }
    
    
    /// 设置按钮中图片在文字的正上方。
    ///
    /// 此函数将重新计算按钮尺寸并将图片放置在文本的上方
    /// - version: 1.1
    /// - since: 2021年01月16日10:40:51
    /// - warning: 在设置字体、文本、尺寸大小后需要重新调用此函数已确保正确将图片显示在文本上方
    /// - Parameter spacing: 图片与文本的间隔，默认0，此属性决定了图片和文字各偏移spacing/2
    func setImageTop(spacing: CGFloat = 0) {
        
        guard imageView != nil, titleLabel != nil, titleLabel?.text != nil else { return }
        /*
         修复日志：
         2018年05月24日17:19
         他娘的，原来要用文本内容的宽度来计算，之前一直用titleLabel.frame.width，当实际内容大于按钮本身时就不准确了我操，搞了一下午突然发现用文本内容计算就贼他妈准确了！
         */
        let titleWidth: CGFloat = titleLabel!.text!.textSize(font: titleLabel!.font).width
        //设置文字偏移：向下偏移图片高度＋向左偏移图片宽度 （偏移量是根据［图片］大小来的，这点是关键）
        titleEdgeInsets = UIEdgeInsets.init(top: imageView!.frame.size.height + spacing/2, left: -imageView!.frame.size.width, bottom: 0, right: 0)
        //设置图片偏移：向上偏移文字高度＋向右偏移文字宽度 （偏移量是根据［文字］大小来的，这点是关键）
        imageEdgeInsets = UIEdgeInsets(top: -titleLabel!.bounds.size.height, left: 0, bottom: spacing/2, right: -titleWidth)

    }
    
    /// 设置左右结构的间距。正常情况下图片在左，文字在右，但间距太小。
    ///
    /// - version: 1.1
    /// - since: 2021年01月16日10:46:33
    /// - warning: 若按钮发生变化需重新调用此函数
    /// - Parameter spacing: 间距值，默认2，此属性决定了图片和文字各偏移 spacing/2
    func setImageTextSpacing(spacing: CGFloat = 2) {
        
        guard imageView != nil, titleLabel != nil else { return }
        
        // UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        contentEdgeInsets = UIEdgeInsets(top: 0 + contentEdgeInsets.top, left: spacing/2 + contentEdgeInsets.left, bottom: 0 + contentEdgeInsets.bottom, right: spacing/2 + contentEdgeInsets.right)

        switch semanticContentAttribute {
        // 标题在左，图片在右
        case .forceRightToLeft:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2 + titleEdgeInsets.left, bottom: 0, right: -spacing/2 + titleEdgeInsets.right)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
        
        // 图片在左，标题在右
        case .forceLeftToRight, .unspecified:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
        default:
            break
        }
        
    }
    
}

