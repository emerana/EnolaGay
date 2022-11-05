//
//  JudyBaseWebViewCtrl.swift
//  Alamofire
//
//  Created by 醉翁之意 on 2022/11/5.
//

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

        let myWebView = WKWebView(viewBounds: view.bounds)
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

// MARK: - 为 WKWebView 新增构造函数

public extension  WKWebView {

    /// 生成一个 WKWebView，该 webView 自带 WKWebViewConfiguration.
    ///
    /// 参考以下代码加载 html 字符:
    /// ```
    /// webView.loadHTMLString(apiData["content"].stringValue, baseURL: nil)
    /// // 记得在 viewDidLayoutSubviews 调整 webViewframe.
    /// webView?.frame = CGRect(x: 0, y: 0, width: webViewParentView!.frame.size.width, height: webViewParentView!.frame.size.height)
    /// ```
    /// - Parameter frame: 为该 webView 制定一个 frame
    convenience init(viewBounds frame: CGRect) {
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
        self.init(frame: frame, configuration: config)
    }
    
}

