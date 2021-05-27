//
//  JudyBaseTabBarCtrl.swift
//  建议作为所有 UITabBarController 的基类。
//
//  Created by 王仁洁 on 2017/6/21.
//  Copyright © 2017年 数睿科技（深圳）. All rights reserved.
//

import UIKit

/// TabBarCtrl 基类。
/// * 支持 tabBar.items 小 icon 使用原图功能，该功能默认为 false，需要手动在 Storyboard 中开启。
open class JudyBaseTabBarCtrl: UITabBarController {
    
    /// 是否使 tabBar.items 中的图标使用原图，默认 false，若需要此功能请在 storyboard 手动开启
    /// - warning: 初始值必须为 false
    @IBInspectable
    public private(set) var isItemOriginal: Bool = false
    
    
    // MARK: - tabBarCtrl 生命周期
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 变更 tabBar icon 的呈现模式（原色彩）
        if isItemOriginal, let items = tabBar.items {
            for item in items {
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            }
        }
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
}


// MARK: - UITabBarControllerDelegate

extension JudyBaseTabBarCtrl: UITabBarControllerDelegate {
    
    // 询问委托是否应该激活指定的视图控制器。
    open func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        tabBar.isHidden = false
        
        return true
    }
    
    // 告诉委托用户在选项卡栏中选择了一个项。
    open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        /*
        // 在子类中重写此方法
        Judy.log("当前选中\(tabBarController.selectedIndex)")
        let items = tabBarController.tabBar.items
        
        for item in items! {
            if item == tabBarController.tabBar.selectedItem {
                item.image = nil
            } else {
                item.image = #imageLiteral(resourceName: "airplan")
            }
        }
        */
        
    }

}


/// 适用于 JudyPlusButtonTabBar 的协议。
///
/// 该协议处理 JudyPlusButtonTabBar 中按钮。
/// - 中间按钮点击事件需实现以下函数。
/// ```
/// func judyAction(sender: UIButton)
/// ```
/// * 协议名后面添加 AnyObject 关键字将协议采用限制为对象类型,而不是结构体或枚举。
public protocol JudyPlusButtonActionDelegate: AnyObject {
    
    /// JudyPlusButtonTabBar 中间大按钮点击事件。
    ///
    /// - Parameter sender: 中间按钮对象。
    func judyAction(sender: UIButton)
}

/// 该 TabBar 在 UITabBar 基础上添加了一个大按钮，只需要给 judy 设置一张图片就可以实现。
///
/// * 通过 install() 函数安装大按钮。
/// * 通过 remove() 函数移除大按钮。
/// * 通过 judyDelegate 代理设置大按钮点击事件。
///
/// - warning: 如果设置了 judyViewCtrl，则点击大按钮会切换到该 judyViewCtrl 而不执行代理方法。
open class JudyPlusButtonTabBar: UITabBar {
    
    /**
     对应的父级 UITabBarController,通过 Storyboard 连线的方式关联，改变 viewControllers 会自动执行 layoutIfNeeded()。
     - 会在父 tabBarCtrl.viewCtrls 里插入一个空的 ViewCtrl。
     */
    @IBOutlet private(set) weak var tabBarCtrl: UITabBarController? {
        didSet{
            if tabBarCtrl != nil && oldValue == nil {
                // 在中间插入一个空白viewCtrl
                tabBarCtrl!.viewControllers!.insert(UIViewController(), at: tabBarCtrl!.viewControllers!.count/2)
            } else if tabBarCtrl == nil && oldValue != nil {
                oldValue!.viewControllers!.remove(at: oldValue!.viewControllers!.count/2)
            } else {    // tabBarCtrl,oldValue 都不为 nil
                Judy.log("tabBarCtrl 已经是 nil，无需再次设置。")
            }
        }
    }


    // MARK: - public var
    
    /// 是否正圆，默认 false。
    @IBInspectable var isRound: Bool = false
    
    /// judy 往上的偏移量，默认 0，此属性将直接改变 judy.center.y。
    @IBInspectable var beyondHeight: CGFloat = 0
    
    /// 增大 judy 的边长。默认是以 UITabBarButton 高度度作为边长。默认0。
    @IBInspectable var bigSquareSide: CGFloat = 0
    
    /// judy 的代理，此代理包含点击事件方法。
    public weak var judyDelegate: JudyPlusButtonActionDelegate?

    
    // MARK: - private var
    
    /// 中间按钮的图片，此图片将决定整个大按钮的生命周期。
    /// - Warning: 此属性仅作为通过在 storyboard 中设置图片以安装中间大按钮。
    @IBInspectable private var judy: UIImage? = nil {
        didSet {
            // 安装
            if oldValue == nil, judy != nil {
                installPlusButton()
            }
            // 卸载
            if oldValue != nil, judy == nil {
                uninstallPlusButton()
            }
            // 更新
            if oldValue != nil, judy != nil {
                judyButton!.setImage(judy, for: .normal)
            }
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    /// 添加中间按钮时需要加入到 viewControllers 中的 ViewCtrl。
    ///
    /// 如果设置了该 ViewCtrl，这中间按钮点击时会直接切换到该 ViewCtrl 而不执行代理方法。
    var judyViewCtrl: UIViewController? {
        didSet{
            guard tabBarCtrl != nil else {
                Judy.log("tabBarCtrl 为 nil！可能需要 install()")
                return
            }
            tabBarCtrl!.viewControllers!.remove(at: tabBarCtrl!.viewControllers!.count/2)
            // 在中间插入指定 viewCtrl
            tabBarCtrl!.viewControllers!.insert(judyViewCtrl!, at: tabBarCtrl!.viewControllers!.count/2)
        }
    }
    
    /// 实际交互的按钮。
    public private(set) var judyButton: UIButton? {
        didSet{
            if oldValue == nil, judyButton != nil {
                addSubview(judyButton!)
            }
            if oldValue != nil, judyButton == nil {
                judyButton?.removeFromSuperview()
            }

        }
    }
    
    /// judyButton 的底层 View,这个 View 要将 UITabBar 上的 item 完全挡住。
    private var backgroundView: UIView? {
        didSet{
            if oldValue == nil, backgroundView != nil {
                addSubview(backgroundView!)
            }
            if oldValue != nil, backgroundView == nil {
                backgroundView?.removeFromSuperview()
            }

        }
    }
    
    /// 此对外的 imageView 是为了支持 gif 图片，使用前请给其初始化。
    ///
    /// 该 imageView 将覆盖在中间按钮之上。
    /// - warning: 使用该 imageView 时会将 judyButton 隐藏，将 judyImageView = nil 即可恢复 judyButton。
    public var judyImageView: UIImageView? {// = UIImageView()
        didSet {
            
            if oldValue == nil, judyImageView != nil {
                updateViews()
                judyButton?.isHidden = true
                addSubview(judyImageView!)
            }
            
            if oldValue != nil, judyImageView == nil {
                judyButton?.isHidden = false
                judyImageView?.removeFromSuperview()
            }
            
        }
    }
    

    // MARK: - 生命周期
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        updateViews()
    }

    
    // MARK: - 重写重载父类方法
    
    // 按钮超出 TabBar 部分点击手势失效问题。
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard judy != nil else { return super.hitTest(point, with: event) }
        
        if (clipsToBounds || isHidden || (alpha == 0.0)) { return nil }
        
        // 因为按钮内部imageView突出
        let newPoint: CGPoint = convert(point, to: judyButton!.imageView)
        // 点属于按钮范围
        if judyButton!.imageView!.point(inside: newPoint, with: event ?? UIEvent()) {
            return judyButton
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
}


// MARK: 公开函数

public extension JudyPlusButtonTabBar {
    
    /// 安装大按钮。
    ///
    /// 此函数将设置中间大按钮的图像。
    /// - Parameters:
    ///   - tabBarCtrl: 父级 tabBarCtrl。
    ///   - judyImage: judy 显示的图片。
    /// - warning: 如果调用此函数将覆盖通过 Storyboard 连线的方式设置的 tabBarCtrl 对象。
    func install(withTabBarCtrl tabBarCtrl: UITabBarController, judyImage: UIImage) {
        self.tabBarCtrl = tabBarCtrl
        judy = judyImage
    }

    /// 是否已经存在 judy 中间大按钮。
    func isInstalled() -> Bool { judy == nil }

    /// 移除大按钮（将 judy 从 tabBar 上移除）。
    func remove() { judy = nil }

}


// MARK: 私有函数

private extension JudyPlusButtonTabBar {
    
    /// 当 judy 被赋值通过此函数初始化所有相关 view。
    func installPlusButton() {

        backgroundView = UIView()
        backgroundView!.backgroundColor = .clear
        
        judyButton = UIButton(type: .custom)
        judyButton?.layer.masksToBounds = true
        judyButton?.addTarget(self, action:#selector(buttonAction), for:.touchUpInside)
        // 给按钮设置图片
        judyButton!.setImage(judy, for: .normal)
    }
    
    /// 当 judy 被释放通过此函数将所有相关 view 移除
    func uninstallPlusButton() {

        judyImageView = nil
        judyButton = nil
        backgroundView = nil
        
        tabBarCtrl = nil
        judyViewCtrl = nil
    }
    
    /// 更新相关视图（尺寸、堆叠层次）
    func updateViews() {
        
        guard judy != nil else {
            Judy.log("请在 storyboard 中为 judy 设置一张图片!")
            return
        }

        for tabBarItem in subviews {
            if tabBarItem.isKind(of: NSClassFromString("UITabBarButton")!) {
                
                // backgroundView 要和 tabBarItem 同宽，和 tabBar 同高
                backgroundView!.frame = CGRect(x: 0, y: 0, width: tabBarItem.frame.size.width, height: tabBarItem.frame.size.height + 1)
                backgroundView!.center.x = bounds.size.width/2  //保证 backgroundView 水平居中
                
                // 设置中间按钮的边长，以backgroundView的高度为边长。将frame设置成正方形
                let btnWidth = backgroundView!.frame.size.height + bigSquareSide
                judyButton!.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnWidth)
                judyButton!.center.x = center.x
                judyButton!.center.y = tabBarItem.center.y - (btnWidth-backgroundView!.frame.size.height) - beyondHeight
                
                break
            }
        }
        
        if isRound { judyButton?.viewRound() }

        // 整理 view 堆叠层次
        bringSubviewToFront(backgroundView!)
        bringSubviewToFront(judyButton!)
        
        if judyImageView != nil {
            judyImageView!.frame = judyButton!.frame
            bringSubviewToFront(judyImageView!)
        }
    }
    
    
    // MARK: - 代理或点击事件
    
    /// 按钮点击事件。
    ///
    /// - Parameter sender: sender。
    @objc func buttonAction(sender: UIButton) {
        if judyViewCtrl == nil {
            if judyDelegate == nil {
                Judy.log("大按钮无法响应点击事件，请设置 judyDelegate!")
            } else {
                judyDelegate?.judyAction(sender: sender)
            }
        } else {
            tabBarCtrl?.selectedIndex = tabBarCtrl!.viewControllers!.count/2
            judyViewCtrl?.view.backgroundColor = .red
        }
    }
}
