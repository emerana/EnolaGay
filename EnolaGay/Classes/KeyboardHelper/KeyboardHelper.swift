//
//  KeyboardHelper.swift
//
//  正确处理键盘遮挡方法
//
//  Created by 醉翁之意 on 2021/3/18.
//

/// 防止键盘遮挡输入框的工具，让指定 view 跟着键盘移动，就像微信的键盘输入效果。
///
/// 仅需通过 `registerKeyboardListener()` 函数即可实现输入框跟随键盘位置移动从而保证输入框不被遮挡
/// - Warning: 请务必保持实例的有效性，如:
/// ```
/// let keyboardHelper = KeyboardHelper()
/// ```
public final class KeyboardHelper {
    
    /// 此属性用于记录当下键盘的高度，若键盘已被收起则为 0.
    public private(set) var keyboardHeight: CGFloat = 0
    /// 输入框所在的 view,当键盘出现或隐藏，会根据键盘的高度移动该 view.
    private(set) var textFieldWrapperView = UIView()
    /// 是否保留安全区域底部距离，默认 true，textFieldWrapperView 在跟随键盘弹出时会预留该距离是底部的安全区域可见，反之亦然
    private(set) var isKeepSafeAreaInsetsBottom = false
    
    
    public init() { }
    
    /// 注册监听键盘弹出收起事件，该函数可使 inputView 跟随键盘弹出收起
    ///
    /// 当需要实现点击空白区域即收起键盘时需要注意，参考如下代码确定点击的位置：
    /// ```
    /// let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTouches(sender:)))
    /// tapGestureRecognizer.cancelsTouchesInView = false
    /// view.addGestureRecognizer(tapGestureRecognizer)
    ///
    /// @objc func handleTouches(sender: UITapGestureRecognizer) {
    ///     // 只要点击区域不在键盘范围即收起键盘。
    ///     if sender.location(in: view).y < view.bounds.height - keyboardHelper.keyboardHeight {
    ///         textFeild.resignFirstResponder()
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - inputView: 输入框所在的 view,即需要跟随键盘的出现而移动的 view
    ///   - isKeepSafeAreaInsetsBottom: inputView 在往上移动时是否保留安全区域底部距离，默认 false.若将该值传入 true 请确保输入框的底部边距 ≥ 安全区域高度。
    /// - Warning: 请注意与 IQKeyboardManagerSwift 的冲突导致键盘高度计算不准确，关闭之即可。
    public func registerKeyboardListener(forView inputView: UIView, isKeepSafeAreaInsetsBottom: Bool = false) {
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardShowHideAction(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        self.textFieldWrapperView = inputView
        self.isKeepSafeAreaInsetsBottom = isKeepSafeAreaInsetsBottom
    }

    /// 监听事件，键盘弹出或收起时均会触发此函数
    @objc private func keyBoardShowHideAction(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        /// 改变目标 textFieldWrapperView 的执行过程事件，更新其 2D 仿射变换矩阵
        let animations: (() -> Void) = { [weak self] in
            guard let strongSelf = self else { return }
            // 键盘弹出事件
            if notification.name == UIResponder.keyboardWillShowNotification {
                // 得到键盘高度
                strongSelf.keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
                
                /// 键盘高度即 textFieldWrapperView.y 轴需要移动的距离
                var yDiff = -strongSelf.keyboardHeight
                // 需要保留底部安全区域处理，需要再往上移动安全区域的高度
                if !strongSelf.isKeepSafeAreaInsetsBottom {
                    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                    yDiff += bottomPadding
                }
                strongSelf.textFieldWrapperView.transform = CGAffineTransform(translationX: 0,y: yDiff)
            }
            // 键盘收起事件
            if notification.name == UIResponder.keyboardWillHideNotification {
                strongSelf.textFieldWrapperView.transform = CGAffineTransform.identity
                strongSelf.keyboardHeight = 0
            }
        }
        
        // 键盘弹出过程时长
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            // 键盘已经弹出，只是切换键盘，直接更新 textFieldWrapperView 2D 仿射变换矩阵
            animations()
        }
    }
}
