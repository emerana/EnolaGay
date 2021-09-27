//
//  DownloadViewCtrl.swift
//  EMERANA
//
//  Created by 王仁洁 on 2021/9/27.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import EnolaGay
import Alamofire

//import MediaPlayer
import AVKit

class DownloadViewCtrl: JudyBaseViewCtrl {
    override var viewTitle: String? { "下载测试" }
    
    var videoUrl = "https://video.jingmaiwang.com/smallvideo/-1_20210426125804.mp4"
    let pro = UIProgressView()
    /// 用于停止下载时,保存已下载的部分
    var cancelledData: Data?
    /// 下载请求对象
    var downloadRequest: DownloadRequest!
    /// 下载文件的保存路径
    var destination: DownloadRequest.DownloadFileDestination!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        loadData()
    }

    func configUI() {
        self.navigationItem.title = "下载测试"
        self.view.backgroundColor = UIColor.white
        pro.frame = CGRect.init(x: 50, y: 200, width: 200, height: 50)
        self.view.addSubview(pro)
        
    }
    
    func loadData() {
        //下载的进度条显示
         Alamofire.download(videoUrl).downloadProgress(queue: DispatchQueue.main) { (progress) in
             //下载进度条
             self.pro.setProgress(Float(progress.fractionCompleted), animated: true)
        }
        
        // 下载存储路径
        self.destination = {_,response in
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
            let fileUrl = documentsUrl?.appendingPathComponent(response.suggestedFilename!)
            
            Judy.log(fileUrl)
            
            return (fileUrl!,[.removePreviousFile, .createIntermediateDirectories] )
        }
        
        self.downloadRequest = Alamofire.download(videoUrl, to: self.destination)
        
        self.downloadRequest.responseData(completionHandler: downloadResponse)
    }
    
    // 根据下载状态处理
    func downloadResponse(response:DownloadResponse<Data>){
        switch response.result {
        case .success:
            print("下载完成")
            let alert = UIAlertController.init(title: "提示", message: "下载完成", preferredStyle: .alert)
            
            let okBtn = UIAlertAction.init(title: "确定", style: .default, handler: nil)
            
            alert.addAction(okBtn)
            self.present(alert, animated: true, completion: {
                self.saveVideoUrl(string: (response.destinationURL?.path)!)
//                self.navigationController?.popViewController(animated: true)
            })
            
//            let vc = AVPlayerViewController()
//            vc.player = AVPlayer.init(url: URL.init(fileURLWithPath: (response.destinationURL?.path)!))
//            vc.player?.play()
//            self.present( vc, animated: true) {
//            }
        case .failure:
            self.cancelledData = response.resumeData//意外停止的话,把已下载的数据存储起来
 
        }
    }
 
    //将下载的网络视频保存到相册
    func saveVideoUrl(string:String) {
        if string != ""{
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(string){
                UISaveVideoAtPathToSavedPhotosAlbum(string, self, #selector(self.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    ///将下载的网络视频保存到相册
    @objc func video(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
 
        if error.code != 0{
            print("保存失败")
            print(error)
        }else{
            print("保存成功")
            let vc = AVPlayerViewController()
            vc.player = AVPlayer.init(url: URL.init(fileURLWithPath: (videoPath)))
            vc.player?.play()
            self.present( vc, animated: true) {
            }
        }
 
    }
}


// MARK: - private methods

private extension DownloadViewCtrl {

}
