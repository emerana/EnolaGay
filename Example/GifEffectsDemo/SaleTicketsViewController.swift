//
//  SaleTicketsViewController.swift
//  GifEffectsDemo
//
//  Created by 醉翁之意 on 2023/3/20.
//  Copyright © 2023 EnolaGay. All rights reserved.
//

import UIKit
import EnolaGay

/// 模拟多线程卖火车票场景
class SaleTicketsViewController: UIViewController {

    @IBOutlet weak private var likeButton: UIButton!

    /// 爱心动画计时器。
    private var animateTimer: Timer?
    
    /// 剩余火车票数量
    @IBOutlet weak private var tickerNumbersLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 恢复计时器
        animateTimer?.fireDate = Date()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 暂停计时器
        animateTimer?.fireDate = Date.distantFuture
    }

    deinit {
        animateTimer?.invalidate()
        animateTimer = nil
    }

    /// 开始购买事件
    @IBAction private func startAction(_ sender: Any) {
        startAnimateTimer()
        
         //onStart()
        // concurrentDispatchQueue()
        // notify()
//         downloadAction()
//         saleTickerDemo()
//        mySemaphore()
        startSaleTickets()
    }
    
    // 烟花爆炸效果
    @IBAction private func emitAction(_ sender: Any) {
        emitFireworks(launcher: sender as! UIView)
    }

}

// 动画特效部分
private extension SaleTicketsViewController {
    
    /// 启动爱心飘动的动画
    func startAnimateTimer() {
        let imageNames = ["icon_点赞1", "icon_点赞2", "icon_点赞3", "icon_点赞4", "icon_点赞5", ]
        let judyPopBubble = JudyPopBubble(inView: view, belowSubview: likeButton)
        judyPopBubble.bubble_animate_dissmiss = 5
        judyPopBubble.bubble_animate_windUp = 6
        judyPopBubble.bubble_animate_height = view.frame.height - 68
        
        /// 计时器两次触发之间的秒数。如果 interval 小于或等于0.0，则该方法选择 0.0001 秒的非负值。
        let interval = Double(1+arc4random_uniform(3))/10
        // 创建计时器，并以默认模式在当前运行循环中调度它。
        animateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            // 随机挑选一张图片
            if let image = UIImage(named: imageNames[NSInteger(arc4random_uniform( UInt32((imageNames.count)) ))]) {
                judyPopBubble.popBubble(image)
            }
        }
    }
    
    /// 发射一朵烟花
    /// - Parameter launcher: 发射台。此 View 表示烟花从哪个位置发射的。
    func emitFireworks(launcher: UIView) {
        let blingImageView = UIImageView(image: UIImage(named: "button_喜欢"))
        blingImageView.frame.size = CGSize(width: 18, height: 18)
        // 设置烟花的起始中心位置为发射台的中心位置。
        // 转换规则为发射台的父 View 将发射台的位置转换成指定 View 上的坐标。
        blingImageView.center = launcher.superview!.convert(launcher.center, to: view)
        view.addSubview(blingImageView)
        
        // 发射并爆炸
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { [weak self] in
            guard let `self` = self else { return }
            // 用动画的方式移动烟花的位置，位置为屏幕中的随机点
            blingImageView.center = CGPoint(
                x: CGFloat(arc4random_uniform(UInt32(self.view.bounds.width))),
                y: CGFloat(arc4random_uniform(UInt32(self.view.bounds.height)))
            )
        }) { _ in
            // 执行烟花爆炸，并在爆炸效果完成后从父视图中移除。
            blingImageView.judy.blingBling {
                blingImageView.removeFromSuperview()
            }
        }
    }
}

// GCD 部分
private extension SaleTicketsViewController {

    /// 开始模拟销售火车票同步
    func startSaleTickets() {
        var tickerCounts = 100 {
            didSet {
                logt(type: .🟢, "卖掉了一张票，还剩：\(tickerCounts)张")
                DispatchQueue.main.async { [weak self] in
                    if tickerCounts == 0 {
                        self?.tickerNumbersLabel.text = "没票啦"
                    } else {
                        self?.tickerNumbersLabel.text = "剩余火车票：\(tickerCounts)"
                    }
                }

            }
        }
        
        // 创建一个并发队列
        let saleQueue = DispatchQueue(label: "saleQueue", qos: .default, attributes: .concurrent)
        // 创建信号量，限制对同一资源的访问线程数量。若初始化信号量时就小于0，则遇到 wait() 就会崩溃。
        let semaphore = DispatchSemaphore(value: 1)

        saleQueue.async {
            log("开启售票……")
            // 开启多条线程同时售票
            for i in 1...6 {
                // 异步执行
                saleQueue.async {
                    Thread.current.name = "\(i)号窗口"
                    while(true) {
                        semaphore.wait()
                        let s = arc4random()%2/10
                        if tickerCounts > 0 {
                            logt("出票中……，预计耗时：\(s) 秒")
                            sleep(s)
                            tickerCounts -= 1
                        } else {
                            logWarning("票已售完")
                            semaphore.signal()
                            break
                        }
                        semaphore.signal()
                    }
                }
            }
        }
    }
    
    /// 信号量测试
    ///
    ///     # wait() 是减1操作，不过这个减1操作的前提是信号量是否大于0：
    ///         * 大于0，线程继续往下跑，然后紧接在 wait() 后才对信号量减1；
    ///         * 等于0，线程休眠，加入到一个都等待这个信号的线程队列当中；
    ///         * 当信号总量为 0 时就会一直等待（阻塞所在线程）；
    ///     # signal() 是对信号量的加 1 操作，signal() 可以任意添加信号量，初始化的信号量是可以随意更改的；
    ///         * 当信号量 >0 时会唤醒这个等待队列中靠前的线程，并继续执行 wait() 后面的代码且对信号量减1，也就确保了信号量大于0才减1；
    ///         * 一般地，signal() 和 wait() 成对使用，signal() 用了几次 wait() 也要用几次。
    /// - Warning: 不存在信号量小于0的情况，除非在初始化时将信号量设置为负数，不过这样做的话运行时程序就会崩溃；
    func onStart() {
        /**
         Dispatch Semaphore 说明：
         
         # GCD 中的信号量是指 Dispatch Semaphore，是持有计数的信号。
            Dispatch Semaphore 在实际开发中主要用于：
             * 保持线程同步，将异步执行任务转换为同步执行任务
             * 保证线程安全，为线程加锁
             * 用于多线程对共享资源的访问控制，保证线程安全，为线程加锁。
             * 保持线程同步，将异步任务转换为同步任务。

         简单来说，信号量起到对多线程调用资源的监管作用。
         在线程安全中可以将 semaphore.wait() 看作加锁，而 semaphore.signal() 看作解锁

         # Dispatch Semaphore 提供了三个函数

         # DispatchSemaphore(value:)
         创建一个Semaphore并初始化信号的总量，构造信号量时传入的初始计数器数值不允许为负值。传入0时一般用于将异步任务转成同步任务，数值大于0时代表最多允许多少个线程同时访问共享资源或者同时执行多少个任务。
         访问共享资源之前调用wait方法。wait方法可以理解为当前线程在请求对共享资源的访问，如果资源可用（未被其他线程占用）则允许访问，否则等待（阻塞线程）。
         访问共享资源结束之后调用signal方法。结束访问时，要通知信号量，我用完了资源，让别人（等待着的线程）来访问吧。

         # semaphore.wait()
         将信号量减1并执行，当前线程再请求对共享资源的访问，如果资源可用（未被其他线程占用）则允许访问，否则等待（阻塞线程）。
         该函数会判断信号量，如果 >0 ，对信号量减1并执行，当信号总量为0就会一直等待（阻塞所在线程）无法减1。通过此函数表示当前线程占用了该资源，其他线程执行到此发现信号总量为 0 就会一直等待（阻塞所在线程）。
         wait 方法有一个等待超时时间参数（尤其注意参数是.distantFuture（无限期等待下去）情况下不要在主线程中调用wait方法，可能将阻塞主线程。）
         调用 wait 计数器即-1，等待结果为 success 时，计数器保持不变，由 signal 负责回归计数器，但是如果等待结果是 timedOut，计数器将自动 +1 回归，因此，应只在结果是 success 时才执行 signal 操作。

         调用 wait 方法时，行为规则如下：

         计数器-1；
         如果-1之后，当前计数器小于0，则线程被阻塞；
         如果-1之后，当前计数器大于等于0，则线程被放行，无需等待；
         
         调用 signal 方法时，行为规则如下：

         计数器+1；
         如果+1之前，计数器小于0，此方法将从线程队列中按照FIFO规则提取第一个等待中的线程并唤醒。
         如果+1之前，计数器大于等于0，说明线程队列是空的，没有正在等待的线程。


         # semaphore.signal()
         信号量加1，表示资源访问完毕，解锁以便其他线程访问。访问共享资源结束之后调用signal方法。结束访问时，要通知信号量，我用完了资源，让别人（等待着的线程）来访问吧。
         
         */
        
        log("进入信号量测试……")
        
        DispatchQueue.global().async {
            log("onStart")
            
            // 创建信号量，若初始化信号量时就小于0，则遇到 semaphore.wait() 就会崩溃
            let semaphore = DispatchSemaphore(value: 0)
            
            // 异步执行
            DispatchQueue.global().async {
                log("任务A执行中……")
                sleep(8)
                log("任务A执行完毕！")
                
                semaphore.signal()  // 信号量+1
            }
            
            DispatchQueue.global().async {
                
                log("任务B执行中……")
                sleep(10)
                log("任务B执行完毕！")
                
                semaphore.signal()  // 信号量+1
            }
            // 因为有两个任务在做，所以需要等待两个
            semaphore.wait()
            semaphore.wait()
            
            // 信号量 >0 了，等待结束，线程继续……
            log("over")
        }
        
    }

}

// 并发部分
private extension SaleTicketsViewController {
    
    // MARK: - 并发队列，模拟多线程下载数据
    
    /// 用并发队列模拟多个线程下载数据
    func concurrentDispatchQueue() {
        let downloadQueue = DispatchQueue(label: "downloadQueue", attributes: .concurrent)
        
        for i in 1...10 {
            downloadAction(index: i, dispatchQueue: downloadQueue)
        }
        logWarning("一来就下载任务完成")
        
        /// 使用目标队列执行一个下载任务。
        func downloadAction(index: Int, dispatchQueue: DispatchQueue) {
            dispatchQueue.async {
                Thread.current.name = "线程：\(index)"
                logt("任务开始……")
                sleep(6)
                logt(type: .🟢, "任务完成。")
            }
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
            // 取余 11
            let s = arc4random()%11
            logt("执行下载任务，预计耗时：\(s) 秒")
            sleep(s)
        }
        // 任务通知到队列
        downloadAction.notify(queue: downloadQueue) {
            log("队列下载任务完成！")
        }
        // 执行任务
        downloadQueue.async(execute: downloadAction)
        
        logt("队列开始执行")
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
                    Thread.current.name = "第\(i)线程"
                    let s = arc4random()%9
                    logt("开始下载任务，预计耗时：\(s) 秒")
                    sleep(s)
                    logt("下载完成，耗时：\(s) 秒")
                    semaphore.signal()
                }
                logt("安排了第\(i)个下载任务")
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
    
    /// 模拟下载多个追加数据
    func appendDownloadAction(maxSemaphore: Int = 3) {
        
        let semaphore = DispatchSemaphore(value: maxSemaphore)
        
        /// 下载的任务组
        let manualGroup = DispatchGroup()
        
        // 创建一个并发队列
        let downloadQueue = DispatchQueue(label: "downloadQueue", attributes: .concurrent)
        
        for _ in 1...30 {
            addDownload(group: manualGroup, dispatchQueue: downloadQueue, semaphore: semaphore)
        }
        
        manualGroup.notify(queue: DispatchQueue.main) {
            print("任务组中所有任务均已完成！")
        }
        
        logt("任务组开始执行了")
        
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
}
