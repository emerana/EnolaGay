//
//  DouYonHomeViewCtrl.swift
//  EnolaGay_Example
//
//  Created by 王仁洁 on 2021/6/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay

class DouYonHomeViewCtrl: JudyBaseViewCtrl {

    private var pageViewCtrl: DouYinPageViewCtrl!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titles = ["附近", "关注", "推荐"]
        pageViewCtrl.onStart(dataSource: titles)
    }

    // MARK: - override
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let scrollView = pageViewCtrl.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = pageViewCtrl

    }
    
    // MARK: - event response


    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
        pageViewCtrl = segue.destination as? DouYinPageViewCtrl
        pageViewCtrl.enolagay = self
        
        
     }
    
}


extension DouYonHomeViewCtrl: EMERANA_JudyBasePageViewCtrlModel {
    
    func viewCtrl(for index: Int, at title: String) -> UIViewController {
        let viewCtrl = storyboard!.instantiateViewController(withIdentifier: "contentViewCtrl")
        switch index {
        case 0:
            viewCtrl.view.backgroundColor = .red
        case 1:
            viewCtrl.view.backgroundColor = .brown
        case 2:
            viewCtrl.view.backgroundColor = .cyan
        default:
            viewCtrl.view.backgroundColor = .green
        }
        return viewCtrl
    }

}

class DouYinPageViewCtrl: JudyBasePageViewCtrl {
    
    private var userHome: UIViewController? {
        didSet {
            Judy.logHappy( userHome != nil ? "生成新界面":"释放新界面")
        }
    }
    
    /// 该标识表示当前是否正在移动新界面
    private var isPushing = false {
        didSet {
            Judy.logHappy(isPushing ? "push 开始":"push 结束")
        }
    }
    
//    private var isPushed = false
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = true
        // Judy.log("滚动:\(scrollView.contentOffset.x)")
        if lastSelectIndex != 2 { return }
        
        if scrollView.contentOffset.x - scrollView.frame.width > 0 {
            if !isPushing {
                isPushing = true
                userHome = storyboard?.instantiateViewController(withIdentifier: "UserHome")
            }
            if userHome != nil {
                if isPushing {
                    Judy.log("移动中……")
//                    userHome?.view.frame.origin.x = scrollView.contentOffset.x - scrollView.frame.width
                    // 直接 push!
                    if scrollView.contentOffset.x - scrollView.frame.width > 15 {
                        Judy.logWarning("触发 push!")
                        navigationController?.pushViewController(userHome!, animated: true)
                        isPushing = false
                        scrollView.delegate = nil
                    }
                }
            }

        } else { // == 0
            if isPushing {
                userHome = nil
                isPushing = false
            }
        }

    }
}
