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

class VideoCell: UITableViewCell {
    
    // MARK: - public var property
    
    /// 当前 Cell 是否已经消失的标志，默认为 true.
    ///
    /// - 务必通过此函数来控制播放器。
    /// - 请在 willDisplay cell 函数中将该值设为 false.
    /// - 请在 didEndDisplaying cell 函数中将该值设为 true.
    var isDisAppear = true {
        didSet {
            log("isDisAppear 被设为：\(isDisAppear)，此时播放器状态为：\(player.playbackState.description)")
            // 暂停播放，或者继续播放
            isDisAppear ? player.pause() : player.playFromCurrentTime()
        }
    }
    
    /// 视频的 URL
    var videoURL: String! {
        didSet {
            guard player.url?.absoluteString != videoURL else {
                Logger.error("都已经是同样的 URL 了，不用设置啦！")
                return
            }
            player.url = URL(string: videoURL)
        }
    }
    
    
    fileprivate var player = Player()

    /// 播放按钮。
    @IBOutlet weak var playerButton: UIButton!
    
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
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        self.player.view.frame = contentView.bounds
        self.player.fillMode = .resize
        self.player.playbackLoops = true

        // self.contentView.addSubview(self.player.view)
        contentView.insertSubview(player.view, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.player.view.frame = contentView.bounds
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


// MARK: - PlayerDelegate

extension VideoCell: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        Logger.happy("ready……")
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        log(player.playbackState.description)
//        switch player.playbackState {
//        case .playing:
//            playerButton.isHidden = true
//        case .paused, .failed, .stopped:
//            playerButton.isHidden = false
//        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        logl("\(#function) error.description")
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
