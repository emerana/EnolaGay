//
//  ChooseGroupTableViewCtrl.swift
//  PasswordBox
//
//  Created by 醉翁之意 on 2022/11/3.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// 修改分组列表界面
class ChooseGroupTableViewCtrl: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "修改分组" }
    
    // MARK: - let property and IBOutlet
    
    // MARK: - public var property
    // 当前分组
    var selectedGroup: Group?
    
    // MARK: - private var property
    private var groups = [Group]()

    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取分组列表
        groups = DataBaseCtrl.judy.getGroupList()

        tableView?.isEditing = true
        // 需要设为复选模式才可以使用真正意义上的多选
        tableView?.allowsMultipleSelectionDuringEditing = true
        
        // 确定当前选中的分组
        if let firstIndex = groups.firstIndex(where: { [weak self] group in
            return group.id == self?.selectedGroup?.id
        }) {
            let selectedIndexPath = IndexPath(item: firstIndex, section: 0)
            tableView?.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .middle)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    // MARK: - override
    
    // MARK: - event response
    
    // 分组确定事件
    @IBAction func confirmAction(_ sender: Any) {
//        tableView?.indexPathForSelectedRow
//        selectedGroup = groups[indexPath.row]
        
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToChooseGroup" {

            if let selectedIndex = tableView?.indexPathForSelectedRow {
                selectedGroup = groups[selectedIndex.row]
            } else {
                selectedGroup = nil
            }
        }
    }

}


// MARK: - tableView dataSource
extension ChooseGroupTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    /// 询问指定 indexPath 的 Cell 实例
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = groups[indexPath.row].name
        cell.imageView?.image = ICON.judy.image(withName: groups[indexPath.row].icon ?? "", iconBundle: .icons_group)
//          if indexPath == selectedIndexPath {
//              cell.accessoryType = .checkmark
//          } else {
//              cell.accessoryType = .none
//          }
        
        // 单选时选中样式一定要设为 default
        cell.selectionStyle = .default
        cell.multipleSelectionBackgroundView = UIView()
        // 选中的圆圈颜色
        cell.tintColor = .purple
        // 背景颜色为透明
        //  cell.backgroundColor = .clear

        return cell
    }

}


// MARK: - tableView delegate
extension ChooseGroupTableViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 将第一次选中的删掉
        guard let lastSelectedIndex = tableView.indexPathsForSelectedRows?.first else { return }
        // 在多选模式下做到单选，需要用 tableView.indexPathsForSelectedRows 数组
        // 需要配合 tableView?.allowsMultipleSelectionDuringEditing = true
        //  只要之前选中的那个indexPath不是当前的indexPath，就把之前那个取消选中
        if lastSelectedIndex != indexPath {
            tableView.deselectRow(at: lastSelectedIndex, animated: true)
        }

    }
    
}
