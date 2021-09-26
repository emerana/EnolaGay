//
//  FontViewSearchAgent.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/11/1.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

class FontViewSearchAgent: NSObject {
    
    /// 搜索结果数据源，当 searchDataSource 发生改变时会 reload table.
    var searchDataSource = [JSON]()
    
    /// 选择 Row 事件
    var didSelectRow: ((String) -> Void)?

}

// MARK: - UITableViewDataSource
extension FontViewSearchAgent: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断 cell == nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = searchDataSource[indexPath.row].stringValue
        cell.textLabel?.font = UIFont.init(name: searchDataSource[indexPath.row].stringValue, size: 18)

        return cell
    }
    
}

extension FontViewSearchAgent: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        didSelectRow?(searchDataSource[indexPath.row].stringValue)
    }

}
