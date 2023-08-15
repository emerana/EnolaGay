//
//  extensions.swift
//  Pods
//
//  Created by 醉翁之意 on 2023/3/18.
//

import UIKit

// 使 UIImage 接受命名空间兼容类型协议
extension UIImage: EnolaGayCompatible { }

// MARK: - 使 UIApplication 接受命名空间兼容类型协议
extension UIApplication: EnolaGayCompatible { }

public extension EnolaGayWrapper where Base: UIApplication {
    /// 获取状态栏 View.
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            if let statusBar = Judy.keyWindow?.viewWithTag(EMERANA.Key.statusBarViewTag) {
                return statusBar
            } else {
                let height = Judy.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = EMERANA.Key.statusBarViewTag
                // 值越高，离观察者越近
                statusBarView.layer.zPosition = 999999
                
                Judy.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if base.responds(to: Selector(("statusBar"))) {
                return base.value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}

// MARK: - 使 UIView 接受命名空间兼容类型协议
extension UIView: EnolaGayCompatible { }

// MARK: - tableView 扩展
public extension EnolaGayWrapper where Base: UITableView {
    /// 将 tableView 滚动到最底部
    ///
    /// 在此之前的方法可能会引起数组越界问题，此函数针对该问题修复
    /// - Parameter animated: 是否需要动画效果？默认为 true
    /// - Warning: 在调用该函数之前请先调用 reloadData()
    func scrollToBottom(animated: Bool = true) {
        if base.numberOfSections > 0 {
            let lastSectionIndex = base.numberOfSections-1
            let lastRowIndex = base.numberOfRows(inSection: lastSectionIndex)-1
            if lastRowIndex > 0 {
                let indexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                base.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}

// MARK: - 解决 UIScrollView 不响应 touches 事件
public extension UIScrollView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
}

// MARK: - UIImage 空间函数扩展
public extension EnolaGayWrapper where Base: UIImage {
    /// 重设图片大小
    /// - Parameter reSize: 目标 size.
    /// - Returns: 目标 image.
    func reSizeImage(reSize: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        base.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return reSizeImage
    }

    /// 等比缩放
    /// - Parameter scaleSize: 缩放倍数
    /// - Returns: 目标 image.
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: base.size.width * scaleSize, height: base.size.height * scaleSize)

        return reSizeImage(reSize: reSize)
    }
    
    /// 压缩图像的体积
    ///
    /// 此函数将返回 UIImage 对象通过此函数得到一个小于原始体积的 Data，通常用于图片上传时限制体积
    /// 大小的计算（图像不得超过128K时）如：
    /// if image.pngData()!.count/1024 >= 128 { resetImgSize(maxImageLenght:131072, maxSizeKB: 128) }
    /// - Parameters:
    ///   - maxImageLenght: 最大长度，通常为 128 * 1024,即 131072.
    ///   - maxSizeKB: 最大 KB 体积，如 128.
    /// - Returns: 目标 Data.
    func resetImgSize(maxImageLenght: CGFloat, maxSizeKB: CGFloat) -> Data {
        
        var maxSize = maxSizeKB
        
        var maxImageSize = maxImageLenght
        
        if (maxSize <= 0.0) { maxSize = 1024.0 }
        
        if (maxImageSize <= 0.0) { maxImageSize = 1024.0 }
        
        //先调整分辨率
        var newSize = CGSize.init(width: base.size.width, height: base.size.height)
        let tempHeight = newSize.height / maxImageSize;
        let tempWidth = newSize.width / maxImageSize;
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            newSize = CGSize.init(width: base.size.width / tempWidth, height: base.size.height / tempWidth)
        } else if (tempHeight > 1.0 && tempWidth < tempHeight){
            newSize = CGSize.init(width: base.size.width / tempHeight, height: base.size.height / tempHeight)
        }
        
        UIGraphicsBeginImageContext(newSize)
        base.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var imageData = newImage!.jpegData(compressionQuality: 1.0)
        var sizeOriginKB : CGFloat = CGFloat((imageData?.count)!) / 1024.0;
        
        // 调整大小
        var resizeRate = 0.9;
        while (sizeOriginKB > maxSize && resizeRate > 0.1) {
            
            imageData = newImage!.jpegData(compressionQuality: CGFloat(resizeRate));
            
            sizeOriginKB = CGFloat((imageData?.count)!) / 1024.0;
            
            resizeRate -= 0.1;
        }
        
        return imageData!
    }

    /// 生成圆形图片
    func imageCircle() -> UIImage {
        // 取最短边长
        let shotest = min(base.size.width, base.size.height)
        // 输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        // 开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        // 添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        // 绘制图片
        base.draw(in: CGRect(x: (shotest-base.size.width)/2,
                        y: (shotest-base.size.height)/2,
                        width: base.size.width,
                        height: base.size.height))
        // 获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }

}

// MARK: - 为 UIImage 新增构造函数
public extension UIImage {
    
    /// 通过颜色生成一张图片
    /// - Parameter color: 该颜色用于直接生成一张图像
    convenience init(color: UIColor) {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard image?.cgImage != nil else {
            self.init()
            logWarning("通过颜色生成图像时发生错误！")
            return
        }
        self.init(cgImage: image!.cgImage!)
    }
    
    /// 通过渐变颜色生成一张图片，渐变色方向为从左往右
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认 red.
    ///   - endColor: 渐变结束颜色，默认 blue.
    ///   - frame: 生成的图片 frame.
    convenience init(gradientColors startColor: UIColor = .red, endColor: UIColor = .blue, frame: CGRect) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        // gradient colors.
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor] // 渐变的颜色信息
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        UIGraphicsBeginImageContext(frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard outputImage?.cgImage != nil else {
            self.init()
            logWarning("通过渐变颜色生成图像时发生错误！")
            return
        }
        self.init(cgImage: outputImage!.cgImage!)
    }
}

// MARK: - UIImageView IBDesignable 扩展
public extension UIImageView {
    
    /// 标识该 imageView 是否需要设置为正圆，需要的话请确保其为正方形，否则不生效
    /// - Warning: 若在 Cell 中不能正常显示正圆，请覆盖 Cell 中 layoutIfNeeded() 设置正圆，或在父 View 中设置
    @IBInspectable private(set) var isRound: Bool {
        set {
            if newValue {
                guard frame.size.width == frame.size.height else {
                    logWarning("该 UIImageView 非正方形，无法设置为正圆！")
                    return
                }
                layer.masksToBounds = true
                contentMode = .scaleAspectFill  // 设为等比拉伸
                layer.cornerRadius = frame.size.height / 2
            }
        }
        get {
            guard layer.cornerRadius != 0,
                  frame.size.width == frame.size.height,
                  layer.cornerRadius == frame.size.height/2
            else { return false }
            return true
        }
    }
    
    /// 给图片设置正圆，请确保 UIImageView 为正方形...此属性相对 roundImage() 函数更费性能
    /// # * 此函数相对 isRound 属性更节约性能，但只能在 viewDidLayoutSubviews() 中使用
    @available(*, deprecated, message: "此函数尚未确定其正确性，不建议使用！")
    final func roundImage() {
        guard bounds.size.height == bounds.size.width else {
            logWarning("图片非正方形，无法设置正圆！")
            return
        }
        //开始图形上下文
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        //获取图形上下文
        let ctx = UIGraphicsGetCurrentContext()
        //根据一个rect创建一个椭圆
        ctx!.addEllipse(in: bounds)
        //裁剪
        ctx!.clip()
        //将原照片画到图形上下文
        image?.draw(in: bounds)
        //从上下文上获取剪裁后的照片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        guard newImage != nil else {
            log("上下文图片创建失败!")
            return
        }
        image? = newImage!
        layer.masksToBounds = true
    }
    
}

// MARK: - UILabel 扩展 NSMutableAttributedString 函数
public extension EnolaGayWrapper where Base: UILabel {
    
    /// 为当前 Label 显示的文本中设置部分文字高亮
    /// - Parameters:
    ///   - textColor: 默认文本颜色
    ///   - highlightedText: label 中需要要高亮的文本
    ///   - highlightedColor: 高亮部分文本颜色，默认 nil，即使用原有颜色
    ///   - highlightedFont: 高亮部分文本字体，默认为 nil，即使用原有字体
    /// - Warning: 在调用此函数前 label.text 不能为 nil
    func setHighlighted(text highlightedText: String, color highlightedColor: UIColor? = nil, font highlightedFont: UIFont? = nil) {
        // attributedText 即 label.text，所以直接判断 attributedText 不为 nil 即可
        guard base.text != nil, base.attributedText != nil else { return }
        //  attributedText: 为该属性分配新值也会将 text 属性的值替换为相同的字符串数据，但不包含任何格式化信息此外，分配一个新值将更新字体、textColor 和其他与样式相关的属性中的值，以便它们反映从带属性字符串的位置 0 开始的样式信息
        
        var attrs = [NSAttributedString.Key : Any]()
        // 高亮文本颜色
        attrs[.foregroundColor] = highlightedColor
        // 高亮文本字体
        attrs[.font] = highlightedFont
        // 将 label 的 NSAttributedString 转换成 NSMutableAttributedString
        let attributedString = NSMutableAttributedString(attributedString: base.attributedText!)
        //  let attributedString = NSMutableAttributedString(text: text!, textColor: textColor, textFont: font, highlightText: highlightedText, highlightTextColor: highlightedColor, highlightTextFont: highlightedFont)
        // 添加到指定范围
        let highlightedRange = attributedString.mutableString.range(of: highlightedText)
        attributedString.addAttributes(attrs, range: highlightedRange)
        
        // 重新给 label 的 attributedText 赋值
        base.attributedText = attributedString
    }
}

// MARK: - UIView IBDesignable 扩展
public extension UIView {
    /// 边框宽度
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }

    /// 边框颜色
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else { return nil }
        }
    }
    
    /// 圆角程度
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get { return layer.cornerRadius }
    }
}

// MARK: - UIView frame 相关扩展
public extension EnolaGayWrapper where Base: UIView {
    
    /// view 的 frame.origin.x.
    var x: CGFloat {
        set { base.frame.origin.x = newValue }
        get { base.frame.origin.x }
    }

    /// view 的 frame.origin.y.
    var y: CGFloat {
        set { base.frame.origin.y = newValue }
        get { base.frame.origin.y }
    }
    
    /// 设置 view 的边框样式
    /// - Parameters:
    ///   - border: 边框大小，默认0.
    ///   - color: 边框颜色，默认 .darkGray.
    func viewBorder(border: CGFloat = 0, color: UIColor? = .darkGray) {
        base.borderWidth = border
        base.borderColor = color
    }
    
    /// 给当前操作的 View 设置正圆，该函数会验证 View 是否为正方形，若不是正方形则圆角不生效
    /// - Warning: 请在 viewDidLayout 函数或涉及到布局的函数中调用，否则可能出现问题
    /// - Parameters:
    ///   - border: 边框大小，默认 0.
    ///   - color: 边框颜色，默认深灰色
    /// - Returns: 是否成功设置正圆
    @discardableResult
    func viewRound(border: CGFloat = 0, color: UIColor? = .darkGray) -> Bool {
        viewBorder(border: border, color: color)
        
        guard base.frame.size.width == base.frame.size.height else { return false }
        base.cornerRadius = base.frame.size.height / 2
        
        return true
    }
    
    /// 给当前操作的 View 设置圆角
    ///
    /// - Parameters:
    ///   - radiu: 圆角大小，默认 10.
    ///   - border: 边框大小，默认 0.
    ///   - color: 边框颜色，默认深灰色
    func viewRadiu(radiu: CGFloat = 10, border: CGFloat = 0, color: UIColor? = .darkGray) {
        viewBorder(border: border, color: color)
        base.cornerRadius = radiu
    }
    
    /// 为指定的角设置圆角
    ///
    /// - Parameters:
    ///   - rectCorner: 需要设置的圆角，若有多个可以为数组，如：[.topLeft, .topRight ]
    ///   - cornerRadii: 圆角的大小
    func viewRadiu(rectCorner: UIRectCorner, cornerRadii: CGSize) {
        let path = UIBezierPath(roundedRect: base.bounds,
                                byRoundingCorners: rectCorner,
                                cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = base.bounds
        maskLayer.path = path.cgPath
        base.layer.mask = maskLayer
    }

    /// 给当前操作的 View 设置阴影效果
    /// * 注意：该函数会将 layer.masksToBounds = false.
    /// - Parameters:
    ///   - offset: 阴影偏移量，默认（0,0）.
    ///   - opacity: 阴影可见度，默认 0.6.
    ///   - color: 阴影颜色，默认黑色
    ///   - radius: 阴影圆角，默认 3.
    func viewShadow(offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.6, color: UIColor = .black, radius: CGFloat = 3) {
        
        base.layer.masksToBounds = false

        // shadowOffset阴影偏移,x向右偏移，y向下偏移，默认 0.
        base.layer.shadowOffset = offset
        base.layer.shadowOpacity = opacity
        base.layer.shadowColor = color.cgColor
        base.layer.shadowRadius = radius
    }
    
    /// 给当前操作的 View 设置边框
    /// - Parameter borderWidth: 边框大小，默认 1.
    /// - Parameter borderColor: 边框颜色，默认红色
    @available(*, unavailable, message: "此函数尚未完善，待修复")
    func viewBorder(borderWidth: CGFloat = 1, borderColor: UIColor = .red){
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 30, width: base.frame.size.width, height: 10)
        borderLayer.backgroundColor = borderColor.cgColor
        // layer.addSublayer(borderLayer)
        base.layer.insertSublayer(borderLayer, at: 0)
    }
    
    /// 给 View 设置渐变背景色，改背景色的方向为从左往右。
    ///
    /// 此方法中会先移除最底层的 CAGradientLayer.
    /// - Parameters:
    ///   - startColor: 渐变起始颜色，默认 red.
    ///   - endColor: 渐变结束颜色，默认 blue.
    @discardableResult
    func gradientView(startColor: UIColor = .red, endColor: UIColor = .blue) -> CAGradientLayer {
        // 渐变 Layer 层
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = EMERANA.Key.gradientViewName
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0, 1] // 对应 colors 的 alpha 值
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // 渐变色起始点
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5) // 渐变色终止点
        gradientLayer.frame = base.bounds
        // layer.addSublayer(gradient1)
        if base.layer.sublayers?[0].name == EMERANA.Key.gradientViewName {
            // 先移除再插入！
            base.layer.sublayers?[0].removeFromSuperlayer()
        }
        //  if layer.sublayers?[0].classForCoder == CAGradientLayer.classForCoder() {
        //  // 先移除再插入！
        //  layer.sublayers?[0].removeFromSuperlayer()
        //  }
        // 插入到最底层
        base.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    
    /// 根据键盘调整 window origin.
    ///
    /// - Parameter isReset: 是否重置窗口？默认 flase.
    /// - Parameter offset: 偏移距离，默认 88.
    func updateWindowFrame(isReset: Bool = false, offset: CGFloat = 88) {
        //滑动效果
        UIView.animate(withDuration: 0.3) { [self] in
            //恢复屏幕
            if isReset {
                base.window?.frame.origin.y = 0
            } else {
                base.window?.frame.origin.y = -offset
            }
            base.window?.layoutIfNeeded()
        }
    }
    
    /// 执行一次发光效果
    ///
    /// 该函数以 View 为中心执行一个烟花爆炸动效
    /// - Warning: 如有必要可参考此函数创建新的扩展函数
    /// - Parameter finishededAction: 动画完成后执行的事件，默认为 nil.
    func blingBling(finishededAction: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            // 放大倍数
            base.transform = CGAffineTransform(scaleX: 2, y: 2)
            let anim = CABasicAnimation(keyPath: "strokeStart")
            anim.fromValue = 0.5 // 从 View 的边缘处开始执行
            anim.toValue = 1
            anim.beginTime = CACurrentMediaTime()
            anim.repeatCount = 1    // 执行次数
            anim.duration = 0.2
            anim.fillMode = .forwards
            // anim.isRemovedOnCompletion = true
            
            let count = 12 // 发光粒子数量
            let spacing: Double = Double(base.bounds.width) + 5 // 发光粒子与 view 间距
            for i in 0..<count {
                let path = CGMutablePath()
                /*
                 x=x+s·cosθ
                 y=y+s·sinθ
                 */
                path.move(to: CGPoint(x: base.bounds.midX, y: base.bounds.midY))
                path.addLine(to: CGPoint(
                    x: Double(base.bounds.midX)+spacing*cos(2*Double.pi*Double(i)/Double(count)),
                    y: Double(base.bounds.midY)+spacing*sin(2*Double.pi*Double(i)/Double(count))
                ))
                
                let trackLayer = CAShapeLayer()
                trackLayer.strokeColor = UIColor.orange.cgColor
                trackLayer.lineWidth = 1
                trackLayer.path = path
                trackLayer.fillColor = UIColor.clear.cgColor
                trackLayer.strokeStart = 1
                base.layer.addSublayer(trackLayer)
                trackLayer.add(anim, forKey: nil)
            }
            
        }, completion: { finished in
            base.transform = CGAffineTransform.identity
            finishededAction?()
        })
    }
    
    /// 模拟抖音双击视频点赞效果
    /// - Parameters:
    ///   - duration: 动画的执行时长，默认 0.3 秒
    ///   - spring: 弹簧阻尼，默认 0.5，值越小震动效果越明显
    func doubleClickThumbUp(duration: TimeInterval = 0.3, spring: CGFloat = 0.5) {
        var transform = base.transform
        /// 随机偏转角度 control 点，该值限制为 0 和 1.
        let j = CGFloat(arc4random_uniform(2))
        /// 随机方向，-1/1 代表了顺时针或逆时针
        let travelDirection = CGFloat(1 - 2*j)
        let angle = CGFloat(Double.pi/4)
        // 顺时针或逆时针旋转
        transform = transform.rotated(by: travelDirection*angle)
        base.transform = transform
        /*
         1. withDuration: TimeInterval  动画执行时间
         2. delay: TimeInterval 动画延迟执行时间
         3. usingSpringWithDamping: CGFloat 弹簧阻力，取值范围为0.0-1.0，数值越小“弹簧”振动效果越明显
         4. initialSpringVelocity: CGFloat  动画初始的速度（pt/s），数值越大初始速度越快但要注意的是，初始速度取值较高而时间较短时，也会出现反弹情况
         5. options: UIViewAnimationOptions 运动动画速度曲线
         6. animations: () -> Void  执行动画的函数，也是本动画的核心
         7. completion: ((Bool) -> Void)?   动画完成时执行的回调，可选性，可以为 nil
         */
        /// 出现动画：变大->变小
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: spring, initialSpringVelocity: 3) {
            // 缩放
            transform = transform.scaledBy(x: 0.8, y: 0.8)
            base.transform = transform
        } completion: { finished in
            // 消失过程动画停留 0.5 秒再消失
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                // 缩放
                transform = transform.scaledBy(x: 8, y: 8)
                base.transform = transform
                base.alpha = 0
            } completion: { finished in
                base.removeFromSuperview()
            }
        }
    }
}


// MARK: - UIButton 扩展

// MARK: - UITextField 扩展

// MARK: - UITextFieldDelegate 扩展函数
public extension UITextFieldDelegate {
    /// 限制当前输入的字符为整数
    /// - Warning: 此函数仅限在输入阶段的 shouldChangeCharactersIn() 使用
    /// - Parameters:
    ///   - textField: 输入框对象
    ///   - string: 输入的字符，即代理方法中的 string.
    ///   - maxNumber: 允许输入的最大数值，默认为0，不限制
    /// - Returns: 是否符合验证，若输入的值不合符该值将不会出现在输入框中
    func numberRestriction(textField: UITextField, inputString string: String, maxNumber: Int = 0) -> Bool {
        // 回退
        guard string != "" else { return true }
        /// 仅允许输入指定的字符
        let cs = CharacterSet(charactersIn: "0123456789\n").inverted
        /// 过滤输入的字符
        let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
        guard (string as String) == filtered  else { logWarning("只能输入数值"); return false }
        
        // 最大值校验
        if maxNumber != 0 {
            let textFieldString = (textField.text!) + string
            // 将输入的整数值
            let numberValue = Int(textFieldString) ?? 0
            if numberValue > maxNumber {
                logWarning("只能输入小于\(maxNumber)的值")
                return false
            }
        }
        return true
    }
}


// MARK: - UIColor 配置扩展
public extension UIColor {
    // 浅色
    static let 淡红色 = #colorLiteral(red: 0.9254901961, green: 0.4117647059, blue: 0.2549019608, alpha: 1)
    static let 浅红橙 = #colorLiteral(red: 0.9450980392, green: 0.568627451, blue: 0.2862745098, alpha: 1)
    static let 浅黄橙 = #colorLiteral(red: 0.9725490196, green: 0.7098039216, blue: 0.3176470588, alpha: 1)
    static let 浅黄 = #colorLiteral(red: 1, green: 0.9568627451, blue: 0.3607843137, alpha: 1)
    static let 浅青豆绿 = #colorLiteral(red: 0.7019607843, green: 0.831372549, blue: 0.3960784314, alpha: 1)
    static let 浅黄绿 = #colorLiteral(red: 0.5019607843, green: 0.7607843137, blue: 0.4117647059, alpha: 1)
    static let 浅绿 = #colorLiteral(red: 0.1960784314, green: 0.6941176471, blue: 0.4235294118, alpha: 1)
    static let 浅绿青 = #colorLiteral(red: 0.07450980392, green: 0.7098039216, blue: 0.6941176471, alpha: 1)
    static let 浅青 = #colorLiteral(red: 0, green: 0.7176470588, blue: 0.9333333333, alpha: 1)
    static let 浅洋红 = #colorLiteral(red: 0.9176470588, green: 0.4078431373, blue: 0.6352941176, alpha: 1)
    static let 浅蓝紫 = #colorLiteral(red: 0.3725490196, green: 0.3215686275, blue: 0.6274509804, alpha: 1)
    static let 浅紫洋红 = #colorLiteral(red: 0.6823529412, green: 0.3647058824, blue: 0.631372549, alpha: 1)

    // 纯净颜色
    static let 纯红 = #colorLiteral(red: 0.9019607843, green: 0, blue: 0.07058823529, alpha: 1)
    static let 纯红橙 = #colorLiteral(red: 0.9215686275, green: 0.3803921569, blue: 0, alpha: 1)
    static let 纯黄橙 = #colorLiteral(red: 0.9529411765, green: 0.5960784314, blue: 0, alpha: 1)
    static let 纯黄 = #colorLiteral(red: 1, green: 0.9450980392, blue: 0, alpha: 1)
    static let 纯青豆绿 = #colorLiteral(red: 0.5607843137, green: 0.7647058824, blue: 0.1215686275, alpha: 1)
    static let 纯黄绿 = #colorLiteral(red: 0.1333333333, green: 0.6745098039, blue: 0.2196078431, alpha: 1)
    static let 纯绿 = #colorLiteral(red: 0, green: 0.6, blue: 0.2666666667, alpha: 1)
    static let 纯绿青 = #colorLiteral(red: 0, green: 0.6196078431, blue: 0.5882352941, alpha: 1)
    static let 纯青 = #colorLiteral(red: 0, green: 0.6274509804, blue: 0.9137254902, alpha: 1)
    static let 纯青蓝 = #colorLiteral(red: 0, green: 0.4078431373, blue: 0.7176470588, alpha: 1)
    static let 纯蓝 = #colorLiteral(red: 0, green: 0.2784313725, blue: 0.6156862745, alpha: 1)
    static let 纯蓝紫 = #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.5333333333, alpha: 1)
    static let 纯紫 = #colorLiteral(red: 0.3764705882, green: 0.09803921569, blue: 0.5254901961, alpha: 1)
    static let 纯紫洋红 = #colorLiteral(red: 0.5725490196, green: 0.02745098039, blue: 0.5137254902, alpha: 1)
    static let 纯洋红 = #colorLiteral(red: 0.8941176471, green: 0, blue: 0.4980392157, alpha: 1)
    static let 纯洋红红 = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.3098039216, alpha: 1)


    /*
     * static 和 class 的区别.
     *
     * static 定义的属性和 func 没办法被子类 override.
     * class 定义的属性和 func 可以被子类 override.
     */

    // MARK: 构造函数

    /// 通过一个 16 进制的 Int 值生成 UIColor
    ///
    /// - Parameters:
    ///   - rgbValue: 如:0x36c7b7（其实就是#36c7b7，但必须以0x开头才能作为 Int）
    ///   - alpha: 默认1 可见度，0.0~1.0，值越高越不透明，越小越透明
    convenience init(rgbValue: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(Float((rgbValue & 0xff0000) >> 16)) / 255.0,
                  green: CGFloat((Float((rgbValue & 0xff00) >> 8)) / 255.0),
                  blue: CGFloat((Float(rgbValue & 0xff) / 255.0)),
                  alpha: alpha)
    }
    
    /// 通过指定 RGB 比值生成 UIColor，不需要2/255，只填入2即可
    /// - Parameters:
    ///   - r: 红色值
    ///   - g: 绿色值
    ///   - b: 蓝色值
    ///   - a: 默认1 透密昂度，0.0~1.0，值越高越不透明，越小越透明
    /// - Warning: 传入的 RGB 值在 0~255 之间哈
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: a)
    }
}


// MARK: UIFont 扩展

/// 字体专用协议
/// - Warning: 此协仅支持对象类型
protocol FontStyle: AnyObject {
    /// 是否不使用 protocol EnolaGayAdapter 中的 defaultFontName 返回的字体名，默认 false，将该值改为 true 即可单独使用在 xib 配置的值，从而忽略 defaultFontName 全局字体名称配置。
    ///
    /// 在 protocol EnolaGayAdapter 中 JudyBaseLabel、JudyBaseButton、JudyBaseTextfield 的默认字体名称使用 EMERANA.enolagayAdapter?.defaultFontName 的配置值。
    var disableFont: Bool { get }
}

/// 常用字体名
public enum FontName: String {

    case 苹方_极细体 = "PingFangSC-Ultralight"
    case 苹方_纤细体 = "PingFangSC-Thin"
    case 苹方_细体 = "PingFangSC-Light"
    case 苹方_常规体 = "PingFangSC-Regular"
    case 苹方_中黑体 = "PingFangSC-Medium"
    case 苹方_中粗体 = "PingFangSC-Semibold"
    
    /// HelveticaNeue 纤细体
    case HlvtcThin = "HelveticaNeue-Thin"
    /// HelveticaNeue 细体
    case HlvtcNeue_Light = "HelveticaNeue-Light"
    /// HelveticaNeue 常规体
    case HlvtcNeue = "HelveticaNeue"
    /// HelveticaNeue 中黑体
    case HlvtcNeue_Medium = "HelveticaNeue-Medium"
    /// HelveticaNeue 粗体
    case HlvtcNeue_Bold = "HelveticaNeue-Bold"
}

public extension UIFont {
    /// 通过 FontName 获得一个 UIFont 对象
    /// - Parameters:
    ///   - name: 参见 FontName，该值默认为 .苹方_中黑体
    ///   - size: 字体的大小，该值最大取 100.
    convenience init(name: FontName = .苹方_中黑体, size: CGFloat) {
        self.init(name: name.rawValue, size: min(size, 100))!
    }
}

/// 为空间包装对象 String 添加扩展函数，此部分适用于 UIFont.
public extension EnolaGayWrapper where Base == String {
    
    /// 计算文本的 size.
    ///
    /// - Parameters:
    ///   - font: 以该字体作为计算尺寸的参考
    ///   - maxSize: 最大尺寸，默认为 CGSize(width: 320, height: 68).
    /// - Returns: 文本所需宽度
    func textSize(maxSize: CGSize = CGSize(width: 320, height: 68), font: UIFont = UIFont(size: 16)) -> CGSize {
        // 根据文本内容获取尺寸，计算文字尺寸 UIFont.systemFont(ofSize: 14.0)
        return base.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin],
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size
    }
    
    /// 计算文本的 size.
    func sizeWith(font: UIFont = UIFont(size: 16) , maxSize : CGSize = CGSize(width: 168, height: 0) , lineMargin : CGFloat = 2) -> CGSize {
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin
        
        var attributes = [NSAttributedString.Key : Any]()
        attributes[NSAttributedString.Key.font] = font
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let textBouds = base.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        
        return textBouds.size
    }
}


// MARK: - EnolaGayAdapter 协议：字体、颜色配置

/// EnolaGay 框架全局适配协议
///
/// 请自行 extension UIApplication: EnolaGayAdapter 实现想要的配置函数。
///
/// - Warning: 该协议仅允许 UIApplication 继承。
public protocol EnolaGayAdapter where Self: UIApplication {
    /// 配置 JudyBaseLabel、JudyBaseButton、JudyBaseTextField 的默认字体样式，但忽略配置字体大小。
    ///
    /// JudyBaseLabel、JudyBaseButton、JudyBaseTextField 无论是不是在 xib 中构建的都会访问该 font 以便获得 fontName.
    ///
    /// 在 xib 中若需要忽略全局配置，使用 xib 设置的字体时，请将 disableFont 设置为 true 即可。
    ///
    /// - Warning:  返回的目标字体仅会影响字体名称（仅使用其 UIFont.fontName），不影响字体大小。
    func defaultFontName() -> UIFont
    
    /// 配置 JudyBaseViewCtrl 及其子类的背景色。
    ///
    /// - Warning: 该函数有默认实现为 systemBackground.
    func viewBackgroundColor() -> UIColor
    
    /// 配置 JudyBaseCollectionViewCtrl、JudyBaseTableViewCtrl 容器 scrollView 的背景色。
    ///
    /// - Warning: 该函数有默认实现，为 systemBackground.
    func scrollViewBackGroundColor() -> UIColor
    
    /// 配置 JudyBaseNavigationCtrl 中的 标题颜色及 tintColor（标题两侧 items）。
    ///
    /// - Warning: 该函数有默认实现，为 systemBlue.
    func navigationBarItemsColor() -> UIColor
}

public extension EnolaGayAdapter {
    
    func defaultFontName() -> UIFont { UIFont(name: .苹方_中黑体, size: 12) }
    
    func viewBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    func scrollViewBackGroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }

    func navigationBarItemsColor() -> UIColor { .systemBlue }
}

public extension EMERANA.Key {
    
    /// CABasicAnimation 中的常用 keypath
    ///
    /// ```
    /// // 大小比例
    /// let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
    /// layer.add(scaleAnimation, forKey: "scale")
    /// ```
    struct keypath {
        /// 大小比例
        public static let scale = "transform.scale"
        /// 宽的比例转换
        public static let scaleX = "transform.scale.x"
        /// 高的比例转换
        public static let scaleY = "transform.scale.y"
        /// 平面的旋转
        public static let rotation = "transform.rotation.z"
        /// 透明度
        public static let opacity = "opacity"
        /// 布局
        public static let margin = "margin"
        /// 翻转
        public static let zPosition = "zPosition"
        /// 背景颜色
        public static let backgroundColor = "backgroundColor"
        /// 圆角
        public static let cornerRadius = "cornerRadius"
        /// 边框宽
        public static let borderWidth = "borderWidth"
        /// 大小
        public static let bounds = "bounds"
        /// 内容
        public static let contents = "contents"
        /// 内容大小
        public static let contentsRect = "contentsRect"
        /// 大小位置
        public static let frame = "frame"
        /// 显示隐藏
        public static let hidden = "hidden"
    }
    
    /*
     抖动动画：
     let ani: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
     ani.values = [-Double.pi/1804,Double.pi/1804,-Double.pi/180*4]
     ani.repeatCount = 3
     imgView.layer.add(ani, forKey: "shakeAnimation")


     CABasicAnimation 中常用的 keypath 值：
     // 大小比例
     let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
     layer.add(scaleAnimation, forKey: "scale")

     mask
     masksToBounds
     opacity
     position
     shadowColor
     shadowOffset
     shadowOpacity
     shadowRadius
     
     */

}
