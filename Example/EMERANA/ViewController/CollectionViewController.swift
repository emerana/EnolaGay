//
//  CollectionViewController.swift
//  emerana
//
//  Created by 醉翁之意 on 2019/11/21.
//  Copyright © 2019 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    /// 间距及边距
    private let spacing: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}

// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    
    // cell数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 3
    }
    
    // MARK: Cell初始化
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Judy.log(indexPath.row)
    }
    
    // cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let heights =  collectionView.frame.size.height

        // 只需要减掉一个 spacing
        let widths =  collectionView.frame.size.width/2 - spacing
        
        if indexPath.row == 0 {
            return CGSize(width: widths, height: heights)
        } else {
            return CGSize(width: widths, height: heights/2-spacing*2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return spacing*2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return spacing*2
    }

}
