//
//  PickerView.swift
//  Mandoline
//
//  Created by Anat Gilboa on 10/18/2017.
//  Copyright (c) 2017 ag. All rights reserved.
//

import SnapKit
import EnolaGay

public class PickerView: UIView {

    /// The dataSource that, upon providing a set of `Selectable` items, reloads the UICollectionView
    public weak var dataSource: PickerViewDataSource? {
        didSet {
            reloadData()
        }
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

//    /// Set the size of the cell
//    public var cellSize: CGSize? {
//        didSet {
//            guard let size = cellSize else { return }
//            selectedItemOverlay.snp.updateConstraints { make in
//                make.size.equalTo(size)
//            }
//            collectionView.snp.updateConstraints { make in
//                make.height.equalTo(size.height)
//            }
//            setNeedsLayout()
//        }
//    }

    /// Change the background color of the UICollectionView
    override public var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }

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

    fileprivate var viewModel: PickerViewModel?
    fileprivate var lastScrollProgress = CGFloat()
    fileprivate var lastIndexPath: IndexPath?
    
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

    fileprivate func setupSubviews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .lightGray
        // 配置 collectionView
        addSubview(collectionView)
        collectionView.register(PickerViewCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.snp.makeConstraints { make in
            // 使 collectionView 完全铺满。
            make.left.right.top.bottom.equalToSuperview()
//            make.height.equalTo(cellSize ?? PickerViewCell.cellSize.height)
        }

        // 配置 selectedItemOverlay
        addSubview(selectedItemOverlay)
        selectedItemOverlay.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.top)
            make.centerX.equalToSuperview()
            // make.size.equalTo(cellSize ?? PickerViewCell.cellSize)
            make.height.equalTo(collectionView)
            // TODO: - 有个宽度需要计算。
            make.width.equalTo(128)
        }
    }

    public final func reloadData() {
        guard let dataSource = self.dataSource else { return }
        // TODO: - 确定注册的 Cell.
        cellReuseIdentifier = dataSource.registerCell(for: collectionView)
        guard cellReuseIdentifier != "" else {
            Judy.logWarning("dataSource.registerCell() 不能响应为空字符")
            return
        }

        viewModel = PickerViewModel(cells: dataSource.selectableCells)
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    /// Scroll to a cell at a given indexPath
    /// 滚动到指定 indexPath 的单元格
    public func scrollToCell(at indexPath: IndexPath) {
        guard let cellViewModelsCount = viewModel?.cells.count else { return }
        if indexPath.row < cellViewModelsCount / 2 {
            let lastIndexPath = IndexPath(row: cellViewModelsCount - 1, section: 0)
            collectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: false)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let inset = center.x - 64
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

public protocol PickerViewDataSource: AnyObject {
    /// The cells that are `Selectable` and set by the implementing ViewController
    var selectableCells: [Selectable] { get }
    
    /// 注册专用 Cell 并询问该 Cell 的重用标识符。
    func registerCell(for collectionView: UICollectionView) -> String
}

public protocol PickerViewDelegate: AnyObject {
    /// UICollectionViewDelegate function that allows the consumer to respond to any selection events
    func collectionView(_ view: PickerView, didSelectItemAt indexPath: IndexPath)
    /// UIScrollView function that allows the consumer to respond to scrolling events beginning
    func scrollViewWillBeginDragging(_ view: PickerView)
    /// UIScrollView function that allows the consumer to respond to scrolling events ending
    func scrollViewWillEndDragging(_ view: PickerView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    /// UIScrollView function that allows the consumer to respond to `scrollViewDidScroll`
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    /// Configuration function to be called with consumer's implemented custom UICollectionViewCell.
    func configure(cell: UICollectionViewCell, for: IndexPath)
}

extension PickerViewDelegate {

    func collectionView(_ view: PickerView, didSelectItemAt indexPath: IndexPath) { }

    func scrollViewWillBeginDragging(_ view: PickerView) { }

    func scrollViewWillEndDragging(_ view: PickerView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }

    func scrollViewDidScroll(_ scrollView: UIScrollView) { }

    func configure(cell: UICollectionViewCell, for: IndexPath) { }
}

extension PickerView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.cells.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier!, for: indexPath)
        delegate?.configure(cell: cell, for: indexPath)
        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        guard let model = viewModel?.cells[indexPath.row] as? ScrollableCellViewModel else { return }
        Judy.log("当前选择的是：\(model.title)")

        delegate?.collectionView(self, didSelectItemAt: indexPath)
    }
}

extension PickerView: UICollectionViewDelegateFlowLayout {

    /// This delegate function determines the size of the cell to return. If the cellSize is not set, then it returns the size of the PickerViewCell
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: - 有个宽度需要计算。
        return CGSize(width: 128, height: collectionView.bounds.size.height)
//        return cellSize ?? PickerViewCell.cellSize
    }
}
extension PickerView : UIScrollViewDelegate {

    /// This delegate function calculates the "snapping" for the overlay over the CollectionView (calendar view) cells
    /// The main purpose of this function is to calculate the size of the selected overlay's imageView,
    /// that is whether it scales from 0 to 1.5x
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
        delegate?.scrollViewWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    /// This delegate function calculates how much the overlay imageView should transform depending on
    /// whether the left and right cells are "selectable"
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let vm = viewModel else { return }
        // TODO: - 有个宽度需要计算。
        let scrollProgress = CGFloat(collectionView.contentOffset.x / 128)
        defer { lastScrollProgress = scrollProgress }
        let leftIndex = Int(floor(scrollProgress))
        let rightIndex = Int(ceil(scrollProgress))
        let interCellProgress = scrollProgress - CGFloat(leftIndex)
        let deltaFromMiddle = abs(0.5 - interCellProgress)
        let (this, next) = (vm.cells[safe: leftIndex]?.isSelectable ?? false,
                            vm.cells[safe: rightIndex]?.isSelectable ?? false)
        let dotScale: CGFloat
        switch (this, next) {
        case (true, true):
            dotScale = 1.5 - (deltaFromMiddle)
        case (true, false):
            dotScale = 1 - interCellProgress
        case (false, true):
            dotScale = interCellProgress
        case (false, false):
            dotScale = 0
        }
        selectedItemOverlay.imageView.transform = CGAffineTransform(scaleX: dotScale, y: dotScale)

        guard ((lastScrollProgress.integerBelow != scrollProgress.integerBelow) && !lastScrollProgress.isIntegral)
            || (scrollProgress.isIntegral && !lastScrollProgress.isIntegral) else { return }
        self.generateFeedback()
        var convertedCenter = collectionView.convert(selectedItemOverlay.center, to: collectionView)
        convertedCenter.x += collectionView.contentOffset.x
        guard let indexPath = collectionView.indexPathForItem(at: convertedCenter) else { return }
        vm.select(cell: vm.cells[indexPath.row])
        self.generateFeedback()
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 这才是正确地获取当前显示的 Cell 方式！
        if scrollView == collectionView {
            guard let model = viewModel?.selectedCell as? ScrollableCellViewModel else { return }
            Judy.log("当前选择的是：\(model.title)")
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
