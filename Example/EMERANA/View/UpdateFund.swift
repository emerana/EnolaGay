//
//  UpdateFund.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/15.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 修改基金信息的 View
class UpdateFund: UIView {

    // MARK: - 私有变量及IBOutlet
    
    /// 所有需要设置统一字体的按钮集合
    @IBOutlet private var buttonFontSetting: [JudyBaseButton]!
    
    /// 星星评分控件
    // @IBOutlet private weak var starRatingView: EDStarRating!
    /// 基金代码Label
    @IBOutlet weak var fundIDLabel: JudyBaseLabel!
    /// 明星经理按钮
    @IBOutlet private weak var 明星经理Button: JudyBaseButton!
    /// 同类排名按钮
    @IBOutlet private weak var similarRankingButton: JudyBaseButton!

    @IBOutlet private weak var fundNameTextField: JudyBaseTextField!
    /// 收益风险比
    @IBOutlet private weak var fundRatingTextField: UITextField!
    @IBOutlet private weak var remarkTextField: JudyBaseTextField!

    
    //// MARK: 组合按钮选择事件
    
    
    /// 基金类型按钮组
    @IBOutlet private var fundTypeButtons: [JudyBaseButton]!
    /// 基金精选情况按钮组
    @IBOutlet private var 精选情况Buttons: [JudyBaseButton]!
    /// 基金专业机构看法按钮组
    @IBOutlet private var 专业机构看法Buttons: [JudyBaseButton]!
    /// 基金投资升值潜力按钮组
    @IBOutlet private var 投资升值潜力Buttons: [JudyBaseButton]!

    var fund = Fund()
    var updateCallback: (() -> Void)?
    
        
    // MARK: - picker
    
    @IBOutlet private weak var pickerView: UIView!
    @IBOutlet private weak var picker: UIPickerView!
    
    private let pickerViewDataSource = [
        "A - \(Fund.SimilarRankingGrade.A.rawValue)",
        "B - \(Fund.SimilarRankingGrade.B.rawValue)",
        "C - \(Fund.SimilarRankingGrade.C.rawValue)",
        "D - \(Fund.SimilarRankingGrade.D.rawValue)",
        "E - \(Fund.SimilarRankingGrade.E.rawValue)",
        "R - \(Fund.SimilarRankingGrade.R.rawValue)"
    ]
    
    
    //// MARK: - 生命周期事件
    
    override func awakeFromNib() {
        showPickerView(isHide: true)

        //  设置选中和未选中的 title 颜色
        buttonFontSetting.forEach { button in
            button.borderColor = .systemBlue
            button.setTitleColor(.systemBlue, for: .normal)
            button.setTitleColor(.white, for: .selected)
        }
        
        frame = UIScreen.main.bounds
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
        
        for touch in touches {
            if (touch.view?.isKind(of: NSClassFromString("UIPickerTableViewTitledCell")!) ?? false )
                || touch.view == pickerView || touch.view == picker {
                return
            }
        }

        showPickerView(isHide: true)

    }
    
    /// 调用该函数初始化匹配基金信息
    func initFundInfo() {
        
        fundIDLabel.text = "基金代码：" + fund.fundID
        fundNameTextField.text = fund.fundName
        fundRatingTextField.text = String(fund.fundRating)
        remarkTextField.text = fund.remark

        // 匹配基金类型
        var tagForType = 1001
        switch fund.fundType {
        case .指数型:
            tagForType = 1001
        case .股票型:
            tagForType = 1002
        case .混合型:
            tagForType = 1003
        }
        var typeButton = viewWithTag(tagForType)
        selectFundTypeAction(typeButton as Any)
        
        // 精选情况
        switch fund.institutionalFeatured {
        case .无:
            tagForType = 2001
        case .精选:
            tagForType = 2002
        case .好基推荐:
            tagForType = 2003
        }
        typeButton = viewWithTag(tagForType)
        精选Action(typeButton as Any)

        // 专业机构看法
        switch fund.institutionalView {
        case .无:
            tagForType = 3001
        case .非常谨慎:
            tagForType = 3002
        case .谨慎:
            tagForType = 3003
        case .中立:
            tagForType = 3004
        case .乐观:
            tagForType = 3005
        case .非常乐观:
            tagForType = 3006
        }
        typeButton = viewWithTag(tagForType)
        专业机构看法Action(typeButton as Any)
        
        // 投资潜力
        switch fund.institutionalPotential {
        case .无:
            tagForType = 4001
        case .高估值:
            tagForType = 4002
        case .中估值:
            tagForType = 4003
        case .低估值:
            tagForType = 4004
        }
        typeButton = viewWithTag(tagForType)
        投资升值潜力Action(typeButton as Any)

        明星经理Button.isSelected = !fund.isStarManager
        明星经理Action(明星经理Button as Any)

        setSimilar(fromPickerDataSource: "\(fund.similarRanking)")
    }

    deinit {
        Judy.log("修改基金View释放")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: - UITextFieldDelegate

extension UpdateFund: UITextFieldDelegate {
    
    // 点击完成按钮收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return textField.resignFirstResponder()
    }
    
    // 2201：基金名称，2202:风险收益分数，2203：备注,2204:ID
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case 2202:
            return Judy.decimal(textFieldText: textField.text! as NSString, range: range, string: string, num: 1, prefix: 2)
        case 2204:
            return numberRestriction(textField: textField, inputString: string)
        default:
            break
        }
        
        Judy.log("shouldChangeCharactersIn<!-- \(string) -->,输入之前为--> \(String(describing: textField.text))")
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 2201: // 设置基金名称
            fund.fundName = textField.text ?? "NO FUNDNAME"
            
        case 2202: // 设置分数
            fund.fundRating = Float(textField.text ?? "0") ?? 0
        case 2203:
            fund.remark = textField.text ?? ""
        case 2204:
            fund.fundID = textField.text ?? ""
        default:
            break
        }
        
        Judy.log(textField.text)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 2203 {
            judy.updateWindowFrame(offset: 188)
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 2203 {
            judy.updateWindowFrame(isReset: true)
        }
        return true
    }
    
}

// MARK: - Actions
extension UpdateFund {
    
    /// 确认修改/确认添加事件
    @IBAction func completionAction(_ sender: Any) {
        //        Judy.log(fund)
        Judy.keyWindow?.endEditing(true)
        
        FundDataSourceCtrl.judy.updateFundInfo(fund: fund) { (rs) in
            if rs {
                removeFromSuperview()
                updateCallback?()
            } else {
                self.toast.activity()
            }
        }
    }
    
    /// 取消事件
    @IBAction func cancelEvent(_ sender: Any) {
        removeFromSuperview()
    }
    
    /// similar button clicked action
    @IBAction func similarAction(_ sender: Any) {
        showPickerView()
    }

    /// pickerView completion Action
    ///
    /// - Parameter sender: sender
    @IBAction  func pickerViewCompletionAction(_ sender: Any) {
        showPickerView(isHide: true)
    }

}

private extension UpdateFund {

    /// 选择基金类型事件: 1001 = 指数，1002=股票，1003=混合
    @IBAction func selectFundTypeAction(_ sender: Any) {
        let button = sender as! JudyBaseButton
        selectButtonAction(button: button, buttons: fundTypeButtons)
        switch button.tag {
        case 1001:
            fund.fundType = .指数型
        case 1002:
            fund.fundType = .股票型
        default:
            fund.fundType = .混合型
        }
    }

    /// 选择基金精选情况事件: 2001 = 无，2002：精选，2003：好基推荐
    @IBAction func 精选Action(_ sender: Any) {
        let button = sender as! JudyBaseButton
        selectButtonAction(button: button, buttons: 精选情况Buttons)
        switch button.tag {
        case 2002:
            fund.institutionalFeatured = .精选
        case 2003:
            fund.institutionalFeatured = .好基推荐
        default:
            fund.institutionalFeatured = .无
        }
    }

    /// 选择基金专业机构看法事件：3001：无，3002：非常谨慎，3003：谨慎，3004：中立，3005：乐观，3006：非常乐观
    @IBAction func 专业机构看法Action(_ sender: Any) {
        let button = sender as! JudyBaseButton
        selectButtonAction(button: button, buttons: 专业机构看法Buttons)
        switch button.tag {
        case 3002:
            fund.institutionalView = .非常谨慎
        case 3003:
            fund.institutionalView = .谨慎
        case 3004:
            fund.institutionalView = .中立
        case 3005:
            fund.institutionalView = .乐观
        case 3006:
            fund.institutionalView = .非常乐观
        default:
            fund.institutionalView = .无
        }
    }

    /// 选择基金投资升值潜力事件：从无-高-》低4001-4004
    @IBAction func 投资升值潜力Action(_ sender: Any) {
        let button = sender as! JudyBaseButton
        selectButtonAction(button: button, buttons: 投资升值潜力Buttons)
        switch button.tag {
        case 4002:
            fund.institutionalPotential = .高估值
        case 4003:
            fund.institutionalPotential = .中估值
        case 4004:
            fund.institutionalPotential = .低估值
        default:
            fund.institutionalPotential = .无

        }
    }

    /// 选择基金明星经理事件
    @IBAction func 明星经理Action(_ sender: Any) {
        let button = sender as! JudyBaseButton
        button.isSelected = !button.isSelected
        button.backgroundColor = button.isSelected ? .systemBlue:.white
        
        fund.isStarManager = button.isSelected
        Judy.log("明星经理按钮选中状态：\(button.isSelected)")
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
 
    
    /// 调用此方法以显示/隐藏pickerView，动画方式。
    func showPickerView(isHide: Bool = false) {
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
                break
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.superview?.layoutIfNeeded()
        })
        
    }

    
}

//// MARK: - 代理
//
//extension UpdateFund: EDStarRatingProtocol {
//
//    func starsSelectionChanged(_ control: EDStarRating!, rating: Float) {
//        Judy.log("评分：\(rating)")
//        fund.fundStarRating = Int(rating)
//    }
//
//}

// MARK: - pickerView dataSource and delegate

extension UpdateFund: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return pickerViewDataSource.count
    }
    
    // MARK: delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return pickerViewDataSource[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        Judy.log("选择了\(pickerViewDataSource[row])")
        setSimilar(fromPickerDataSource: pickerViewDataSource[row])
    }
    
    /// 设置同类排名按钮及 pickerView 数据源选中队列
    /// - Parameter similarRawValue: pickerDataSource 中的值，该值需保证第一个字符为 SimilarRankingGrade 的值
    private func setSimilar(fromPickerDataSource similarRawValue: String) {
        
        // 使用索引的方式
        for (index, value) in pickerViewDataSource.enumerated() {
            // 通过前缀判断是否为同一个字符
            if value[value.startIndex] == similarRawValue[similarRawValue.startIndex] {
                Judy.log(value + "被设置了")
                picker.selectRow(index, inComponent: 0, animated: true)
                
                // 截取字符串，去掉前4个字符
                let newStartIndex = value.index(value.startIndex, offsetBy: 4)
                let sourceString: String  = String(value[newStartIndex ..< value.endIndex])
                
                guard let similar = Fund.SimilarRankingGrade(rawValue: sourceString) else {
                    Judy.log("同类排名信息转换失败！")
                    fund.similarRanking = .R
                    similarRankingButton.setTitle("转换失败！", for: .normal)
                    break
                }
                fund.similarRanking = similar
                similarRankingButton.setTitle(pickerViewDataSource[picker.selectedRow(inComponent: 0)], for: .normal)

                break
            }
        }

    }
    
    
}
