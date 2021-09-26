//
//  InvestmentView.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/29.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 添加定投 View
class InvestmentView: UIView {

    @IBOutlet private var buttonFontSetting: [JudyBaseButton]!

    @IBOutlet private weak var fundIDLabel: JudyBaseLabel!
    @IBOutlet private weak var fundNameLabel: JudyBaseLabel!
    /// 金额输入框
    @IBOutlet private weak var amountTextField: JudyBaseTextField!
    @IBOutlet private weak var remarkTextField: JudyBaseTextField!

    /// 定投时间按钮
    @IBOutlet private weak var dayButton: JudyBaseButton!
    
    // MARK: - picker
    
    @IBOutlet private weak var pickerView: UIView!
    @IBOutlet private weak var picker: UIPickerView!
    
    private var dataSource = ["Judy"] {
        didSet{
            picker.reloadAllComponents()
        }
    }

    var fundPurchased = FundPurchased()
    /// 添加成功后的回调函数
    var addSuccessCallback: (() -> Void)?
    
    // MARK: 生命周期
    
    override func awakeFromNib() {
        show(isHide: true)
        //  设置选中和未选中的 title 颜色
        buttonFontSetting.forEach { button in
            button.borderColor = .systemBlue
            button.setTitleColor(.systemBlue, for: .normal)
            button.setTitleColor(.white, for: .selected)
        }
        
        let button = viewWithTag(1001)
        selectInvestmentTypeAction(button as Any)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        buttonFontSetting.forEach { button in
            button.titleLabel?.font = UIFont(size: 16)
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //  view.endEditing(true)
        // 在界面即将消失（包含所有界面跳转）时关闭所有键盘
        Judy.keyWindow?.endEditing(true)
        
//        updateWindowFrame(isReset: true)

        for touch in touches {
            if (touch.view?.isKind(of: NSClassFromString("UIPickerTableViewTitledCell")!) ?? false )
                || touch.view == pickerView || touch.view == picker {
                return
            }
        }

        confirmAction(dayButton as Any)
    }
    


    deinit {
        Judy.log("添加定投信息 View 已经释放")
    }
}

// MARK: - 公开函数

extension InvestmentView {

    /// 请在设置 fund 后调用此函数以设置基本信息
    func setFundInfo() {
        fundIDLabel.text = "基金代码:" + fundPurchased.fund.fundID
        fundNameLabel.text = fundPurchased.fund.fundName
        amountTextField.text = "\(fundPurchased.amount)"
        remarkTextField.text = fundPurchased.remark
    }

}


// MARK: - Actions

private extension InvestmentView {

    /// 选择定投周期事件：1001=每周，1002=每两周，1003=每天，1004=每月
    @IBAction func selectInvestmentTypeAction(_ sender: Any) {
        let button = sender as! JudyBaseButton
        selectButtonAction(button: button, buttons: buttonFontSetting)
        
        let weeks = ["一", "二", "三", "四", "五"]
        var days = [String]()
        for day in 1...28 {
            days.append("\(day)日")
        }
        
        switch button.tag {
        case 1001:
            fundPurchased.investmentType = .weekly
            dataSource = weeks
            dayButton.setTitle(weeks.first!, for: .normal)
        case 1002:
            fundPurchased.investmentType = .everyTwoWeeks
            dataSource = weeks
            dayButton.setTitle(weeks.first!, for: .normal)
        case 1003:
            show(isHide: true)
            dayButton.setTitle("每天", for: .normal)
            fundPurchased.investmentType = .daily
        case 1004:
            fundPurchased.investmentType = .monthly
            dataSource = days
            dayButton.setTitle(days.first!, for: .normal)

        default:
            break
        }
    }
    
    /// 定投日事件
    @IBAction func investmentDayAction(_ sender: Any) {
        if fundPurchased.investmentType != .daily {
            show()
        }

    }

    /// 确认修改事件
    @IBAction func completionAction(_ sender: Any) {
        fundPurchased.amount = Int(amountTextField.text ?? "0") ?? 0
        fundPurchased.dayForInvestmentType = dayButton.title(for: .normal) ?? "未知"
        fundPurchased.remark = remarkTextField.text
        
        FundDataSourceCtrl.judy.addInvestment(fundPurchased: fundPurchased) { (rs) in
            JudyTip.message(text: rs ? "添加定投成功":"添加定投失败！")
            if rs {
                removeFromSuperview()
                addSuccessCallback?()
            }
        }

    }
    
    /// 取消事件
    @IBAction func cancelEvent(_ sender: Any) {
        removeFromSuperview()
    }
    
    /// 确定选中按钮背景色
    /// - Parameter button: 目标按钮
    /// - Parameter buttons: 目标按钮所在的按钮组
    func selectButtonAction(button: JudyBaseButton, buttons: [JudyBaseButton] ){
        
        for btn in buttons {
            // 找到当前选中的按钮
            btn.isSelected = button == btn
            if btn.isSelected {
                btn.backgroundColor = .systemBlue
            } else {
                btn.backgroundColor = .white
            }
            
        }
    }
}

extension InvestmentView: UITextFieldDelegate {
    
    // 点击完成按钮收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return textField.resignFirstResponder()
    }
    
    // 2201：金额，2202:备注
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 金额输入框
        if textField.tag == 2201 {
            return Judy.numberInput(textField: textField, range: range, string: string)
        }

        return true
    }
        
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag != 2201 {
            judy.updateWindowFrame()
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        judy.updateWindowFrame(isReset: true)
        return true
    }
        
}

// MARK: - picker actions

private extension InvestmentView {
    
    /// 完成按钮点击事件
    ///
    /// - Parameter sender: sender
    @IBAction  func confirmAction(_ sender: Any) {
        show(isHide: true)

    }
    
    /// 调用此方法以显示/隐藏pickerView，动画方式。
    func show(isHide: Bool = false) {
        guard pickerView.superview != nil else {
            return
        }
        // 通过约束确定
        for constraint in pickerView.superview!.constraints {
            guard constraint.secondItem != nil else {
                continue
            }
            // 找到底部约束
            if constraint.secondItem! as? NSObject == pickerView
                && constraint.secondAttribute == NSLayoutConstraint.Attribute.bottom {
                
                if isHide {
                    constraint.constant = -frame.size.height
                } else {
                    constraint.constant = 0
                }
                
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.superview?.layoutIfNeeded()
        })
        
    }
        
}


// MARK: - pickerView dataSource and delegate

extension InvestmentView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return dataSource.count
    }
    
    // MARK: delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return dataSource[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        Judy.log("选择了\(dataSource[row])")
        dayButton.setTitle(dataSource[row], for: .normal)

    }
    
}
