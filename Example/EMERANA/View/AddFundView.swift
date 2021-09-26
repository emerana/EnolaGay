//
//  AddFundView.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/11/8.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 添加一条基金信息 View
class AddFundView: UpdateFund {

    @IBOutlet private weak var fundIDTextField: JudyBaseTextField!

    override func initFundInfo() {
        super.initFundInfo()
        fundIDLabel.text = "基金代码："
        fundIDTextField.text = "\(fund.fundID)"
    }
    
}

extension AddFundView {
    
    override func completionAction(_ sender: Any) {
        Judy.keyWindow?.endEditing(true)
        
        // 添加一条新的基金信息
        FundDataSourceCtrl.judy.insertFundTable(funds: [fund]) { rs in
            if rs {
                removeFromSuperview()
            } else {
                JudyTip.message(text: "添加失败！已存在该基金")
            }
        }

    }
    
}

// MARK: actions
extension AddFundView {

}
