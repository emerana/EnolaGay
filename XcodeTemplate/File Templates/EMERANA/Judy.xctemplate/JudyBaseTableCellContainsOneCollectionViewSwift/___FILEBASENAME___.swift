//___FILEHEADER___

import UIKit
import EnolaGay
import SwiftyJSON

/// 该类型的 tableCell 里面包含了一个 UICollectionView
class ___FILEBASENAMEASIDENTIFIER___: JudyBaseTableCell {
    
    // MARK: - let property and IBOutlet
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    // MARK: - var property

    // MARK: collection 属性

    /// 点击事件
    var collectionCellAction:((Int) -> Void)?
    
    /// 本 cell 中 collectionView 数据源
    private lazy var dataSource = { [JSON]() }()
    
    /// cell 最小间距
    private(set) lazy var margin: CGFloat = <#8#>
    
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置 collection 滚动位置
        if collectionView.visibleCells.count != 0 {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        }
        
    }
    
    /// 从xib或故事板创建对象的初始化方法
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 配置 collectionView.
        collectionView.dataSource = self
        collectionView.delegate = self
        // 注册 collectionViewCell.
        let nib = UINib(nibName: "<#CollectionCell#>", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "<#CollectionCell#>")
    }
    
    // MARK: - override - 重写重载父类的方法
    
    /// 布局子视图。创建对象顺序一定是先有 frame，再 awakeFromNib，再调整布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - override - 重写重载父类的方法
    
    /// 设置数据源事件
    override func jsonDidSetAction() {
        // super.setJSON
        titleLabel?.text = json["<#title#>"].stringValue
        subTitleLabel?.text = json["<#subTitle#>"].stringValue
        masterImageView?.sd_setImage(with: URL(string: json["<#Newsimages#>"].stringValue), placeholderImage: <##imageLiteral(resourceName: "t4")#>, completed: nil)
    }
    
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件
    
    // MARK: - private method - 私有方法
    
}


// MARK: - UICollectionViewDataSource
extension ___FILEBASENAMEASIDENTIFIER___: UICollectionViewDataSource {
    
    // section 数量
    //    func numberOfSections(in collectionView: UICollectionView) -> Int{ 1 }

    // cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6  //可能为：dataSource.count
    }
    
    // MARK: Cell初始化
    
    /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "<#CollectionCell#>", for: indexPath)
        //        (cell.viewWithTag(101)as! UIImageView).image = UIImage(named: dataSource[indexPath.row]["imageName"].stringValue)
        //        if indexPath.row % 2 == 0 {
        //            cell.backgroundColor = .red
        //        } else {
        //            cell.backgroundColor = .green
        //        }
        
        return cell
    }
    
}


// MARK: - UICollectionViewDelegate
extension ___FILEBASENAMEASIDENTIFIER___: UICollectionViewDelegate {
    // MARK: scrollView delegate
    
    /// scrollView 滚动之后执行的代理方法，此方法实现了上拉隐藏下拉显示导航栏，重写此方法记得super可实现
    ///
    /// - Parameter scrollView: scrollView对象
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //    }
    
    // MARK: collectionView delegate
    
    /// 选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log("选中\(indexPath)")
        // 可能执行的操作：collectionCellAction?(indexPath.row)
    }
    
    // Judy-mark: 完美解决 collectionView 滚动条被 Header 遮挡问题
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension ___FILEBASENAMEASIDENTIFIER___: UICollectionViewDelegateFlowLayout {
    // 设置 headerView 的 size。一般用不上这个方法，在生成HeaderView中就可以设置高度或者在xib中设置高度即可。
    /*
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     
     // 这里设置宽度不起作用
     return CGSize.init(width: 0, height: <#58#>)
     }
     
     */
    
    /// 询问 cell 大小，在此函数中计算好对应的 size.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// 在一个 line 中需要显示的 cell 数量
        let countOfCells: CGFloat = <#3#>
        /// cell 参与计算的边长，初值为 line 的长度（包含间距）
        ///
        /// 一个 line 中需要显示的所有 cell. 宽度（或高度）及他们之间所有间距的总和，以此来确定单个 cell 的边长
        /// - Warning: 请注意在此处减去不参与计算 cell 边长的部分，比如 collectionView.contentInset 的两边
        var lineWidthOfCell = collectionView.frame.width
        // var lineWidthOfCell = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        // 正确地计算 cellWidth 公式，若发现实际显示不正确，请确认是否关闭 collectionView 的 Estimate Size，将其设置为 None.
        lineWidthOfCell = (lineWidthOfCell + itemSpacing)/countOfCells - itemSpacing
        
        let heightForCell: CGFloat = <#88#>
        
        return CGSize(width: lineWidthOfCell, height: heightForCell)
    }
    
    // 针对 section 进行偏移
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
        
    // 连续的行或列之间的最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return margin
    }
    
    // 连续的Cell间的最小间距。这个间距决定了一行内有多少个Cell,但Cell的数量确定后,实际的间距可能会向上调整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return margin
    }
    
}
