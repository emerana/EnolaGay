//
//  SegmentedView.swift
//  SegmentedView 中的主要 View.
//
//  Created by 王仁洁 on 2021/3/9.
//

import UIKit

/// 自动数值：-1
public let SegmentedAutomaticDimension: CGFloat = -1

/// SegmentedView 核心 View.
public class SegmentedView: UIView {
    
    /// 数据源协议对象，设置该对象即重载所有 SegmentedView 相关数据。
    open weak var dataSource: SegmentedViewDataSource? {
        didSet { reloadData() }
    }
    
    /// 代理协议。
    open weak var delegate: SegmentedViewDelegate?

    // MARK: collectionView 相关
    
    /// 核心 collectionView.
    public private(set) var collectionView: SegmentedCollectionView!
    
    /// 在 collectionView 中展示的数据源，该值取决于 dataSource.itemDataSource.
    private var items = [SegmentedItemModel]()
    
    /// 用于存储 collectionView 注册 Cell 的重用标识符。
    private var cellReuseIdentifier: String?

    /// Cell 内边距，该值取决于 dataSource.itemSpacing，且该值直接决定了 item 之间的最小间距。
    private var innerItemSpacing: CGFloat = 0
    
    /// 整体内容两侧的边距，默认值为 SegmentedAutomaticDimension.
    ///
    /// - Warning: 通常情况下该值会等于 dataSource 中的 itemSpacing.
    private var contentEdgeInsetLeft: CGFloat = SegmentedAutomaticDimension,
                contentEdgeInsetRight: CGFloat = SegmentedAutomaticDimension
    
    /// 该值标识当前选中的的 index.
    public private(set) var selectedIndex: Int = 0
    /// 初始化或者 reloadData 之前设置，用于指定默认的 index.
    open var defaultSelectedIndex: Int = 0 {
        didSet { selectedIndex = defaultSelectedIndex }
    }
    
    /// 正在滚动中的目标 index,用于处理正在滚动列表的时候，立即点击 item，会导致界面显示异常。
    private var scrollingTargetIndex: Int = -1
    /// 是否第一次触发 LayoutSubviews 函数的标识，默认 true.
    private var isFirstLayoutSubviews = true

    /// indicators 的元素必须是遵从 JXSegmentedIndicatorProtocol 协议的 UIView 及其子类。
    open var indicators = [UIView & IndicatorProtocol]() {
        didSet {
            collectionView.indicators = indicators
        }
    }

    
    // MARK: Initialization
        
    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        // 部分使用者为了适配不同的手机屏幕尺寸，SegmentedView 的宽高比要求保持一样。所以它的高度就会因为不同宽度的屏幕而不一样。计算出来的高度，有时候会是位数很长的浮点数，如果把这个高度设置给 UICollectionView 就会触发内部的一个错误。所以，为了规避这个问题，在这里对高度统一向下取整。
        // 如果向下取整导致了你的页面异常，请自己重新设置 SegmentedView 的高度，保证为整数即可。
        let targetFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: floor(bounds.size.height))
        
        // 首次 layoutSubviews 函数时需要设置 CollectionView 的 frame 及载入数据。
        if isFirstLayoutSubviews {
            isFirstLayoutSubviews = false
            collectionView.frame = targetFrame
            reloadData()
        } else {
            if collectionView.frame != targetFrame {
                collectionView.frame = targetFrame
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.reloadData()
            }
        }
    }

}


// MARK: 公开函数

public extension SegmentedView {
    
    /// 更新目标 item.
    ///
    /// 在每次做出选择后都会触发此函数以更新该 cell 中的数据。
    final func reloadItem(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        
        if let entity = dataSource?.segmentedView(self, entityForItem: items[index], entityForItemAt: index, selectedIndex: selectedIndex) {
            
            let cell = collectionView.cellForItem(at: IndexPath(item: entity.index, section: 0)) as? SegmentedCell
            cell?.reloadData(itemModel: entity)
        }
    }

    /// 要求重新载入所有 SegmentedView 数据，该函数会在首次 layoutSubviews 时触发。
    ///
    /// 此函数为 SegmentedView 的关键函数，其规范了所有相关的数据、流程、并管理内部所有的关键信息。
    final func reloadData() {
        guard dataSource != nil else {
            Judy.logWarning("warning: 请设置 SegmentedView.dataSource!!!")
            return
        }
        // 确定注册的 Cell.
        cellReuseIdentifier = dataSource!.segmentedView(registerCellForCollectionViewAt: collectionView)
        guard cellReuseIdentifier != "" else {
            Judy.logWarning("为 SegmentedView 注册 Cell 的 identifier 不能为空！")
            return
        }

        /// 询问 item 总数。
        let itemCount = dataSource!.numberOfItems(in: self)
        // 确定当前选中的索引。
        if selectedIndex < 0 || selectedIndex >= itemCount {
            defaultSelectedIndex = 0
            selectedIndex = 0
        }
        // 确定数据源。
        items.removeAll()
        for index in 0..<itemCount {
            // 通过 dataSource 创建实例。
            let entity = dataSource!.segmentedView(self, entityForItem: nil, entityForItemAt: index, selectedIndex: selectedIndex)
            
            entity.index = index
            entity.isSelected = index == selectedIndex
            entity.itemWidth = dataSource!.segmentedView(self, widthForItem: entity)
            entity.isItemWidthZoomEnabled = dataSource!.isItemWidthZoomEnabled

            items.append(entity)
        }
        
        // 确定 innerItemSpacing 间距。
        innerItemSpacing = dataSource!.itemSpacing
        
        /// 所有 item 的累计宽度，该宽度将用于确定指示器的宽度。
        var totalItemWidth: CGFloat = 0
        /// 确定整体内容宽度，该宽度即整个 collectionView 的宽度。
        var totalContentWidth: CGFloat = getContentEdgeInsetLeft()
        for (index, itemModel) in items.enumerated() {
            totalItemWidth += itemModel.itemWidth
            // 最后一个模型需要加上右边的边距。
            if index == items.count - 1 {
                totalContentWidth += itemModel.itemWidth + getContentEdgeInsetRight()
            }else {
                totalContentWidth += itemModel.itemWidth + innerItemSpacing
            }
        }
        // 当累计宽度小于显示宽度且 item 宽度需要平均分配，应该更新间距而不是使 Cell 等宽。
        if dataSource!.isItemSpacingAverageEnabled && totalContentWidth < bounds.size.width {
            var itemSpacingCount = items.count - 1
            var totalItemSpacingWidth = bounds.size.width - totalItemWidth

            if contentEdgeInsetLeft == SegmentedAutomaticDimension {
                itemSpacingCount += 1
            } else {
                totalItemSpacingWidth -= contentEdgeInsetLeft
            }
            if contentEdgeInsetRight == SegmentedAutomaticDimension {
                itemSpacingCount += 1
            } else {
                totalItemSpacingWidth -= contentEdgeInsetRight
            }
            if itemSpacingCount > 0 {
                innerItemSpacing = totalItemSpacingWidth / CGFloat(itemSpacingCount)
            }
        }
        // 根据选中的 item 起点确定整体内容宽度 totalContentWidth.
        var selectedItemFrameX = innerItemSpacing
        var selectedItemWidth: CGFloat = 0
        totalContentWidth = getContentEdgeInsetLeft()
        for (index, itemModel) in items.enumerated() {
            if index < selectedIndex {
                selectedItemFrameX += itemModel.itemWidth + innerItemSpacing
            } else if index == selectedIndex {
                selectedItemWidth = itemModel.itemWidth
            }
            if index == items.count - 1 {
                totalContentWidth += itemModel.itemWidth + getContentEdgeInsetRight()
            } else {
                totalContentWidth += itemModel.itemWidth + innerItemSpacing
            }
        }
        // 确定 collectionView 初始偏移量。
        let minX: CGFloat = 0
        let maxX = totalContentWidth - bounds.size.width
        let targetX = selectedItemFrameX - bounds.size.width/2 + selectedItemWidth/2
        collectionView.setContentOffset(CGPoint(x: max(min(maxX, targetX), minX), y: 0), animated: false)
        
        // 确定 indicator.
        for indicator in indicators {
            if items.isEmpty {
                indicator.isHidden = true
            } else {
                indicator.isHidden = false
                // 确定选中 item 的大小。
                let selectedItemFrame = getItemFrameAt(index: selectedIndex)
                let indicatorParams = IndicatorSelectedParams(index: selectedIndex,
                                                              itemFrame: selectedItemFrame,
                                                              contentWidth: dataSource!.segmentedView(self, widthForItemContent: items[selectedIndex]),
                                                              collectionViewContentSize: CGSize(width: totalContentWidth, height: bounds.size.height))
                indicator.refreshIndicatorState(model: indicatorParams)
                
                if indicator.isIndicatorConvertToItemFrameEnabled {
                    var indicatorConvertToItemFrame = indicator.frame
                    indicatorConvertToItemFrame.origin.x -= selectedItemFrame.origin.x
                    items[selectedIndex].indicatorConvertToItemFrame = indicatorConvertToItemFrame
                }
            }
        }
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
        
    /// 使当前 segmentedView 选中指定目标，若 index 已经被选中则忽略此次选择操作。
    /// - Parameter index: 目标 index，函数内部会对该参数进行合法校验。
    /// - Parameter selectedType: 触发选择的操作类型。
    final func selectItem(at index: Int) {
        // 确保允许选中
        guard delegate?.segmentedView(self, canClickItemAt: index) != false else { return }

        guard (0..<items.count).contains(index) else { return }
        
        // 选中的就是当前选中的，不操作
        if index == selectedIndex {
            // delegate?.segmentedView(self, didSelectedItemAt: index)
            scrollingTargetIndex = -1
            return
        }

        // 更新数据模型
        let currentSelectedItemModel = items[selectedIndex]
        let willSelectedItemModel = items[index]
        
        updateSelectedEntitys(currentSelected: currentSelectedItemModel, willSelected: willSelectedItemModel)
        
        // 更新两个 Cell
        let currentSelectedCell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? SegmentedCell
        currentSelectedCell?.reloadData(itemModel: currentSelectedItemModel)

        let willSelectedCell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SegmentedCell
        willSelectedCell?.reloadData(itemModel: willSelectedItemModel)
        
        // 根据滚动情况再次更新
        if scrollingTargetIndex != -1 && scrollingTargetIndex != index {
            let scrollingTargetItemModel = items[scrollingTargetIndex]
            scrollingTargetItemModel.isSelected = false

            updateSelectedEntitys(currentSelected: scrollingTargetItemModel, willSelected: willSelectedItemModel)

            let scrollingTargetCell = collectionView.cellForItem(at: IndexPath(item: scrollingTargetIndex, section: 0)) as? SegmentedCell
            scrollingTargetCell?.reloadData(itemModel: scrollingTargetItemModel)
        }
        // 处理缩放情况
        if dataSource?.isItemWidthZoomEnabled == true {
            // 延时为了解决 cellwidth 变化，点击最后几个 cell，scrollToItem 会出现位置偏移 bug。需要等 cellWidth 动画渐变结束后再滚动到 index 的 cell 位置。
            let selectedAnimationDurationInMilliseconds = Int((dataSource?.selectedAnimationDuration ?? 0)*1000)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(selectedAnimationDurationInMilliseconds)) {
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        } else {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        selectedIndex = index
        
        // 更新 indicator
        let currentSelectedItemFrame = getItemFrameAt(index: selectedIndex)
        for indicator in indicators {
            let indicatorParams = IndicatorSelectedParams(index: selectedIndex,
                                                          itemFrame: currentSelectedItemFrame,
                                                          contentWidth: dataSource!.segmentedView(self, widthForItemContent: items[selectedIndex]),
                                                          collectionViewContentSize: nil)
            indicator.selectItem(model: indicatorParams)
            
            if indicator.isIndicatorConvertToItemFrameEnabled {
                var indicatorConvertToItemFrame = indicator.frame
                indicatorConvertToItemFrame.origin.x -= currentSelectedItemFrame.origin.x
                items[selectedIndex].indicatorConvertToItemFrame = indicatorConvertToItemFrame
                willSelectedCell?.reloadData(itemModel: willSelectedItemModel)
            }
        }

        scrollingTargetIndex = -1
        
        // 执行代理事件
        delegate?.segmentedView(self, didSelectedItemAt: index)
    }
}


// MARK: 私有函数

private extension SegmentedView {
    
    /// 初始化函数。
    func commonInit() {
        // 清除用户在故事板/xib 中设置的背景色。
        backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = SegmentedCollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(collectionView)
    }
    
    /// 出列一个可重用的 SegmentedCell.
    func dequeueReusableCell(at index: Int) -> SegmentedCell {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier!, for: indexPath)
        // 只允许 SegmentedCell 类型。
        guard cell.isKind(of: SegmentedCell.self) else {
            fatalError("Cell 必须为 SegmentedCell 的子类，请确认 registerCellForCollectionViewAt 代理函数！")
        }
        return cell as! SegmentedCell
    }
    

    /// 确定 collectionView 内容左侧的嵌入边距。
    func getContentEdgeInsetLeft() -> CGFloat {
        contentEdgeInsetLeft == SegmentedAutomaticDimension ?
            innerItemSpacing:contentEdgeInsetLeft
    }
    
    /// 确定 collectionView 内容右侧的嵌入边距。
    func getContentEdgeInsetRight() -> CGFloat {
        contentEdgeInsetRight == SegmentedAutomaticDimension ?
            innerItemSpacing:contentEdgeInsetRight
    }
    
    // MARK: 选中相关函数
            
    /// 当发生选中事件时需要更新选中前和选中后的实体。
    func updateSelectedEntitys(currentSelected: SegmentedItemModel, willSelected: SegmentedItemModel) {
        guard dataSource != nil else { return }
        
        dataSource!.refreshItemModel(self, currentSelectedItemModel: currentSelected, willSelectedItemModel: willSelected)
        
        // 针对 SegmentedItemTitleModel 处理。
        if let currentModel =  currentSelected as? SegmentedItemTitleModel {
            currentModel.titleCurrentColor = currentModel.titleNormalColor
            currentModel.titleCurrentZoomScale = currentModel.titleNormalZoomScale
            currentModel.titleCurrentStrokeWidth = currentModel.titleNormalStrokeWidth
            currentModel.indicatorConvertToItemFrame = CGRect.zero
        }
        if let willModel =  willSelected as? SegmentedItemTitleModel {
            willModel.titleCurrentColor = willModel.titleSelectedColor
            willModel.titleCurrentZoomScale = willModel.titleSelectedZoomScale
            willModel.titleCurrentStrokeWidth = willModel.titleSelectedStrokeWidth
        }

        // 处理 Cell 宽度缩放。
        if dataSource!.isItemWidthZoomEnabled {
            let animator = Animator()
            animator.duration = dataSource!.selectedAnimationDuration
            animator.progressClosure = {[weak self] (percent) in
                guard let self = self else { return }
                currentSelected.itemWidthCurrentZoomScale = SegmentedViewTool.interpolate(from: currentSelected.itemWidthSelectedZoomScale, to: currentSelected.itemWidthNormalZoomScale, percent: percent)
                
                currentSelected.itemWidth = self.dataSource!.segmentedView(self, widthForItem: currentSelected)
                
                willSelected.itemWidthCurrentZoomScale = SegmentedViewTool.interpolate(from: willSelected.itemWidthNormalZoomScale, to: willSelected.itemWidthSelectedZoomScale, percent: percent)
                
                willSelected.itemWidth = self.dataSource!.segmentedView(self, widthForItem: willSelected)
                // 要求 collectionView 重新计算布局。
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            animator.start()
        } else {
            currentSelected.itemWidthCurrentZoomScale = currentSelected.itemWidthNormalZoomScale
            willSelected.itemWidthCurrentZoomScale = willSelected.itemWidthSelectedZoomScale
        }
        
        currentSelected.isSelected = false
        willSelected.isSelected = true
    }
        
    /// 获取目标 index 的 item.frame，禁止通过 Cell 获取。
    func getItemFrameAt(index: Int) -> CGRect {
        guard index < items.count else { return CGRect.zero }
        
        // 确认起点。
        var x = getContentEdgeInsetLeft()
        for i in 0..<index {
            let itemModel = items[i]
            let itemWidth: CGFloat = dataSource!.segmentedView(self, widthForItem: itemModel)

            x += itemWidth + innerItemSpacing
        }
        
        var width: CGFloat = 0
        let selectedItemModel = items[index]
        if selectedItemModel.isTransitionAnimating && selectedItemModel.isItemWidthZoomEnabled {
            width = dataSource!.segmentedView(self, widthForItem: selectedItemModel) * selectedItemModel.itemWidthSelectedZoomScale
        } else {
            width = selectedItemModel.itemWidth
        }
        return CGRect(x: x, y: 0, width: width, height: bounds.size.height)
    }

}


// MARK: - UICollectionViewDataSource
extension SegmentedView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = dequeueReusableCell(at: indexPath.item)
        // segmentCell 重新载入数据
        cell.reloadData(itemModel: items[indexPath.item])
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension SegmentedView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var isTransitionAnimating = false
        for itemModel in items {
            if itemModel.isTransitionAnimating {
                isTransitionAnimating = true
                break
            }
        }
        if !isTransitionAnimating {
            //当前没有正在过渡的 item，才允许点击选中
            selectItem(at: indexPath.item)
        }
    }

}


// MARK: - UICollectionViewDelegateFlowLayout
extension SegmentedView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: getContentEdgeInsetLeft(), bottom: 0, right: getContentEdgeInsetRight())
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: items[indexPath.item].itemWidth, height: collectionView.bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return innerItemSpacing
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return innerItemSpacing
    }
}
