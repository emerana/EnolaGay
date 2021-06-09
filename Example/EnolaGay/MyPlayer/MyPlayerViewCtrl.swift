//
//  MyPlayerViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/6/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

class MyPlayerViewCtrl: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "Player" }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSoruce()
    }

    override func registerReuseComponents() {
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "Cell")
    }

}

extension MyPlayerViewCtrl {
    
    func setDataSoruce() {
        dataSource = [
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210414135329.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210425153032.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210422095345.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210422100200.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210422100512.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210410094203.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210429131045.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210414135138.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210415143308.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210425160443.mp4"]),
        ]
    }
}

extension MyPlayerViewCtrl {
    // 明确预估高度。
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // viewDidLoad 中执行 tableView?.scrollToRow 后，
        // 导致上下切换 Cell 还会残留上一个 Cell 问题，
        // 是因为 Estimate 为 Automatic，给其设置一个值即可。
        return tableView.frame.height - tableView.safeAreaInsets.top
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height - tableView.safeAreaInsets.top
    }
    
    /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)  as! VideoCell
        cell.json = dataSource[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }


}
