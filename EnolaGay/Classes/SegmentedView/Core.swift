//
//  SegmentedView 中核心组件相关内容
//
//  Created by 王仁洁 on 2021/3/10.
//

import Foundation
import UIKit


// MARK: - SegmentedItemModel

/// SegmentedCell 中的基础数据模型。
open class SegmentedItemModel {

    /// 该值为实体的索引。
    open var index: Int = 0
    /// 该属性标识当前实体的选中状态，此属性将直接影响 itemWidthCurrentZoomScale 属性。
    open var isSelected: Bool = false {
        didSet{
            if isSelected {
                itemWidthCurrentZoomScale = itemWidthSelectedZoomScale
            } else {
                itemWidthCurrentZoomScale = itemWidthNormalZoomScale
            }
        }
    }
    
    /// 计算属性，该值标识 item 宽度，即 cell 宽度。
    ///
    /// - Warning: 在获取该属性时会根据 isSelected、isItemWidthZoomEnabled 来返回正确的宽度。
    open var itemWidth: CGFloat {
        set { cellWidth = newValue }
        get{
            return isItemWidthZoomEnabled ? cellWidth * itemWidthCurrentZoomScale:cellWidth
        }
    }
    
    /// 该值用于表示 item（ cell ） 是否允许宽度缩放，该值默认为 false。
    open var isItemWidthZoomEnabled: Bool = false

    /// 指示器视图 Frame 转换到 Cell。
    open var indicatorConvertToItemFrame: CGRect = .zero
    /// 选中的时候，是否需要动画过渡。自定义的cell需要自己处理动画过渡逻辑，动画处理逻辑参考`SegmentedTitleCell`
    open var isSelectedAnimable: Bool = false

    /// 当前正显示的 item 宽度比例，此属性受 isSelected 影响。
    open var itemWidthCurrentZoomScale: CGFloat = 1
    ///  item 宽度在默认情况下的显示比例。
    open var itemWidthNormalZoomScale: CGFloat = 1
    /// item 宽度在选中的情况下显示的 scale（比例）。
    open var itemWidthSelectedZoomScale: CGFloat = 1.1

    /// 是否正在进行过渡动画。
    open var isTransitionAnimating: Bool = false
    
    /// 该值用于存储 item 宽度，即 cell 宽度，此属性受 itemWidth 影响
    private var cellWidth: CGFloat = 0

    
    public init() {}
}


/// 适用于以标题为主的模型。
open class SegmentedItemTitleModel: SegmentedItemModel {
    
    /// 标题文本。
    open var title: String?
    /// label的numberOfLines。
    open var titleNumberOfLines: Int = 0
    
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

    /// 计算 title 的宽度
    private func widthForTitle() -> CGFloat {
//        if widthForTitleClosure != nil {
//            return widthForTitleClosure!(title)
//        }else {
            let textWidth = NSString(string: title ?? "").boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : titleNormalFont], context: nil).size.width
            return CGFloat(ceilf(Float(textWidth)))
//        }
    }

}


// MARK: - CollectionView、SegmentedCell


/// SegmentedView 中的基础 Cell，此 Cell 模拟 JXSegmentedTitleCell
open class SegmentedCell: UICollectionViewCell {
    
    /// 持有的实体。
    open var itemModel: SegmentedItemModel?

    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }
    
    /// 通用初始化函数。
    open func commonInit() {
        // FIXME: Cell 背景色
        // backgroundColor = .green
    }

    /// 通过此函数设置 Cell 中的实体
    ///
    /// - Parameters:
    ///   - itemModel: SegmentedItemModel 数据模型。
    open func reloadData(itemModel: SegmentedItemModel) {
        self.itemModel = itemModel
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
            //允许mask，maskTitleLabel在titleLabel上面，maskTitleLabel设置为titleSelectedColor。titleLabel设置为titleNormalColor
            //为了显示效果，使用了双遮罩。即titleMaskLayer遮罩titleLabel，maskTitleMaskLayer遮罩maskTitleLabel
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
//            }else {
                titleLabel.textColor = myItemModel.titleCurrentColor
//            }
        }

//        startSelectedAnimationIfNeeded(itemModel: itemModel, selectedType: selectedType)

        setNeedsLayout()
    }

}


/// SegmentedView 中的基础 CollectionView
open class SegmentedCollectionView: UICollectionView {

    open var indicators = [IndicatorView]() {
        willSet {
            for indicator in indicators {
                indicator.removeFromSuperview()
            }
        }
        didSet {
            for indicator in indicators {
                addSubview(indicator)
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        for indicator in indicators {
//            sendSubviewToBack()
            bringSubviewToFront(indicator)

            if let backgroundView = backgroundView {
                sendSubviewToBack(backgroundView)
            }
        }
    }

}



// MARK: - Indicator


/**
指示器传递的数据模型，不同情况会对不同的属性赋值，根据不同情况的api说明确认。
为什么会通过model传递数据，因为指示器处理逻辑以后会扩展不同的使用场景，会新增参数。如果不通过model传递，就会在api新增参数，一旦修改api修改的地方就特别多了，而且会影响到之前自定义实现的开发者。
*/
public struct IndicatorSelectedParams {
   public let currentSelectedIndex: Int
   public let currentSelectedItemFrame: CGRect
//   public let selectedType: SegmentedItemSelectedType
   public let currentItemContentWidth: CGFloat
   /// collectionView的contentSize
   public var collectionViewContentSize: CGSize?

   public init(currentSelectedIndex: Int, currentSelectedItemFrame: CGRect, currentItemContentWidth: CGFloat, collectionViewContentSize: CGSize?) {
       self.currentSelectedIndex = currentSelectedIndex
       self.currentSelectedItemFrame = currentSelectedItemFrame
//       self.selectedType = selectedType
       self.currentItemContentWidth = currentItemContentWidth
       self.collectionViewContentSize = collectionViewContentSize
   }
}

public struct SegmentedIndicatorTransitionParams {
   public let currentSelectedIndex: Int
   public let leftIndex: Int
   public let leftItemFrame: CGRect
   public let rightIndex: Int
   public let rightItemFrame: CGRect
   public let leftItemContentWidth: CGFloat
   public let rightItemContentWidth: CGFloat
   public let percent: CGFloat

   public init(currentSelectedIndex: Int, leftIndex: Int, leftItemFrame: CGRect, leftItemContentWidth: CGFloat, rightIndex: Int, rightItemFrame: CGRect, rightItemContentWidth: CGFloat, percent: CGFloat) {
       self.currentSelectedIndex = currentSelectedIndex
       self.leftIndex = leftIndex
       self.leftItemFrame = leftItemFrame
       self.leftItemContentWidth = leftItemContentWidth
       self.rightIndex = rightIndex
       self.rightItemFrame = rightItemFrame
       self.rightItemContentWidth = rightItemContentWidth
       self.percent = percent
   }
}

/// 指示器专用协议
public protocol IndicatorProtocol {
    
    /// 是否需要将当前的 indicator 的 frame 转换到 Cell。辅助 SegmentedTitleDataSourced 的 isTitleMaskEnabled 属性使用。
    /// 如果添加了多个 indicator，仅能有一个 indicator 的 isIndicatorConvertToItemFrameEnabled 为 true。
    /// 如果有多个 indicator 的 isIndicatorConvertToItemFrameEnabled 为 true，则以最后一个 isIndicatorConvertToItemFrameEnabled 为 true 的 indicator 为准。
    var isIndicatorConvertToItemFrameEnabled: Bool { get }
    
    /// 视图重置状态时调用，已当前选中的 index 更新状态
    /// param selectedIndex 当前选中的 index
    /// param selectedCellFrame 当前选中的 cellFrame
    /// param contentSize collectionView 的 contentSize
    /// - Parameter model: model description
    func refreshIndicatorState(model: IndicatorSelectedParams)

    /// contentScrollView 在进行手势滑动时，处理指示器跟随手势变化 UI 逻辑；
    /// param selectedIndex 当前选中的 index
    /// param leftIndex 正在过渡中的两个 Cell，相对位置在左边的 Cell 的 index
    /// param leftCellFrame 正在过渡中的两个 Cell，相对位置在左边的 Cell 的 frame
    /// param rightIndex 正在过渡中的两个 Cell，相对位置在右边的 Cell 的 index
    /// param rightCellFrame 正在过渡中的两个 Cell，相对位置在右边的 Cell 的 frame
    /// param percent 过渡百分比
    /// - Parameter model: model description
    func contentScrollViewDidScroll(model: SegmentedIndicatorTransitionParams)

    /// 点击选中了某一个item
    /// param selectedIndex 选中的 index
    /// param selectedCellFrame 选中的 cellFrame
    /// param selectedType 选中的类型
    /// - Parameter model: model description
    func selectItem(model: IndicatorSelectedParams)
}

/// 指示器的位置
public enum IndicatorLocation {
    /// 指示器显示在 segmentedView 顶部
    case top
    /// 指示器显示在 segmentedView 底部
    case bottom
    /// 指示器显示在 segmentedView 垂直方向中心位置
    case center
}

/// 指示器外观样式
public enum IndicatorStyle {
    case normal
    case lengthen
    case lengthenOffset
}


/// 指示器 View
open class IndicatorView: UIView, IndicatorProtocol {
        
    /// 指示器的位置，默认显示在 Cell 底部。
    open var indicatorPosition: IndicatorLocation = .bottom
    
    open var lineStyle: IndicatorStyle = .normal
    
    /// 指示器的颜色
    open var indicatorColor: UIColor = .red
    
    /// 指示器的高度，默认 SegmentedViewAutomaticDimension（与cell的高度相等）。内部通过 getIndicatorHeight 方法获取实际的值。
    open var indicatorHeight: CGFloat = SegmentedAutomaticDimension
    
    /// 默认 SegmentedViewAutomaticDimension （等于indicatorHeight/2）。内部通过 getIndicatorCornerRadius 方法获取实际的值。
    open var indicatorCornerRadius: CGFloat = SegmentedAutomaticDimension

    /// 默认 SegmentedViewAutomaticDimension（与cell的宽度相等）。内部通过getIndicatorWidth方法获取实际的值。
    open var indicatorWidth: CGFloat = SegmentedAutomaticDimension

    ///  指示器的宽度是否跟随item的内容变化（而不是跟着cell的宽度变化）。indicatorWidth=JXSegmentedViewAutomaticDimension才能生效
    open var isIndicatorWidthSameAsItemContent = false

    /// 指示器的宽度增量。比如需求是指示器宽度比cell宽度多10 point。就可以将该属性赋值为10。最终指示器的宽度=indicatorWidth+indicatorWidthIncrement
    open var indicatorWidthIncrement: CGFloat = 0
    
    /// 垂直方向偏移，指示器默认贴着底部或者顶部，verticalOffset越大越靠近中心。
    open var verticalOffset: CGFloat = 0

    /// 手势滚动、点击切换的时候，是否允许滚动。
    open var isScrollEnabled: Bool = true
    
    /// 点击选中时的滚动动画时长
    open var scrollAnimationDuration: TimeInterval = 0.25

    // MARK: 协议属性
    
    public var isIndicatorConvertToItemFrameEnabled: Bool { true }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }
    
    open func commonInit() {

        backgroundColor = .red
        frame = CGRect(origin: CGPoint(x: 0, y: 0), size: .zero)
    
        indicatorHeight = 3

    }

    public func getIndicatorCornerRadius(itemFrame: CGRect) -> CGFloat {
        if indicatorCornerRadius == SegmentedAutomaticDimension {
            return getIndicatorHeight(itemFrame: itemFrame)/2
        }
        return indicatorCornerRadius
    }

    public func getIndicatorWidth(itemFrame: CGRect, itemContentWidth: CGFloat) -> CGFloat {
        if indicatorWidth == SegmentedAutomaticDimension {
            if isIndicatorWidthSameAsItemContent {
                return itemContentWidth + indicatorWidthIncrement
            }else {
                return itemFrame.size.width + indicatorWidthIncrement
            }
        }
        return indicatorWidth + indicatorWidthIncrement
    }

    public func getIndicatorHeight(itemFrame: CGRect) -> CGFloat {
        if indicatorHeight == SegmentedAutomaticDimension {
            return itemFrame.size.height
        }
        return indicatorHeight
    }

    public func canHandleTransition(model: SegmentedIndicatorTransitionParams) -> Bool {
        if model.percent == 0 || !isScrollEnabled {
            //model.percent等于0时不需要处理，会调用selectItem(model: JXSegmentedIndicatorParamsModel)方法处理
            //isScrollEnabled为false不需要处理
            return false
        }
        return true
    }

    public func canSelectedWithAnimation(model: IndicatorSelectedParams) -> Bool {
        if isScrollEnabled {
            //允许滚动且选中类型是点击或代码选中，才进行动画过渡
            return true
        }
        return false
    }
    
    
    // MARK: IndicatorProtocol

    
    public func refreshIndicatorState(model: IndicatorSelectedParams) {
        backgroundColor = indicatorColor
        layer.cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)

        let width = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        let height = getIndicatorHeight(itemFrame: model.currentSelectedItemFrame)
        let x = model.currentSelectedItemFrame.origin.x + (model.currentSelectedItemFrame.size.width - width)/2
        var y: CGFloat = 0
        switch indicatorPosition {
        case .top:
            y = verticalOffset
        case .bottom:
            y = model.currentSelectedItemFrame.size.height - height - verticalOffset
        case .center:
            y = (model.currentSelectedItemFrame.size.height - height)/2 + verticalOffset
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    public func contentScrollViewDidScroll(model: SegmentedIndicatorTransitionParams) { }
    

    public func selectItem(model: IndicatorSelectedParams) {

        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        var toFrame = self.frame
        toFrame.origin.x = model.currentSelectedItemFrame.origin.x + (model.currentSelectedItemFrame.size.width - targetWidth)/2
        toFrame.size.width = targetWidth
        if canSelectedWithAnimation(model: model) {
            UIView.animate(withDuration: scrollAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.frame = toFrame
            }) { (_) in
            }
        }else {
            frame = toFrame
        }
    }

}

/// 样式为一条线的指示器
open class IndicatorLineView: IndicatorView {
    
    /// lineStyle为lengthenOffset时使用，滚动时x的偏移量
    open var lineScrollOffsetX: CGFloat = 10

    public override func refreshIndicatorState(model: IndicatorSelectedParams) {
        backgroundColor = indicatorColor
        layer.cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)

        let width = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        let height = getIndicatorHeight(itemFrame: model.currentSelectedItemFrame)
        let x = model.currentSelectedItemFrame.origin.x + (model.currentSelectedItemFrame.size.width - width)/2
        var y: CGFloat = 0
        switch indicatorPosition {
        case .top:
            y = verticalOffset
        case .bottom:
            y = model.currentSelectedItemFrame.size.height - height - verticalOffset
        case .center:
            y = (model.currentSelectedItemFrame.size.height - height)/2 + verticalOffset
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }

    open override func contentScrollViewDidScroll(model: SegmentedIndicatorTransitionParams) {

        guard canHandleTransition(model: model) else { return }

        let rightItemFrame = model.rightItemFrame
        let leftItemFrame = model.leftItemFrame
        let percent = model.percent
        var targetX: CGFloat = leftItemFrame.origin.x
        var targetWidth = getIndicatorWidth(itemFrame: leftItemFrame, itemContentWidth: model.leftItemContentWidth)

        let leftWidth = targetWidth
        let rightWidth = getIndicatorWidth(itemFrame: rightItemFrame, itemContentWidth: model.rightItemContentWidth)
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
        
        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        
        var toFrame = self.frame
        toFrame.origin.x = model.currentSelectedItemFrame.origin.x + (model.currentSelectedItemFrame.size.width - targetWidth)/2
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


// MARK: Animator


/// Segmented 专用动画控制类
open class Animator {
    
    /// 动画持续时间。
    open var duration: TimeInterval = 0.25
    /// 执行任务的闭包，传入的值为 0~1。
    open var progressClosure: ((CGFloat)->())?
    /// 当任务执行完毕后触发此闭包。
    open var completedClosure: (()->())?
    
    /// 一个计时器对象，它允许应用程序将其绘图同步到显示的刷新率。
    private var displayLink: CADisplayLink!
    /// 与最初显示的帧相关联的时间值。
    private var firstTimestamp: CFTimeInterval?

    public init() {
        displayLink = CADisplayLink(target: self, selector: #selector(processDisplayLink(sender:)))
    }
    
    /// 开始与刷新率同步执行动画
    open func start() {
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }

    /// 停止动画
    open func stop() {
        progressClosure?(1)
        displayLink.invalidate()
        completedClosure?()
    }

    @objc private func processDisplayLink(sender: CADisplayLink) {
        if firstTimestamp == nil {
            firstTimestamp = sender.timestamp
        }
        let percent = (sender.timestamp - firstTimestamp!)/duration
        if percent >= 1 {
            stop()
        } else {
            progressClosure?(CGFloat(percent))
        }
    }
}
