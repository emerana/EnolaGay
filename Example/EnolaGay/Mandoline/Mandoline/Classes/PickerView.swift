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

    /// 通用的宽度。
    var cellWidth: CGFloat = 88
    /// 数据源。
    public private(set) var items = [PickerViewItemModel]()
    
    /// 当前选中的数据模型。
    private(set) var selectedModel: Selectable?
    fileprivate var lastScrollProgress = CGFloat()
    /// 最后选中的 indexPath.
    private var lastIndexPath = IndexPath(row: 0, section: 0)
    /// 在拖拽时临时存储的 indexPath.
    private lazy var didScrollIndexPath = IndexPath(row: 0, section: 0)
    /// 当前显示在中间的 Cell 的 frame.
    private var centerFrame = CGRect.zero

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
                               attribute: .top, multiplier: 1, constant: 0))
        
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .left,
                               relatedBy: .equal, toItem: self,
                               attribute: .left, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .bottom,
                               relatedBy: .equal, toItem: self,
                               attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(
            NSLayoutConstraint(item: collectionView, attribute: .right,
                               relatedBy: .equal, toItem: self,
                               attribute: .right, multiplier: 1, constant: 0))
        // 配置 selectedItemOverlay
        addSubview(selectedItemOverlay)
        
        selectedItemOverlay.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.top)
            make.centerX.equalToSuperview()
            // make.size.equalTo(cellSize ?? PickerViewCell.cellSize)
            make.height.equalTo(collectionView)
            // TODO: - 有个宽度需要计算。
            make.width.equalTo(cellWidth)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard dataSource != nil,
              let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }

        let inset = center.x - cellWidth/2
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
        collectionView.register(ScrollableCell.self, forCellWithReuseIdentifier: "DayCell")

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

// MARK: 私有函数
private extension PickerView {
    /// 设置一个三角形在中间位置。
    func setupTriangleView() {
        /// 三角形。
        let triangleView = PickerViewOverlayTriangleView()
        triangleView.frame = CGRect(origin: CGPoint(x: self.frame.size.width/2, y: 0), size: CGSize(width: 10, height: 5))
        triangleView.color = .red
        addSubview(triangleView)
    }
}

// MARK: - PickerViewDataSource
public protocol PickerViewDataSource: AnyObject {
    /// 询问 pickerView 的标题列表。
    func titles(for pickerView: PickerView) -> [String]
    
    /// 询问指定 index 的 Cell 宽度。
    // func pickerView(_ pickerView: PickerView, widthForItemAt index: Int) -> CGFloat

    // func reload(cell: UICollectionViewCell, for index: Int, with source: [String])
}

// MARK: - PickerViewDelegate
public protocol PickerViewDelegate: AnyObject {
    /// 当选中的数据发生实质性的变更时的处理。
    func pickerView(_ pickerView: PickerView, didSelectedItemAt index: Int)

    /// Configuration function to be called with consumer's implemented custom UICollectionViewCell.
    // func configure(cell: UICollectionViewCell, for: IndexPath)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! ScrollableCell
        // dataSource?.reload(cell: cell, for: indexPath.item, with: items)
        cell.reloadData(model: items[indexPath.item])
        return cell
    }

    public final func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if let recgt = collectionView.cellForItem(at: indexPath)?.frame {
            centerFrame = collectionView.convert(recgt, to: self)
        }
        // 防止重复点击。
        guard lastIndexPath != indexPath else { return }
        lastIndexPath = indexPath
        delegate?.pickerView(self, didSelectedItemAt: lastIndexPath.item)
    }
}

extension PickerView: UICollectionViewDelegateFlowLayout {

    /// This delegate function determines the size of the cell to return. If the cellSize is not set, then it returns the size of the PickerViewCell
    public final func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //  return CGSize(width: items[indexPath.item].textWidth, height: collectionView.bounds.size.height)
        return CGSize(width: cellWidth, height: collectionView.bounds.size.height)
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
    // 自动对齐
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 您的应用程序可以更改targetContentOffset参数的值，以调整滚动视图完成滚动动画的位置。
        // 滚动动作减速到停止时的预期偏移量。
        let targetXOffset = targetContentOffset.pointee.x
        // collectionView 预期显示的 rect
        let rect = CGRect(origin: targetContentOffset.pointee, size: collectionView.bounds.size)
        Judy.log("预期显示的区域 = \(rect)")
        // 检索指定矩形中所有单元格和视图的布局属性。
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForElements(in: rect) else { return }
        let xOffsets = attributes.map { $0.frame.origin.x }
        
        Judy.log("selectedItemOverlay.frame.origin.x = \(selectedItemOverlay.frame.origin.x)")
        // 左边距离。
        let distanceToOverlayLeftEdge = selectedItemOverlay.frame.origin.x - collectionView.frame.origin.x
        // 目标Cell左边边缘
        let targetCellLeftEdge = targetXOffset + distanceToOverlayLeftEdge
        // 差异
        let differences = xOffsets.map { fabs(Double($0 - targetCellLeftEdge)) }
        
        guard let min = differences.min(), let position = differences.firstIndex(of: min) else { return }
        
        let actualOffset = xOffsets[position] - distanceToOverlayLeftEdge
        Judy.log("actualOffset = \(actualOffset)")
        targetContentOffset.pointee.x = actualOffset
    }

    /// This delegate function calculates how much the overlay imageView should transform depending on
    /// whether the left and right cells are "selectable"
    public final func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let vm = viewModel else { return }
        guard dataSource != nil else { return }
        let scrollProgress = CGFloat(collectionView.contentOffset.x / cellWidth)
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
