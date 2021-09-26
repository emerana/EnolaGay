//
//  FullViewController.swift
//  Live
//
//  Created by 醉翁之意 on 2020/3/20.
//  Copyright © 2020 指尖躁动. All rights reserved.
//

import UIKit
import EnolaGay

class FullViewController: UIViewController {

    //var player: IJKFFMoviePlayerController!
    
    // MARK: 单个界面需要横屏的标准方式
    // 这里一定要弄成false
    override var shouldAutorotate: Bool { return false }
    
    // 支持的旋转方向
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscapeRight }
    
    // 模态切换的默认方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .landscapeRight }


    override func viewDidLoad() {
        super.viewDidLoad()

//        player.view.frame = self.view.bounds
        self.view.autoresizesSubviews = true
//        self.view.addSubview(player.view)
        // 将某个View调整至最下面
//        self.view.sendSubviewToBack(player.view)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func exitAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}

