//
//  AccountCollectionCell.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/10/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 账号界面的 CollectionViewCell
class AccountCollectionCell: JudyBaseCollectionViewCell {
    // MARK: - let property and IBOutlet
    
    // MARK: - var property
    
    /// 该 Cell 中的 group 模型
    var group: Group? {
        didSet {
//            masterImageView?.image = UIImage(ICONCtrl.j named: group?.icon ?? "placeholder")

            guard group != nil else { return }
            masterImageView?.image = UIImage(named: group?.icon ?? "jiemi",
                                             in: ICONCtrl.judy.bundle(iconBundle: .icons_group),
                                             compatibleWith: nil)
            
            // 设置背景色
            let colorValue: Int = group!.backgroundColor.intValueFrom16Decimal
            backgroundColor = UIColor(rgbValue: colorValue )
            titleLabel?.text = group!.name
            subTitleLabel?.text = String(group!.count)
        }
    }
    
    // MARK: - life cycle
    
    /// 从 xib 或故事板创建对象的初始化方法
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    // MARK: - override
    
    /// 布局子视图。创建对象顺序一定是先有 frame，再 awakeFromNib，再调整布局。
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
