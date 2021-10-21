//
//  FundPageViewCtrller.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/14.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 基金信息 pageViewCtrl
class FundPageViewCtrller: JudyBasePageViewSegmentCtrl {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let viewCtrlArray =  [
//            storyboard!.instantiateViewController(withIdentifier: "FundViewController"),
//            storyboard!.instantiateViewController(withIdentifier: "FavoriteViewCtrl"),
//            storyboard!.instantiateViewController(withIdentifier: "PurchasedViewCtrl"),
//        ]
//        setPageViewDataSource(dataSource: viewCtrlArray)
        
//        setSegmentedCtrl()
    }
    
//    func setSegmentedCtrl() {
//        super.setSegmentedCtrl()
//        
//        // 设置 navigationSegmentedCtrl 的 frame
//        segmentedCtrl.frame.size.height -= 8
//        segmentedCtrl.frame.size.width = "基金定投基金定投基金定投".textSize().width + 30
//        
//        segmentedCtrl.judy_configNormolStyle(color: .judy(.text))
//        segmentedCtrl.judy_configSelectedStyle(color: .judy(.text))
//
//    }
    
    @IBAction private func rightItemAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "请选择对应操作",
                                                message: nil,
                                                preferredStyle: .alert)
        
        let closure: ((UIAlertAction) -> Void) = {
            (alertAction: UIAlertAction) in
            
            switch alertAction.title {
            case "创建基金信息表":
                FundDataSourceCtrl.judy.createTableFundInfo()
            case "创建自选基金表":
                FundDataSourceCtrl.judy.createOptionalTable()
            case "创建定投基金表":
                FundDataSourceCtrl.judy.createInvestmentTable()
            case "添加一条基金信息":
                let viewCtrl = self.storyboard!.instantiateViewController(withIdentifier: "AddFundViewCtrl")
                let addFundView = viewCtrl.view as! AddFundView
                addFundView.initFundInfo()
                Judy.appWindow.addSubview(addFundView)
            case "创建fundID索引":
                FundDataSourceCtrl.judy.createIndexForFundID()
            case "从Bmob拉取最新数据":
                FundDataSourceCtrl.judy.pullFundInfoFormBmob()
            default:
                break
            }
            
        }
        
        // 创建UIAlertAction空间， style: .destructive 红色字体
        let 创建基金信息表 = UIAlertAction(title: "创建基金信息表", style: .default, handler: closure)
        let 创建自选基金表 = UIAlertAction(title: "创建自选基金表", style: .default, handler: closure)
        let 创建定投基金表 = UIAlertAction(title: "创建定投基金表", style: .default, handler: closure)
        let 添加一条基金信息 = UIAlertAction(title: "添加一条基金信息", style: .default, handler: closure)
        let 创建fundID索引 = UIAlertAction(title: "创建fundID索引", style: .default, handler: closure)
        let 从Bmob拉取最新数据 = UIAlertAction(title: "从Bmob拉取最新数据", style: .default, handler: closure)
        let 关闭 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(创建基金信息表)
        alertController.addAction(创建自选基金表)
        alertController.addAction(创建定投基金表)
        alertController.addAction(添加一条基金信息)
        alertController.addAction(创建fundID索引)
        alertController.addAction(从Bmob拉取最新数据)
        alertController.addAction(关闭)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
}
