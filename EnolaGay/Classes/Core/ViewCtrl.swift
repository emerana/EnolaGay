//
//  Created by 王仁洁 on 2017/8/4.
//  Copyright © 2017年 数睿科技 8891.com.tw. All rights reserved.
//

import UIKit
import SwiftyJSON

@available(*, unavailable, message: "暂不可用")
public class Tip {
    var title = "标题"
    var subTitle = "副标题"
    var toast: JudyTipViewCtrl?
    var hostViewCtrl: UIViewController?

    
    public init(host: UIViewController) {
        hostViewCtrl = host
    }
    
    public func show(msg: String) {
        let currentBundle = Bundle(for: JudyTipViewCtrl.classForCoder())
        guard let tipViewCtrl = currentBundle.loadNibNamed("TipViewCtrl", owner: nil, options: nil)?.first as? JudyTipViewCtrl else {
            return
        }
        hostViewCtrl?.addChild(tipViewCtrl)
        hostViewCtrl?.view.addSubview(tipViewCtrl.view)
        toast = tipViewCtrl
    }
    
    public func dismiss() {
        toast?.view.removeFromSuperview()
        toast?.removeFromParent()
    }
    
    deinit {
        Judy.logHappy("Tip 已释放")
    }

}

@available(*, unavailable, message: "暂不可用")
public class JudyTipViewCtrl: UIViewController {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init() {
//        let nibNameOrNil = String(classForCoder.string)
        let currentBundle = Bundle(for: JudyTipViewCtrl.classForCoder())
        
         // 考虑到 xib 文件可能不存在或被删，故加入判断
//        [NSBundle bundleWithPath:[[NSBundle bundleForClass:[CHDatePickerView class]] pathForResource:@"CHDatePickerLocalizable" ofType:@"bundle"]];
//        let s = Bundle(path:
//                Bundle(for: JudyTipViewCtrl.classForCoder()).path(forResource: "JudyTipViewCtrl", ofType: "bundle")!
//        )
//
        if currentBundle.path(forResource: "TipViewCtrl", ofType: "xib") != nil {
             self.init(nibName: "TipViewCtrl", bundle: nil)
         } else {
             self.init(nibName: nil, bundle: nil)
             view.backgroundColor = .white
         }
    }
    
    deinit { Judy.logHappy("\(classForCoder) - 已释放") }
}

/// 遵循统一标准的核心 ViewController
///
/// * 重写 viewTitle 属性为当前界面设置标题
/// * 本类中包含一个 json，用好它
/// * 本类中已集成 Api 层，通过设置 requestConfig 对象以配置请求信息，请求流详见 reqApi().
open class JudyBaseViewCtrl: UIViewController {

    // MARK: - public var property

    /// 为当前设置一个标题。**当前界面的标题显示优先顺序为 viewTitle > title > navigationItem.title.**
    ///
    /// 如需更改显示的标题请在 viewDidLoad 之后设置 navigationItem.title 即可
    /// - Warning: 重写读写属性方式为实现 get、set，且里面最好全调用 super，尤其是 set.
    open var viewTitle: String? { nil }
    /// 当前界面包含的 json 数据，设置该值将触发 jsonDidSet() 函数，初值为 JSON().
    open var json = JSON() { didSet{ jsonDidSet() } }

    // MARK: Api 相关属性
    
    /// 请求配置对象
    open lazy var requestConfig = ApiRequestConfig()
    /// 服务器响应的 JSON 数据
    final lazy private(set) public var apiData = JSON()
    
    /// 当前界面网络请求成功的标识，默认 false.
    ///
    /// 该值为 false 时会在 viewWillAppear() 中触发 reqApi()；
    /// 若需要取消该请求，重写父类 viewWillAppear()，并在调用父类之前将值改为 true. 参考如下代码：
    /// ```
    /// isReqSuccess = true
    /// super.viewWillAppear(animated)
    /// ```
    /// - Warning: 注意生命周期 viewWillAppear() ，每次都会调用；
    /// * 当 requestConfig.api = nil，reqApi() 中会将该值设为 true;
    /// * 若需要界面每次出现都发送请求，请在 super.viewWillAppear() 之前或 reqApi() 响应后（如 reqOver()）将该值设为 false.
    final lazy public var isReqSuccess: Bool = false

    /// 是否由当前 viewCtrl 决定 statusBarStyle，默认 false.
    /// - Warning: 如果该值为 true，则重写 preferredStatusBarStyle 以设置当前 viewCtrl 的 statusBarStyle.
    open var isCustomStatusBarStyle: Bool? { return nil }
        
    
    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 优化 title 显示方式，如果 viewTitle 为 nil，则使用该 viewCtrl 的 title.
        if viewTitle == nil {
            if title != nil { navigationItem.title = title }
        } else {
            title = viewTitle
            navigationItem.title = title
        }
        
        // 设置背景色
        view.backgroundColor = EMERANA.enolagayAdapter?.viewBackgroundColor() ?? .white
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 若请求失败，则需在每次视图出现时重新发起请求
        if !isReqSuccess { reqApi() }
        
        // Judy-mark: 正确的修改导航条方式
        /*
         navigationController?.navigationBar.barTintColor = .white
         navigationController?.navigationBar.tintColor = .black
         setNeedsStatusBarAppearanceUpdate()
         */
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 在界面即将消失（包含所有界面跳转）时关闭所有键盘
        UIApplication.shared.windows.last?.endEditing(true)
    }
        
    // MARK: - override
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        Judy.topViewCtrl.view.endEditing(true)
    }
    
    /// 重写此函数以配置当 json 被设置的事件
    /// - Warning: 若要在此函数中设置 UI 需要注意 json 的设置一定要在 viewDidLoad 之后
    open func jsonDidSet() {}

    // MARK: Api 相关函数
    
    /// 发起网络请求
    ///
    /// 通过调用此函数发起一个完整的请求流，此方法中将更新 apiData.
    /// - Warning: 此方法中会更改 isReqSuccess 对应状态
    /// - 请求结果在此函数中分流，此函数内部将依次执行以下函数，请重写相关函数以实现对应操作
    ///     - setApi()
    ///     - reqResult()
    ///     - reqSuccess() / reqFailed()
    ///     - reqOver()
    /// - Parameters:
    ///   - isSetApi: 是否需要调用 setApi()，默认 true，需重写 setApi() 并在其中设置 requestConfig 信息；若 isSetApi = false，则本次请求不调用 setApi().
    ///   - isSupportWaitingHUD: 该请求是否允许显示等待过程的 HUD，默认 true，若该值为 false，即使 isGlobalHideWaitingHUD 为 true 也将无效
    public final func reqApi(isSetApi: Bool = true, isSupportWaitingHUD: Bool = true) {
        if isSetApi { setApi() }
        优化未设置 Api 的处理情况
        // 为设置 api 直接不发起请求
        guard requestConfig.api != nil else {
            self.apiData = EMERANA.notsetApiERROR
            isReqSuccess = true
            reqNotApi()
            return
        }
        
        if isSupportWaitingHUD {
            if !Self.isGlobalHideWaitingHUD() { view.toast.makeToastActivity(.center) }
        }
        
        /// 接收响应的闭包
        let responseClosure: ((JSON) -> Void) = { [weak self] json in
            guard let `self` = self else {
                Judy.logWarning("发现逃逸对象！")
                return
            }
            self.view.toast.hideToastActivity()

            self.apiData = json
            self.reqResult()

            // 先处理失败情况
            if let error = self.apiData.ApiERROR {
                // 如果是未设置 api 则视为请求成功处理
                self.isReqSuccess = error[.code].intValue == EMERANA.ErrorCode.notSetApi
                self.reqFailed()
            } else {
                self.isReqSuccess = true
                self.reqSuccess()
            }
            
            self.reqOver()
        }

        // 发起请求
        requestConfig.request(withCallBack: responseClosure)
    }
    
    /// 设置 requestConfig 及其它任何需要在发起请求前处理的事情
    ///
    /// 在整个 reqApi() 请求流程中最先执行的方法
    /// - Warning: 在此方法中配置好 requestConfig 对象，一般情况子类可以不调用 super.setApi().
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
    
    /// 当 api 为 nil 时调用了 reqApi() ，请求流将终止在此方法中，不会进行网络请求，且 isReqSuccess 将被设为 true.
    ///
    /// 此方法应主要执行在上下拉刷新界面时需要中断 header、footer 刷新状态，更改 isReqSuccess 等操作
    open func reqNotApi() {}
    
    /// 当服务器有响应时，最先执行此方法，无论请求是否成功。**此时 apiData 为服务器返回的元数据**
    open func reqResult() {}
    
    /// 请求成功的消息处理
    ///
    /// - Warning: 若在此函数中涉及到修改 requestConfig.api 并触发 reqApi() 请注意先后顺序，遵循后来居上原则
    open func reqSuccess() {}
    
    /// 请求失败或服务器响应为失败信息时的处理，在父类该函数将弹出失败消息体。若无需弹出请重写此函数并不调用 super 即可
    open func reqFailed() {
        if let error = apiData.ApiERROR {
            view.toast.makeToast(error[.msg].stringValue)
        }
    }
    
    /// 在整个请求流程中最后执行的方法
    ///
    /// - Warning: 执行到此方法时，setApi() -> [ reqResult() -> reqFailed() / reqSuccess() ] 整个流程已经全部执行完毕
    open func reqOver() {}
    
    deinit {
        Judy.logHappy("\(classForCoder) - \(viewTitle ?? title ?? navigationItem.title ?? "未命名界面") 已释放")
    }
    
}


// MARK: - WKWebView
import WebKit

/// 内置一个 WKWebView 的基础控制器
///
/// 内置的 WKWebView 已经具备以下功能：
/// * 若未设置界面标题将默认使用网页附带的 title;
/// * 网页内容自适应屏幕宽度；
/// * 禁止长按/选择 网页内容；
open class JudyBaseWebViewCtrl: UIViewController, WKNavigationDelegate {

    /// 目标 url,webView 将打开该路径
    public var url: String?

    /// 核心 webView.
    public private(set) lazy var  webView: WKWebView = {
        // 初始化偏好设置属性：preferences.
        let preferences = WKPreferences()
        // 是否支持 JavaScript.
        preferences.javaScriptEnabled = true
        // 不通过用户交互，是否可以打开窗口
        preferences.javaScriptCanOpenWindowsAutomatically = false

        let myWebView = judy.webView()
        myWebView.configuration.preferences = preferences
        
        return myWebView
    }()
    
    /// 网页加载进度指示条，允许更改该 progressView 的外观
    public private(set) lazy var progressView = UIProgressView()

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 记得在 deinit 中 webView.configuration.userContentController.removeScriptMessageHandler
        // webView.configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "JMWPay")
        guard url != nil,
              let url = URL(stringUTF8: url!) else {
            Judy.logWarning("无效 url，不能将无法打开 WKWebView!")
            return
        }
        
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        webView.load(URLRequest(url: url))

        view.addSubview(progressView)
        progressView.progressTintColor = .red
        progressView.trackTintColor = .clear
        progressView.frame = webView.frame
        progressView.frame.size.height = 3
        progressView.progress = 1

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    deinit {
        Judy.logHappy("\(classForCoder) - \(title ?? "未命名的 WebViewCtrl") 已经释放。")
    }
    
    // KVO.
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 监听网页加载进度
        progressView.progress = Float(webView.estimatedProgress)
    }
    
    
    // MARK: - WKNavigationDelegate
    
    // 网页内容加载完成之后触发
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // 获取网页 title.
        if title == "" { title = webView.title }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.progressView.isHidden = true
        }
        
        // 禁止长按/选择 事件
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)

    }
    
    // 页面加载失败时调用
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.progressView.progress = 0.0
            self?.progressView.isHidden = true
        }
    }

}


// MARK: - 为 UIViewController 提供的包装对象函数

/// 由 EnolaGay 为 UIViewController 提供的函数
public extension EnolaGayWrapper where Base: UIViewController {
    
    /// 此函数将在系统的 present 函数基础上强化，使目标 viewController 的 modalPresentationStyle 属性为 fullScreen.
    func present(_ viewController: UIViewController, presentationStyle: UIModalPresentationStyle = .fullScreen, animated: Bool, completion: (() -> Void)? = nil) {
        if viewController.modalPresentationStyle == .pageSheet {
            viewController.modalPresentationStyle = presentationStyle
        }
        base.present(viewController, animated: animated, completion: completion)
    }

    
    /// 生成一个 WKWebView，该 webView 的 frame 为 view.bounds，且已加载自适应屏幕宽度脚本
    ///
    /// 参考以下代码加载 html 字符:
    /// ```
    /// webView.loadHTMLString(apiData["content"].stringValue, baseURL: nil)
    /// // 记得在 viewDidLayoutSubviews 调整 webViewframe.
    /// webView?.frame = CGRect(x: 0, y: 0, width: webViewParentView!.frame.size.width, height: webViewParentView!.frame.size.height)
    /// ```
    /// - Returns: WKWebView.
    func webView() -> WKWebView {
        let config = WKWebViewConfiguration()
        // 创建 UserContentController（提供 JavaScript 向 webView 发送消息的方法）
        let userContent = WKUserContentController()
        // 添加消息处理，注意：self 指代的对象需要遵守 WKScriptMessageHandler 协议，结束时需要移除
        // userContent.add(self, name: "NativeMethod")
        /*
         // 原有的，不支持图文混排
         let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
         */
        
        // 自适应屏幕宽度 js.
        let jSString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}"
        let wkUserScript = WKUserScript(source: jSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        // 添加自适应屏幕宽度 js 调用的方法
        userContent.addUserScript(wkUserScript)
        // 将 UserConttentController 设置到配置文件
        config.userContentController = userContent

        return WKWebView(frame: base.view.bounds, configuration: config)
    }


    // MARK: - gradientLayer 渐变

    /// 获取一个 CAGradientLayer 渐变
    /// * 使用方式如下：
    /// ```
    /// self.view.layer.insertSublayer(gradientLayer, at: 0)
    /// ```
    ///
    /// - Parameters:
    ///   - vertical: 是否垂直方向的渐变，默认是。否则为横向渐变
    ///   - frame: 默认为屏幕 frame.
    ///   - startColor: 起始颜色，默认为 red.
    ///   - endColor: 终止颜色，默认为 green.
    /// - Returns: CAGradientLayer 对象
    func getGradient(vertical: Bool = true, frame: CGRect = UIScreen.main.bounds, startColor: UIColor = .red, endColor: UIColor = .green) -> CAGradientLayer {
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
    

    // MARK: - 截图功能

    /// 截取指定 UIScrollView 生成图片
    ///
    /// - Parameters:
    ///   - targetScrollView: 要保存为图片的 UIScrollView.
    ///   - transparent: 是否透明，默认 false，如果背景颜色可能是部分透明我们必须用白色填充
    ///   - savedPhotosAlbum: 是否保存到相册，默认 false.
    /// - Warning: 调用此方法务必在 viewDidAppear 函数之后
    /// - Returns: 你要的图像
    func captureScreenImage(targetScrollView: UIScrollView, transparent: Bool = false, savedPhotosAlbum: Bool = false ) -> UIImage? {
        
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

    /// 截取指定 View 生成图片
    ///
    /// - Parameters:
    ///   - targetView: 要保存为图片的 View.
    ///   - transparent: 是否透明，默认 false，如果背景颜色可能是部分透明我们必须用白色填充
    ///   - complete: 是否需要截取完整视图层次结构（包含状态栏），默认 false.
    /// - Warning: 调用此方法务必在 viewDidAppear 函数之后
    /// - Returns: 你要的图像
    func captureScreenImage(targetView: UIView, transparent: Bool = false, complete: Bool = false) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let rect = CGRect(origin: CGPoint(x: targetView.judy.x, y: targetView.judy.y), size: targetView.bounds.size)
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
    
    /// 截取指定 View 生成图片，并保存到相册
    ///
    /// - Parameters:
    ///   - targetView: 要保存为图片的 View.
    ///   - transparent: 是否透明
    /// - Warning: 调用此方法务必在 viewDidAppear 函数之后
    /// - Returns: 保存结果
    @discardableResult
    func captureImageSavedPhotosAlbum(targetView: UIView, transparent: Bool = false) -> Bool {
        
        let image = captureScreenImage(targetView: targetView, transparent: transparent)
        guard image != nil else {
            Judy.log("图片截取失败！")
            return false
        }
        
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        return true
    }


    // MARK: - UIViewController 其他扩展函数

    /// 递归查找 UITextField.
    /// - Parameter view: UITextField 可能存在的父 View.
    func recursionUITextField(view: UIView) -> UIView? {
        
        var textField: UIView? = nil
        
        for subView in view.subviews {
            if let _ = subView as? UITextField {
                return subView
            } else {
                textField = recursionUITextField(view: subView)
            }
        }
        
        return textField
    }
        
    
    // MARK: 将导航栏移出屏幕外
    
    /// 移动导航条，将导航栏移出屏幕外（或恢复原位置）
    ///
    /// - Parameter isHihe: 是否隐藏。默认值应该为 false.
    /// - Warning: 该方法一般要调用两次（移动之后需要恢复）
    func moveNavigationBar(isHihe: Bool = false) {
        guard base.navigationController != nil else { return }
        
        UIView.animate(withDuration: 0.2) {
            // 获取状态栏高度
            let statusBarHeight = UIApplication.shared.judy.statusBarView?.frame.size.height ?? 0
            
            let yDiff = isHihe ? base.navigationController!.navigationBar.frame.origin.y - base.navigationController!.navigationBar.frame.size.height - statusBarHeight :base.navigationController!.navigationBar.frame.origin.y + base.navigationController!.navigationBar.frame.size.height + statusBarHeight
            // 重设 navigationBar.frame
            base.navigationController!.navigationBar.frame =
                CGRect(x: 0, y: yDiff,
                       width: base.navigationController!.navigationBar.frame.size.width,
                       height: base.navigationController!.navigationBar.frame.size.height)
        }
    }
    
    /// 弹出一个系统警告框，只包含一个取消类型的按钮。通常用于临时性提醒、警告作用
    /// - Parameters:
    ///   - title: alert的标题，默认为"提示"
    ///   - msg: 消息文字
    ///   - cancelButtonTitle: 取消按钮的标题，默认为"确定"
    ///   - cancelAction: 取消按钮点击事件，默认为 nil.
    func alert(title: String = "提示", msg: String? = nil, cancelButtonTitle: String = "确定", cancelAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        // 创建 UIAlertAction 控件
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { alertAction in
            cancelAction?()
        }
        alertController.addAction(cancelAction)
        base.present(alertController, animated: false, completion: nil)
    }
    
    /// 获取当前 UIViewController 的导航控制器
    ///
    /// - Returns: UIViewController的导航控制器对象
    func navigationCtrller() -> UINavigationController {
        var navigationController: UINavigationController!
        
        if base.isKind(of: UINavigationController.classForCoder()) {
            navigationController = base as? UINavigationController
        } else {
            if base.isKind(of: UITabBarController.classForCoder()) {
                navigationController = (base as! UITabBarController).selectedViewController?.judy.navigationCtrller()
            } else { // 只能是 UIViewController
                guard navigationController != nil else {
                    Judy.logWarning("当前 ViewCtrl 没有可用的 UINavigationController，故返回了一个 UINavigationController()")
                    return UINavigationController()
                }
                
                navigationController = base.navigationController!
            }
        }
        return navigationController
    }
}

// MARK: 需要升级的函数

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
}


/// 此方式处理键盘遮挡输入框方式已废弃
/*
private extension UIViewController {

    /// 在 extension 中新增存储属性相关的key
    private struct AssociatedKey {
        static var keyBoardHeight: CGFloat = 0
        static var keyBoardView: UIView?
        static var isSafeAreaInsetsBottom = false
    }

    /// 键盘的高度（如果有弹出键盘）
    private(set) var keyBoardHeight: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.keyBoardHeight) as? CGFloat ?? 0
        }
        set {   // Bugfix: OBJC_ASSOCIATION_ASSIGN 会崩溃，用 OBJC_ASSOCIATION_COPY 就可以
            objc_setAssociatedObject(self, &AssociatedKey.keyBoardHeight, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 需要跟随键盘移动的目标 View，通常为输入框的父视图
    private(set) weak var quoteKeyBoardView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.keyBoardView) as? UIView
        }
        set { // OBJC_ASSOCIATION_RETAIN_NONATOMIC 也可以
            objc_setAssociatedObject(self, &AssociatedKey.keyBoardView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// keyBoardView 是否有保留安全区域底部内边距
    private var isSafeAreaInsetsBottom: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.isSafeAreaInsetsBottom) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.isSafeAreaInsetsBottom, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    /// 注册监听键盘弹出收起事件，该函数可使 quoteKeyBoardView 跟随键盘弹出收起
    /// - Parameter keyBoardView: 需要跟随键盘移动的 view，一般为输入框所在的父 View.
    /// - Parameter isSafeAreaInsetsBottom: keyBoardView 是否保留安全区域底部内边距，默认 true，keyBoardView 在跟随键盘弹出时会自动扣除安全区域的高度距离，反之亦然
    func registerKeyBoardListener(forView keyBoardView: UIView, isSafeAreaInsetsBottom: Bool = true) {
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.quoteKeyBoardView = keyBoardView
        self.isSafeAreaInsetsBottom = isSafeAreaInsetsBottom
    }
    
    /// 监听事件，键盘弹出或收起时均会触发此函数
    @objc private func keyBoardShowHideAction(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        /// 改变目标 keyBoardView 的执行过程事件，更新其 2D 仿射变换矩阵
        let animations: (() -> Void) = { [weak self] in
            // 键盘弹出事件
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度
                self?.keyBoardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                
                /// quoteKeyBoardView y 轴需要移动的距离
                var yDiff = -self!.keyBoardHeight
                // 判断是否有底部安全区域
                if self!.isSafeAreaInsetsBottom {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                    yDiff += bottomPadding
                }
                self?.quoteKeyBoardView?.transform = CGAffineTransform(translationX: 0,y: yDiff)
            }
            // 键盘收起事件
            if notification.name == UIResponder.keyboardWillHideNotification {
                self?.quoteKeyBoardView?.transform = CGAffineTransform.identity
            }
        }
        
        // 键盘弹出过程时长
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘，直接更新 keyBoardView 2D仿射变换矩阵
            animations()
        }

    }
    
}
*/
