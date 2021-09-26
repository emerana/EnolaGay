//
//  FundCell.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/13.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// FundCell
class FundCell: JudyBaseTableCell {
    
    // MARK: - let property and IBOutlet
    @IBOutlet weak private var 精选Label: JudyBaseLabel?
    @IBOutlet weak private var 明星经理Label: UILabel?
    
    @IBOutlet weak private var 评分Label: JudyBaseLabel?
    @IBOutlet weak private var 看法Label: JudyBaseLabel?
    @IBOutlet weak private var 类型Label: JudyBaseLabel?
    @IBOutlet weak private var 潜力Label: JudyBaseLabel?
    @IBOutlet weak private var similarRankingLabel: JudyBaseLabel?
    @IBOutlet weak var remarkLabel: JudyBaseLabel?
    
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
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        similarRankingLabel?.font = UIFont(size: 16)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        精选Label?.paddingLeft = 2
        精选Label?.paddingRight = 2
        
        看法Label?.paddingLeft = 8
        潜力Label?.paddingLeft = 8

        remarkLabel?.paddingTop = 6

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - override - 重写重载父类的方法
    

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件
    
    // MARK: - private method - 私有方法
    
}

extension FundCell {

    /// 设置 cell 内容
    /// - Parameter fund: fund 对象
    func  setFund(fund: Fund) {
        titleLabel?.text = fund.fundName
        subTitleLabel?.text = fund.fundID
        if fund.institutionalFeatured == .无 {
            精选Label?.text = nil
            精选Label?.paddingLeft = 0
            精选Label?.paddingRight = 0
        } else {
            精选Label?.text = "\(fund.institutionalFeatured)"
        }
        明星经理Label?.isHidden = !fund.isStarManager
        
        评分Label?.text = "\(fund.fundRating)"
        类型Label?.text = "\(fund.fundType)"
        if fund.institutionalView == .无 {
            看法Label?.text = nil
            看法Label?.paddingLeft = 0
        } else {
            看法Label?.text = "\(fund.institutionalView)"
        }
        
        if fund.institutionalPotential == .无 {
            潜力Label?.text = nil
            潜力Label?.paddingLeft = 0
        } else {
            潜力Label?.text = "\(fund.institutionalPotential)"
        }
        similarRankingLabel?.text = "\(fund.similarRanking)"
        switch fund.similarRanking {
        case .A:
            similarRankingLabel?.textColor = .brown
        case .B:
            similarRankingLabel?.textColor = .brown
        case .C:
            similarRankingLabel?.textColor = .brown
        case .D:
            similarRankingLabel?.textColor = .brown
        case .E:
            similarRankingLabel?.textColor = .brown
        default:
            similarRankingLabel?.textColor = #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1)
        }
        
        if fund.institutionalPotential == .无 {
            潜力Label?.text = nil
            潜力Label?.paddingLeft = 0
        } else {
            潜力Label?.text = "\(fund.institutionalPotential)"
        }
        if fund.remark == "" {
            remarkLabel?.text = nil
            remarkLabel?.paddingTop = 0
        } else {
            remarkLabel?.text = fund.remark
        }
        
    }
}
