//
//  LiveViewCtrl.swift
//  MeaningOfDrunk
//
//  Created by 醉翁之意 on 2020/3/21.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import IJKMediaFramework
import Alamofire

/// 直播拉流效果测试
class LiveViewCtrl: JudyBaseViewCtrl {
    
    override var viewTitle: String? { return "直播拉流效果测试" }

    // MARK: - let property and IBOutlet
    @IBOutlet weak private var playerView: UIView!
        
    // MARK: - public var property
    var player: IJKFFMoviePlayerController!
    
    /// 网络监听对象
    fileprivate let net = NetworkReachabilityManager()

    // MARK: - private var property

    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        net?.startListening()
        net?.listener = { [weak self] status in
            if self?.net?.isReachable ?? false {

                switch status{
                case .notReachable:
                    print("无网络连接")
                case .unknown:
                    print("网络不稳定")
                case .reachable(.ethernetOrWiFi):
                    print("通过WiFi链接")
                case .reachable(.wwan):
                    print("通过移动网络链接")
                }
            } else {
                print("网络不可用")
            }
        }
        
        showVideo()
    }
    
    func showVideo(){
        
        //视频源地址
        //        let url = URL.init(string: "rtmp://live.tuiyizx.com/tuiyizx/e068933e")
        let url = URL.init(string: "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8")
        
        let options = IJKFFOptions.byDefault()
        //初始化播放器，播放在线视频或直播（RTMP）
        player = IJKFFMoviePlayerController.init(contentURL: url, with: options)
        //播放页面视图宽高自适应
        let autoresize = UIView.AutoresizingMask.flexibleWidth.rawValue |
            UIView.AutoresizingMask.flexibleHeight.rawValue
        player.view.autoresizingMask = UIView.AutoresizingMask(rawValue: autoresize)
        
        player.scalingMode = .aspectFit //缩放模式
        player.shouldAutoplay = true //开启自动播放
        // 显示信息
        //        player.shouldShowHudView = true
        
        playerView.autoresizesSubviews = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //准备播放
        player.prepareToPlay()
        player.view.frame = playerView.bounds
        playerView.addSubview(player.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    deinit {
        player.shutdown()
        net?.stopListening()
    }

    @IBAction private func startLive(_ sender: Any) {
        player.play()
    }
    
    @IBAction private func endLive(_ sender: Any) {
        player.pause()
    }
    
    // MARK: - override
    

    // MARK: - Event response
        

     // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showFullViewCtrl" {
            let viewCtrl = segue.destination as! FullViewController
            // 直接使用当前 veiwCtrl 中的对象
            viewCtrl.player = player
        }
    }
    
}


// MARK: - Private Methods

private extension LiveViewCtrl {

    func listeningNetwork() {

    }
    
}
