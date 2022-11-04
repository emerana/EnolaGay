//___FILEHEADER___

import UIKit
import EnolaGay

class ___FILEBASENAMEASIDENTIFIER___: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "<#title#>" }
    
    // MARK: - let property and IBOutlet
    
    // MARK: - public var property

    // MARK: - private var property
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSource()
    }
    
    // MARK: - override
    
    // MARK: - event response
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }

}


// MARK: - private methods
private extension ___FILEBASENAMEASIDENTIFIER___ {
    /// 设置 JSON 数据源
    func setDataSource() {
        dataSource = [
            [
                EMERANA.Key.title: "模拟数据",
                EMERANA.Key.segue: "模拟数据",
            ],
            [EMERANA.Key.title: "模拟数据", ],
            [EMERANA.Key.title: "模拟数据", ],
        ]
    }
    
}


// MARK: - tableView dataSource
extension ___FILEBASENAMEASIDENTIFIER___ {
    /// 询问指定 indexPath 的 Cell 实例
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) // as! JudyBaseTableCell

        //  cell.json = dataSource[indexPath.row]
        //  cell.textLabel?.text = dataSource[indexPath.row]["title"].stringValue
        //  if dataSource[indexPath.row]["subtitle"] == nil {
        //      cell.detailTextLabel?.text = nil
        //      cell.accessoryType = .disclosureIndicator
        //  } else {
        //      cell.detailTextLabel?.text = dataSource[indexPath.row]["subtitle"].stringValue
        //      cell.accessoryType = .none
        //  }
        
        return cell
    }

}


// MARK: - tableView delegate
extension ___FILEBASENAMEASIDENTIFIER___ {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
    }

}
