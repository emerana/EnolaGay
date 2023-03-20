//
//  SemaphoreViewCtrl.swift
//  emerana
//
//  Created by 王仁洁 on 2020/8/28.
//  Copyright © 2020 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// 信号量演示 view controllers
class SemaphoreViewCtrl: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // saleTickets()
        // onstart()
//        notify()
        downloadAction(maxSemaphore: 3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
}


// MARK: - Private Methods

extension SemaphoreViewCtrl {
    // MARK: - 并发队列，模拟多线程下载数据

    /// 用并发队列模拟多个线程下载数据
    func concurrentDispatchQueue() {
        let downloadQueue = DispatchQueue(label: "downloadQueue", attributes: .concurrent)

        for _ in 0...100 {
            downloadAction(dispatchQueue: downloadQueue)
        }
        print("下载任务完成")
    }

    /// 使用目标队列执行一个下载任务。
    func downloadAction(dispatchQueue: DispatchQueue) {
        dispatchQueue.async {
            //Thread.current.name = "线程任务"
            print("\(Thread.current) 任务开始……")
            sleep(3)
            print("\(Thread.current) 任务完成……")
        }

    }

    // MARK: - 并发队列测试

    /// 监听任务的执行是否完成
    func notify() {
        // 创建一个并发队列
        let downloadQueue = DispatchQueue(label: "downloadQueue", attributes: .concurrent)

        /// 下载任务
        let downloadAction = DispatchWorkItem {
            Thread.current.name = "下载线程"
            let s = arc4random()%9
            print("\(Thread.current) 开始下载任务，预计耗时：\(s) 秒")
            sleep(s)
        }
        
        downloadAction.notify(queue: downloadQueue) {
            print("\(Thread.current) 下载任务全部完成！")
        }
        downloadQueue.async(execute: downloadAction)

        print("\(Thread.current)")
    }


    /// 模拟下载多个数据
    func downloadAction(maxSemaphore: Int = 3) {
        // 创建一个并发队列
        let downloadQueue = DispatchQueue(label: "downloadQueue", attributes: .concurrent)
        
        /// 下载任务
        let downloadAction = DispatchWorkItem {
            let semaphore = DispatchSemaphore(value: 0)

            for i in 1...maxSemaphore {
                downloadQueue.async {
                    Thread.current.name = "下载线程\(i)"
                    let s = arc4random()%9
                    print("\(Thread.current) 开始下载任务，预计耗时：\(s) 秒")
                    sleep(s)
                    print("\(Thread.current) 下载完成，耗时：\(s) 秒")
                    semaphore.signal()
                }
                log("执行了第\(i)个下载任务")
            }
            for i in 1...maxSemaphore {
                semaphore.wait()
                log("等待第\(i)次")
            }
        }
        
        downloadAction.notify(queue: downloadQueue) {
            logHappy("\(Thread.current) 下载任务全部完成！")
        }
        
        downloadQueue.async(execute: downloadAction)
        
        print("\(Thread.current)")
    }


    // MARK: - 队列组

    /// 自动任务组测试。
    func autoDispatchGroup() {
        let group = DispatchGroup()
        
        DispatchQueue.global().async(group: group) {
            print("任务1执行中……")
            sleep(3)
        }
        DispatchQueue.global().async(group: group) {
            print("任务2执行中……")
            sleep(2)
        }
        DispatchQueue.global().async(group: group) {
            print("任务3执行中……")
            sleep(4)
        }

        group.notify(queue: DispatchQueue.main) {
            print("任务组中所有任务均已完成！")
        }
        print("\(Thread.current)")
    }

    /// 手动任务组测试。
    func manualDispatchGroup() {
        let manualGroup = DispatchGroup()

        manualGroup.enter()

        DispatchQueue.global().async {
            print("任务1执行中……")
            sleep(3)
            manualGroup.leave()
        }
        DispatchQueue.global().async {
            print("任务2执行中……")
            sleep(2)
            manualGroup.leave()
        }
        DispatchQueue.global().async {
            print("任务3执行中……")
            sleep(4)
            manualGroup.leave()
        }

        manualGroup.notify(queue: DispatchQueue.main) {
            print("任务组中所有任务均已完成！")
        }
        print("\(Thread.current)")
    }


    // MARK: - 模拟下载多个追加数据


    /// 模拟下载多个追加数据。
    func appendDownloadAction(maxSemaphore: Int = 3) {
        
        let semaphore = DispatchSemaphore(value: maxSemaphore)
        /// 下载的任务组。
        let manualGroup = DispatchGroup()

        // 创建一个并发队列。
        let downloadQueue = DispatchQueue(label: "downloadQueue", attributes: .concurrent)
        
        for _ in 1...30 {
            addDownload(group: manualGroup, dispatchQueue: downloadQueue, semaphore: semaphore)
        }
        
        manualGroup.notify(queue: DispatchQueue.main) {
            print("任务组中所有任务均已完成！")
        }
        
        print("\(Thread.current)")
    }

    func addDownload(group: DispatchGroup, dispatchQueue: DispatchQueue, semaphore: DispatchSemaphore) {
        group.enter()
        dispatchQueue.async {
            semaphore.wait()
            Thread.current.name = "下载线程"
            let s = arc4random()%9
            print("\(Thread.current) 开始下载任务，预计耗时：\(s) 秒")
            sleep(s)
            print("\(Thread.current) 下载完成")
            group.leave()
            semaphore.signal()
        }
    }

}
