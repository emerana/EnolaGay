//
//  HomeCollectionCellA.swift
//  emerana
//  首页的CollectionViewCell
//  Created by 醉翁之意 on 2018/8/2.
//  Copyright © 2018年 艾美拉娜.王仁洁 All rights reserved.
//

import UIKit
import EnolaGay

class HomeCollectionCellAB: JudyBaseCollectionViewCell {
    
    // MARK: - let property and IBOutlet
    
    // MARK: - var property
    
    // MARK: - Life Cycle
    
    /// 从xib或故事板创建对象的初始化方法
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }
    
    // MARK: - override - 重写重载父类的方法
    
    /// 布局子视图。创建对象顺序一定是先有frame，再awakeFromNib，再调整布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        judy.viewRadiu(radiu: 6)
    }
        
    // MARK: - override - 重写重载父类的方法
        
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件
    
    // MARK: - private method - 私有方法
    
}

class HomeCollectionCellC: HomeCollectionCellAB {
    
}


