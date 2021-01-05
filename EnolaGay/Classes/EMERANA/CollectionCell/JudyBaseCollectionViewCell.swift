//
//  BaseGreenCoinCellCollectionViewCell.swift
//  PPScience
//
//  Created by 醉翁之意 on 2018/4/20.
//  Copyright © 2018年 GSDN. All rights reserved.
//

import UIKit
import SDWebImage

/// collectionView 通用 cell，包含一张主要图片、副标题以及默认数据源 json。
/// * labelsForColor 中的 labels 会配置颜色 foreground
open class JudyBaseCollectionViewCell: UICollectionViewCell, EMERANA_CellBasic {

    // MARK: - let property and IBOutlet
    
    @IBOutlet weak public var titleLabel: UILabel?
    
    @IBOutlet weak public var subTitleLabel: UILabel?
    
    @IBOutlet weak public var masterImageView: UIImageView?
    
    @IBOutlet lazy public var labelsForColor: [UILabel]? = nil

    // MARK: - var property
    
    public var json = JSON() { didSet{ jsonDidSetAction() } }

    
    // MARK: - life cycle

    
    // Judy-mark: cell准备重用时会先执行此方法.
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        // 此处应重置cell状态，清除在重用池里面设置的值
    }

    /// 重写了此方法必须调用 super.awakeFromNib()，里面实现了配置。
    open override func awakeFromNib() {
        super.awakeFromNib()
        globalAwakeFromNib()
        labelsForColor?.forEach { label in
            label.textColor = .judy(.text)
        }

    }
    
    /// 布局子视图。创建对象顺序一定是先有frame，再awakeFromNib，再调整布局
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        /*
         给cell添加渐变颜色
         //create gradientLayer
         let gradientLayer : CAGradientLayer = CAGradientLayer()
         gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
         
         //gradient colors
         let colors = [ Judy.colorByRGB(rgbValue: <#T##0x12ba2d#>).cgColor,  Judy.colorByRGB(rgbValue: <#T##0x12ba2d#>).cgColor]
         
         gradientLayer.colors = colors
         gradientLayer.startPoint = CGPoint(x: 0, y: 0);
         gradientLayer.endPoint = CGPoint(x: 1, y: 0);
         self.layer.insertSublayer(gradientLayer, at: 0)
         
         */
        // 在 CollectionCell 中设置正圆的正确方式
        layoutIfNeeded()
        if masterImageView?.isRound ?? false {
            masterImageView?.viewRound()
        }
        
    }
    
    // 如果布局更新挂起，则立即布局子视图。
    open override func layoutIfNeeded() {
        super.layoutIfNeeded()

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
