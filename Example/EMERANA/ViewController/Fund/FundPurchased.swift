//
//  FundPurchased.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/24.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 定投/已购基金模型
struct FundPurchased {
    
    /// 基金模型
    var fund = Fund()
    /// 定投金额，默认188
    var amount: Int = 188
    /// 定投类型，默认每周
    var investmentType: InvestmentType = .weekly
    /// 定投时间，默认周一
    var dayForInvestmentType: String = "一"
    /// 备注
    var remark: String? = nil
    
}


// MARK: 函数

private extension FundPurchased {
    
    /// 获取定投周期
    func getInvestmentCycle() -> String {
        return "每周"
    }
    
}

// MARK: 枚举

extension FundPurchased {

    /// 定投类型枚举
    enum InvestmentType: String {
        case monthly = "每月"
        case weekly = "每周"
        case everyTwoWeeks = "每两周"
        case daily = "每天"
    }

}
