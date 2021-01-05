//
//  JudyBaseTableCell.swift
//  RunEn
//
//  Created by 醉翁之意 on 2018/4/2.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

import UIKit
import SDWebImage

/// tableVie 通用 cell，包含一张主要图片、副标题以及默认数据源 json。
/// * labelsForColor 中的 labels 会配置颜色 foreground
open class JudyBaseTableCell: UITableViewCell, EMERANA_CellBasic {
    
    /// 是否需要解决 UITableView 有 footerView 时最后一个 cell 不显示分割线问题，默认 false
    @IBInspectable lazy var isShowSeparatorAtFooter: Bool = false
    
    // MARK: - let property and IBOutlet

    @IBOutlet weak public var titleLabel: UILabel?
    
    @IBOutlet weak public var subTitleLabel: UILabel?
    
    @IBOutlet weak public var masterImageView: UIImageView?
    
    @IBOutlet lazy public var labelsForColor: [UILabel]? = nil
    

    // MARK: - var property

    /**
     didSet 时重新定义 super.frame
     # 切记是要更改 super.frame，而不是 self，否则会进入死循环
     */
    open override var frame: CGRect {
        didSet{
            // 改变 super 的 frame，需要计算好 row height。如实际需要100，底部留空10，则 row height 应该为 100 + 10
            // super.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height - 10))
        }
    }
        
    public var json = JSON() { didSet{ jsonDidSetAction() } }
    
    
    // MARK: - Life Cycle
    
    // Cell 准备重用时执行的方法
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        // 此处应重置cell状态，清除在重用池里面设置的值
    }
    
    /// 从 xib 或故事板创建对象将会执行此初始函数
    /// 重写了此方法必须调用 super.awakeFromNib()，里面实现了配置。
    open override func awakeFromNib() {
        super.awakeFromNib()
        globalAwakeFromNib()
        labelsForColor?.forEach { label in
            label.textColor = .judy(.text)
        }
        
    }
    
    /// 布局子视图，创建对象顺序一定是先有 frame，再 awakeFromNib，再调整布局
    open override func layoutSubviews() {
        super.layoutSubviews()

        // 此处涉及到布局，因此必须放在 layoutSubviews() 中
        if isShowSeparatorAtFooter {
            // 解决 UITableView 有 footerView 时最后一个 cell 不显示分割线问题
            for separatorView in self.contentView.superview!.subviews {
                if NSStringFromClass(separatorView.classForCoder).hasSuffix("SeparatorView") {
                    separatorView.alpha = 1

                    separatorView.x_emerana = separatorInset.left
                    let newWidth = frame.width - (separatorInset.left + separatorInset.right)
                    separatorView.frame.size = CGSize(width: newWidth, height: separatorView.frame.size.height)
                    
                }
            }
        }

    }
    
    // 如果布局更新挂起，则立即布局子视图。
    open override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        // 设置正圆
        if masterImageView?.isRound ?? false {
            masterImageView?.viewRound()
        }
        
    }
    
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    open func jsonDidSetAction() {
        titleLabel?.text = json[EMERANA.Key.Cell.title].stringValue
        subTitleLabel?.text = json[EMERANA.Key.Cell.subtitle].stringValue
        if let imageName = json[EMERANA.Key.Cell.icon].string {
            masterImageView?.image = UIImage(named: imageName)
        }
        if let imageURL = json[EMERANA.Key.Cell.image].string {
            masterImageView?.sd_setImage(with: URL(string: imageURL), completed: nil)
        }
    }

}
