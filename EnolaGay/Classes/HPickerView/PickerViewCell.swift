//
//  PickerViewCell.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import UIKit

class PickerViewCell: UICollectionViewCell {
    /// Cell 中持有的实体。
    // public lazy var model = PickerViewCellModel()
    /// 用于显示标题的 lebel.
    public let titleLabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        backgroundColor = nil
//        contentView.layer.borderColor = UIColor.cyan.cgColor
        //UIColor.black.withAlphaComponent(0.08).cgColor
//        contentView.layer.borderWidth = 1.0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // 在 numberOfLines 大于 0 的时候，cell 进行重用的时候通过`sizeToFit`，label 设置成错误的 size，用`sizeThatFits`可以规避掉这个问题。
        let labelSize = titleLabel.sizeThatFits(self.contentView.bounds.size)
        let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        titleLabel.bounds = labelBounds
        titleLabel.center = contentView.center
    }
    
    /// 给 Cell 重新设置模型数据。
    open func reloadData(model: PickerViewCellModel) {
        let attriText = NSMutableAttributedString(text: model.title,
                                                  textColor: model.titleNormalColor,
                                                  textFont: model.titleNormalFont)
        titleLabel.attributedText = attriText
                
        if model.isSelected {
            titleLabel.textColor = model.titleSelectedColor
            titleLabel.font = model.titleSelectedFont
        } else {
            titleLabel.textColor = model.titleNormalColor
            titleLabel.font = model.titleNormalFont
        }
        setNeedsLayout()
    }
}

/// Cell 中的基础模型。
public class PickerViewCellModel {

    /// title 普通状态时的字体。
    public var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// 选中状态下的字体。
    public var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    /// title 普通状态的 textColor.
    public var titleNormalColor: UIColor = .gray
    /// title 选中状态的 textColor.
    public var titleSelectedColor: UIColor = .black
    /// 标题。
    public internal(set) var title = ""
    /// 该值为实体的索引。
    public internal(set) var index: Int = 0
    /// 当前是否为选中状态，默认 false.
    public internal(set) var isSelected: Bool = false

    /// title 下文本的宽度。
    @available(*, unavailable, message: "暂时用不到")
    public var textWidth: CGFloat {
        let textWidth = NSString(string: title)
            .boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                          options: [.usesFontLeading, .usesLineFragmentOrigin],
                          attributes: [.font: titleNormalFont],
                          context: nil).size.width
        return CGFloat(ceilf(Float(textWidth)))
    }
    
}
