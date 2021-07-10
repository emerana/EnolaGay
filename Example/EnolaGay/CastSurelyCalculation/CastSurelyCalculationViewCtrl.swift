//
//  CastSurelyCalculationViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 醉翁之意 on 2021/7/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class CastSurelyCalculationViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "定投计算" }

    // MARK: - let property and IBOutlet
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// 计算事件。
    @IBAction private func calculationAction(_ sender: Any) {
        guard let number = Int(inputTextField.text ?? "0") else {
            detailLabel.text = "输入不合法！"
            return
        }
        view.endEditing(true)
        let calendar = Calendar.current
        let currentDayInfo = "今天是 \(calendar.judy.components.year!) 年 \(calendar.judy.components.month!) 月 \(calendar.judy.components.day!) 日\n"
        
        var numberInfo = "每日定投 \(number) 元，接下来6个月如下：\n"

        for i in 0...6 {
            if i == 0 {
                var currentMonthNumber = 0
                for d in 0..<calendar.judy.daysResidueInCurrentMonth {
                    let weekday = calendar.judy.getWeekday(year: calendar.judy.components.year!,
                                                           month: calendar.judy.components.month!,
                                                           day: calendar.judy.components.day! + d)
                    if weekday == 1 || weekday == 7 { continue }
                    currentMonthNumber += number
                }
                numberInfo += "从今日算起本月共需投入 \(currentMonthNumber) 元。\n"
            } else {
                var currentMonthNumber = 0
                for d in 1...calendar.judy.getDaysInMonth(year: calendar.judy.components.year!,
                                                          month: calendar.judy.components.month!+i) {
                    
                    let weekday = calendar.judy.getWeekday(year: calendar.judy.components.year!,
                                                           month: calendar.judy.components.month!+i,
                                                           day: d)
                    if weekday == 1 || weekday == 7 { continue }
                    currentMonthNumber += number
                }
                numberInfo += "\(calendar.judy.components.month!+i)月需投入 \(currentMonthNumber) 元。\n"
            }
        }

        detailLabel.text = currentDayInfo + numberInfo
    }
}

// MARK: - private methods
private extension CastSurelyCalculationViewCtrl {
}

extension CastSurelyCalculationViewCtrl: UITextFieldDelegate {
    // 输入验证。当值发生更改时的确认。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        Judy.log("shouldChangeCharactersIn<!-- \(string) -->,输入之前为--> \(String(describing: textField.text))")
        return Judy.numberInputRestriction(textField: textField, range: range, string: string, num: 4, maxNumber: 1688, minNumber: 1)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        Judy.log(textField.text)
        calculationAction("执行计算")
    }
}
