//
//  Fund.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/10/13.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

// MARK: - 基金 struct

/// 基金模型
struct Fund {
    
    /// 基金代码
    var fundID: String = "000000"
    /// 基金名称
    var fundName: String = "NO FundName"
    /// 基金星级
    var fundStarRating: Int = 0
    /// 基金评分
    var fundRating: Float = 0
    /// 明星经理
    var isStarManager = false
    /// 是否已经添加到自选，默认 false
    var isOption = false
    /// 是否已经添加到定投，默认 false
    var isInvestment = false
    
    /// 同类排名等级
    var similarRanking: SimilarRankingGrade = .C    
    /// 机构看法
    var institutionalView: InstitutionalView = .无
    /// 投资潜力
    var institutionalPotential: InstitutionalPotential = .无
    /// 精选情况
    var institutionalFeatured: InstitutionalFeatured = .无
    /// 基金类型
    var fundType: FundType = .指数型
    /// 备注
    var remark = ""


    /// 机构看法
    enum InstitutionalView: String {
        case 无 = ""
        case 非常乐观 = "非常乐观"
        case 乐观 = "乐观"
        case 中立 = "中立"
        case 谨慎 = "谨慎"
        case 非常谨慎 = "非常谨慎"
    }

    /// 投资潜力
    enum InstitutionalPotential: String {
        case 无 = ""
        case 低估值 = "低估值"
        case 中估值 = "中估值"
        case 高估值 = "高估值"
    }

    /// 精选情况
    enum InstitutionalFeatured: String {
        case 无 = ""
        case 好基推荐 = "好基推荐"
        case 精选 = "精选"
    }

    /// 基金类型
    enum FundType: String {
        case 指数型 = "指数型"
        case 股票型 = "股票型"
        case 混合型 = "混合型"
    }

    /// 同类排名等级
    enum SimilarRankingGrade: String {
        /*
         同比等级对应
         R:≤2 34%~100%
         E:3~4 21%~33%
         D:5~6 16%~20%
         C:7~9 11%~15%
         B:10~12 8%~10%
         A:≥13 7%~1%
         */
        
        case A = "同比基数：≥13，相当之优秀！"
        case B = "同比基数：10~12，非常优秀！"
        case C = "同比基数：7~9，优秀！"
        case D = "同比基数：5~6，不错！"
        case E = "同比基数：3~4，还行。"
        case R = "同比基数：≤2，垃圾基金！"
        
        /// 对应等级说明
        var similarRankingGradeMark: String {
            switch self {
            case .A:
                return "同比基数：≥13，排名为前7%，相当之优秀！"
            case .B:
                return "同比基数：10~12，排名为前8%~10%，非常优秀！"
            case .C:
                return "同比基数：7~9，排名前11%~15%，优秀！"
            case .D:
                return "同比基数：5~6，排名前16%~20%，不错！"
            case .E:
                return "同比基数：3~4，还行。"
            default:
                return "同比基数：≤2，排名34%之后，垃圾基金！"
            }
        }
    }

    
}
