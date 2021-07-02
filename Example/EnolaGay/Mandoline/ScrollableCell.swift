//
//  ScrollableCell.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class ScrollableCell: UICollectionViewCell {
    /// Cell 中持有的实体。
    open lazy var itemModel = ScrollableCellViewModel()

    public let titleLabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)

        titleLabel.textAlignment = .center
        backgroundColor = .white
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
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
    
    open func reloadData(itemModel: ScrollableCellViewModel) {
        self.itemModel = itemModel
        titleLabel.numberOfLines = 1
        titleLabel.text = itemModel.title
        if itemModel.isSelectable {
            titleLabel.textColor = itemModel.titleSelectedColor
        } else {
            titleLabel.textColor = itemModel.titleNormalColor
        }
        setNeedsLayout()
    }

}

open class ScrollableCellViewModel: Selectable {

    /// title 普通状态时的字体。
    open var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// 选中状态下的字体。
    open var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// title 普通状态的 textColor.
    open var titleNormalColor: UIColor = .black
    /// 当前显示的颜色。
    open var titleCurrentColor: UIColor = .black
    /// title 选中状态的 textColor.
    open var titleSelectedColor: UIColor = .red

    public var isSelectable: Bool = false
    public var title = ""
    public var cellWidth: CGFloat {
        let textWidth = NSString(string: title)
            .boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                          options: [.usesFontLeading, .usesLineFragmentOrigin],
                          attributes: [.font: titleNormalFont],
                          context: nil).size.width
        return CGFloat(ceilf(Float(textWidth)))
    }


}
