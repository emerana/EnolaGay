//
//  SegmentedView 中核心组件相关内容
//
//  Created by 王仁洁 on 2021/3/10.
//

import Foundation
import UIKit


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


/// SegmentedView 中的基础 Cell，此 Cell 模拟 JXSegmentedTitleCell
open class SegmentedCell: UICollectionViewCell {
    
    /// Cell 中持有的实体。
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

    /// 通过此函数设置 Cell 中的实体详细信息。
    ///
    /// - Parameters:
    ///   - itemModel: SegmentedItemModel 数据模型。
    open func reloadData(itemModel: SegmentedItemModel) {
        self.itemModel = itemModel
    }
    
}


/// SegmentedView 中的基础 CollectionView
open class SegmentedCollectionView: UICollectionView {

    open var indicators = [UIView & IndicatorProtocol]() {
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
            sendSubviewToBack(indicator)
            //bringSubviewToFront(indicator)

            if let backgroundView = backgroundView {
                sendSubviewToBack(backgroundView)
            }
        }
    }

}



// MARK: - Indicator


/// 指示器传递的数据模型。
public struct IndicatorSelectedParams {
    /// 选中的索引。
    public let index: Int
    /// 选中项的窗体(Cell)矩形。
    public let itemFrame: CGRect
    /// 该值表示指示器的宽度。
    public let contentWidth: CGFloat
    /// collectionView 的 contentSize。
    public var collectionViewContentSize: CGSize?
    
    public init(index: Int, itemFrame: CGRect, contentWidth: CGFloat, collectionViewContentSize: CGSize?) {
        self.index = index
        self.itemFrame = itemFrame
        self.contentWidth = contentWidth
        self.collectionViewContentSize = collectionViewContentSize
    }
}

public struct IndicatorTransitionParams {
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

/// 一个普通的标准指示器 View，如果需要自定义指示器可参考本类实现方式。
open class IndicatorView: UIView, IndicatorProtocol {
    
    public var isIndicatorConvertToItemFrameEnabled: Bool { true }

    // MARK: 自有属性
    
    /// 指示器的位置，默认显示在 Cell 底部。
    open var indicatorPosition: IndicatorLocation = .bottom
    
    /// 指示器的颜色，默认为 gray。
    open var indicatorColor: UIColor = .gray
    
    /// 指示器的高度，默认 SegmentedAutomaticDimension。
    open var indicatorHeight: CGFloat = SegmentedAutomaticDimension
    /// 指示器的宽度，默认 SegmentedViewAutomaticDimension。
    private(set) var indicatorWidth: CGFloat = SegmentedAutomaticDimension

    /// 圆角程度，默认为 SegmentedAutomaticDimension。
    open var indicatorCornerRadius: CGFloat = SegmentedAutomaticDimension

    /// 指示器的宽度增量。比如需求是指示器宽度比 Cell 宽度多 10 point，就可以将该属性赋值为10。最终指示器的宽度为 indicatorWidth + indicatorWidthIncrement。
    open var indicatorWidthIncrement: CGFloat = 0
    
    /// 垂直方向偏移，指示器默认贴着底部或者顶部，verticalOffset 越大越靠近中心。
    open var verticalOffset: CGFloat = 0

    /// 手势滚动、点击切换的时候，是否允许滚动。
    open var isScrollEnabled: Bool = true
    
    /// 点击选中时的滚动动画时长
    open var scrollAnimationDuration: TimeInterval = 0.25


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

        backgroundColor = indicatorColor
        frame = CGRect(origin: CGPoint(x: 0, y: 0), size: .zero)
    
    }

    public func canHandleTransition(model: IndicatorTransitionParams) -> Bool {
        if model.percent == 0 || !isScrollEnabled {
            // model.percent 等于0时不需要处理，会调用 selectItem(model: SegmentedIndicatorParamsModel) 方法处理
            // isScrollEnabled 为 false 不需要处理
            return false
        }
        return true
    }

    public func canSelectedWithAnimation(model: IndicatorSelectedParams) -> Bool {
        if isScrollEnabled {
            // 允许滚动且选中类型是点击或代码选中，才进行动画过渡。
            return true
        }
        return false
    }
    
    
    // MARK: IndicatorProtocol

    
    public func refreshIndicatorState(model: IndicatorSelectedParams) {
        // 确定背景色。
        backgroundColor = indicatorColor
        // 确定圆角。
        layer.cornerRadius = indicatorCornerRadius == SegmentedAutomaticDimension ? 2:indicatorCornerRadius

        // 确定 frame。
        let width = indicatorWidth == SegmentedAutomaticDimension ?
            model.contentWidth + indicatorWidthIncrement:indicatorWidth
        
        // 高度默认为 Cell 高度
        let height: CGFloat = (indicatorHeight == SegmentedAutomaticDimension) ?
            model.itemFrame.size.height:indicatorHeight

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
    
    public func selectItem(model: IndicatorSelectedParams) {

        let width = indicatorWidth == SegmentedAutomaticDimension ?
            model.contentWidth + indicatorWidthIncrement:indicatorWidth
        var toFrame = self.frame
        toFrame.origin.x = model.itemFrame.origin.x + (model.itemFrame.size.width - width)/2
        toFrame.size.width = width
        if canSelectedWithAnimation(model: model) {
            // 动画过渡改变窗体
            UIView.animate(withDuration: scrollAnimationDuration, delay: 0, options: .curveEaseOut) {
                self.frame = toFrame
            }
        } else {
            frame = toFrame
        }
    }
    
    public func contentScrollViewDidScroll(model: IndicatorTransitionParams) { }

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
