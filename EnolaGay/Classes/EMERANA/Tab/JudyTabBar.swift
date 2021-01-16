//
//  JudyTabBar.swift
//  MyTabBar
//  可以实现在Tabbar中间放置一个自定义的按钮
//  Created by Judy-王仁洁 on 2017/7/14.
//  Copyright © 2017年 ICBC. All rights reserved.
//

import UIKit


/**
 JudyTabBar 中间大按钮协议。包含JudyTabBar中间按钮点击事件。
 - 中间按钮点击事件需实现以下函数
 ```
 judyAction(sender: UIButton)
 ```
 ## 协议名后面添加 class 关键字将协议采用限制为类类型,而不是结构体或枚举
 */
public  protocol EMERANA_TabBar: class {
    
    /// JudyTabBar中间按钮点击事件
    ///
    /// - Parameter sender: 中间按钮
    func judyAction(sender: UIButton)
}

/**
 JudyTabBar 中间大按钮协议。包含JudyTabBar中间按钮点击事件，需实现以下函数。
 ```
 judyAction(sender: UIButton)
 */
@available(*, deprecated, message: "该协议已更名，请使用新协议", renamed: "EMERANA_TabBar")
public  protocol EMERANATabBar: class {
    /// JudyTabBar中间按钮点击事件
    ///
    /// - Parameter sender: 中间按钮对象
    @available(*, deprecated, message: "该函数所属协议已更名，请使用新协议")
    func judyAction(sender: UIButton)
}

/**
 自定义Tabbar,只需要给judy设置一张图片就可以实现在tabbar中间添加一个按钮，
 核心是一个tabBar上叠加一个backgroundView和一个button，点击button实现功能。
 * 使用方式
 ```
 tabBar.setJudy(withTabBarCtrl: tabBarController!, judyImage: #imageLiteral(resourceName: "ABC"))
 ```
 - 移除方式
 ```
 tabBar.setJudyNil()
 ```
 ## 按钮的点击事件实现JudyTabBarDelegate即可。请自行建立public extension并实现EMERANATabBar。
 ```
 (self.tabBarController?.tabBar as? JudyTabBar)?.judyDelegate = self
 ```
 ## 如果设置了judyViewCtrl，则点击judy会切换到该viewCtrl而不执行代理方法。
 ```
 tabBar.setJudyViewCtrl(viewCtrl: UIViewController)
 ```
 */
@IBDesignable open class JudyTabBar: UITabBar {
    // @IBDesignable class 就是告诉IB可以动态预览
    
    // MARK: - IBOutlet var
    
    /**
     对应的父级UITabBarController,通过Storyboard连线的方式关联，改变viewControllers会自动layoutIfNeeded()
     - 会在父tabBarCtrl.[vc]里插入一个空ViewCtrl
     */
    @IBOutlet private(set) weak var tabBarCtrl: UITabBarController? {
        didSet{
            if tabBarCtrl != nil && oldValue == nil {
                // 在中间插入一个空白viewCtrl
                tabBarCtrl!.viewControllers!.insert(UIViewController(), at: tabBarCtrl!.viewControllers!.count/2)
            } else if tabBarCtrl == nil && oldValue != nil {
                oldValue!.viewControllers!.remove(at: oldValue!.viewControllers!.count/2)
            } else {    // tabBarCtrl,oldValue都不为nil
                Judy.log("已经设置了tabBarCtrl或tabBarCtrl已经是nil")
            }
        }
    }

    /**
     中间按钮的图片，一旦设置了图片，就意味着tabBar上会加上一个按钮
     
     - 设置judy方式
     ```
     tab.setJudy(withTabBarCtrl: tabBarController!, judyImage: #imageLiteral(resourceName: "ABC"))

     ```
     - 使用以下方法移除中间按钮
     ```
     tab.setJudyNil()
     ```
     */
    @IBInspectable private var judy: UIImage? = nil {
        didSet {
            if judy != nil {
                initButton()
            } else {
                deinitButton()
            }
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    // MARK: - public var

    /// 是否需要动画,默认false，这样在SB界面可以直观看到效果
//    @IBInspectable dynamic public var animate: Bool = false {
//        didSet{
    
//        }
//    }
    /// 是否正圆
    @IBInspectable var isRound: Bool = false
    
    /// judy往上的偏移量，默认0，此属性将直接改变judy.center.y
    @IBInspectable var beyondHeight: CGFloat = 0
    
    /// 增大judy的边长。默认是以UITabBarButton高度度作为边长。默认0
    @IBInspectable var bigSquareSide: CGFloat = 0
    
    /// judy的代理，此代理包含点击事件方法
    public weak var judyDelegate: EMERANA_TabBar?

    // MARK: - private var

    /// 添加中间按钮时需要加入到 viewControllers 中的 ViewCtrl。
    ///
    /// 如果设置了该ViewCtrl，这中间按钮点击时会直接切换到该ViewCtrl而不执行代理方法。
    /// - warning: 使用 setJudyViewCtrl() 函数以设置 ViewCtrl
    /// - since: v2.0 2021年01月06日17:04:54
    private(set) var judyViewCtrl: UIViewController?
    
    public private(set) var judyButton: UIButton? = nil
    
    /// 这个View要将UITabBarButton完全挡住
    private var backgroundView: UIView? = nil
    
    /// 对外的 imageView
    ///
    /// 该 imageView 将覆盖在中间按钮之上
    /// - warning: 需要该 imageView 时记得隐藏 judyButton
    /// - since: v2.0 2021年01月06日17:06:23
    public private(set) lazy var judyImageView: UIImageView = UIImageView()
    

    // MARK: - 生命周期方法
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard judyButton != nil, backgroundView != nil, tabBarCtrl != nil  else {
            Judy.log((judyButton == nil ? "judyButton":backgroundView == nil ? "backgroundView":"tabBarCtrl")+"为空！不更新judy!")
            return
        }

        self.updateFrame()
        
        judyImageView.frame = judyButton!.frame

//        UIView.animate(withDuration: 0.5) {
//            self.layoutIfNeeded()
//        }

    }

    // MARK: - 重写重载父类方法

    // 按钮超出 TabBar 部分点击手势失效问题
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard judy != nil else {
            return super.hitTest(point, with: event)
        }
        if (clipsToBounds || isHidden || (alpha == 0.0)) {
            return nil
        }
        // 因为按钮内部imageView突出
        let newPoint: CGPoint = convert(point, to: judyButton!.imageView)
        // 点属于按钮范围
        if judyButton!.imageView!.point(inside: newPoint, with: event ?? UIEvent()) {
            return judyButton
        } else {
            return super.hitTest(point, with: event)
        }
    }

    // MARK: - 代理或点击事件

    /// 按钮点击事件
    ///
    /// - Parameter sender: sender
    @objc private func buttonAction(sender: UIButton) {
        if judyViewCtrl == nil {
            judyDelegate?.judyAction(sender: sender)
        } else {
            tabBarCtrl?.selectedIndex = tabBarCtrl!.viewControllers!.count/2
            judyViewCtrl?.view.backgroundColor = .red
        }
    }
    
    
    // MARK: public method
    
    
    /// 获取当前tabBar上是否已经存在 judy 中间大按钮
    ///
    /// - Returns: judy == nil ?
    public func isJudy() -> Bool { return judy == nil }
    
    /// 将judy从tabBar上移除
    public func removeJudy(){ judy = nil }
    
    /// 设置judy
    ///
    /// - Parameters:
    ///   - tabBarCtrl: 父级tabBarCtrl
    ///   - judyImage: judy显示的图片
    public func setJudy(withTabBarCtrl tabBarCtrl: UITabBarController, judyImage: UIImage){
        self.tabBarCtrl = tabBarCtrl
        judy = judyImage
    }
    
    /// 设置添加judy时需要加入到viewControllers中的ViewCtrl。
    /// 如果设置了该ViewCtrl，这中间按钮点击时会直接切换到该ViewCtrl而不执行代理方法。
    /// - Parameter viewCtrl: judy需要展示的ViewCtrl
    public func setJudyViewCtrl(viewCtrl: UIViewController){
        guard tabBarCtrl != nil else {
            Judy.log("此时，tabBarCtrl还是nil，请先setJudy()!")
            return
        }
        judyViewCtrl = viewCtrl
        tabBarCtrl!.viewControllers!.remove(at: tabBarCtrl!.viewControllers!.count/2)
        // 在中间插入指定viewCtrl
        tabBarCtrl!.viewControllers!.insert(viewCtrl, at: tabBarCtrl!.viewControllers!.count/2)
    }
    
    
    // MARK: private method

    /// 初始化按钮及背景图
    private func initButton() {

        if backgroundView == nil {
            backgroundView = UIView()
            // 将背景图的颜色保持和barTint颜色一致
            backgroundView!.backgroundColor = .clear //barTintColor //backViewColor ??

            addSubview(backgroundView!)
        }
        
        if judyButton == nil {
            judyButton = UIButton.init(type: .custom)
            judyButton!.layer.masksToBounds = true
            judyButton!.addTarget(self, action:#selector(buttonAction), for:.touchUpInside)
            judyButton!.showsTouchWhenHighlighted = true    //  使其在按住的时候不会有黑影
            if isRound {
                judyButton?.viewRound()
            }
            
            addSubview(judyButton!)
            addSubview(judyImageView)
            
        }
        
        judyButton!.setImage(judy, for: .normal)

    }
    
    /// 将按钮和bgView移除
    private func deinitButton() {
        judyImageView.removeFromSuperview()
        judyButton?.removeFromSuperview()
        backgroundView?.removeFromSuperview()
        judyButton = nil
        backgroundView = nil
        tabBarCtrl = nil
        judyViewCtrl = nil
    }
    
    /// 更新控件
    private func updateFrame() {
        for tabBarItem in subviews {
            if tabBarItem.isKind(of: NSClassFromString("UITabBarButton")!) {
                
                // backgroundView要和tabBarItem同宽，和tabBar同高
                backgroundView!.frame = CGRect(x: 0, y: 0, width: tabBarItem.frame.size.width, height: tabBarItem.frame.size.height + 1)
                backgroundView!.center.x = bounds.size.width/2  //保证backgroundView水平居中
                
                // 设置中间按钮的边长，以backgroundView的高度为边长。将frame设置成正方形
                let btnWidth = backgroundView!.frame.size.height + bigSquareSide
                judyButton?.frame = CGRect.init(x: 0, y: 0, width: btnWidth, height: btnWidth)
                judyButton?.center.x = center.x
                judyButton?.center.y = tabBarItem.center.y - (btnWidth-backgroundView!.frame.size.height) - beyondHeight
                
                break
            }
        }
        bringSubviewToFront(backgroundView!)
        bringSubviewToFront(judyButton!)
        bringSubviewToFront(judyImageView)

    }
    
}
