//
//  LivePageViewCtrl.swift
//  EnolaGay
//
//  Created by 醉翁之意 on 2021/1/7.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

/// LivePageViewCtrl 测试用例
class LivePageViewCtrl: UIViewController {

    private var livePageViewCtrl: JudyLivePageViewCtrl!
    
    private let dataSource = [1,2,3,4,5,6,7,8,9,10]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LivePageViewCtrl 进阶"
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "loadJudyLivePageViewCtrl" {
            livePageViewCtrl = segue.destination as? JudyLivePageViewCtrl
            livePageViewCtrl.enolagay = self
            livePageViewCtrl.onStart()
        }

    }

}

extension LivePageViewCtrl: JudyPageViewCtrlDelegate {
    
    func entitys(for pageViewCtrl: UIPageViewController) -> [Any] { dataSource }
    
    func index(for viewCtrl: UIViewController, at entitys: [Any]) -> Int {
        var rs = 0
        entitys.enumerated().forEach { (index, entity) in
            if (viewCtrl as! LiveModelViewCtrl).tagDataSource == (entity as! Int) {
                rs = index
                return
            }
        }
        Logger.info("当前询问的序列索引为：\(rs)")
        return rs
    }
    
    func viewCtrl(for entity: Any) -> UIViewController {
        let modelViewCtrl = storyboard?.instantiateViewController(withIdentifier: "LiveModelViewCtrl") as! LiveModelViewCtrl
        modelViewCtrl.tagDataSource = entity as! Int
        return modelViewCtrl
    }
    
    
    func viewController(isForward forward: Bool, previousViewControllers viewCtrl: UIViewController?) -> UIViewController? {
        
        let modelViewCtrl = storyboard?.instantiateViewController(withIdentifier: "LiveModelViewCtrl") as? LiveModelViewCtrl

        // 配置初始页
        guard viewCtrl != nil else {
            modelViewCtrl?.tagDataSource = dataSource[0]
            return modelViewCtrl
        }

        // 配置上一页或下一页
        guard let current = dataSource.firstIndex(of: (viewCtrl as! LiveModelViewCtrl).tagDataSource) else { return nil }

        if forward { // 下一个界面
            if current >= dataSource.count - 1 { return nil }
            modelViewCtrl?.tagDataSource = dataSource[current+1]
        } else { // 上一个界面
            if current <= 0 { return nil }
            modelViewCtrl?.tagDataSource = dataSource[current-1]
        }

        return modelViewCtrl
    }
    
    
}
