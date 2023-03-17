//
//  FundDetailViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/15.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 基金详情界面
class FundDetailViewCtrl: JudyBaseViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet private weak var 基金名称Label: JudyBaseLabel!
    @IBOutlet private weak var 精选情况Label: JudyBaseLabel!
    @IBOutlet private weak var 基金代码Label: JudyBaseLabel!
    @IBOutlet private weak var 基金类型Label: JudyBaseLabel!
    @IBOutlet private weak var 明星经理Label: JudyBaseLabel!
    @IBOutlet private weak var 收益风险比Label: JudyBaseLabel!
    @IBOutlet private weak var 看法Label: JudyBaseLabel!
    @IBOutlet private weak var 潜力Label: JudyBaseLabel!
    @IBOutlet private weak var remarkLabel: JudyBaseLabel!
    
    /// 统一字体样式
    @IBOutlet private var configFontLabel: [JudyBaseLabel]!
    
    @IBOutlet private weak var similarLabel: JudyBaseLabel!
    @IBOutlet private weak var similarDetailLabel: JudyBaseLabel!

    /// 添加到自选按钮/删除自选按钮
    @IBOutlet private weak var optionButton: JudyBaseButton!
    /// 添加到定投按钮/删除定投按钮
    @IBOutlet private weak var investmentButton: JudyBaseButton!

    // MARK: - public var property - 公开var
    
    /// 界面类型，默认为基金信息
    var detailViewCtrlType: DetailType = .fundInfo
    
    enum DetailType {
        /// 基金信息
        case fundInfo
        /// 自选基金
        case fundOption
        /// 已购基金
        case fundInvestment
    }
    
    
    /// 删除基金后的回调函数
    var deleteCallback: (() -> Void)?
    /// 删除自选后的回调函数
    var deleteOptionCallback: (() -> Void)?
    /// 删除定投后的回调函数
    var deleteInvestmentCallback: (() -> Void)?

    
    var fund: Fund? = nil
    
    override var viewTitle: String? {
        return "基金详情"
    }

    // MARK: - private var property - 私有var
    
    
    // MARK: - Life Cycle - 生命周期

    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard fund != nil else {
            return
        }
        fund = FundDataSourceCtrl.judy.getFundDetail(fundID: fund!.fundID)
        guard fund != nil else {
            return
        }
        navigationItem.title = fund!.fundName
        
        setFundInfo()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法
        
    // MARK: Api相关
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard fund != nil else {
            self.view.toast.activity()
            // 操控 dismiss 至少需要即将 appear 才行
            dismiss(animated: true, completion: nil)
            return
        }

    }
    
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    /// 自选事件
    @IBAction private func addSelectAction(_ sender: Any) {
        guard fund != nil else {
            return
        }
        if fund!.isOption { // 删除自选
            deleteAction()
        } else {    // 添加自选
            FundDataSourceCtrl.judy.addOptional(fund: fund!) { (rs) in
                self.view.toast.activity()

                if rs {
                    dismiss(animated: true, completion: nil)
                }
                
            }
        }
                

    }
    
    /// 定投事件
    @IBAction private func investmentAction(_ sender: Any) {
        if fund!.isInvestment { // 删除定投
            deleteAction(isInvestment: true)
        } else {    // 添加定投
            let viewCtrl = storyboard!.instantiateViewController(withIdentifier: "InvestmentViewCtrl")
            let addInvestmentView = viewCtrl.view as! InvestmentView
            var fundInfo = FundPurchased()
            fundInfo.fund = fund!
            addInvestmentView.fundPurchased = fundInfo
            Judy.appWindow.addSubview(addInvestmentView)
            addInvestmentView.setFundInfo()
            addInvestmentView.addSuccessCallback = {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    
    /// 修改事件
    @IBAction private func updateAction(_ sender: Any) {
        guard fund != nil else {
            return
        }
        let judyView = Bundle.main.loadNibNamed("UpdateFund", owner: self, options: nil)![0] as! UpdateFund
        judyView.fund = fund!
        judyView.initFundInfo()
        judyView.updateCallback = {
            self.dismiss(animated: true, completion: nil)
        }
        Judy.appWindow.addSubview(judyView)

    }

    /// 删除事件
    @IBAction private func deleteAction(_ sender: Any) {
        guard fund != nil else {
            self.view.toast.activity()
            return
        }
        let alertController = UIAlertController(title: "确认删除该基金信息吗？",
                                                message: "删除该基金信息将同步删除自选基金和定投基金",
                                                preferredStyle: .alert)
        let closure: ((UIAlertAction) -> Void) = {
            (alertAction: UIAlertAction) in
            
            // 异步执行
            FundDataSourceCtrl.judy.deleteFundInfo(fundID: self.fund!.fundID) { (rs) in
                self.view.toast.activity()
                if rs {
                    self.dismiss(animated: true, completion: {
                        self.deleteCallback?()
                    })
                }
            }
            
            
        }
        
        // 创建UIAlertAction空间， style: .destructive 红色字体
        let confirmButton = UIAlertAction(title: "确认", style: .destructive, handler: closure)
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(confirmButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)

    }

    // MARK: - Event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        Judy.log("identifier:\(identifier)")
        return true
    }
    
    // MARK: 解决模态视图推出时影响 window 背景色
    
    override func loadView() {
        super.loadView()
        
        // 将 window 背景色设为 nil
        Judy.keyWindow?.backgroundColor = nil
        
    }
    
    deinit {
        // 将 window 背景色重置
        Judy.keyWindow?.backgroundColor = .black
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}

//// MARK: - 配置UI

private extension FundDetailViewCtrl {
    
    /// 删除公用事件
    /// - Parameter isInvestment: 是否为定投，默认 false
    func deleteAction(isInvestment: Bool = false) {
        let alertController = UIAlertController(title: "确认删除该" + (isInvestment ?"定投":"自选基金") + "信息吗？",
                                                message:nil,
                                                preferredStyle: .alert)
        let closure: ((UIAlertAction) -> Void) = {
            (alertAction: UIAlertAction) in
         
            // 异步执行
            DispatchQueue.global().async {
                FundDataSourceCtrl.judy.deleteOptionalOrInvestment(fundID: self.fund!.fundID, isInvestment: isInvestment) { (rs) in
                    DispatchQueue.main.async {
                        if isInvestment {
                            self.view.toast.activity()
                        } else {
                            self.view.toast.activity()
                        }
                        if rs {
                            self.dismiss(animated: true) {
                                if isInvestment {
                                    self.deleteInvestmentCallback?()
                                } else {
                                    self.deleteOptionCallback?()
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
        
        // 创建UIAlertAction空间， style: .destructive 红色字体
        let confirmButton = UIAlertAction(title: "确认", style: .destructive, handler: closure)
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(confirmButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    func setFundInfo() {
        guard fund != nil else {
            return
        }
        基金名称Label.text = fund!.fundName

        if fund!.institutionalFeatured == .无 {
            精选情况Label.removeFromSuperview()
        } else {
            精选情况Label.text = fund!.institutionalFeatured.rawValue
        }
        
        基金代码Label.text = fund!.fundID
        基金类型Label.text = fund!.fundType.rawValue
        
        if !fund!.isStarManager {
            明星经理Label.removeFromSuperview()
        }

        if fund!.remark == "" {
            remarkLabel.removeFromSuperview()
        } else {
            remarkLabel.text = "\(fund!.remark)"
        }

        收益风险比Label.text = "\(fund!.fundRating)"
        看法Label.text = "\(fund!.institutionalView)"
        潜力Label.text = "\(fund!.institutionalPotential)"
        
//        starRatingView.rating = Float(fund!.fundStarRating)
        
        setSimilarLabel()
        
        setButtonStatus()
    }
    
    /// 设置同类排名 Label
    func setSimilarLabel() {
        
        similarLabel.text = "\(fund!.similarRanking)"
        similarDetailLabel.text = fund!.similarRanking.similarRankingGradeMark

        switch fund!.similarRanking {
        case .A:
            similarLabel.textColor = .brown
        case .B:
            similarLabel.textColor = .brown
        case .C:
            similarLabel.textColor = .brown
        case .D:
            similarLabel.textColor = .brown
        case .E:
            similarLabel.textColor = .brown
        default:
            similarLabel.textColor = #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1)
        }
        similarDetailLabel.textColor = similarLabel.textColor
    }
    
    /// 设置按钮状态
    func setButtonStatus() {
        optionButton.setTitle( fund!.isOption ?"删除自选":"添加到自选", for: .normal)
        investmentButton.setTitle(fund!.isInvestment ?"删除定投":"添加到定投", for: .normal)

    }

    
}
