//
//  Toast.swift
//  Toast 是一个 Swift 扩展，它向 UIView 对象类添加 Toast 通知。它的目的是简单、轻量级和易于使用。大多数 toast 通知可以用一行代码触发。
//
//  “makeToast”方法创建一个新视图，然后将其显示为 toast.
//
//  “showToast”方法将任何视图显示为 toast.
//

import UIKit

public extension UIView {
    
    /** 用于关联对象的键 */
    private struct ToastKeys {
        static var timer        = "enolagay.toast.timer"
        static var duration     = "enolagay.toast.duration"
        static var point        = "enolagay.toast.point"
        static var completion   = "enolagay.toast.completion"
        static var activeToasts = "enolagay.toast.activeToasts"
        static var activityView = "enolagay.toast.activityView"
        static var queue        = "enolagay.toast.queue"
    }
    
    /// Swift 闭包不能通过直接与对象关联 Objective-C 运行时，所以（不详的）解决方案是将它们包装在类，该类可与关联对象一起使用。
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private enum ToastError: Error {
        case missingParameters
    }
    
    private var activeToasts: NSMutableArray {
        get {
            if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToasts) as? NSMutableArray {
                return activeToasts
            } else {
                let activeToasts = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.activeToasts, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return activeToasts
            }
        }
    }
    
    private var queue: NSMutableArray {
        get {
            if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
                return queue
            } else {
                let queue = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return queue
            }
        }
    }
    
    // MARK: - Make Toast Methods

    /// 创建并显示新的 toast
    /// - Parameters:
    ///   - message: 显示的消息体
    ///   - duration: toast 显示的持续时间
    ///   - position: toast 显示的位置
    ///   - title: 标题
    ///   - image: 在 toast 中添加一张图片
    ///   - style: toast 风格。当为 nil 时，将使用共享样式。
    ///   - completion: 完成闭包，在 toast 视图消失后执行。如果 toast 从 tap 中删除，则 didTap 将为 true.
    func makeToast(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, title: String? = nil, image: UIImage? = nil, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)? = nil) {
        do {
            let toast = try toastViewForMessage(message, title: title, image: image, style: style)
            showToast(toast, duration: duration, position: position, completion: completion)
        } catch ToastError.missingParameters {
            print("Error: message, title, and image are all nil")
        } catch {}
    }
    
    /// 创建新的 toast 视图并在给定的中心点显示它
    /// - Parameters:
    ///   - message: 显示的消息体
    ///   - duration: toast 显示的持续时间
    ///   - point: toast 的中心点
    ///   - title: 标题
    ///   - image: 在 toast 中添加一张图片
    ///   - style: toast 风格。当为 nil 时，将使用共享样式。
    ///   - completion: 完成闭包，在 toast 视图消失后执行。如果 toast 从 tap 中删除，则 didTap 将为 true.
    func makeToast(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, title: String?, image: UIImage?, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)?) {
        do {
            let toast = try toastViewForMessage(message, title: title, image: image, style: style)
            showToast(toast, duration: duration, point: point, completion: completion)
        } catch ToastError.missingParameters {
            print("Error: message, title, and image cannot all be nil")
        } catch {}
    }
    
    // MARK: - Show Toast Methods
    
    /// 在指定的位置和持续时间将任何视图显示为 toast
    /// - Parameters:
    ///   - toast: 显示成 toast 的 view
    ///   - duration: 持续时长
    ///   - position: toast 要显示的位置
    ///   - completion: toast 完成的闭包，在 toast 消失后，将执行 completion，如果 toast 已经消失 didTap 将为 true.
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, completion: ((_ didTap: Bool) -> Void)? = nil) {
        let point = position.centerPoint(forToast: toast, inSuperview: self)
        showToast(toast, duration: duration, point: point, completion: completion)
    }
    
    /// 在提供的中心点和持续时间上将任何视图显示为 toast
    /// - Parameters:
    ///   - toast: 显示成 toast 的 view
    ///   - duration: 持续时长
    ///   - point: toast 的中心点
    ///   - completion: toast 完成的闭包，在 toast 消失后，将执行 completion，如果 toast 已经消失 didTap 将为 true.
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
        objc_setAssociatedObject(toast, &ToastKeys.completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
            objc_setAssociatedObject(toast, &ToastKeys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            queue.add(toast)
        } else {
            showToast(toast, duration: duration, point: point)
        }
    }
    
    // MARK: - Hide Toast Methods
   
    /// 隐藏活跃的 toast
    ///
    /// 如果一个视图中有多个活动的 toast，这个方法会隐藏最旧的的 toast(第一个已经出现的 toast)，
    /// 你可以使用 `hideAllToasts()` 方法从视图中删除所有活动的 toast.
    /// - Warning: 此方法对活跃的 toast 没有影响。使用 hideToastActivity 方法隐藏活跃的 toast.
    func hideToast() {
        guard let activeToast = activeToasts.firstObject as? UIView else { return }
        hideToast(activeToast)
    }
    
    /// 隐藏一个活跃的 toast
    /// - Warning: 这并不能清除当前在队列中等待的 toast
    /// - Parameter toast: 将被消失的 toast.任何当前显示在屏幕上的 toast 都被认为是活跃的。
    func hideToast(_ toast: UIView) {
        guard activeToasts.contains(toast) else { return }
        hideToast(toast, fromTap: false)
    }
    
    /// 隐藏所有 toast
    /// - Parameters:
    ///   - includeActivity: 如果 true，toast 活动也会被隐藏。该值默认为 false.
    ///   - clearQueue: 如果 true，则从队列中删除所有 toast.该值默认为 true.
    func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }
        
        activeToasts.compactMap { $0 as? UIView }
                    .forEach { hideToast($0) }
        
        if includeActivity {
            hideToastActivity()
        }
    }
    
    /// 从队列中删除所有 toast 视图
    /// - Warning: 这对活跃的 toast 没有影响。你可以使用 `hideAllToasts(clearQueue:)` 隐藏活跃的 toast 并清除队列。
    func clearToastQueue() {
        queue.removeAllObjects()
    }
    
    // MARK: - Activity Methods
    
    /// 在指定位置创建并显示一个新的 toast 活动指示器视图
    /// - Warning: 每个父视图只能显示一个 toast 活动指示器视图。随后对 makeToastActivity(position:) 函数的调用将被忽略，直到 hideToastActivity() 被调用。
    /// - Warning: makeToastActivity(position:) 独立于 showToast 方法。toast 活动视图可以在 toast 视图被显示时显示和取消。makeToastActivity(position:) 对 showToast 方法的排队行为没有影响。
    /// - Parameter position: toast 的位置
    func makeToastActivity(_ position: ToastPosition) {
        // sanity
        guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }
        
        let toast = createToastActivityView()
        let point = position.centerPoint(forToast: toast, inSuperview: self)
        makeToastActivity(toast, point: point)
    }
    
    /// 在指定位置创建并显示一个新的 toast 活动指示器视图
    /// - Warning: 每个父视图只能显示一个 toast 活动指示器视图。随后对 makeToastActivity(point:) 函数的调用将被忽略，直到 hideToastActivity() 被调用。
    /// - Warning: makeToastActivity(point:) 独立于 showToast 方法。toast 活动视图可以在 toast 视图被显示时显示和取消。makeToastActivity(point:) 对 showToast 方法的排队行为没有影响。
    /// - Parameter point: toast 的中心
    func makeToastActivity(_ point: CGPoint) {
        // sanity
        guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }
        
        let toast = createToastActivityView()
        makeToastActivity(toast, point: point)
    }
    
    /// 隐藏/使消失活跃的 toast 活动指示器视图
    func hideToastActivity() {
        if let toast = objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView {
            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0.0
            }) { _ in
                toast.removeFromSuperview()
                objc_setAssociatedObject(self, &ToastKeys.activityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: - Private Activity Methods
    
    private func makeToastActivity(_ toast: UIView, point: CGPoint) {
        toast.alpha = 0.0
        toast.center = point
        
        objc_setAssociatedObject(self, &ToastKeys.activityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 1.0
        })
    }
    
    private func createToastActivityView() -> UIView {
        let style = ToastManager.shared.style
        
        let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        activityView.backgroundColor = style.activityBackgroundColor
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2.0, y: activityView.bounds.size.height / 2.0)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.color = style.activityIndicatorColor
        activityIndicatorView.startAnimating()
        
        return activityView
    }
    
    // MARK: - Private Show/Hide Methods
    
    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        toast.center = point
        toast.alpha = 0.0
        
        if ToastManager.shared.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        activeToasts.add(toast)
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toast.alpha = 1.0
        }) { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
            timer.invalidate()
        }
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
            self.activeToasts.remove(toast)
            
            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.firstObject as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
            }
        }
    }
    
    // MARK: - Events
    
    @objc
    private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hideToast(toast, fromTap: true)
    }
    
    @objc
    private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast)
    }
    
    // MARK: - Toast Construction
    
    /// 创建一个包含消息、标题和图像的新 toast。外观是通过样式配置的。与' makeToast '方法不同，该方法不会自动显示 toast 视图。其中一个 `showToast` 方法必须用于显示结果视图。
    /// - Parameters:
    ///   - message: 显示的消息体
    ///   - title: 标题
    ///   - image: 在 toast 中添加一张图片
    ///   - style: toast 风格。当为 nil 时，将使用共享样式。
    /// - Throws: ToastError.missingParameters, 当 message、title、image 都为 nil 时抛出异常。
    /// - Returns: 新创建的 toast
    func toastViewForMessage(_ message: String?, title: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
        // sanity
        guard message != nil || title != nil || image != nil else {
            throw ToastError.missingParameters
        }
        
        var messageLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
        
        if let image = image {
            imageView = UIImageView(image: image)
            imageView?.contentMode = .scaleAspectFit
            imageView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
        }
        
        var imageRect = CGRect.zero
        
        if let imageView = imageView {
            imageRect.origin.x = style.horizontalPadding
            imageRect.origin.y = style.verticalPadding
            imageRect.size.width = imageView.bounds.size.width
            imageRect.size.height = imageView.bounds.size.height
        }

        if let title = title {
            titleLabel = UILabel()
            titleLabel?.numberOfLines = style.titleNumberOfLines
            titleLabel?.font = style.titleFont
            titleLabel?.textAlignment = style.titleAlignment
            titleLabel?.lineBreakMode = .byTruncatingTail
            titleLabel?.textColor = style.titleColor
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.text = title;
            
            let maxTitleSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
            if let titleSize = titleSize {
                titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
            }
        }
        
        if let message = message {
            messageLabel = UILabel()
            messageLabel?.text = message
            messageLabel?.numberOfLines = style.messageNumberOfLines
            messageLabel?.font = style.messageFont
            messageLabel?.textAlignment = style.messageAlignment
            messageLabel?.lineBreakMode = .byTruncatingTail;
            messageLabel?.textColor = style.messageColor
            messageLabel?.backgroundColor = UIColor.clear
            
            let maxMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
            if let messageSize = messageSize {
                let actualWidth = min(messageSize.width, maxMessageSize.width)
                let actualHeight = min(messageSize.height, maxMessageSize.height)
                messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
            }
        }
  
        var titleRect = CGRect.zero
        
        if let titleLabel = titleLabel {
            titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
            titleRect.origin.y = style.verticalPadding
            titleRect.size.width = titleLabel.bounds.size.width
            titleRect.size.height = titleLabel.bounds.size.height
        }
        
        var messageRect = CGRect.zero
        
        if let messageLabel = messageLabel {
            messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
            messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
            messageRect.size.width = messageLabel.bounds.size.width
            messageRect.size.height = messageLabel.bounds.size.height
        }
        
        let longerWidth = max(titleRect.size.width, messageRect.size.width)
        let longerX = max(titleRect.origin.x, messageRect.origin.x)
        let wrapperWidth = max((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
        let wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)))
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        if let titleLabel = titleLabel {
            titleRect.size.width = longerWidth
            titleLabel.frame = titleRect
            wrapperView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageRect.size.width = longerWidth
            messageLabel.frame = messageRect
            wrapperView.addSubview(messageLabel)
        }
        
        if let imageView = imageView {
            wrapperView.addSubview(imageView)
        }
        
        return wrapperView
    }
    
}

// MARK: - Toast Style

/// ToastStyle 实例定义了通过 `makeToast` 方法创建的 toast 的外观和触觉，以及直接使用 `toastViewForMessage(message:title:image:style:)` 创建的 toast。
/// - Warning: ToastStyle 为默认的 toast 视图提供了相对简单的样式选项。如果你需要一个带有更复杂 UI 的 toast 视图，它可能会提供更多创建你自己的自定义 UIView 子类，并用 `showToast` 方法呈现它。
public struct ToastStyle {

    public init() {}
    
    /// 背景颜色。默认为黑色，不透明度为 80%.
    public var backgroundColor: UIColor = .black.withAlphaComponent(0.8)
    
    /// 标题颜色。默认为白色。
    public var titleColor: UIColor = .white
    
    /// 消息颜色。默认为白色。
    public var messageColor: UIColor = .white
    
    /// 从 0.0 ~ 1.0 的百分比值，表示 toast 的最大宽度。视图相对于它的父视图。默认值是0.8(父视图宽度的80%)。
    public var maxWidthPercentage: CGFloat = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }
    
    /// 从 0.0 ~ 1.0 的百分比值，表示 toast 的最大高度。视图相对于它的父视图。默认值是0.8(父视图高度的80%)。
    public var maxHeightPercentage: CGFloat = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }
    
    /// 从 toast 视图的水平边缘到内容的间距。当有图像出现时，它也被用作图像和文本之间的填充。默认是10.0。
    public var horizontalPadding: CGFloat = 10.0
    
    /// 从 toast 视图的垂直边缘到内容的间距。当出现标题时，它也被用作标题和消息之间的填充。默认是10.0。在iOS11+上，这个值会加上 safeAreaInset.top 和 safeAreaInsets.bottom.
    public var verticalPadding: CGFloat = 10.0
    
    /// 圆角程度，默认为 10.
    public var cornerRadius: CGFloat = 10.0;
    
    /// 标题字体，默认为 UIFont(name: .苹方_中粗体, size: 16)
    public var titleFont: UIFont = UIFont(name: .苹方_中粗体, size: 16)
    
    /// 消息字体，默认为 UIFont(size: 16)
    public var messageFont: UIFont = UIFont(size: 16)
    
    /// 标题对齐方式。默认为 .left
    public var titleAlignment: NSTextAlignment = .left
    
    /// 消息文本对齐方式。默认为 .left
    public var messageAlignment: NSTextAlignment = .left
        
    /// 标题的最大行数。默认值是0(没有限制)。
    public var titleNumberOfLines = 0
    
    /// 消息的最大行数。默认值是0(没有限制)。
    public var messageNumberOfLines = 0
    
    /// 启用或禁用 toast 上的阴影。默认为 false.
    public var displayShadow = false
    
    /// 阴影颜色，默认 .black
    public var shadowColor: UIColor = .black
    
    /// 一个从0.0到1.0的值，表示阴影的不透明度。默认值是0.8(不透明度80%)。
    public var shadowOpacity: Float = 0.8 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }

    /// 阴影圆角半径。默认是6.0.
    public var shadowRadius: CGFloat = 6.0
    
    
    /// 阴影偏移量。默认值是4 * 4.
    public var shadowOffset = CGSize(width: 4.0, height: 4.0)
    
    /// 图像大小。默认为80 x 80.
    public var imageSize = CGSize(width: 80.0, height: 80.0)
    
    /// 当 makeToastActivity(position:) 被调用时，toast 活动视图的大小。默认为68 x 68.
    public var activitySize = CGSize(width: 68.0, height: 68.0)
    
    /// 淡入/淡出动画持续时间。默认是0.2。
    public var fadeDuration: TimeInterval = 0.2
    
    /// 活动指示器的颜色。默认设置是“.white”.
    public var activityIndicatorColor: UIColor = .white
    
    /// 活动指示器背景颜色。默认为黑色，不透明度为80%.
    public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
}

// MARK: - Toast Manager

/**
 `ToastManager` provides general configuration options for all toast
 notifications. Backed by a singleton instance.
*/
public class ToastManager {
    
    /**
     The `ToastManager` singleton instance.
     
     */
    public static let shared = ToastManager()
    
    /**
     The shared style. Used whenever toastViewForMessage(message:title:image:style:) is called
     with with a nil style.
     
     */
    public var style = ToastStyle()
    
    /**
     Enables or disables tap to dismiss on toast views. Default is `true`.
     
     */
    public var isTapToDismissEnabled = true
    
    /**
     Enables or disables queueing behavior for toast views. When `true`,
     toast views will appear one after the other. When `false`, multiple toast
     views will appear at the same time (potentially overlapping depending
     on their positions). This has no effect on the toast activity view,
     which operates independently of normal toast views. Default is `false`.
     
     */
    public var isQueueEnabled = false
    
    /**
     The default duration. Used for the `makeToast` and
     `showToast` methods that don't require an explicit duration.
     Default is 3.0.
     
     */
    public var duration: TimeInterval = 3.0
    
    /**
     Sets the default position. Used for the `makeToast` and
     `showToast` methods that don't require an explicit position.
     Default is `ToastPosition.Bottom`.
     
     */
    public var position: ToastPosition = .bottom
    
}

// MARK: - ToastPosition

public enum ToastPosition {
    case top
    case center
    case bottom
    
    fileprivate func centerPoint(forToast toast: UIView, inSuperview superview: UIView) -> CGPoint {
        let topPadding: CGFloat = ToastManager.shared.style.verticalPadding + superview.csSafeAreaInsets.top
        let bottomPadding: CGFloat = ToastManager.shared.style.verticalPadding + superview.csSafeAreaInsets.bottom
        
        switch self {
        case .top:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
        case .center:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding)
        }
    }
}

// MARK: - Private UIView Extensions

private extension UIView {
    
    var csSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
}
