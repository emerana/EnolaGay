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


}



//extension CollectionViewLayoutViewCtrl: URLSessionDelegate, URLSessionDownloadDelegate {
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        //1.拿到cache文件夹的路径
//        let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
//        //2,拿到cache文件夹和文件名
//        let file: String = cache?.appendingPathComponent(downloadTask.response?.suggestedFilename ?? "") ?? ""
//
//        do {
//            try FileManager.default.moveItem(at: location, to: URL.init(fileURLWithPath: file))
//        } catch let error {
//            print(error)
//        }
//
//        //3，保存视频到相册
//        let videoCompatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file)
//        //判断是否可以保存
//        if videoCompatible {
//            UISaveVideoAtPathToSavedPhotosAlbum(file, self, #selector(didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
//        } else {
////            JJHUDManage.show("该视频无法保存至相册")
//        }
//    }
//
//    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
//
//        if error != nil{
////            JJHUDManage.errorShow("保存失败")
////            JJLog(error?.localizedDescription)
//        }else{
////            JJHUDManage.successShow("保存成功")
//        }
//    }
//
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//
////        //下载进度
////        CGFloat progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
////        dispatch_async(dispatch_get_main_queue(), ^{
////            //进行UI操作  设置进度条
////            self.progressView.progressValue = progress;
////            self.progressView.contentLabel.text = [NSString stringWithFormat:@"%.2f%%",progress*100];
////        });
//    }
//
//}

// MARK: - UICollectionViewDataSource
extension CollectionViewLayoutViewCtrl: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return dataSource.count }
    
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
    
    // MARK: collectionView delegate
    
    // 选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let json = dataSource[indexPath.section][indexPath.row].stringValue
        log("选中\(json)")

    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewLayoutViewCtrl: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
}
