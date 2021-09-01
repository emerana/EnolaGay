//
//  InvestmentCell.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/25.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 定投 Cell
class InvestmentCell: FundCell {
    
    // MARK: - let property and IBOutlet
    
    /// 定投信息Label
    @IBOutlet weak private var investmentLabel: UILabel?

    // MARK: - var property
        
    // MARK: - Life Cycle
    
    /// 从xib或故事板创建对象的初始化方法
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - override - 重写重载父类的方法
    
    /// 布局子视图。创建对象顺序一定是先有frame，再awakeFromNib，再调整布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - override - 重写重载父类的方法
    
    /// 设置数据源事件

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件
    
    // MARK: - private method - 私有方法
    
}

// MARK: 公开函数
extension InvestmentCell {
    
    func setFundPurchased(fundPurchased: FundPurchased) {
        if fundPurchased.investmentType == .daily {
            investmentLabel?.text = "\(fundPurchased.investmentType.rawValue)定投\(fundPurchased.amount)元"
        } else {
            investmentLabel?.text = "\(fundPurchased.investmentType.rawValue)\(fundPurchased.dayForInvestmentType)定投\(fundPurchased.amount)元"
        }
                
        setFund(fund: fundPurchased.fund)
        if fundPurchased.remark == nil || fundPurchased.remark == "" {
            remarkLabel?.text = nil
            remarkLabel?.paddingTop = 0
        } else {
            remarkLabel?.text = fundPurchased.remark
        }
//        layoutSubviews()
    }
    
}
