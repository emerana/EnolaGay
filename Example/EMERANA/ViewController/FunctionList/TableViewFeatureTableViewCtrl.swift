//
//  TableViewFeatureTableViewCtrl.swift
//  MeaningOfDrunk
//
//  Created by 醉翁之意 on 2020/3/27.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

class TableViewFeatureTableViewCtrl: JudyBaseTableViewCtrl {
    
    override var viewTitle: String? { return "tableView" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }

    @IBAction func singleSelectedAction(_ sender: Any) {
        tableView?.isEditing = !tableView!.isEditing
    }
    
    @IBAction func printAction(_ sender: Any) {
        Judy.log("当前选中\(String(describing: tableView?.indexPathsForSelectedRows))")
    }
    
    @IBAction func editSelectedAction(_ sender: Any) {
        
    }

}


// MARK: - tableView dataSource
extension TableViewFeatureTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 8 }
    
    /// 初始化 Cell，此处 Cell 默认的 identifier = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectCell = super.tableView(tableView, cellForRowAt: indexPath) as! SelectCell
        // 单选时选中样式一定要设为 default
        cell.selectionStyle = .gray
//        cell.multipleSelectionBackgroundView = UIView()
        // 选中的圆圈颜色
//        cell.tintColor = .red
        // 背景颜色为透明
//        cell.backgroundColor = .clear

        return cell
    }

}

// MARK: - tableView delegate
extension TableViewFeatureTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if !tableView.isEditing {
//            tableView.deselectRow(at: indexPath, animated: true)
//        } else { // 在多选模式下做到单选，原理，只要之前选中的那个indexPath不是当前的indexPath，就把之前那个取消选中
//            if tableView.indexPathsForSelectedRows!.first != indexPath {
//                tableView.deselectRow(at: tableView.indexPathsForSelectedRows!.first!, animated: true)
//            }
//        }
    }


}


class SelectCell: JudyBaseTableCell {
    // Cell 准备重用时执行的方法
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 此处应重置 Cell 状态，清除在重用池里面设置的值
    }
    
    /// 从 xib 或故事板创建对象将会执行此初始函数
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
        
    /// 布局子视图，创建对象顺序一定是先有 frame，再 awakeFromNib，再调整布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - override
    
    /// 设置数据源事件
    override func jsonDidSetAction() {

    }
    
}

