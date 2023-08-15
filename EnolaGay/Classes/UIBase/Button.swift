//
//  Button.swift
//  EnolaGay
//
//  Created by 艾美拉娜 on 2018/10/12.
//  Copyright © 2018. All rights reserved.
//

// MARK: - JudyBaseButton

import UIKit

/// EMERANA框架中所用到的Button，默认 FontStyle 为均码
open class JudyBaseButton: UIButton, FontStyle {

    /// 图像方位
    private enum ImageDirection: Int {
        case left = 0
        case up
        case right
        case down
    }

    /// 图像所在方位，默认0，对应 enum ImageDirection, left = 0, up = 1, right = 2, down = 3
    @IBInspectable private(set) var imageDirection: Int = 0

    @IBInspectable private(set) public var disableFont: Bool = false
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /// 使用 JudyBaseButton() 构造器将触发此构造函数
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initFont()
    }
    
    /// 从 xib/storyboard 中构造会先触发此构造函数再唤醒 awakeFromNib.
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        if !disableFont { initFont() }

        guard let tempImageDirection = JudyBaseButton.ImageDirection(rawValue: imageDirection) else {
            return
        }
        switch tempImageDirection {
        case .up:
            judy.setImageTop(spacing: 8)
        case .right:
            judy.setImageRight()
        default:break
        }
    
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

    }
    
}

private extension JudyBaseButton {
    /// 在构造 JudyBaseLabel 时就设置好 label 的默认 font.
    func initFont() {
//        if let defaultFont = EMERANA.enolagayAdapter?.defaultFontName() {
//            titleLabel?.font = UIFont(name: defaultFont.fontName, size: titleLabel?.font.pointSize ?? 12)
//        }
    }
}

// MARK: - UIButton 空间扩展方法
public extension EnolaGayWrapper where Base: UIButton {
    
    /// 以动画的方式显示该按钮
    func show() {
        guard base.isHidden == true else { return }
        
        base.isHidden = false
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
        
        base.layer.add(scaleAnimation, forKey: "scale")
        base.layer.add(opacityAnimation, forKey: "opacity")
    }
    
    /// 设置文字在左，图片在右
    ///
    /// - Warning: 直接在 Storyboard 使用 semanticContentAttribute 属性设为从右向左即可
    /// - Parameter spacing: 间距
    func setImageRight(spacing: CGFloat = 0) {
        base.semanticContentAttribute = .forceRightToLeft
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
    
    /// 设置按钮中图片在文字的正上方
    ///
    /// 此函数将重新计算按钮尺寸并将图片放置在文本的上方
    /// - Warning: 在设置字体、文本、尺寸大小后需要重新调用此函数已确保正确将图片显示在文本上方
    /// - Parameter spacing: 图片与文本的间隔，默认0，此属性决定了图片和文字各偏移spacing/2.
    func setImageTop(spacing: CGFloat = 0) {
        guard base.imageView != nil,
              base.titleLabel != nil,
              base.titleLabel?.text != nil else { return }
        /*
         修复日志：
         2018年05月24日17:19
         他娘的，原来要用文本内容的宽度来计算，之前一直用titleLabel.frame.width，当实际内容大于按钮本身时就不准确了我操，搞了一下午突然发现用文本内容计算就贼他妈准确了！
         */
        let titleWidth: CGFloat = base.titleLabel!.text!
            .judy.textSize(font: base.titleLabel!.font).width
        //设置文字偏移：向下偏移图片高度＋向左偏移图片宽度 （偏移量是根据［图片］大小来的，这点是关键）
        base.titleEdgeInsets = UIEdgeInsets(top: base.imageView!.frame.size.height + spacing/2,
                                            left: -base.imageView!.frame.size.width,
                                            bottom: 0, right: 0)
        //设置图片偏移：向上偏移文字高度＋向右偏移文字宽度 （偏移量是根据［文字］大小来的，这点是关键）
        base.imageEdgeInsets = UIEdgeInsets(top: -base.titleLabel!.bounds.size.height,
                                            left: 0, bottom: spacing/2, right: -titleWidth)
    }
    
    /// 设置左右结构的间距。正常情况下图片在左，文字在右，但间距太小
    ///
    /// - Warning: 若按钮发生变化需重新调用此函数
    /// - Parameter spacing: 间距值，默认2，此属性决定了图片和文字各偏移 spacing/2.
    func setImageTextSpacing(spacing: CGFloat = 2) {
        guard base.imageView != nil, base.titleLabel != nil else { return }
        
        // UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        base.contentEdgeInsets = UIEdgeInsets(top: 0 + base.contentEdgeInsets.top,
                                              left: spacing/2 + base.contentEdgeInsets.left,
                                              bottom: 0 + base.contentEdgeInsets.bottom,
                                              right: spacing/2 + base.contentEdgeInsets.right)

        switch base.semanticContentAttribute {
        // 标题在左，图片在右
        case .forceRightToLeft:
            base.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                left: spacing/2 + base.titleEdgeInsets.left,
                                                bottom: 0,
                                                right: -spacing/2 + base.titleEdgeInsets.right)
            base.titleEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
        
        // 图片在左，标题在右
        case .forceLeftToRight, .unspecified:
            base.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            base.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
        default:
            break
        }
        
    }
    
}


// MARK: - JudyVerifyButton

/**
 * 验证码倒计时按钮，字体样式默认为小码，请在 storyboard 中将按钮类型改为 Custom.
 * * 配置 clickActionClosure 设置按钮点击事件(可选)
 * * 通过 star() 方法启动倒计时以及配置按钮的颜色
 */
open class JudyVerifyButton: JudyBaseButton {
    
    /// 按钮点击事件的回调，JudyVerifyButton: 该按钮对象
    public var clickActionClosure:((JudyVerifyButton) -> Void)?

    /// 计时状态改变回调，Bool: 是否开始计时
    private var countingStatuClosure:((Bool) -> Void)?
    
    // MARK: 计时器相关属性
    
    /// 等待时长，默认为60秒
    private var waitTime = 60
    
    /// 计时器对象
    private var countdownTimer: Timer?
    
    /// 剩余秒数
    private var remainingSeconds = 0 {
        willSet {
            setTitle("\(newValue)秒", for: .normal)
            if newValue <= 0 {
                setTitle("重新获取", for: .normal)
                isCounting = false
            }
            // 计时过程中保持按钮不可点击状态
            isEnabled = newValue <= 0
        }
    }
    
    /// 是否开始计时，默认否
    private var isCounting = false {
        willSet {
            if newValue {
                // 创建一个计时器对象，每隔1秒执行一次updateTime方法
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(timer:)), userInfo: nil, repeats: true)
                // TODO: 在此设置等待时长
                remainingSeconds = waitTime
                //                verificationCodeButton.backgroundColor = UIColor.gray
            } else {
                countdownTimer?.invalidate() // 计时器设为无效
                countdownTimer = nil
                //                verificationCodeButton.backgroundColor = UIColor.red
            }
        }
        didSet{
            countingStatuClosure?(isCounting)
        }
    }
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addTarget(self, action: #selector(verificationButtonAction), for: .touchUpInside)
    }
    
    /// 启动倒计时
    ///
    /// - Parameters:
    ///   - waitTime: 允许再次点击时的等待时长，默认60秒
    ///   - countingChangedAction: 计时状态改变回调，isCounting: Bool 是否正在计时
    public func star(waitTime: Int = 60, _ countingChangedAction: ((Bool) -> Void)? = nil) {
        self.waitTime = waitTime
        countingStatuClosure = countingChangedAction
        // 启动倒计时
        isCounting = true
    }
    
    /// 验证码按钮点击事件
    @objc private func verificationButtonAction(_ sender: Any) {
        clickActionClosure?(self)
    }
    
    /// 逐秒递减
    ///
    /// - Parameter timer: timer.
    @objc private func updateTime(timer: Timer) {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds = remainingSeconds  - 1
    }

}
