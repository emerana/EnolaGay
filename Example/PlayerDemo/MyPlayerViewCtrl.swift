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
import AVFAudio

class MyPlayerViewCtrl: JudyBaseTableViewCtrl {
    override var viewTitle: String? { "Player" }

    /// 当前正播放视频的 Cell.
    private(set) var currentPlayerCell: VideoCell? {
        didSet {
            oldValue?.isDisAppear = true
            currentPlayerCell?.isDisAppear = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 手机静音模式下依然播放声音。
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        setDataSoruce()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isReqSuccess = true
        super.viewWillAppear(animated)
    }

    override func registerReuseComponents() {
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: EMERANA.Key.cell)
    }

}

extension MyPlayerViewCtrl {
    func setDataSoruce() {
        dataSource = [
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210413161440.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210429131045.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210414135138.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210415143308.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210425160443.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210426084615.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210414135009.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210426130012.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210414135329.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210425153032.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210422095345.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210422100200.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210422100512.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210410094203.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210425160639.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210429132634.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210420153851.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210415130817.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210425152907.mp4"]),
            JSON(["urls": "https://video.jingmaiwang.com/smallvideo/-1_20210426085627.mp4"]),
        ]
    }
}

extension MyPlayerViewCtrl {
    // 明确预估高度。
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // viewDidLoad 中执行 tableView?.scrollToRow 后，
        // 导致上下切换 Cell 还会残留上一个 Cell 问题，
        // 是因为 Estimate 为 Automatic，给其设置一个值即可。
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    /// 询问指定 indexPath 的 cell 实例，默认取 identifier 为 cell 的实例。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)  as! VideoCell
        cell.json = dataSource[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}


// MARK: - tableView delegate
extension MyPlayerViewCtrl {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Judy.logs("Cell \(indexPath.row) 显示，并开始播放。")
        currentPlayerCell = cell as? VideoCell
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Judy.logWarning("Cell \(indexPath.row) 消失，并暂停播放。")
        (cell as? VideoCell)?.isDisAppear = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 这才是正确地获取当前显示的 Cell 方式！
        if scrollView == tableView {
            let cells = tableView?.visibleCells
            currentPlayerCell = cells?.first as? VideoCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? VideoCell
        cell?.isDisAppear = !cell!.isDisAppear
    }

}
