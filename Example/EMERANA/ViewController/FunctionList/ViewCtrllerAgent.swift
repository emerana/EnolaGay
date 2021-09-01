//
//  ViewCtrllerAgent.swift
//  Judy_CollectionInScrollView
//  ViewCtrllerAgent
//  Created by Judy-王仁洁 on 2017/5/27.
//  Copyright © 2017年 Judy.CMB. All rights reserved.
//  From Judy template.
//

import UIKit
import EnolaGay

class ViewCtrllerAgent: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate let numberOfRows = 18
    fileprivate let margin: CGFloat = 4
    
    private let screenWidth = UIScreen.main.bounds.size.width
    
    //MARK: - collectionView delegate
    
    // 初始化
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        var cell = UICollectionViewCell()
        //        if collectionView.tag == 101 {
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellForA", for: indexPath)
        //        } else {
        //            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellForA", for: indexPath)
        //        }
        
        return cell;
    }
    
    // cell数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return numberOfRows
    }
    
    // section数量
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    // cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        var widthForCell: CGFloat = 100.0, heightForCell: CGFloat = 100
        // 一行有多少个cell
        let numForCellInRow: CGFloat = 3
        // cell宽度 =（屏幕宽度-（Cell左边距+Cell右边距）x 数量）/数量
//        widthForCell = (screenWidth - margin*(numForCellInRow - 1)) / numForCellInRow
        widthForCell = (screenWidth + margin)/numForCellInRow - margin

        return CGSize(width: widthForCell, height: heightForCell)
    }
    
    // 连续的行或列之间的最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return margin
    }
    
    // 这个间距决定了一行内有多少个Cell,但Cell的数量确定后,实际的间距可能会向上调整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return margin
    }
    
}
