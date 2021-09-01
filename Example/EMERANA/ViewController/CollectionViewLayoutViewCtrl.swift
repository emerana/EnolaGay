//
//  CollectionViewLayoutViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2020/8/6.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

/// UICollectionViewLayou 探究
class CollectionViewLayoutViewCtrl: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView?

    var dataSource = [JSON]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        dataSource = [
            ["醉翁之意", "Judy", "EnolaGay", "EMERANA", "时间魔术师", "王仁洁", "我日你仙人板板", "醉翁之意", "Judy", "EnolaGay", "EMERANA", "时间魔术师", "王仁洁", "我日你仙人板板"],
            ["醉翁之意", ],
        ]

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

// MARK: - UICollectionViewDataSource
extension CollectionViewLayoutViewCtrl: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    // Cell 数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return dataSource[section].arrayValue.count
    }
    
    // Cell 初始化函数
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        (cell.viewWithTag(101) as? UILabel)?.text = dataSource[indexPath.section][indexPath.row].stringValue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
            return sectionHeaderView
        } else {
            let sectionFooter = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            
            return sectionFooter
        }

    }
        
}


// MARK: - UICollectionViewDelegate
extension CollectionViewLayoutViewCtrl: UICollectionViewDelegate {
    
    // MARK: scrollView delegate
    
    /// scrollView 滚动之后执行的代理方法，此方法实现了上拉隐藏下拉显示导航栏，重写此方法记得super可实现。
    ///
    /// - Parameter scrollView: scrollView对象
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //    }
    
    // MARK: collectionView delegate
    
    // 选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let json = dataSource[indexPath.section][indexPath.row].stringValue
        Judy.log("选中\(json)")

    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewLayoutViewCtrl: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
    
}
