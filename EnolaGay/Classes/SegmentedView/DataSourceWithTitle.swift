//
//  title 样式的数据源相关文件。
//  此样式即最常用的、普通的以标题为主的数据源样式。
//  如果需要高度自定义 SegmentedView 请参考此文件的实现方式。
//
//  Created by 王仁洁 on 2021/3/22.
//


/// 以 title 为主的实体数据
open class SegmentedItemTitleModel: SegmentedItemModel {
    
    /// 标题文本。
    open var title: String?
    /// label的numberOfLines，默认为 1。
    open var titleNumberOfLines: Int = 1
    
    /// title 普通状态的 textColor。
    open var titleNormalColor: UIColor = .black
    /// 当前显示的颜色。
    open var titleCurrentColor: UIColor = .black
    /// title 选中状态的 textColor。
    open var titleSelectedColor: UIColor = .red
    
    /// title 普通状态时的字体。
    open var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// 选中状态下的字体。
    open var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 15)
    
    /// title 是否缩放。使用该效果时，务必保证 titleNormalFont 和 titleSelectedFont 值相同。
    open var isTitleZoomEnabled: Bool = false
    open var titleNormalZoomScale: CGFloat = 0
    open var titleCurrentZoomScale: CGFloat = 0
    
    /// isTitleZoomEnabled 为 true 才生效。是对字号的缩放，比如 titleNormalFont 的 pointSize 为10，放大之后字号就是10*1.2=12。
    open var titleSelectedZoomScale: CGFloat = 0
    /// title 的线宽是否允许粗细。使用该效果时，务必保证 titleNormalFont 和 titleSelectedFont 值相同。
    open var isTitleStrokeWidthEnabled: Bool = false
    open var titleNormalStrokeWidth: CGFloat = 0
    
    /// 用于控制字体的粗细（底层通过NSStrokeWidthAttributeName实现），负数越小字体越粗。
    open var titleCurrentStrokeWidth: CGFloat = 0
    /// 选中状态下字体的粗细。
    open var titleSelectedStrokeWidth: CGFloat = 0
    
    /// title 是否使用遮罩过渡。
    open var isTitleMaskEnabled: Bool = false
    /// title 文本的宽度。
    open var textWidth: CGFloat {
        get{ return widthForTitle() }
    }
    
    /// item 左右滚动过渡时，是否允许渐变。比如 titleZoom、titleNormalColor、titleStrokeWidth 等渐变。
    open var isItemTransitionEnabled: Bool = true

    /// 计算 title 的宽度。
    private func widthForTitle() -> CGFloat {
        let textWidth = NSString(string: title ?? "").boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : titleNormalFont], context: nil).size.width
        return CGFloat(ceilf(Float(textWidth)))
    }

}


/// 适用于以标题为主的 Cell。
open class SegmentedTitleCell: SegmentedCell {
    
    /// 主要 label
    public let titleLabel = UILabel()
    public let maskTitleLabel = UILabel()
    public let titleMaskLayer = CALayer()
    public let maskTitleMaskLayer = CALayer()
    
    
    open override func commonInit() {
        super.commonInit()
        
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        // FIXME: titleLabel 背景色
        // titleLabel.backgroundColor = .gray
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        // 在 numberOfLines 大于 0 的时候，cell 进行重用的时候通过`sizeToFit`，label 设置成错误的 size，用`sizeThatFits`可以规避掉这个问题。
        let labelSize = titleLabel.sizeThatFits(self.contentView.bounds.size)
        let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        titleLabel.bounds = labelBounds
        titleLabel.center = contentView.center

        maskTitleLabel.bounds = labelBounds
        maskTitleLabel.center = contentView.center

    }

    open override func reloadData(itemModel: SegmentedItemModel) {
        super.reloadData(itemModel: itemModel)

        // 当前 Cell 需要确保 item 为 SegmentedItemModelByTitle
        guard let myItemModel = itemModel as? SegmentedItemTitleModel else { return }
        
        titleLabel.numberOfLines = myItemModel.titleNumberOfLines
        maskTitleLabel.numberOfLines = myItemModel.titleNumberOfLines
        // 允许标题缩放
        if myItemModel.isTitleZoomEnabled {
            //先把font设置为缩放的最大值，再缩小到最小值，最后根据当前的 titleCurrentZoomScale 值，进行缩放更新。这样就能避免 transform 从小到大时字体模糊
            let maxScaleFont = UIFont(descriptor: myItemModel.titleNormalFont.fontDescriptor, size: myItemModel.titleNormalFont.pointSize*CGFloat(myItemModel.titleSelectedZoomScale))
            let baseScale = myItemModel.titleNormalFont.lineHeight/maxScaleFont.lineHeight

//            if myItemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
//                //允许动画且当前是点击的
//                let titleZoomClosure = preferredTitleZoomAnimateClosure(itemModel: myItemModel, baseScale: baseScale)
//                appendSelectedAnimationClosure(closure: titleZoomClosure)
//            }else {
                titleLabel.font = maxScaleFont
                maskTitleLabel.font = maxScaleFont
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                let currentTransform = CGAffineTransform(scaleX: baseScale*CGFloat(myItemModel.titleCurrentZoomScale), y: baseScale*CGFloat(myItemModel.titleCurrentZoomScale))
                self.titleLabel.transform = currentTransform
                self.maskTitleLabel.transform = currentTransform
//            }, completion: { finished in
//
//            })
//            }
        } else {
            if myItemModel.isSelected {
                titleLabel.font = myItemModel.titleSelectedFont
                maskTitleLabel.font = myItemModel.titleSelectedFont
            } else {
                titleLabel.font = myItemModel.titleNormalFont
                maskTitleLabel.font = myItemModel.titleNormalFont
            }
        }

        let title = myItemModel.title ?? ""
        let attriText = NSMutableAttributedString(string: title)
        if myItemModel.isTitleStrokeWidthEnabled {
//            if myItemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
//                //允许动画且当前是点击的
//                let titleStrokeWidthClosure = preferredTitleStrokeWidthAnimateClosure(itemModel: myItemModel, attriText: attriText)
//                appendSelectedAnimationClosure(closure: titleStrokeWidthClosure)
//            }else {
                attriText.addAttributes([NSAttributedString.Key.strokeWidth: myItemModel.titleCurrentStrokeWidth], range: NSRange(location: 0, length: title.count))
                titleLabel.attributedText = attriText
                maskTitleLabel.attributedText = attriText
//            }
        }else {
            titleLabel.attributedText = attriText
            maskTitleLabel.attributedText = attriText
        }

        if myItemModel.isTitleMaskEnabled {
            //允许 mask，maskTitleLabel 在 titleLabel 上面，maskTitleLabel 设置为 titleSelectedColor。titleLabel 设置为 titleNormalColor
            //为了显示效果，使用了双遮罩。即 titleMaskLayer 遮罩 titleLabel，maskTitleMaskLayer 遮罩 maskTitleLabel
            maskTitleLabel.isHidden = false
            titleLabel.textColor = myItemModel.titleNormalColor
            maskTitleLabel.textColor = myItemModel.titleSelectedColor
            let labelSize = maskTitleLabel.sizeThatFits(self.contentView.bounds.size)
            let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
            maskTitleLabel.bounds = labelBounds

            var topMaskFrame = myItemModel.indicatorConvertToItemFrame
            topMaskFrame.origin.y = 0
            var bottomMaskFrame = topMaskFrame
            var maskStartX: CGFloat = 0
            if maskTitleLabel.bounds.size.width >= bounds.size.width {
                topMaskFrame.origin.x -= (maskTitleLabel.bounds.size.width - bounds.size.width)/2
                bottomMaskFrame.size.width = maskTitleLabel.bounds.size.width
                maskStartX = -(maskTitleLabel.bounds.size.width - bounds.size.width)/2
            }else {
                topMaskFrame.origin.x -= (bounds.size.width - maskTitleLabel.bounds.size.width)/2
                bottomMaskFrame.size.width = bounds.size.width
                maskStartX = 0
            }
            bottomMaskFrame.origin.x = topMaskFrame.origin.x
            if topMaskFrame.origin.x > maskStartX {
                bottomMaskFrame.origin.x = topMaskFrame.origin.x - bottomMaskFrame.size.width
            }else {
                bottomMaskFrame.origin.x = topMaskFrame.maxX
            }

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if topMaskFrame.size.width > 0 && topMaskFrame.intersects(maskTitleLabel.frame) {
                titleLabel.layer.mask = titleMaskLayer
                titleMaskLayer.frame = bottomMaskFrame
                maskTitleMaskLayer.frame = topMaskFrame
            }else {
                titleLabel.layer.mask = nil
                maskTitleMaskLayer.frame = topMaskFrame
            }
            CATransaction.commit()
        } else {
            maskTitleLabel.isHidden = true
            titleLabel.layer.mask = nil
//            if myItemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
//                //允许动画且当前是点击的
//                let titleColorClosure = preferredTitleColorAnimateClosure(itemModel: myItemModel)
//                appendSelectedAnimationClosure(closure: titleColorClosure)
//            } else {
                titleLabel.textColor = myItemModel.titleCurrentColor
//            }
        }

//        startSelectedAnimationIfNeeded(itemModel: itemModel, selectedType: selectedType)

        setNeedsLayout()
    }

}


/// 指示器外观样式
public enum IndicatorStyle {
    case normal
    case lengthen
    case lengthenOffset
}


/// 样式为一条线的指示器
open class IndicatorLineView: IndicatorView {
    
    open var lineStyle: IndicatorStyle = .normal

    /// lineStyle 为 lengthenOffset 时使用，滚动时x的偏移量
    open var lineScrollOffsetX: CGFloat = 10

    
    open override func refreshIndicatorState(model: IndicatorSelectedParams) {
        // 确定背景色
        backgroundColor = indicatorColor
        // 确定 frame。
        let width = indicatorWidth == SegmentedAutomaticDimension ?
            model.contentWidth + indicatorWidthIncrement:indicatorWidth

        let height: CGFloat = (indicatorHeight == SegmentedAutomaticDimension) ?4:indicatorHeight
        layer.cornerRadius = height/2

        let x = model.itemFrame.origin.x + (model.itemFrame.size.width - width)/2
        var y: CGFloat = 0
        switch indicatorPosition {
        case .top:
            y = verticalOffset
        case .bottom:
            y = model.itemFrame.size.height - height - verticalOffset
        case .center:
            y = (model.itemFrame.size.height - height)/2 + verticalOffset
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }

    open override func contentScrollViewDidScroll(model: IndicatorTransitionParams) {

        guard canHandleTransition(model: model) else { return }

        let rightItemFrame = model.rightItemFrame
        let leftItemFrame = model.leftItemFrame
        let percent = model.percent
        var targetX: CGFloat = leftItemFrame.origin.x
        //        var targetWidth = getIndicatorWidth(itemFrame: leftItemFrame, itemContentWidth: model.leftItemContentWidth)
        var targetWidth = indicatorWidth == SegmentedAutomaticDimension ?
            model.leftItemContentWidth + indicatorWidthIncrement:indicatorWidth

        let leftWidth = targetWidth
        let rightWidth = model.rightItemContentWidth
        let leftX = leftItemFrame.origin.x + (leftItemFrame.size.width - leftWidth)/2
        let rightX = rightItemFrame.origin.x + (rightItemFrame.size.width - rightWidth)/2

        switch lineStyle {
        case .normal:
            targetX = SegmentedViewTool.interpolate(from: leftX, to: rightX, percent: CGFloat(percent))
            if indicatorWidth == SegmentedAutomaticDimension {
                targetWidth = SegmentedViewTool.interpolate(from: leftWidth, to: rightWidth, percent: CGFloat(percent))
            }
        case .lengthen:
            //前50%，只增加width；后50%，移动x并减小width
            let maxWidth = rightX - leftX + rightWidth
            if percent <= 0.5 {
                targetX = leftX
                targetWidth = SegmentedViewTool.interpolate(from: leftWidth, to: maxWidth, percent: CGFloat(percent*2))
            }else {
                targetX = SegmentedViewTool.interpolate(from: leftX, to: rightX, percent: CGFloat((percent - 0.5)*2))
                targetWidth = SegmentedViewTool.interpolate(from: maxWidth, to: rightWidth, percent: CGFloat((percent - 0.5)*2))
            }
        case .lengthenOffset:
            // 前50%，增加width，并少量移动x；后50%，少量移动x并减小width
            let maxWidth = rightX - leftX + rightWidth - lineScrollOffsetX*2
            if percent <= 0.5 {
                targetX = SegmentedViewTool.interpolate(from: leftX, to: leftX + lineScrollOffsetX, percent: CGFloat(percent*2))
                targetWidth = SegmentedViewTool.interpolate(from: leftWidth, to: maxWidth, percent: CGFloat(percent*2))
            }else {
                targetX = SegmentedViewTool.interpolate(from:leftX + lineScrollOffsetX, to: rightX, percent: CGFloat((percent - 0.5)*2))
                targetWidth = SegmentedViewTool.interpolate(from: maxWidth, to: rightWidth, percent: CGFloat((percent - 0.5)*2))
            }
        }
        
        self.frame.origin.x = targetX
        self.frame.size.width = targetWidth
    }
    
    
    public override func selectItem(model: IndicatorSelectedParams) {
        
        let targetWidth =  indicatorWidth == SegmentedAutomaticDimension ?
            model.contentWidth + indicatorWidthIncrement:indicatorWidth
        
        var toFrame = self.frame
        toFrame.origin.x = model.itemFrame.origin.x + (model.itemFrame.size.width - targetWidth)/2
        toFrame.size.width = targetWidth
        
        if canSelectedWithAnimation(model: model) {
            
            UIView.animate(withDuration: scrollAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.frame = toFrame
            }) {_ in }
            
        } else {
            frame = toFrame
        }
    }
    
}


// MARK: 内置可直接使用的数据源

/// 可直接使用的适用于 SegmentedItemTitleModel 、SegmentedTitleCell 类型的数据源
open class SegmentedViewTitleDataSource: SegmentedViewDataSource {
    
    // MARK: - 协议属性
    public var itemSpacing: CGFloat = 8
    public var isItemSpacingAverageEnabled: Bool = true
    public var isItemWidthZoomEnabled: Bool = false
    public var selectedAnimationDuration: TimeInterval = 0.25

    // MARK: - 自有属性
    
    /// 该 title 数组用于确定 dataSource
    open var titles = ["大家好", "我是", "VAE", "，", "这是我即将发表的首张独创专辑", "自定义", "里面的一首", "推荐曲目", "词曲编曲都是我自己", "-->", "有何不可"]

    /// 真实的 item 宽度 = itemWidth + itemWidthIncrement。
    open var itemWidthIncrement: CGFloat = 0
    /// 如果将 SegmentedView 嵌套进 UITableView 的 cell，每次重用的时候，SegmentedView 进行 reloadData 时，会重新计算所有的 title 宽度。所以该应用场景，需要 UITableView 的 cellModel 缓存 titles 的文字宽度，再通过该闭包方法返回给 SegmentedView。
    // open var widthForTitleClosure: ((String)->(CGFloat))?

    /// title 普通状态时的颜色，默认为 black。
    open var titleNormalColor: UIColor = .black
    /// title 选中状态下的颜色，默认为 red。
    open var titleSelectedColor: UIColor = .red

    /// title 普通状态时的字体，默认为 systemFont(ofSize: 15)。
    open var titleNormalFont: UIFont = UIFont.systemFont(ofSize: 15)
    /// title 选中状态下的字体，默认为 systemFont(ofSize: 15)。
    open var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 15)

    
    public init() {}

    public func segmentedView(registerCellForCollectionViewAt collectionView: UICollectionView) -> String {
        collectionView.register(SegmentedTitleCell.self, forCellWithReuseIdentifier: "Cell")
        return "Cell"
    }
    
    public func numberOfItems(in segmentedView: SegmentedView) -> Int { titles.count }
    
    public func segmentedView(_ segmentedView: SegmentedView, entityForItem entity: SegmentedItemModel?, entityForItemAt index: Int, selectedIndex: Int) -> SegmentedItemModel {
        
        var model = SegmentedItemTitleModel()
        if entity as? SegmentedItemTitleModel != nil {
            model = entity as! SegmentedItemTitleModel
        }
        
        model.isItemTransitionEnabled = true
        model.isSelectedAnimable = false
        
        model.title = titles[index]

        model.titleNormalColor = titleNormalColor
        model.titleSelectedColor = titleSelectedColor
        
        model.titleNormalFont = titleNormalFont
        model.titleSelectedFont = titleSelectedFont
        
        model.isTitleZoomEnabled = false
        
        model.isTitleStrokeWidthEnabled = false
        model.isTitleMaskEnabled = false
        
        model.titleNormalZoomScale = 1
        model.titleSelectedZoomScale = 1.2
        model.titleSelectedStrokeWidth = -2
        model.titleNormalStrokeWidth = 0
        // 确定选中的模型。
        if index == selectedIndex {
            model.titleCurrentColor = titleSelectedColor
            model.titleCurrentZoomScale = 1.2
            model.titleCurrentStrokeWidth = -2
        } else {
            model.titleCurrentColor = titleNormalColor
            model.titleCurrentZoomScale = 1
            model.titleCurrentStrokeWidth = 0
        }
        
        return model
    }
    
    public func segmentedView(_ segmentedView: SegmentedView, widthForItem entity: SegmentedItemModel) -> CGFloat {
        
        return itemWidthIncrement + (entity as! SegmentedItemTitleModel).textWidth
    }
    
    public func segmentedView(_ segmentedView: SegmentedView, widthForItemContent item: SegmentedItemModel) -> CGFloat {
        let model = item as! SegmentedItemTitleModel
        if model.isTitleZoomEnabled {
            return model.textWidth*model.titleCurrentZoomScale
        } else {
            return model.textWidth
        }
    }

}


