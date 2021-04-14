//
//  Created by 王仁洁 on 2017/8/4.
//  Copyright © 2017年 数睿科技 8891.com.tw. All rights reserved.
//

/*
 实现的功能描述：
 1：实现统一的背景色，支持单独设置背景色，若未单独设置则使用统一的背景色。
 2：界面出现即加载网络数据并正确展示，若加载失败，该界面每次出现需再次加载网络数据，直到加载成功。
 */

import UIKit
import SwiftyJSON

/// 遵循统一标准的 ViewController。
/// - warning: **该 viewController 遵循以下标准**
/// * 重写 viewTitle 以设置标题
/// * 设置 requestConfig 对象以配置请求信息
open class JudyBaseViewCtrl: UIViewController {

    
    // MARK: - public var property

    /// navigationItem.title，该 viewTitle 优先于 self.title 显示，且将覆盖 self.title。
    ///
    /// 如需更改该值请在 viewDidLoad 之后 navigationItem.title = 新 title 即可。
    /// - Warning: 重写读写属性方式为实现 get、set，且里面最好全调用 super，尤其是 set。
    open var viewTitle: String? { return nil }
    /// 当前界面包含的 json 数据，设置该值将触发 jsonDidSet() 函数，初值为 JSON()。
    open var json = JSON() { didSet{ jsonDidSet() } }

    
    // MARK: Api 相关属性
    
    /// 请求配置对象。
    open lazy var requestConfig = ApiRequestConfig()
    /// 服务器响应的 JSON 数据。
    final lazy private(set) public var apiData = JSON()
    
    /// 当前界面网络请求成功的标识，默认 false。
    ///
    /// 该值为 false 时会在 viewWillAppear() 中触发 reqApi()；若需要取消该请求，重写父类 viewWillAppear() 参考如下代码：
    /// ```
    /// isReqSuccess = true
    /// super.viewWillAppear(animated)
    /// ```
    /// - Warning: 注意生命周期 viewWillAppear() ，每次都会调用；
    /// * 当 requestConfig.api = nil，reqApi() 中会将该值设为 true;
    /// * 若需要界面每次出现都发送请求，请在 super.viewWillAppear() 之前或 reqApi() 响应后（如 reqOver()）将该值设为 false。
    final lazy public var isReqSuccess: Bool = false

    /// 是否由当前 viewCtrl 决定 statusBarStyle，默认 false。
    /// - Warning: 如果该值为 true，则重写 preferredStatusBarStyle 以设置当前 viewCtrl 的 statusBarStyle。
    open var isCustomStatusBarStyle: Bool? { return nil }

    
    // MARK: - private var property
    
    
    // MARK: - Life Cycle
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 优化 title 显示方式，如果 viewTitle 为 nil，则使用该 viewCtrl 的 title。
        if viewTitle == nil {
            navigationItem.title = title
        } else {
            navigationItem.title = viewTitle
            title = viewTitle
        }
        
        // 在 viewCtrl 中 view 的背景色默认是 systemBackground。
        if #available(iOS 13.0, *) {
            if view.backgroundColor == UIColor.systemBackground {
                view.backgroundColor = .judy(.view)
            }
        } else {
            if view.backgroundColor == nil {
                view.backgroundColor = .judy(.view)
            }
        }

    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 若请求失败，则需在每次视图出现时重新发起请求。
        if !isReqSuccess { reqApi() }
        
        // Judy-mark: 正确的修改导航条方式。
        /*
         navigationController?.navigationBar.barTintColor = .white
         navigationController?.navigationBar.tintColor = .black
         setNeedsStatusBarAppearanceUpdate()
         */
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 在界面即将消失（包含所有界面跳转）时关闭所有键盘。
        UIApplication.shared.windows.last?.endEditing(true)
        
        // 2020年09月01日16:33:47 注释原因：不具备通用性
        // navigationController?.setNavigationBarHidden(false, animated: true)
    }
        
    // MARK: - override
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // 在界面即将消失（包含所有界面跳转）时关闭所有键盘。
        UIApplication.shared.windows.last?.endEditing(true)
    }
    
    
    /// 重写此函数以配置当 json 被设置的事件。
    open func jsonDidSet() {}
    

    // MARK: Api 相关函数
    
    /// 发起网络请求。
    ///
    /// 通过调用此函数发起一个完整的请求流，此方法中将更新 apiData。
    /// - Warning: 此方法中会更改 isReqSuccess 对应状态。
    /// - 请求结果在此函数中分流，此函数内部将依次执行以下函数，请重写相关函数以实现对应操作
    ///     - setApi()
    ///     - reqResult()
    ///     - reqSuccess() / reqFailed()
    ///     - reqOver()
    /// - Parameters:
    ///   - isSetApi: 是否需要调用 setApi()，默认 true，需重写 setApi() 并在其中设置 requestConfig 信息；若 isSetApi = false，则本次请求不调用 setApi()。
    public final func reqApi(isSetApi: Bool = true) {
        if isSetApi { setApi() }
        // 为设置 api 直接不发起请求。
        guard requestConfig.api != nil else {
            isReqSuccess = true
            return
        }
        
        if !Self.isGlobalHideWaitingHUD() { JudyTip.wait() }
        
        /// 接收响应的闭包。
        let responseClosure: ((JSON) -> Void) = { [weak self] json in
            guard let strongSelf = self else {
                JudyTip.message(messageType: .error, text: "发现逃逸对象！")
                return
            }
            strongSelf.apiData = json
            strongSelf.reqResult()
            
            //  存在 EMERANA.Key.JSON.error 即失败。
            if json[EMERANA.Key.JSON.error].isEmpty {
                JudyTip.dismiss()
                strongSelf.isReqSuccess = true
                strongSelf.reqSuccess()
            } else {
                // 确保错误代码不是未设置 api。
                strongSelf.isReqSuccess = json[EMERANA.Key.JSON.error, EMERANA.Key.JSON.code].intValue == EMERANA.ErrorCode.notSetApi
                strongSelf.reqFailed()
            }
            strongSelf.reqOver()
        }

        // 发起请求。
        requestConfig.request(withCallBack: responseClosure)
    }
    
    /// 设置 requestConfig 及其它任何需要在发起请求前处理的事情。
    ///
    /// 在整个 reqApi() 请求流程中最先执行的方法。
    /// - Warning: 在此方法中配置好 requestConfig 对象，一般情况子类可以不调用 super.setApi()。
    ///
    /// ```
    /// requestConfig.domain = "http://www.baidu.com/Api"
    /// ```
    /// 设置请求api的字段
    /// ```
    /// requestConfig.api = .???
    /// ```
    /// 设置请求参数体
    /// ```
    /// requestConfig.parameters?["userName"] = "Judy"
    /// ```
    open func setApi() {}
    
    /// 当 api 为 nil 时调用了 reqApi() ，请求流将终止在此方法中，不会进行网络请求，且 isReqSuccess 将被设为 true。
    ///
    /// - Warning: 此方法应主要执行在上下拉刷新界面时需要中断 header、footer 刷新状态，更改 isReqSuccess 等操作。
    open func reqNotApi() {}
    
    /// 当服务器有响应时，最先执行此方法，无论请求是否成功。**此时 apiData 为服务器返回的元数据**。
    open func reqResult() {}
    
    /// 请求成功的消息处理
    ///
    /// - Warning: 若在此函数中涉及到修改 requestConfig.api 并触发 reqApi() 请注意先后顺序，遵循后来居上原则
    open func reqSuccess() {}
    
    /// 请求失败或服务器响应失败时的消息处理，该函数默认弹出失败消息体。
    open func reqFailed() {
        let msg = apiData[EMERANA.Key.JSON.error, EMERANA.Key.JSON.msg].string
        JudyTip.message(text: msg)
    }
    
    /// 在整个请求流程中最后执行的方法。
    ///
    /// - Warning: 执行到此方法时，setApi() -> [ reqResult() -> reqFailed() / reqSuccess() ] 整个流程已经全部执行完毕。
    open func reqOver() {}
    
    deinit {
        Judy.log("🚙 <\(viewTitle ?? (title ?? "未命名界面"))> 已经释放 - \(classForCoder)")
    }
    
}


// MARK: - WKWebView

import WebKit
public extension UIViewController {
    
    /**
     生成一个WKWebView
     - 此webView主要用来加载html，里面已经完美适配的屏幕宽度
     ## 使用以下代码加载html字符
     ```
     webView.loadHTMLString(apiData["content"].stringValue, baseURL: nil)
     // 记得在viewDidLayoutSubviews调整webViewframe
     webView?.frame = CGRect(x: 0, y: 0, width: webViewParentView!.frame.size.width, height: webViewParentView!.frame.size.height)
     ```
     - Returns: WKWebView
     */
    final func judy_webView() -> WKWebView {
        let config = WKWebViewConfiguration()
        // 创建UserContentController（提供JavaScript向webView发送消息的方法）
        let userContent = WKUserContentController()
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        //        userContent.add(self, name: "NativeMethod")
        /*
         // 原有的，不支持图文混排
         let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
         */
        
        // 自适应屏幕宽度js
        let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}"
        let wkUserScript = WKUserScript(source: jSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        // 添加自适应屏幕宽度js调用的方法
        userContent.addUserScript(wkUserScript)
        // 将UserConttentController设置到配置文件
        config.userContentController = userContent
        
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        
        return webView
    }
    
}

// MARK: - gradientLayer 渐变
public extension UIViewController {
    
    /// 获取一个CAGradientLayer渐变
    /// * 使用方式如下
    /// ```
    /// self.view.layer.insertSublayer(gradientLayer, at: 0)
    /// ```
    ///
    /// - Parameters:
    ///   - vertical: 是否垂直方向的渐变，默认是。否则为横向渐变。
    ///   - frame: 默认为屏幕frame
    ///   - startColor: 起始颜色，默认为red
    ///   - endColor: 终止颜色，默认为green
    /// - Returns: CAGradientLayer对象
    final func judy_getGradient(vertical: Bool = true, frame: CGRect = UIScreen.main.bounds, startColor: UIColor = .red, endColor: UIColor = .green) -> CAGradientLayer {
        //create gradientLayer
        let gradientLayer : CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        
        //gradient colors
        // Judy.colorByRGB(r: 2, g: 191, b: 101), Judy.colorByRGB(r: 51, g: 221, b: 140)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0);
        gradientLayer.endPoint = CGPoint(x: 1, y: 0);
        if vertical {
            gradientLayer.endPoint = CGPoint(x: 0, y: 1);
        }
        //        self.navigationBar.layer.insertSublayer(gradientLayer, at: 0)     // 这样无效
        //        self.navigationBar.setBackgroundImage(Judy.image(fromLayer: gradientLayer), for: .default)
        return gradientLayer
    }
    
}


// MARK: - 截图功能
public extension UIViewController {
    
    @available(*, unavailable, message: "不要使用这个方法，目前还没完善", renamed: "judyGenerateImage")
    final func judyGenerateImageWithNav(targetScrollView: UIScrollView, transparent: Bool = false, savedPhotosAlbum: Bool = false ) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: targetScrollView.contentSize.width, height: 280) , false, 0.0)
        let topView = Judy.keyWindow!.rootViewController!.view!

        // 将完整视图层次结构的快照以在屏幕上可见的形式呈现到当前上下文中.此方法可以将状态栏也包含
        topView.drawHierarchy(in: topView.frame, afterScreenUpdates: true)
        let imageLitter = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // 截止到此处导航栏正确

        UIGraphicsBeginImageContextWithOptions(targetScrollView.contentSize, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let savedContentOffset = targetScrollView.contentOffset
        let savedFrame = targetScrollView.frame
        let rect = CGRect(x: 0, y: 0, width: targetScrollView.contentSize.width, height: targetScrollView.contentSize.height)
        
        targetScrollView.contentOffset = .zero
        targetScrollView.frame = rect
        
        // 处理背景可能是透明的情况
        if targetScrollView.isOpaque || !transparent {
            // 背景颜色可能是部分透明的，如果我们想输出不透明的图像，我们必须用白色填充
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = targetScrollView.backgroundColor {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        // 将完整视图层次结构的快照以在屏幕上可见的形式呈现到当前上下文中.此方法可以将状态栏也包含
        topView.frame.size = targetScrollView.contentSize
        topView.drawHierarchy(in: topView.frame, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        targetScrollView.contentOffset = savedContentOffset
        targetScrollView.frame = savedFrame
        UIGraphicsEndImageContext()

        
        // 将 imageLitter 添加到新图片上
        
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0)
        
        image!.draw(in: CGRect(origin: CGPoint(), size: image!.size))
        
        imageLitter!.draw(in: CGRect(origin: CGPoint(), size: imageLitter!.size))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        //
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    
    /// 截取指定 UIScrollView 生成图片。 **调用此方法务必在 viewDidAppear 函数之后**
    ///
    /// - Parameters:
    ///   - targetScrollView: 要保存为图片的 UIScrollView
    ///   - transparent: 是否透明，默认 false，如果背景颜色可能是部分透明我们必须用白色填充
    ///   - savedPhotosAlbum: 是否保存到相册，默认 false
    /// - Returns: 你要的图像
    final func judy_captureScreenImage(targetScrollView: UIScrollView, transparent: Bool = false, savedPhotosAlbum: Bool = false ) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(targetScrollView.contentSize, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let savedContentOffset = targetScrollView.contentOffset
        let savedFrame = targetScrollView.frame
        let rect = CGRect(x: 0, y: 0, width: targetScrollView.contentSize.width, height: targetScrollView.contentSize.height)

        targetScrollView.contentOffset = .zero
        targetScrollView.frame = rect
        
        // 处理背景可能是透明的情况
        if targetScrollView.isOpaque || !transparent {
            // 背景颜色可能是部分透明的，如果我们想输出不透明的图像，我们必须用白色填充
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = targetScrollView.backgroundColor {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        targetScrollView.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        targetScrollView.contentOffset = savedContentOffset
        targetScrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        
        if savedPhotosAlbum && image != nil {
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
        
        return image
    }

    
    /// 截取指定 View 生成图片。 **调用此方法务必在 viewDidAppear 函数之后**
    ///
    /// - Parameters:
    ///   - targetView: 要保存为图片的 View
    ///   - transparent: 是否透明，默认 false，如果背景颜色可能是部分透明我们必须用白色填充
    ///   - complete: 是否需要截取完整视图层次结构（包含状态栏），默认 false
    /// - Returns: 你要的图像
    final func judy_captureScreenImage(targetView: UIView, transparent: Bool = false, complete: Bool = false) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let rect = CGRect(origin: CGPoint(x: targetView.x_emerana, y: targetView.y_emerana), size: targetView.bounds.size)
        // 处理背景可能是透明的情况
        if targetView.isOpaque || !transparent {
            // 背景颜色可能是部分透明的，如果我们想输出不透明的图像，我们必须用白色填充
            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            
            if let backgroundColor = targetView.backgroundColor {
                context.setFillColor(backgroundColor.cgColor)
                context.fill(rect)
            }
        }
        
        if complete {
            // 将完整视图层次结构的快照以在屏幕上可见的形式呈现到当前上下文中.此方法可以将状态栏也包含
            targetView.drawHierarchy(in: targetView.frame, afterScreenUpdates: true)
        } else {
            // 将层及其子层呈现到指定上下文中，此方法是不包含状态栏的
            targetView.layer.render(in: context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 截取指定 View 生成图片，并保存到相册。 **调用此方法务必在 viewDidAppear 函数之后**
    ///
    /// - Parameters:
    ///   - targetView: 要保存为图片的 View
    ///   - transparent: 是否透明
    /// - Returns: 保存结果
    @discardableResult
    final func judy_captureImageSavedPhotosAlbum(targetView: UIView, transparent: Bool = false) -> Bool {
        
        let image = judy_captureScreenImage(targetView: targetView, transparent: transparent)
        guard image != nil else {
            Judy.log("图片截取失败！")
            return false
        }
        
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        return true
    }

}


// MARK: - UIViewController 其他扩展函数

public extension UIViewController {
    
    /// 递归查找 UITextField
    /// - Parameter view: UITextField 可能存在的父 View
    func judy_recursionUITextField(view: UIView) -> UIView? {
        
        var textField: UIView? = nil
        
        for subView in view.subviews {
            if let _ = subView as? UITextField {
                return subView
            } else {
                textField = judy_recursionUITextField(view: subView)
            }
        }
        
        return textField
    }
        
    /// 解决 push 时右上角出现可恶的黑影，给 keyWindow 设置背景色即可，一般为白色或 EMERANA 配置的通用背景色
    @available(*,unavailable,message: "此函数太过于简单，弃用之！")
    func judy_setWindowBackgroundColor() {  }
    /// 将 window 背景色重置为 nil
    @available(*,unavailable,message: "此函数太过于简单，弃用之！")
    func judy_resetWindowBackgroundColor() {  }
    
    
    // MARK: 将导航栏移出屏幕外
    
    /// 移动导航条，将导航栏移出屏幕外（或恢复原位置）。
    ///
    /// - Parameter isHihe: 是否隐藏。默认值应该为 false
    /// - Warning: 该方法一般要调用两次（移动之后需要恢复）。
    func judy_moveNavigationBar(isHihe: Bool = false) {
        guard navigationController != nil else { return }
        
        UIView.animate(withDuration: 0.2) {
            // 获取状态栏高度
            let statusBarHeight = UIApplication.shared.statusBarView?.frame.size.height ?? 0
            
            let yDiff = isHihe ? self.navigationController!.navigationBar.frame.origin.y - self.navigationController!.navigationBar.frame.size.height - statusBarHeight :self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.size.height + statusBarHeight
            // 重设 navigationBar.frame。
            self.navigationController!.navigationBar.frame =
                CGRect(x: 0, y: yDiff,
                       width: self.navigationController!.navigationBar.frame.size.width,
                       height: self.navigationController!.navigationBar.frame.size.height)
        }
    }

    
    /// 弹出一个系统警告框，只包含一个确定按钮，没有任何按钮的操作事件。
    ///
    /// 通常用于临时性提醒、警告作用。
    ///
    /// - Parameter title: alert的标题，默认为"提示"。
    /// - Parameter msg: 消息文字。
    /// - Parameter cancelButtonTitle: 取消按钮的标题，默认为"确定"。
    /// - Parameter completionAction: 取消按钮点击事件，默认为 nil。
    func judy_alert(title: String = "提示", msg: String? = nil, cancelButtonTitle: String = "确定", completionAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        // 创建 UIAlertAction 控件
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: false, completion: completionAction)
        }
    }

    
    
    /// 获取当前 UIViewController 的导航控制器。
    ///
    /// - Returns: UIViewController的导航控制器对象。
    final func judy_navigationCtrller() -> UINavigationController {
        var navigationController: UINavigationController!
        
        if self.isKind(of: UINavigationController.classForCoder()) {
            navigationController = self as? UINavigationController
        } else {
            if self.isKind(of: UITabBarController.classForCoder()) {
                navigationController = (self as! UITabBarController).selectedViewController?.judy_navigationCtrller()
            } else { // 只能是 UIViewController
                guard self.navigationController != nil else {
                    Judy.log("🚔当前 ViewCtrl 没有可用的 UINavigationController，故返回了一个 UINavigationController()")
                    return UINavigationController()
                }
                
                navigationController = self.navigationController!
            }
        }
        return navigationController
    }

}

// MARK: - 正确地处理键盘遮挡输入框

public extension UIViewController {
    
    /// 在 extension 中新增存储属性相关的key。
    private struct AssociatedKey {
        static var keyBoardHeight: CGFloat = 0
        static var keyBoardView: UIView?
        static var isSafeAreaInsetsBottom = false
    }
    
    /// 键盘的高度（如果有弹出键盘）。
    private(set) var keyBoardHeight: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.keyBoardHeight) as? CGFloat ?? 0
        }
        set {   // Bugfix: OBJC_ASSOCIATION_ASSIGN 会崩溃，用 OBJC_ASSOCIATION_COPY 就可以。
            objc_setAssociatedObject(self, &AssociatedKey.keyBoardHeight, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 需要跟随键盘移动的目标 View，通常为输入框的父视图。
    private(set) weak var quoteKeyBoardView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.keyBoardView) as? UIView
        }
        set { // OBJC_ASSOCIATION_RETAIN_NONATOMIC 也可以
            objc_setAssociatedObject(self, &AssociatedKey.keyBoardView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// keyBoardView 是否有保留安全区域底部内边距。
    private var isSafeAreaInsetsBottom: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.isSafeAreaInsetsBottom) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.isSafeAreaInsetsBottom, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    
    /// 注册监听键盘弹出收起事件，该函数可使 quoteKeyBoardView 跟随键盘弹出收起。
    /// - Parameter keyBoardView: 需要跟随键盘移动的 view，一般为输入框所在的父 View。
    /// - Parameter isSafeAreaInsetsBottom: keyBoardView 是否保留安全区域底部内边距，默认 true，keyBoardView 在跟随键盘弹出时会自动扣除安全区域的高度距离，反之亦然。
    func registerKeyBoardListener(forView keyBoardView: UIView, isSafeAreaInsetsBottom: Bool = true) {
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.quoteKeyBoardView = keyBoardView
        self.isSafeAreaInsetsBottom = isSafeAreaInsetsBottom
    }
    
    /// 监听事件，键盘弹出或收起时均会触发此函数。
    @objc private func keyBoardShowHideAction(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        /// 改变目标 keyBoardView 的执行过程事件，更新其 2D 仿射变换矩阵。
        let animations: (() -> Void) = { [weak self] in
            // 键盘弹出事件。
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度。
                self?.keyBoardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                
                /// quoteKeyBoardView y 轴需要移动的距离。
                var yDiff = -self!.keyBoardHeight
                // 判断是否有底部安全区域。
                if self!.isSafeAreaInsetsBottom {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                    yDiff += bottomPadding
                }
                self?.quoteKeyBoardView?.transform = CGAffineTransform(translationX: 0,y: yDiff)
            }
            // 键盘收起事件。
            if notification.name == UIResponder.keyboardWillHideNotification {
                self?.quoteKeyBoardView?.transform = CGAffineTransform.identity
            }
        }
        
        // 键盘弹出过程时长。
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘，直接更新 keyBoardView 2D仿射变换矩阵。
            animations()
        }

    }
    
}
