//
//  PickerViewCell.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import UIKit

public protocol Selectable {
    var isSelectable: Bool { get set }
}

open class PickerViewCell: UICollectionViewCell, Selectable {
    public var isSelectable = true
    public var cellWidth: CGFloat = 128

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        contentView.layer.borderWidth = 1.0
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
    }
}


class ScrollableCell: UICollectionViewCell {
    /// Cell 中持有的实体。
    open lazy var model = PickerViewItemModel()
    
    /// 用于显示标题的 lebel。
    public let titleLabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        backgroundColor = .white
        contentView.layer.borderColor = UIColor.cyan.cgColor
        //UIColor.black.withAlphaComponent(0.08).cgColor
        contentView.layer.borderWidth = 1.0

//        contentView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
////            make.top.bottom.equalTo(8)
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
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
    open func reloadData(model: PickerViewItemModel) {
        self.model = model
        
        let attriText = NSMutableAttributedString(text: model.title,
                                                  textColor: model.titleNormalColor,
                                                  textFont: model.titleNormalFont)
        titleLabel.attributedText = attriText
                
        if model.isSelectable {
            titleLabel.textColor = model.titleSelectedColor
        } else {
            titleLabel.textColor = model.titleNormalColor
        }
        setNeedsLayout()
    }
}

/// Cell 中的基础模型。
open class PickerViewItemModel {
    /// 该值为实体的索引。
    // open var index: Int = 0

    open var title = ""
    /// title 普通状态时的字体。
    open var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// 选中状态下的字体。
    open var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// title 普通状态的 textColor.
    open var titleNormalColor: UIColor = .black
    /// title 选中状态的 textColor.
    open var titleSelectedColor: UIColor = .red

    open var isSelectable: Bool = false
    
//    open var cellWidth: CGFloat = 0
//    {
//        let textWidth = NSString(string: title)
//            .boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
//                          options: [.usesFontLeading, .usesLineFragmentOrigin],
//                          attributes: [.font: titleNormalFont],
//                          context: nil).size.width
//        return CGFloat(ceilf(Float(textWidth)))
//    }
    
    /// title 下文本的宽度。
    open var textWidth: CGFloat {
        
        let textWidth = NSString(string: title)
            .boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                          options: [.usesFontLeading, .usesLineFragmentOrigin],
                          attributes: [.font: titleNormalFont],
                          context: nil).size.width
        return CGFloat(ceilf(Float(textWidth)))
    }
    
}
