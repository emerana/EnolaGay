//
//  VideoCell.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/6/9.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import Player

class VideoCell: JudyBaseTableCell {
    
    fileprivate var player = Player()

    /// 播放按钮。
    @IBOutlet weak var playerButton: JudyBaseButton!
    
    // MARK: - var property
    
    
    // MARK: - life cycle
    
    // cell 准备重用时执行的方法。
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 此处应重置 cell 状态，清除在重用池里面设置的值。
    }
    
    /// 从 xib 或故事板创建对象将会执行此初始函数。
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .green
//        contentMode = .scaleAspectFit
        
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        self.player.view.frame = contentView.bounds
//        self.player.fillMode = .resizeAspect

        // self.addChild(self.player)
        self.contentView.addSubview(self.player.view)
        // self.player.didMove(toParent: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.player.view.frame = contentView.bounds
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // MARK: - override
    
    /// 设置数据源事件。
    override func jsonDidSetAction() {
        self.player.url = URL(string: json["urls"].stringValue)!
    }
    
}


// MARK: - PlayerDelegate

extension VideoCell: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        print("\(#function) ready")
        self.player.playFromBeginning()
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
    
}

// MARK: - PlayerPlaybackDelegate

extension VideoCell: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }

    func playerPlaybackDidLoop(_ player: Player) {
    }
}

