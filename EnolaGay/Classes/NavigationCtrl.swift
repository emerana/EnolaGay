//
//  NavigationCtrl.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 2018/3/31.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//


/// JudyBaseNavigationCtrl navigationBar 相关协议，包括 barTintColor、backIndicatorImage、tintColor、titleColor
public protocol EMERANA_NavigationBar where Self: JudyBaseNavigationCtrl {
    
    /// 为所有 JudyBaseNavigationCtrl 对象设置一个统一指示符图像
    ///
    /// - Returns: UIImage: 指定的返回图标，若为 nil 则使用 storyboard 设置的或系统自带的, Bool: 决定了是否使用图片原色彩
    func setBackIndicatorImage() -> (UIImage?, Bool)
    
    /// 设置 navigationBar的 barTintColor(此操作可能会影响到毛玻璃效果)，若要使用此函数请确保 storyboard 中该属性为 Default
    /// - Parameter color: 要设置的目标颜色，若该颜色的 alpha 为 0，则 barTintColor 为 nil。该值默认值 nil (judy(.navigationBarTint))
    /// - Parameter isApplyBackground: 是否需要一块设置 navigationBar.backgroundColor，默认值 false
    func setBarTintColor(color: UIColor?, isApplyBackground: Bool)

    /// 设置 JudyBaseNavigationBar 上的所有 items 的颜色（两侧按钮、返回箭头)
    /// - Parameter color: 要设置的目标颜色，默认值 nil (.judy(.text))
    func setItemsColor(color: UIColor?)
    
    /// 设置标题颜色
    /// - Parameters:
    ///   - color: 要设置的目标颜色，默认值 nil(.judy(.navigationBarTitle))
    ///   - isApplyTint: 是否需要同时设置 navigationBar 上的 tintColor，默认 false
    func setTitleColor(color: UIColor?, isApplyTint: Bool)

}


// MARK: - JudyBaseNavigationCtrl

import UIKit

/// 所有导航条的根类
open class JudyBaseNavigationCtrl: UINavigationController {

    // MARK: var
    
    /// 是否通过 EMERANA 配置获取 barTint、tint、titleTextAttributes 颜色？默认 true
    /// * 如果需要在 storyboard 中设置颜色只需将该值关闭即可，否则 storyboard 中的设置将被 EMERANA 覆盖
    @IBInspectable private var EMERANA: Bool = true
    
    /// 当前 navigationCtrl navigationBar 的返回指示符图像
    @IBInspectable private lazy var backImage: UIImage? = nil
    
    /// 是否使用深色的(.default)状态栏样式，默认 true, 反之为 lightContent
    /// # 当 ViewCtrl 嵌入于 navigationCtrl 中，则由 navigationCtrl 负责 preferredStatusBarStyle。
    /// # **如果通过代码改变还需要调用 setNeedsStatusBarAppearanceUpdate() 方法。**
    @IBInspectable var isGaryStatusBar: Bool = true

    // plist 文件中需要将 View controller-based status bar appearance 设置成 YES 才能设置状态栏颜色
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        var style = UIStatusBarStyle.default
        style = isGaryStatusBar ? .default : .lightContent
        guard let viewCtrl: JudyBaseViewCtrl = viewControllers.last as? JudyBaseViewCtrl else {
            return style
        }
        // 如果该 JudyBaseViewCtrl 有设置 isCustomStatusBarStyle 则取它的 statusBatStyle
        if viewCtrl.isCustomStatusBarStyle != nil && viewCtrl.isCustomStatusBarStyle! {
            //return the status property of each VC, look at step 2
            style = viewCtrl.preferredStatusBarStyle
        }
        
        return style
    }

    
    // MARK: life
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // 设置指示符图像
        var backIndicatorImage = backImage
        if backImage == nil {
            backIndicatorImage = setBackIndicatorImage().0
        }
        //  设置导航条返回箭头
        let isAlwaysOriginal = setBackIndicatorImage().1
        // 如果自定义返回指示符图像，还必须设置 backIndicatorTransitionMaskImage
        navigationBar.backIndicatorImage = backIndicatorImage?.withRenderingMode(isAlwaysOriginal ? .alwaysOriginal:.automatic)
        // 如果要自定义反向指示符图像，还必须设置此图像
        navigationBar.backIndicatorTransitionMaskImage = backIndicatorImage?.withRenderingMode(isAlwaysOriginal ? .alwaysOriginal:.automatic)
        
        // EMERANA 配色
        if EMERANA {

            setBarTintColor()
            
            setTitleColor()

            setItemsColor()
        }
        
    }
        
    /// 覆盖 push 事件，实现在 push 过程中自定义部分操作。
    ///
    /// - Parameters:
    ///   - viewController: 当前ViewCtrl
    ///   - animated: 动画
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            
            // 解决 push 时右上角出现可恶的黑影，给 keyWindow 设置背景色即可，一般为白色或 EMERANA 配置的通用背景色
            Judy.keyWindow!.backgroundColor = .white

            // 将底部TabBar隐藏
            viewController.hidesBottomBarWhenPushed = true
            
            // Judy-mark:在父级ViewCtrl中使用这句将左侧返回按钮标题清空，保留箭头
            children.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }

        // Judy-mark: 完全清空左侧返回按钮。此方法会使右划手势失效，无法 pop。
        // viewController.navigationItem.setLeftBarButton(UIBarButtonItem(), animated: false)
        
        if topViewController != nil {
            // topViewController!.responds(to: #selector(topViewController!.pushAction))，是通过 public extension 新增的函数，所以该函数一定有响应。
            topViewController!.pushAction(current: topViewController!, pushTo: viewController)

        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
}

// MARK: - EMERANA_NavigationBar 协议实现
extension JudyBaseNavigationCtrl: EMERANA_NavigationBar {
    
    public func setBackIndicatorImage() -> (UIImage?, Bool) {
        return (nil, false)
    }
    
    
    final public func setBarTintColor(color: UIColor? = nil, isApplyBackground: Bool = false) {
        var barTintColor = UIColor.blue
        
        if color != nil { barTintColor = color! }
        
        // 设置 navigationBarTint 颜色，对 barTint 设置颜色将会影响到毛玻璃效果
        if barTintColor.cgColor.alpha == 0 {
            navigationBar.barTintColor = nil
        } else {
            navigationBar.barTintColor = barTintColor
        }
        if isApplyBackground {
            navigationBar.backgroundColor = barTintColor
        } else {
            navigationBar.backgroundColor = nil
        }
    }
    
    final public func setItemsColor(color: UIColor? = nil) {
        var barColor = UIColor.white
        if color != nil { barColor = color! }
        // 设置 navigationBar 上所有 item(标题两侧按钮或返回箭头) 的色彩
        navigationBar.tintColor = barColor
    }
    
    
    final public func setTitleColor(color: UIColor? = nil, isApplyTint: Bool = false) {
        var titleColor = UIColor.white
        if color != nil { titleColor = color! }
        // 设置 navigationBar 上的 titleColor(foregroundColor)
        // 该属性的值是一个 UIColor 对象。使用此属性在呈现时指定文本的颜色。如果没有指定此属性，则将文本呈现为黑色。
        let attributed: [NSAttributedString.Key: Any] = [.foregroundColor: titleColor]
        if navigationBar.titleTextAttributes == nil {
            navigationBar.titleTextAttributes = attributed
        } else {
            navigationBar.titleTextAttributes![.foregroundColor] = attributed[.foregroundColor]
        }
        
        if isApplyTint {
            setItemsColor(color: titleColor)
        }

    }

    
    
}



// MARK: - 扩展返回按钮图标及导航条透明
public extension JudyBaseNavigationCtrl {

    /// 将导航栏设为透明，一般用于 viewWillAppear()，恢复请调用 resetNav()
    /// # 一般和 resetNav() 成对使用
    /// * 如果在 resetNav() 中需要恢复阴影线请使用代理隐藏导航条的方式
    func setNavTransParent(){
        // 透明
        navigationBar.isTranslucent = true
        // 设置导航栏背景图片为一个空的image，这样就透明了
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        // 去掉透明后导航栏下边的黑边
        navigationBar.shadowImage = UIImage()
    }
    
    /// 恢复导航栏，当设置了导航栏设为透明时，别的界面不需要透明调用此方法恢复。一般用于 viewWillDisappear()
    /// # 一般和 setNavTransParent() 成对使用
    /// * 由于在 setNavTransParent() 中会将 isTranslucent = true，所以调用此函数后需自行设置 isTranslucent
    func resetNav(){
        navigationBar.shadowImage = nil
        // 不让其他页面的导航栏变为透明 需要重置
        navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    /// 设置导航栏渐变背景色，渐变方向为从左向右
    ///
    /// - Parameters:
    ///   - startColor: 起始颜色，默认为red
    ///   - endColor: 终止颜色，默认为green
    func setNavGradient(startColor: UIColor = .red, endColor: UIColor = .green)  {

        // self.navigationBar.layer.insertSublayer(gradientLayer, at: 0)     // 这样无效
        let backgroundImage = UIImage(gradientColors: startColor, endColor: endColor, frame: navigationBar.frame)
        self.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        
    }
    
}


// MARK: - 配合拦截系统导航条返回事件，为 JudyBaseViewCtrl 新增返回按钮点击函数
extension JudyBaseViewCtrl {
    
    /// 当前界面导航条返回按钮点击事件，此函数决定了是否执行 pop 事件
    /// * 此函数依然能手势滑动返回，可以用以下方式禁用系统侧滑返回
    /// ```
    /// self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    /// ```
    /// * 如果使用了 JudyNavigationCtrl，则依然可以直接侧滑返回，但点按钮仍然会被拦截
    /// * JudyNavigationCtrl 中默认就关闭了 interactivePopGestureRecognizer(交互手势识别器)
    /// # 重写方式
    /// ```
    /// override func judyPopOnBackBtn() -> Bool {
    ///      // do something
    ///      return false/true
    /// }
    /// ```
    /// // Handle the pop gesture
    /// ```
    /// override func willMove(toParentViewController parent: UIViewController?) {
    ///      if parent == nil { // When the user swipe to back, the parent is nil
    ///          // do something
    ///          return
    ///      }
    ///      super.willMove(toParentViewController: parent)
    /// }
    /// ```
    /// * Returns: 是否允许执行 pop?
    @objc open func judyPopOnBackBtn() -> Bool {
        return true
    }

}


// MARK: 拦截系统导航条返回事件，遵循 UINavigationBarDelegate
extension JudyBaseNavigationCtrl: UINavigationBarDelegate {
    
    /// 重写 UINavigationBarDelegate 的 pop 事件，在此实现拦截
    ///
    /// - Parameters:
    ///   - navigationBar: 导航条
    ///   - item: item
    /// - Returns: rs
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool{
        
        guard let items = navigationBar.items else { return false }
        
        if viewControllers.count < items.count { return true }
        
        var isShouldPop = true
        
        // 使用 judyPopOnBackBtn 函数返回结果来决定是否放行
        if let vc = topViewController as? JudyBaseViewCtrl,
            vc.responds(to: #selector(JudyBaseViewCtrl.judyPopOnBackBtn)){

            isShouldPop = vc.judyPopOnBackBtn()
        }
        
        return isShouldPop
        /*
         if isShouldPop {
         DispatchQueue.main.async {
         self.popViewController(animated: true)
         }
         } else {
         for aView in navigationBar.subviews{
         if aView.alpha > 0 && aView.alpha < 1{
         aView.alpha = 1.0
         }
         }
         }
         return false
         */
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {

        Judy.keyWindow?.backgroundColor = nil
    }

    
    
    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {

    }
        
}


// MARK: 为 UIViewController 新增 push 函数，并配合 JudyBaseNavigationCtrl 控制器
extension UIViewController {

    /// 当前界面 push 事件，该函数只在导航控制器为 JudyBaseNavigationCtrl 下才有效。
    /// * 常用于当前界面 push 新界面之后无需返回此界面场景，参考如下代码：
    /// ```
    ///    if viewCtrl === self {
    ///        let newViewCtrls = navigationController?.viewControllers.filter({ (viewCtrl) -> Bool in
    ///            // 移除当前 ViewCtrl
    ///            return viewCtrl !== self
    ///        })
    ///
    ///        navigationController?.viewControllers = newViewCtrls!
    ///
    ///    }
    /// ```
    /// - Parameters:
    ///   - viewCtrl: 当前的 viewCtrl
    ///   - targetViewCtrl: push 的目标 viewCtrl
    @objc open func pushAction(current viewCtrl: UIViewController, pushTo targetViewCtrl: UIViewController) {
        
    }
    
}


// MARK: - JudyNavigationCtrl


/// 很酷的右划返回手势，当点击左上角返回按钮则是标准的返回样式
public class JudyNavigationCtrl: JudyBaseNavigationCtrl {
    
    /// 触摸的起点
    private lazy var startTouch = CGPoint(x: 0, y: 0)
    /// push前最后的屏幕快照
    private lazy var lastScreenShotView: UIImageView? = nil
    /// 黑色遮罩 View
    private lazy var blackMask: UIView? = nil
    private lazy var backgroundView: UIView? = nil
    /// 截图列表
    private var screenShotsList = [UIImage]()
    
    /// 是否正在移动
    private lazy var isMoving = false
    /// 平移手势
    private var recognizer: UIPanGestureRecognizer!
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 平移手势
        recognizer = UIPanGestureRecognizer.init(target: self, action: #selector(paningGestureReceive(recoginzer:)))
        view.addGestureRecognizer(recognizer)
        reOpenRecognizer()
        
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {

        // push 之前截取当前屏幕
        let capturedImage = judy_captureScreenImage(targetView: topView, complete: true)
        screenShotsList.append(capturedImage!)
        
        super.pushViewController(viewController, animated: animated)
    }
    
    @discardableResult
    public override func popViewController(animated: Bool) -> UIViewController? {
        // pop 之前将最后一个截图删除
        screenShotsList.removeLast()
        return super.popViewController(animated: animated)
    }
    
    deinit {
        backgroundView?.removeFromSuperview()
        backgroundView = nil
        Judy.log("JudyNavigation 释放！")
    }
    
}

// MARK: - 公开方法
extension JudyNavigationCtrl {
    
    /// 关闭向右滑动 Pop 事件，调用此函数后将失去全屏 Pop 手势能力，请调用 reOpenRecognizer() 函数重新开启该能力
    final func closeRecognizer() {
        recognizer.delegate = nil
        // 开启系统自带返回手势
        interactivePopGestureRecognizer?.isEnabled = true

    }
    
    /// 重新开启向右滑动 Pop 能力
    final func reOpenRecognizer() {
        recognizer.delegate = self
        // 禁用系统自带返回手势，因为系统自带返回手势 pop 时机不一样
        interactivePopGestureRecognizer?.isEnabled = false
    }

    
    /// 人工模拟手势全屏返回
    ///
    /// - Parameter duration: pop 持续时长，默认0.3
    final func doPopAction(duration: Double = 0.3) {

        UIView.animate(withDuration: duration, animations: {
            self.panBeganAction(startTouchPoint: CGPoint(x: 0, y: 0))
            if self.isMoving {
                self.moveViewWithX(x: self.view.frame.width)
            }
        }) { (rs) in
            self.popActionWithAnimate()
        }
        
    }
    
}

// MARK: - 私有事件
private extension JudyNavigationCtrl {

    var keyWindow: UIWindow { return Judy.keyWindow! }
    var topView: UIView { return Judy.keyWindow!.rootViewController!.view }
    
    /// 移动 topView 的位置
    ///
    /// - Parameter x: frame 的 x ，跟随手指移动实时刷新
    func moveViewWithX(x: CGFloat){
        var x = x
        // 最大最小值限制
        x = x > view.frame.width ? view.frame.width:x
        x = x < 0 ? 0:x
        
        // Judy.log("当前移动X:\(x)")
        
        // 移动顶层 View 的 X
        topView.frame.origin.x = x
        
        // 规模为1时表示不缩放
        var scale: CGFloat = (x/6800) + 0.95
        scale = scale > 1 ? 1:scale
        // 滑动过程中的遮罩 View 能见度
        let alpha = 0.68*(1 - x/view.frame.width)
        
        lastScreenShotView?.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        blackMask?.alpha = alpha
        
    }
    
    /// 手指离开屏幕，拖动结束事件，此事件未达到 navigationCtrl pop 条件，还原 topView 位置
    func panEndedReductionAction() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.moveViewWithX(x: 0)
        }) { (finished) in
            self.isMoving = false
            self.backgroundView?.isHidden = true
        }
        
    }
    
    /// 手指开始拖动事件
    ///
    /// - Parameter startTouchPoint: 触摸的起点
    func panBeganAction(startTouchPoint: CGPoint) {
        isMoving = true
        startTouch = startTouchPoint
        
        if backgroundView == nil {
            let frame = topView.frame
            backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            topView.superview?.insertSubview(backgroundView!, belowSubview: topView)
            
            blackMask = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            blackMask?.backgroundColor = .black
            backgroundView?.addSubview(blackMask!)
        }
        
        backgroundView?.isHidden = false
        
        if lastScreenShotView != nil {
            lastScreenShotView?.removeFromSuperview()
            lastScreenShotView = nil
        }
        
        let lastScreenShot = screenShotsList.last
        lastScreenShotView = UIImageView(image: lastScreenShot)
        backgroundView?.insertSubview(lastScreenShotView!, belowSubview: blackMask!)
    }

    /// 以动画的方式触发 Pop 事件
    func popActionWithAnimate() {
        UIView.animate(withDuration: 0.3, animations: {
            self.moveViewWithX(x: self.view.frame.width)
        }) { (finished) in
            // 触发 pop
            self.popViewController(animated: false)
            
            self.topView.frame.origin.x = 0
            self.isMoving = false
            self.backgroundView?.isHidden = true
            // 将遮罩层恢复为不透明
            self.blackMask?.alpha = 1
        }
    }
    
    
    /// 平移手势事件，不断的执行
    @objc func paningGestureReceive(recoginzer: UIPanGestureRecognizer){
        if viewControllers.count <= 1 {
            return
        }
        
        // 平移时将window背景设为黑色
        keyWindow.backgroundColor = .black
        
        let touchPoint = recoginzer.location(in: keyWindow)
        
        // 开始拖动屏幕触发
        if recoginzer.state == .began {
            //            Judy.log("began")
            panBeganAction(startTouchPoint: touchPoint)
            
            // 结束，手指离开屏幕触发
        } else if recoginzer.state == .ended {
            //            Judy.log("ended")
            // 设置滑动多少距离就可以触发pop
            if touchPoint.x - startTouch.x > 28 {
                popActionWithAnimate()
            } else {
                panEndedReductionAction()
            }
            return
        } else if recoginzer.state == .cancelled {  // 取消了
            //            Judy.log("cancelled")
            panEndedReductionAction()
            return
        }
        
        if isMoving {
            moveViewWithX(x: touchPoint.x - startTouch.x)
        }
        
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension JudyNavigationCtrl: UIGestureRecognizerDelegate {
    
    // 接收事件代理方法
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return children.count > 1
    }
    
}
