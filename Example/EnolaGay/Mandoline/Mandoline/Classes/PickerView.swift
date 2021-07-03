//
//  PickerView.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import EnolaGay
import SnapKit

/// 一款横向选择器。
public class PickerView: UIView {

    /// The dataSource that, upon providing a set of `Selectable` items, reloads the UICollectionView
    public weak var dataSource: PickerViewDataSource? {
        didSet { reloadData() }
    }

    /// The object that acts as a delegate
    public weak var delegate: PickerViewDelegate?

    /// Change the color of the overlay's border
    /// 改变覆盖的边界的颜色
    public var selectedOverlayColor: UIColor = UIColor.blue {
        didSet {
            selectedItemOverlay.maindoBorderColor = selectedOverlayColor
        }
    }

    /// Change the color of the dot
    /// 改变点的颜色。
    public var dotColor: UIColor = UIColor.green {
        didSet {
            selectedItemOverlay.dotColor = dotColor
        }
    }

    /// Change the size of the picker triangle
    /// 改变三角形的大小。
    public var triangleSize: CGSize? {
        didSet {
            guard let size = triangleSize else { return }
            selectedItemOverlay.triangleSize = size
        }
    }

    /// Change the size of the dot
    /// 改变点的大小。
    public var dotSize: CGSize? {
        didSet {
            guard let size = dotSize else { return }
            selectedItemOverlay.dotSize = size
        }
    }

    /// Change the distance of the dot from the top of the UICollectionView
    /// 改变点与 UICollectionView 顶部的距离
    public var dotDistanceFromTop: CGFloat? {
        didSet {
            guard let distance = dotDistanceFromTop else { return }
            selectedItemOverlay.dotDistanceFromTop = distance
        }
    }

    /// Change the background color of the UICollectionView
    override public var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    /// 数据源。
    public private(set) var items = [PickerViewItemModel]()

    /// 当前选中的数据模型。
    private(set) var selectedModel: Selectable?
    fileprivate var lastScrollProgress = CGFloat()
    /// 最后选中的 indexPath.
    private var lastIndexPath = IndexPath(row: 0, section: 0)
    /// 在拖拽时临时存储的 indexPath.
    private lazy var didScrollIndexPath = IndexPath(row: 0, section: 0)
    
    /// 用于存储 collectionView 注册 Cell 的重用标识符。
    private var cellReuseIdentifier: String?

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.clipsToBounds = true
        return collectionView
    }()
    
    /// 选中项的覆盖层
    let selectedItemOverlay: PickerViewOverlay = {
        let view = PickerViewOverlay()
        view.isUserInteractionEnabled = false
        return view
    }()


    /// Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSubviews()
    }

    fileprivate func setupSubviews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .lightGray

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // 配置 collectionView
        addSubview(collectionView)
        
        // 设置 collectionView 铺满 self.
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .top,
                               relatedBy: .equal, toItem: self,
                               attribute: .top, multiplier: 1,
                               constant: 0))
        
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .left,
                               relatedBy: .equal, toItem: self,
                               attribute: .left, multiplier: 1,
                               constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .bottom,
                               relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1,
                               constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .right,
                               relatedBy: .equal, toItem: self,
                               attribute: .right, multiplier: 1,
                               constant: 0))
        // 配置 selectedItemOverlay
//        addSubview(selectedItemOverlay)
//        selectedItemOverlay.snp.makeConstraints { make in
//            make.top.equalTo(collectionView.snp.top)
//            make.centerX.equalToSuperview()
//            // make.size.equalTo(cellSize ?? PickerViewCell.cellSize)
//            make.height.equalTo(collectionView)
//            // TODO: - 有个宽度需要计算。
//            make.width.equalTo(128)
//        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard dataSource != nil,
              let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }

        let inset = center.x - dataSource!.pickerView(self, widthForItemAt: lastIndexPath.item)/2
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

public extension PickerView {
    /// 重新载入所有数据。
    final func reloadData() {
        guard let dataSource = self.dataSource else {
            Judy.logWarning("请设置 PickerView.dataSource")
            return
        }
        // 确定注册的 Cell.
        cellReuseIdentifier = dataSource.registerCell(for: collectionView)
        guard cellReuseIdentifier != "" else {
            Judy.logWarning("dataSource.registerCell() 不能响应为空字符")
            return
        }
        items.removeAll()
        items = dataSource.titles(for: self).map { title in
            let model = PickerViewItemModel()
            model.title = title
            
            return model
        }
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    /// Scroll to a cell at a given indexPath
    /// 滚动到指定 index.
    func select(at index: Int) {
        guard index < items.count else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if index < items.count / 2 {
            let lastIndexPath = IndexPath(row: items.count - 1, section: 0)
            collectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: false)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - PickerViewDataSource
public protocol PickerViewDataSource: AnyObject {
    /// The cells that are `Selectable` and set by the implementing ViewController
    // var selectableCells: [Selectable] { get }
    
    /// 询问 pickerView 的标题列表。
    func titles(for pickerView: PickerView) -> [String]

    /// 注册专用 Cell 并询问该 Cell 的重用标识符。
    func registerCell(for collectionView: UICollectionView) -> String
    
    /// 询问指定 index 的 Cell 宽度。
    func pickerView(_ pickerView: PickerView, widthForItemAt index: Int) -> CGFloat

    func reload(cell: UICollectionViewCell, for index: Int, with source: [String])

}

// MARK: - PickerViewDelegate
public protocol PickerViewDelegate: AnyObject {
    /// 当选中的数据发生实质性的变更时的处理。
    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int)

    /// Configuration function to be called with consumer's implemented custom UICollectionViewCell.
    func configure(cell: UICollectionViewCell, for: IndexPath)
}

extension PickerViewDelegate {

    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int) { }

    func configure(cell: UICollectionViewCell, for: IndexPath) { }
}

extension PickerView: UICollectionViewDataSource {

    public final func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    public final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    public final func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier!, for: indexPath) as! ScrollableCell
        // dataSource?.reload(cell: cell, for: indexPath.item, with: items)
        cell.reloadData(model: items[indexPath.item])
        return cell
    }

    public final func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // 防止重复点击。
        guard lastIndexPath != indexPath else { return }
        lastIndexPath = indexPath
        delegate?.pickerView(self, didSelectedItemAt: lastIndexPath.item)
    }
}

extension PickerView: UICollectionViewDelegateFlowLayout {

    /// This delegate function determines the size of the cell to return. If the cellSize is not set, then it returns the size of the PickerViewCell
    public final func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

//        let width = dataSource!.pickerView(self, widthForItemAt: indexPath.item)
        return CGSize(width: items[indexPath.item].textWidth, height: collectionView.bounds.size.height)
//        return CGSize(width: 128, height: collectionView.bounds.size.height)
    }
}

// MARK: - UIScrollViewDelegate
extension PickerView : UIScrollViewDelegate {

    /// This delegate function calculates the "snapping" for the overlay over the CollectionView (calendar view) cells
    /// The main purpose of this function is to calculate the size of the selected overlay's imageView,
    /// that is whether it scales from 0 to 1.5x
    ///这个委托函数计算 CollectionView (日历视图)单元格上覆盖的“捕捉”，
    ///这个函数的主要目的是计算所选覆盖的imageView的大小，
    ///它是否从 0 到 1.5x
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetXOffset = targetContentOffset.pointee.x
        let rect = CGRect(origin: targetContentOffset.pointee, size: collectionView.bounds.size)
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForElements(in: rect) else { return }
        let xOffsets = attributes.map { $0.frame.origin.x }
        let distanceToOverlayLeftEdge = selectedItemOverlay.frame.origin.x - collectionView.frame.origin.x
        let targetCellLeftEdge = targetXOffset + distanceToOverlayLeftEdge
        let differences = xOffsets.map { fabs(Double($0 - targetCellLeftEdge)) }
        guard let min = differences.min(), let position = differences.firstIndex(of: min) else { return }
        let actualOffset = xOffsets[position] - distanceToOverlayLeftEdge
        targetContentOffset.pointee.x = actualOffset
//        delegate?.scrollViewWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    /// This delegate function calculates how much the overlay imageView should transform depending on
    /// whether the left and right cells are "selectable"
    public final func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let vm = viewModel else { return }
        guard dataSource != nil else { return }
        let scrollProgress = CGFloat(collectionView.contentOffset.x / items[lastIndexPath.item].textWidth)
        defer { lastScrollProgress = scrollProgress }
        let leftIndex = Int(floor(scrollProgress))
        let rightIndex = Int(ceil(scrollProgress))
        let interCellProgress = scrollProgress - CGFloat(leftIndex)
        let deltaFromMiddle = abs(0.5 - interCellProgress)
        
//        let (this, next) = (items[safe: leftIndex]?.isSelectable ?? false,
//                            items[safe: rightIndex]?.isSelectable ?? false)
//        let dotScale: CGFloat
//        switch (this, next) {
//        case (true, true):
//            dotScale = 1.5 - (deltaFromMiddle)
//        case (true, false):
//            dotScale = 1 - interCellProgress
//        case (false, true):
//            dotScale = interCellProgress
//        case (false, false):
//            dotScale = 0
//        }
//        selectedItemOverlay.imageView.transform = CGAffineTransform(scaleX: dotScale, y: dotScale)

        guard ((lastScrollProgress.integerBelow != scrollProgress.integerBelow) && !lastScrollProgress.isIntegral)
            || (scrollProgress.isIntegral && !lastScrollProgress.isIntegral) else { return }
        self.generateFeedback()
        var convertedCenter = collectionView.convert(selectedItemOverlay.center, to: collectionView)
        convertedCenter.x += collectionView.contentOffset.x
        guard let indexPath = collectionView.indexPathForItem(at: convertedCenter) else { return }
//        selectedModel = items[indexPath.row]
        didScrollIndexPath = indexPath
        self.generateFeedback()
    }
    
    public final func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 这才是正确地获取当前显示的 Cell 方式
        if scrollView == collectionView {
            guard lastIndexPath != didScrollIndexPath else { return }
            lastIndexPath = didScrollIndexPath
            delegate?.pickerView(self, didSelectedItemAt: lastIndexPath.item)
        }
    }

}

extension PickerView {

    /// Generates feedback "selectionChanged" feedback
    fileprivate func generateFeedback() {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
    }
}
