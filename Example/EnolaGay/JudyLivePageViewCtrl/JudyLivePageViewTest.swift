//
//  JudyLivePageViewTest.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 2021/1/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// JudyLivePageViewCtrl 测试用例
class JudyLivePageViewTest: UIViewController {

    private var livePageViewCtrl: JudyLivePageViewCtrl!
    
    private let dataSource = [1,2,3,4,5,6,7,8,9,10]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "loadJudyLivePageViewCtrl" {
            livePageViewCtrl = segue.destination as? JudyLivePageViewCtrl
            livePageViewCtrl.enolagay = self
        }

    }

}

extension JudyLivePageViewTest: EMERANA_JudyLivePageViewCtrl {
    
    func viewController(isForward forward: Bool, awayViewCtrl viewCtrl: UIViewController?) -> UIViewController? {
        
        // 配置初始页
        guard viewCtrl != nil else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "LiveModelViewCtrl") as? LiveModelViewCtrl
            vc?.tagDataSource = dataSource[0]
            return vc
        }

        // 配置上一页或下一页
        guard let index = dataSource.firstIndex(of: (viewCtrl as! LiveModelViewCtrl).tagDataSource) else { return nil }
        let modelViewCtrl = storyboard?.instantiateViewController(withIdentifier: "LiveModelViewCtrl")as? LiveModelViewCtrl

        if forward { // 下一个界面
            if index >= dataSource.count - 1 { return nil }
            modelViewCtrl?.tagDataSource = dataSource[index+1]
        } else { // 上一个界面
            if index <= 0 { return nil }
            modelViewCtrl?.tagDataSource = dataSource[index-1]
        }

        return modelViewCtrl
    }
    
    
}
