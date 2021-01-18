//
//  JudyVerifyButton.swift
//  倒计时按钮
//
//  Created by 醉翁之意 on 2018/5/11.
//  Copyright © 2018年 GSDN. All rights reserved.
//

import UIKit

/**
 * 验证码倒计时按钮，字体样式默认为小码，请在 storyboard 中将按钮类型改为 Custom
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
    /// - Parameter timer: timer
    @objc private func updateTime(timer: Timer) {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds = remainingSeconds  - 1
    }
    
    
    
}
