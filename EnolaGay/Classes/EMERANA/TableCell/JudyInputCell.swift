//
//  JudyInputCell.swift
//
//  Created by 醉翁之意 on 2018/5/12.
//  Copyright © 2018年 GSDN. All rights reserved.
//

import UIKit

/// 包含一个输入框的 UITableViewCell，**在设置 json 之前请务必设置 indexPath**
/// # * 设置 json 键值对必选字段
/// # EMERANA.Key.Cell.title -> cell 最左边的 title，
/// # EMERANA.Key.Cell.placeholder -> 输入框的 placeholder,
/// # EMERANA.Key.Cell.value -> 输入框的值，
/// # EMERANA.Key.Cell.input -> 如果需要支持输入请将该值设为 true，否则该输入框将仅供展示
open class JudyInputCell: JudyBaseTableCell {
    
    /// 输入框，请确保该输入框的类型是 JudyCellTextField
    @IBOutlet weak public var inputTextField: JudyCellTextField?
    
    /// 对应cell中的indexPath，请在设置 json 之前设置好该值
    public var indexPath: IndexPath! {
        didSet{ inputTextField?.indexPath = indexPath }
    }
    
    open override func jsonDidSetAction() {
        super.jsonDidSetAction()
        
        guard indexPath != nil else {
            titleLabel?.text = "请先设置 indexPath！"
            return
        }
        inputTextField?.placeholder = json[EMERANA.Key.Cell.placeholder].stringValue
        inputTextField?.text = json[EMERANA.Key.Cell.value].stringValue
        inputTextField?.isEnabled = json[EMERANA.Key.Cell.input].boolValue
    }
    
    
}

/// 包含一个 indexPath 的 UITextField，该 UITextField 通常嵌于 TableViewCell 里，为此在里面指定一个 indexPath。
/// * 此类必须独立出来
final public class JudyCellTextField: JudyBaseTextField {
    /// 对应 cell 中的 indexPath
    public var indexPath: IndexPath!
}
