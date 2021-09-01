//
//  GracePeriodViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/9/16.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 免息期计算
class GracePeriodViewCtrl: JudyBaseViewCtrl {

    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet weak var 最长还款日Label: JudyBaseLabel!
    @IBOutlet weak var 当前免息期Label: JudyBaseLabel!

    // MARK: - public var property - 公开var
    
    override var viewTitle: String? {
        return "免息期计算"
    }
    
    // MARK: - private var property - 私有var
    
    private var 出账日 = 0 {
        didSet{
            calcuteAction()
        }
    }

    private var 还款日 = 0 {
        didSet{
            calcuteAction()
        }
    }

    private var 当日 = 0 {
        didSet{
            calcuteAction()
        }
    }

    
    
    // MARK: - Life Cycle - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        calculateInterestDays(出账日: 30, 还款日: 2)
//        calculateInterestDays(出账日: 1, 还款日: 30, 当日: 31)
//
//        calculateInterestDays(出账日: 7, 还款日: 2)  // 农行
//        calculateInterestDays(出账日: 12, 还款日: 1)  // 中信
//        calculateInterestDays(出账日: 3, 还款日: 23)  // 浦发
//        calculateInterestDays(出账日: 22, 还款日: 12)  // 民生

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法
    
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - Event response - 响应事件
    
    @IBAction func editingEndAction(_ sender: Any) {
        let judyTextField = sender as! JudyBaseTextField
//        Judy.log(judyTextField.tag)
        guard judyTextField.text != nil, judyTextField.text!.judy.clean() != "" else {
//            Judy.log("请输入正确的值")
            最长还款日Label.text = "请输入正确的日期"
            当前免息期Label.text = "请输入正确的日期"
            return
        }

        switch judyTextField.tag {
        case 201:
            出账日 = Int(judyTextField.text!)!
        case 202:
            还款日 = Int(judyTextField.text!)!
        case 203:
            当日 = Int(judyTextField.text!)!
        default:
            break
        }
    }
    
    /// 回到今天
    @IBAction func backToDayAction(_ sender: Any) {
        let currentCarlendarComponents = Calendar.current.dateComponents([.day], from: Date())
        当日 = currentCarlendarComponents.day!
        (view.viewWithTag(203)as! JudyBaseTextField).text = String(当日)
    }
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - 信用卡免息期计算
private extension GracePeriodViewCtrl {
    
    func calcuteAction() {
        calculateInterestDays(出账日: 出账日, 还款日: 还款日, 当日: 当日)
    }
    
    /// 计算免息天数
    ///
    /// - Parameters:
    ///   - 出账日: 信用卡出账日，默认为7日
    ///   - 还款日: 信用卡还款日，默认为2日
    ///   - 当日: 以指定的日期算出当前剩余的免息天数，该日期默认为16
    func calculateInterestDays(出账日: Int = 7, 还款日: Int = 2, 当日: Int? = nil) {
        guard 出账日 < 31 && 出账日 > 0, 还款日 < 31 && 还款日 > 0 else {
//            Judy.log("出账或还款日期不合法！")
            最长还款日Label.text = "出账或还款日期不合法！"
            当前免息期Label.text = "出账或还款日期不合法！"

            return
        }
        
        var 当前日期 = 1
        
        if  当日 == nil {
            let currentCarlendarComponents = Calendar.current.dateComponents([.day], from: Date())
            当前日期 = currentCarlendarComponents.day!
        } else {
            if 当日! < 31 && 当日! > 0 {
                当前日期 = 当日!
            } else {    // 传入的日期不合法
                Judy.log("请传入正确的日期！")

                let currentCarlendarComponents = Calendar.current.dateComponents([.day], from: Date())
                当前日期 = currentCarlendarComponents.day!
                (view.viewWithTag(203)as! JudyBaseTextField).text = String(当前日期)

            }
        }
        
        /// 最长免息天数
        var 最长免息天数 = 0
        /// 距当日免息天数
        var 当前免息天数 = 0
        
        if 出账日 > 还款日 {    // 跨月还款
            最长免息天数 = 30 + (30 - 出账日) + 还款日
        } else {    // 当月还款
            最长免息天数 = 30 - 出账日 + 还款日
        }
        
        if 当前日期 > 出账日 {
            当前免息天数 = 最长免息天数 - (当前日期 - 出账日)
        } else {
            当前免息天数 = 30 + 还款日 - 当前日期
        }
        最长还款日Label.text = "最长免息天数：\(最长免息天数)天"
        当前免息期Label.text = "当前免息期天数：\(当前免息天数)天"
        Judy.log("出账日：\(出账日)，还款日：\(还款日)，最长免息天数：\(最长免息天数)，今天\(当前日期)号，当前免息天数：\(当前免息天数)天")
    }

}
