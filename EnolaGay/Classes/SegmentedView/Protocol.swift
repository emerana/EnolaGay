//
//  SegmentedView 相关数据源、代理及相关协议定义
//
//  Created by 王仁洁 on 2021/3/10.
//

import Foundation
import UIKit


// MARK: - SegmentedViewDataSource

/// SegmentedView 中的数据源协议，通过实现此协议来配置 SegmentedView
public protocol SegmentedViewDataSource: AnyObject {
    
    /// 该值用于确定 item 的间距
    var itemSpacing: CGFloat { get }
    /// 当 collectionView.contentSize.width 小于 SegmentedView 的宽度时，是否将 itemSpacing 均分
    var isItemSpacingAverageEnabled: Bool { get }
    /// 该值用于表示 item（ cell ） 是否允许宽度缩放，该值直接对应 SegmentedItemModel.isItemWidthZoomEnabled
    var isItemWidthZoomEnabled: Bool { get }
    /// 选中动画的时长
    var selectedAnimationDuration: TimeInterval { get }

    
    /// 此函数要求对指定 collectionView 注册重用 Cell，并返回其重用标识符
    ///
    /// 参考 UICollectionView.register 函数
    /// - Parameter collectionView: 需要注册重用 Cell 的目标 collectionView
    /// - Returns: 注册 Cell 用到的唯一重用标识符
    func segmentedView(registerCellForCollectionViewAt collectionView: UICollectionView) -> String

    /// 询问用于展示的 entity 数量
    func numberOfItems(in segmentedView: SegmentedView) -> Int
        
    /// 询问目标 index 实体及详细信息
    ///
    /// 请在该代理函数中设置实体的属性，注意 index、isSelected、itemWidth、isItemWidthZoomEnabled 属性会在该函数返回后自动设置
    /// - Parameters:
    ///   - segmentedView: 发起该请求的 segmentedView 对象
    ///   - entity: 需要更新信息的目标实体，若该实体为 nil，请自行实例化并更新该实体信息确保其准确性
    ///   - index: 目标实体对应的 index，此参数用于确保目标实体的准确性
    ///   - selectedIndex: 被选中的索引，由该索引来确定被选中的实体
    /// - Warning: 若传入参数 entity 不为 nil，请务必返回该 entity 实体对象本身
    func segmentedView(_ segmentedView: SegmentedView, entityForItem entity: SegmentedItemModel?, entityForItemAt index: Int, selectedIndex: Int) -> SegmentedItemModel
    
    /// 询问指定实体的宽度（即 Cell 的宽度）
    ///
    /// 比如当前使用的是 SegmentedItemTitleModel，就需要计算实体的宽度为 (entity as! SegmentedItemTitleModel).textWidth
    /// - Parameters:
    ///   - segmentedView: 所属 segmentedView 对象
    ///   - entity: 目标实体
    func segmentedView(_ segmentedView: SegmentedView, widthForItem entity: SegmentedItemModel) -> CGFloat

    /// 询问指定 index 对应实体的 content 宽度，等同于 Cell 上面内容的宽度
    /// - Warning: 与代理方法 widthForItem 不同，需要注意辨别，部分使用场景下，cell。 的宽度比较大，但是内容的宽度比较小。这个时候指示器又需要和实体的 content 等宽。所以添加了此代理方法
    func segmentedView(_ segmentedView: SegmentedView, widthForItemContent entity: SegmentedItemModel) -> CGFloat
    
    /// 更新选中事件的相关实体
    ///
    /// 在选中 item 时此函数将被触发，在此函数中更新选中前和选中后的两个实体
    /// - Parameters:
    ///   - segmentedView: segmentedView 对象
    ///   - currentSelectedItemModel: 在作出选择之前的被选中项
    ///   - willSelectedItemModel: 被选择之后的选中项
    /// - Warning: 此函数中修改实体的 isSelected 属性无效，其将被强制更改为对应的选中状态
    func refreshItemModel(_ segmentedView: SegmentedView, currentSelectedItemModel: SegmentedItemModel, willSelectedItemModel: SegmentedItemModel)

}

/// 提供 SegmentedViewDataSource 的默认实现，这样对于遵从 SegmentedViewDataSource 的类来说，所有代理方法都是可选实现的
public extension SegmentedViewDataSource {

    func refreshItemModel(_ segmentedView: SegmentedView, currentSelectedItemModel: SegmentedItemModel, willSelectedItemModel: SegmentedItemModel) { }
}


// MARK: - SegmentedViewDelegate

/// SegmentedView 相关事件代理协议
public protocol SegmentedViewDelegate: AnyObject {
    /// 询问是否允许点击选中目标 index 的 item，该函数已默认实现返回 true.
    func segmentedView(_ segmentedView: SegmentedView, canClickItemAt index: Int) -> Bool
    
    /// 告诉代理选中了目标，此函数发生在完成选中指定项之后。
    /// - Parameters:
    ///   - segmentedView: 操作的 segmentedView 对象
    ///   - index: 被选中的索引
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int)
    
    /// 告诉代理选中的重复目标，比如当前 index 为 0，但用于依然点击了第 0 项。
    func segmentedView(_ segmentedView: SegmentedView, selectedRepetition repetitionIndex: Int)
}

// MARK: SegmentedViewDelegate 默认实现

/// 提供 SegmentedViewDelegate 的默认实现，这样对于遵从 SegmentedViewDelegate 的类来说，所有代理方法都是可选实现的。
public extension SegmentedViewDelegate {
    func segmentedView(_ segmentedView: SegmentedView, canClickItemAt index: Int) -> Bool { true }

    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) { }
    
    func segmentedView(_ segmentedView: SegmentedView, selectedRepetition repetitionIndex: Int) { }
}


// MARK: 指示器专用协议

/// 指示器专用协议
public protocol IndicatorProtocol {
    
    /// 是否需要将当前的 indicator 的 frame 转换到 Cell。辅助 SegmentedTitleDataSourced 的 isTitleMaskEnabled 属性使用
    /// 如果添加了多个 indicator，仅能有一个 indicator 的 isIndicatorConvertToItemFrameEnabled 为 true
    /// 如果有多个 indicator 的 isIndicatorConvertToItemFrameEnabled 为 true，则以最后一个 isIndicatorConvertToItemFrameEnabled 为 true 的 indicator 为准
    var isIndicatorConvertToItemFrameEnabled: Bool { get }
    
    
    /// 重置指示器，以当前选中的 index 更新状态，使其所有信息恢复至默认值
    ///
    /// 通常情况下，需要在此函数中更新背景色、圆角、frame 等关键属性
    /// - Parameter model: 指示器详细参数
    func refreshIndicatorState(model: IndicatorSelectedParams)

    /// 点击选中了某一个 item 通过此函数更新指示器信息
    ///
    /// 通常情况下，主要在此函数中更新 frame 属性
    /// - Parameter model: 指示器详细参数
    func selectItem(model: IndicatorSelectedParams)

    /// contentScrollView 在进行手势滑动时，处理指示器跟随手势变化 UI 逻辑；
    /// param selectedIndex 当前选中的 index
    /// param leftIndex 正在过渡中的两个 Cell，相对位置在左边的 Cell 的 index
    /// param leftCellFrame 正在过渡中的两个 Cell，相对位置在左边的 Cell 的 frame
    /// param rightIndex 正在过渡中的两个 Cell，相对位置在右边的 Cell 的 index
    /// param rightCellFrame 正在过渡中的两个 Cell，相对位置在右边的 Cell 的 frame
    /// param percent 过渡百分比
    /// - Parameter model: model description
    func contentScrollViewDidScroll(model: IndicatorTransitionParams)

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


// MARK: extension

public extension UIColor {
    
    var f_red: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    
    var f_green: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    
    var f_blue: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
    
    var f_alpha: CGFloat {
        return cgColor.alpha
    }
}

public class SegmentedViewTool {
    
    public static func interpolate<T: SignedNumeric & Comparable>(from: T, to:  T, percent:  T) ->  T {
        let percent = max(0, min(1, percent))
        return from + (to - from) * percent
    }

    public static func interpolateColor(from: UIColor, to: UIColor, percent: CGFloat) -> UIColor {
        let r = interpolate(from: from.f_red, to: to.f_red, percent: percent)
        let g = interpolate(from: from.f_green, to: to.f_green, percent: CGFloat(percent))
        let b = interpolate(from: from.f_blue, to: to.f_blue, percent: CGFloat(percent))
        let a = interpolate(from: from.f_alpha, to: to.f_alpha, percent: CGFloat(percent))
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    public static func interpolateColors(from: [CGColor], to: [CGColor], percent: CGFloat) -> [CGColor] {
        var resultColors = [CGColor]()
        for index in 0..<from.count {
            let fromColor = UIColor(cgColor: from[index])
            let toColor = UIColor(cgColor: to[index])
            let r = interpolate(from: fromColor.f_red, to: toColor.f_red, percent: percent)
            let g = interpolate(from: fromColor.f_green, to: toColor.f_green, percent: CGFloat(percent))
            let b = interpolate(from: fromColor.f_blue, to: toColor.f_blue, percent: CGFloat(percent))
            let a = interpolate(from: fromColor.f_alpha, to: toColor.f_alpha, percent: CGFloat(percent))
            resultColors.append(UIColor(red: r, green: g, blue: b, alpha: a).cgColor)
        }
        return resultColors
    }
}
