//
//  ViewCtrller.swift
//  Judy_CollectionInScrollView
//  滚动视图里嵌套横向滚动视图，实现两个不同高度的CollectionView切换
//  Created by Judy-王仁洁 on 2017/5/27.
//  Copyright © 2017年 Judy.CMB. All rights reserved.
//

import UIKit
import EnolaGay

class ViewCtrller: UIViewController, UIScrollViewDelegate {
    
    // MARK: - let property and IBOutlet
    
    private let screenWidth = UIScreen.main.bounds.size.width
    private let collectionViewAgent = ViewCtrllerAgent()
    private let numOfCellInRow: CGFloat = 5
    private let minimumInteritemSpacing: CGFloat = 1
    
    @IBOutlet weak var leftCollectionView: UICollectionView!
    @IBOutlet weak var rightCollectionView: UICollectionView!
    /// 横向滚动视图的高度约束
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    // MARK: - var property
    
    // KVO检测的标量
    var leftCollectionViewForKVO: NSObject!
    var rightCollectionViewForKVO: NSObject!
    // 记录对应collectionView的高度
    var leftCollectionHeight: CGFloat = 0.1
    var rightCollectionHeight: CGFloat = 0.1
    /// 是否显示左边的collectionView，默认是
    var isShowLeft = true
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 两个CollectionView添加KVO监控，通过监控CollectionView的contentSize来
        leftCollectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: &leftCollectionViewForKVO)
        rightCollectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: &rightCollectionViewForKVO)
        
        // Do any additional setup after loading the view.
        rightCollectionView.dataSource = collectionViewAgent
        rightCollectionView.delegate = collectionViewAgent
        
        let flow_layout = UICollectionViewFlowLayout()
        //设置每一个item的大小
        flow_layout.itemSize = CGSize(width: (screenWidth - minimumInteritemSpacing*(numOfCellInRow - 1))/numOfCellInRow, height: 68)
        flow_layout.minimumInteritemSpacing = minimumInteritemSpacing
        flow_layout.minimumLineSpacing = 1

        leftCollectionView.dataSource = collectionViewAgent
        leftCollectionView.setCollectionViewLayout(flow_layout, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
//        print("左边的CollectionView高度:\(self.leftCollectionView.contentSize.height)")
    }
    
    // MARK: - override - 重写重载父类的方法
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件
    
    // MARK: - event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //Judy-mark: 通过监控CollectionView的contentSize来确定当前CollectionView的高度

        if context == &leftCollectionViewForKVO {
//            print("left---contentSize height:\(self.leftCollectionView.contentSize.height)")
            leftCollectionHeight = self.leftCollectionView.contentSize.height
        }
        if context == &rightCollectionViewForKVO {
//            print("right---contentSize height:\(self.rightCollectionView.contentSize.height)")
            rightCollectionHeight = self.rightCollectionView.contentSize.height
        }
        
        if keyPath == "contentSize" {
            //            print("检测到contentSize height:\(self.leftCollectionView.contentSize.height)")
            //            print("检测到contentSize height:\(self.rightCollectionView.contentSize.height)")
            //            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6.0, options: .curveEaseIn, animations: {
            //                self.view.layoutIfNeeded()
            //            }, completion: nil)
        }
        refreshCollectionView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Judy-mark: 通过scrollView滚动来确定显示哪边的CollectionView
        
        //        print("当前偏移量\(scrollView.contentOffset.x)")
        //        isShowLeft = scrollView.contentOffset.x < UIScreen.main.bounds.size.width
        if scrollView.contentOffset.x == 0 {
            isShowLeft = true
        } else {
            isShowLeft = false
        }
        //        print("当前显示为：", isShowLeft ? "左边":"右边")
        refreshCollectionView()
    }
    
    // MARK: - private method - 私有方法的代码尽量抽取创建公共class。
    
    /// 刷新CollectionView高度
    private func refreshCollectionView() {
        scrollViewHeight.constant = isShowLeft ? leftCollectionHeight:rightCollectionHeight
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        print("即将消失")
    }
    
    // 千万记得移除KVO
    deinit {
        leftCollectionView.removeObserver(self, forKeyPath: "contentSize")
        rightCollectionView.removeObserver(self, forKeyPath: "contentSize")
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
