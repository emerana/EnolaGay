//
//  BaseCollectionViewCtrl.swift
//  与 UICollectionView 相关的文件。
//
//  Created by 醉翁之意 on 2018/4/23.
//  Copyright © 2018年 吾诺翰卓. All rights reserved.
//

// MARK: - JudyBaseCollectionViewCtrl

import UIKit
import SwiftyJSON

/// 该类包含一个 collectionView，请将 collectionView 与故事板关联
/// * 该类已经实现了三个代理，UICollectionReusableView 在 dataSource 里
/// * delegateFlowLayout 里面定义了布局系统
/// * 默认 collectionViewCellidentitier 为 "Cell"
open class JudyBaseCollectionViewCtrl: JudyBaseViewCtrl, EMERANA_CollectionBasic {
    
    
    // MARK: - let property and IBOutlet
    
    /// 主要的 CollectionView,该 CollectionView 默认将 dataSource、dataSource 设置为 self
    @IBOutlet public weak var collectionView: UICollectionView?

    
    // MARK: - var property
    
    open lazy var dataSource = [JSON]()
    
    /// 同一 line 中 item（cell）之间的最小间隙
    open var itemSpacing: CGFloat { return 6 }

    
    // MARK: - Life Cycle
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard collectionView != nil else {
            Judy.log("🚔 collectionView 没有关联 IBOutlet！")
            return
        }

        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        registerReuseComponents()
        
        // 滑动时关闭键盘
        collectionView?.keyboardDismissMode = .onDrag

        // 配置 collectionView 的背景色
        if #available(iOS 13.0, *) {
            if collectionView?.backgroundColor == UIColor.systemBackground {
                collectionView?.backgroundColor = .judy(.scrollView)
            }
        } else {
            if collectionView?.backgroundColor == nil {
                collectionView?.backgroundColor = .judy(.scrollView)
            }
        }
        
    }
    
    open func registerReuseComponents() {
        /*
         // Judy-mark: 这样注册 cell 代替 Storyboard 里添加 cell
         let nib = UINib.init(nibName: "<#xibName#>", bundle: nil)
         tableView?.register(nib, forCellReuseIdentifier: "<#Cell#>")
         // 获取Cell
         let cell = tableView.dequeueReusableCell(withIdentifier: "<#Cell#>", for: indexPath)
         */
    }

}


// MARK: - UICollectionViewDataSource
extension JudyBaseCollectionViewCtrl: UICollectionViewDataSource {
    
    // cell数量
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataSource.count
    }
    
    // section数量
    //    func numberOfSections(in collectionView: UICollectionView) -> Int{
    //        return 1
    //    }
    
    // MARK: Cell初始化
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        return cell
    }
    
    // 生成 HeaderView 和 FooterView
    /*
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
     
     let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
     
     if kind == UICollectionElementKindSectionFooter {
     let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
     
     return footerView
     }
     
     
     return headerView
     }
     */

}


// MARK: - UICollectionViewDelegate
extension JudyBaseCollectionViewCtrl: UICollectionViewDelegate {
    
    // MARK: scrollView delegate
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Judy-mark: 正确的活动隐藏显示导航栏姿势！
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -5 {  // 上拉
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 5 {    // 下拉
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        // MARK: Judy-mark:scrollView的代理方法，取消tableViewHeader悬停的办法 取消悬停
        let sectionHeaderHeight:CGFloat = 8   // 这里的高度一定要>=heightForHeaderInSection的高度
        if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
            scrollView.contentInset = UIEdgeInsets.init(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsets.init(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
        
    }
    */
    
    
    // MARK: collectionView delegate
    
    
    // 选中事件
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("点击-\(indexPath)")
    }
    
    // Judy-mark: 完美解决 collectionView 滚动条被 Header 遮挡问题
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension JudyBaseCollectionViewCtrl: UICollectionViewDelegateFlowLayout {
        
    // 设置headerView的Size。一般用不上这个方法，在生成HeaderView中就可以设置高度或者在xib中设置高度即可。
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     
     // 这里设置宽度不起作用
     return CGSize.init(width: 0, height: <#58#>)
     }
     
     */
    
    // cell大小
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        var widthForCell: CGFloat = collectionView.frame.width
        let heightForCell: CGFloat = 88
        // 在同一个 Line 中需要显示的 Cell 数量
        let numForCellInRow: CGFloat = 3
        
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 CollectionView 的 Estimate Size，将其设置为 None.
        widthForCell = (widthForCell + itemSpacing)/numForCellInRow - itemSpacing
        if let cellHeight = dataSource[indexPath.section][EMERANA.Key.Cell.height].float {
            return CGSize(width: widthForCell, height: CGFloat(cellHeight))
        }
        
        return CGSize(width: widthForCell, height: heightForCell)
    }

    /* 针对 Section 进行偏移。可直接在 Storyboard 中设置，必要的情况下重写此函数即可。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    */
    
    
    // 一个 section 中连续的行或列之间的最小间距，默认为0。实际值可能大于该值，但不会比其小。
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return itemSpacing
    }
    
    // 同一行中连续的 Cell 间的最小间距，该间距决定了一行内有多少个 Cell，Cell 数量确定后，实际的间距可能会比该值大。
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return itemSpacing
    }

}


// MARK: - JudyBaseCollectionRefreshViewCtrl


/// 在 JudyBaseCollectionViewCtrl 的基础上加上刷新控件，以支持分页加载数据。
///
/// 需要重写 setSumPage() 函数以设置总页数
/// - warning: reqApi() 周期主要匹配分页加载功能，若存在多种用途请注意参考重写以下函数：
///     * reqResult()，此函数中影响上下拉状态，无需控制 UI 状态时需要在此函数中排除
///     * reqSuccess()，此函数中影响设置总页数函数 setSumPage(), 无关的逻辑应该在此排除
///```
///override func reqResult() {
///    if requestConfig.api == 分页加载的 Api 请求 {
///        super.reqResult()
///    }
///}
///override func reqSuccess() {
///    if requestConfig.api == 分页加载的 Api 请求 {
///        super.reqSuccess()
///    }
///}
///```
open class JudyBaseCollectionRefreshViewCtrl: JudyBaseCollectionViewCtrl, EMERANA_Refresh {
    
    open var pageSize: Int { 10 }
    open var defaultPageIndex: Int { 1 }
    final public private(set) var currentPage = 0 { didSet{ didSetCurrentPage() } }
    final lazy public private(set) var isAddMore = false

    
    // MARK: - Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        resetStatus()
        // 配置刷新控件。
        if !isNoHeader() {
            EMERANA.refreshAdapter?.initHeaderRefresh(scrollView: collectionView, callback: {
                [weak self] in
                self?.refreshHeader()
                
                self?.isAddMore = false
                self?.currentPage = self!.defaultPageIndex
                EMERANA.refreshAdapter?.resetNoMoreData(scrollView: self?.collectionView)
                
                self?.reqApi()
            })
        }
        if !isNoFooter() {
            EMERANA.refreshAdapter?.initFooterRefresh(scrollView: collectionView, callback: {
                [weak self] in
                self?.refreshFooter()
                
                self?.isAddMore = true
                self?.currentPage += 1
                
                self?.reqApi()
            })
        }
    }


    // MARK: Api相关
        
    /// 设置 api、param.
    ///
    /// 参考如下代码：
    ///```
    ///requestConfig.api = .???
    ///requestConfig.parameters?["userName"] = "Judy"
    ///```
    /// - Warning: 此函数中已经设置好 requestConfig.parameters?["page"] = currentPage
    open override func setApi() {
        requestConfig.parameters?[pageParameterString()] = currentPage
        requestConfig.parameters?[pageSizeParameterString()] = pageSize
    }
    
    open override func reqNotApi() {
        if isAddMore { currentPage -= 1 }
        reqResult()
    }
    
    /// 当服务器响应时首先执行此函数。
    ///
    /// 此函数中会调用 endRefresh()，即结束 header、footer 的刷新状态。
    /// - warning: 此函数中影响上下拉状态，请确认正确条件下调用 super.reqResult()。
    /// ```
    /// if  requestConfig.api?.value == ApiActions.Live.getAnchorLibraries.rawValue {
    ///     super.reqResult()
    /// }
    /// ```
    open override func reqResult() {
        EMERANA.refreshAdapter?.endRefresh(scrollView: collectionView)
    }
    
    /// 请求成功的消息处理，子类请务必调用父类函数。
    ///
    /// 此函数已经处理是否有更多数据，需自行根据服务器响应数据更改数据源及刷新 collectionView。
    /// - Warning: 此函数中影响设置总页数函数 setSumPage(), 无关的逻辑应该在此排除。
    open override func reqSuccess() {
        // 设置总页数。
        let sumPage = setSumPage()
        // 在此判断是否有更多数据。结束刷新已经在 reqResult() 中完成。
        if sumPage <= currentPage {    // 最后一页了，没有更多。
            // 当没有更多数据的时候要将当前页设置为总页数或默认页数。
            currentPage = sumPage <= defaultPageIndex ? defaultPageIndex:sumPage
            EMERANA.refreshAdapter?.endRefreshingWithNoMoreData(scrollView: collectionView)
        }
    }
    
    /// 请求失败的消息处理。
    ///
    /// 重写此方法务必调用父类方法。
    /// - Warning: 当 isAddMore = true (上拉刷新)时触发了此函数，此函数会将 currentPage - 1
    open override func reqFailed() {
        super.reqFailed()
        reqNotApi()
    }
    
    
    // MARK: - EMERANA_Refresh
    
    open func isNoHeader() -> Bool { false }
    open func isNoFooter() -> Bool { false }
    
    open func pageParameterString() -> String { "pageIndex" }
    open func pageSizeParameterString() -> String { "pageSize" }
    
    open func didSetCurrentPage() {}
    
    open func refreshHeader() {}
    open func refreshFooter() {}

    /// 测试将总页数设置为 3 页，请覆盖此函数已配置正确的总页数。
    open func setSumPage() -> Int { 3 }
    
    open func resetStatus() {
        currentPage = defaultPageIndex
        isAddMore = false
    }
}

// MARK: - JudyCollectionViewLayout

public extension UICollectionViewLayoutAttributes {
    
    func leftAlignFrameWithSectionInset(sectionInset: UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }

}

/// UICollectionViewFlowLayout 自定义版
public class JudyCollectionViewLayout: UICollectionViewFlowLayout {

    public override func prepare() {
        super.prepare()
        // 设置一个非0的 size 以自动计算 Cell 大小
        estimatedItemSize = CGSize(width: 100, height: 28)

    }

    /*
     返回 UICollectionViewLayoutAttributes 类型的数组，UICollectionViewLayoutAttributes 对象包含 cell 或 view 的布局信息。
     子类必须重载该方法，并返回该区域内所有元素的布局信息，包括 cell,追加视图和装饰视图。
     */
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let originalAttributes = super.layoutAttributesForElements(in: rect)!
        var updatedAttributes: [UICollectionViewLayoutAttributes]? = originalAttributes
        
        for attributes in originalAttributes {
            if attributes.representedElementKind == nil {
                let index = updatedAttributes!.firstIndex(of: attributes)!
                updatedAttributes?[index] = layoutAttributesForItem(at: attributes.indexPath)!
            }
        }
        
        return updatedAttributes
    }
    
    /*
     返回指定 indexPath 的 item 的布局信息。子类必须重载该方法,该方法只能为 cell 提供布局信息，不能为补充视图和装饰视图提供。
     */
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
                
        let currentItemAttributes: UICollectionViewLayoutAttributes = super.layoutAttributesForItem(at: indexPath)!
        
        let sectionInset = evaluatedSectionInsetForItemAtIndex(index: indexPath.section)
        
        let isFirstItemInSection = indexPath.item == 0
        let layoutWidth: CGFloat = (collectionView?.frame.width)! - sectionInset.left - sectionInset.right
        // 如果是第一个
        if isFirstItemInSection {
            currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset: sectionInset)
            return currentItemAttributes
        }

        let previousIndexPath = IndexPath(item: indexPath.item-1, section: indexPath.section)
        
        let previousFrame: CGRect = layoutAttributesForItem(at: previousIndexPath)!.frame
        
        let previousFrameRightPoint: CGFloat = previousFrame.origin.x + previousFrame.size.width
        let currentFrame: CGRect = currentItemAttributes.frame
        
        let strecthedCurrentFrame: CGRect = CGRect(x: sectionInset.left,
                                                   y: currentFrame.origin.y,
                                                   width: layoutWidth,
                                                   height: currentFrame.size.height)
        
        // if the current frame, once left aligned to the left and stretched to the full collection view
        // width intersects the previous frame then they are on the same line
        let isFirstItemInRow = !previousFrame.intersects(strecthedCurrentFrame)

        if isFirstItemInRow {
            // 确保一行中的第一项左对齐
            currentItemAttributes.leftAlignFrameWithSectionInset(sectionInset: sectionInset)
            return currentItemAttributes
        }

        var frame: CGRect = currentItemAttributes.frame
        frame.origin.x = previousFrameRightPoint + evaluatedMinimumInteritemSpacingForSectionAtIndex(sectionIndex: indexPath.section)
        
        currentItemAttributes.frame = frame
        
        return currentItemAttributes
    }
        
}

private extension JudyCollectionViewLayout {
    
    /// 计算 Cell 间最小项间距
    func evaluatedMinimumInteritemSpacingForSectionAtIndex(sectionIndex: NSInteger) -> CGFloat {

        if collectionView?.delegate?.responds(to: #selector((collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) ?? false {
            let itemSpacing = (collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView!(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: sectionIndex)
            
            return itemSpacing
        } else {
            return minimumInteritemSpacing
        }
    }
    
    /// 计算 Section 的 UIEdgeInsets
    func evaluatedSectionInsetForItemAtIndex(index: NSInteger) -> UIEdgeInsets {
        
        if collectionView?.delegate?.responds(to: #selector((collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView(_:layout:insetForSectionAt:))) ?? false {
            let edgeInsets = (collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView!(collectionView!, layout: self, insetForSectionAt: index)
            
            return edgeInsets
        } else {
            return sectionInset
        }
    }
    
    
}


// MARK: - JudyBaseCollectionViewCell


/// collectionView 通用 cell，包含一张主要图片、副标题以及默认数据源 json。
/// * labelsForColor 中的 labels 会配置颜色 foreground
open class JudyBaseCollectionViewCell: UICollectionViewCell, EMERANA_CellBasic {

    // MARK: - let property and IBOutlet
    
    @IBOutlet weak public var titleLabel: UILabel?
    
    @IBOutlet weak public var subTitleLabel: UILabel?
    
    @IBOutlet weak public var masterImageView: UIImageView?
    
    @IBOutlet lazy public var labelsForColor: [UILabel]? = nil

    // MARK: - var property
    
    public var json = JSON() { didSet{ jsonDidSetAction() } }

    
    // MARK: - life cycle

    
    // Judy-mark: Cell 准备重用时会先执行此方法。
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        // 此处应重置 Cell 状态，清除在重用池里面设置的值。
    }
    
    /// 重写了此方法必须调用 super.awakeFromNib()，里面实现了配置。
    open override func awakeFromNib() {
        super.awakeFromNib()
        globalAwakeFromNib()
        labelsForColor?.forEach { label in
            label.textColor = .judy(.text)
        }
        
    }
    
    /// 布局子视图。创建对象顺序一定是先有 frame，再 awakeFromNib，再调整布局。
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        /*
         给cell添加渐变颜色
         //create gradientLayer
         let gradientLayer : CAGradientLayer = CAGradientLayer()
         gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
         
         //gradient colors
         let colors = [ Judy.colorByRGB(rgbValue: <#T##0x12ba2d#>).cgColor,  Judy.colorByRGB(rgbValue: <#T##0x12ba2d#>).cgColor]
         
         gradientLayer.colors = colors
         gradientLayer.startPoint = CGPoint(x: 0, y: 0);
         gradientLayer.endPoint = CGPoint(x: 1, y: 0);
         self.layer.insertSublayer(gradientLayer, at: 0)
         
         */
        // 在 CollectionCell 中设置正圆的正确方式
        layoutIfNeeded()
        if masterImageView?.isRound ?? false {
            masterImageView?.viewRound()
        }
        
    }
    
    // 如果布局更新挂起，则立即布局子视图。
    open override func layoutIfNeeded() {
        super.layoutIfNeeded()

    }
    
    open func jsonDidSetAction() {
        titleLabel?.text = json[EMERANA.Key.Cell.title].stringValue
        subTitleLabel?.text = json[EMERANA.Key.Cell.subtitle].stringValue
        if let imageName = json[EMERANA.Key.Cell.icon].string {
            masterImageView?.image = UIImage(named: imageName)
        }
    }


}
