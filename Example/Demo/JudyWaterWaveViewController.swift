//
//  JudyWaterWaveViewController.swift
//  Demo
//
//  Created by 醉翁之意 on 2023/4/20.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

/// 水波纹动画
class JudyWaterWaveViewController: UIViewController {

    @IBOutlet weak var wateerView: JudyWaterWaveView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        wateerView.star()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        wateerView.continue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        wateerView.paused()
    }

    deinit {
        wateerView.stop()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
