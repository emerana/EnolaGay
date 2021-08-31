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
        
        saleTickets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
}


// MARK: - Private Methods

private extension SemaphoreViewCtrl {
    
    /// 售票函数，模拟售卖火车票同步。
    func saleTickets() {
        
        DispatchQueue.global().async {
            var numbers = 100 {
                didSet {
                    print("卖出一张票了，还有\(numbers)张票！")
                }
            }
            // 最多允许多少个线程同时访问共享资源或者同时执行多少个任务。
            let semaphore = DispatchSemaphore(value: 2)
            
            for index in 1...102 {
                DispatchQueue.global().async {
                    semaphore.wait()
                    print("第\(index)位用户开始抢票……")
                    
                    if numbers <= 0 {
                        print("没票啦！！！")
                        semaphore.signal()
                        return
                    }
                    numbers -= 1
                    semaphore.signal()
                }
            }
        }

    }

    /// 启动信号量
    /// * Warning:不存在信号量小于0的情况，除非在初始化时将信号量设置为负数，不过这样做的话运行时程序就会崩溃；
    ///     # wait() 是减1操作，不过这个减1操作的前提是信号量是否大于0：
    ///     * 大于0，线程继续往下跑，然后紧接在 wait() 后才对信号量减1；
    ///     * 等于0，线程休眠，加入到一个都等待这个信号的线程队列当中；
    ///     * 当信号总量为 0 时就会一直等待（阻塞所在线程）；
    ///     # signal() 是对信号量的加 1 操作，signal() 可以任意添加信号量，初始化的信号量是可以随意更改的；
    ///     * 当信号量 >0 时会唤醒这个等待队列中靠前的线程，并继续执行 wait() 后面的代码且对信号量减1，也就确保了信号量大于0才减1；
    ///      * 一般地，signal() 和 wait() 成对使用，signal() 用了几次 wait() 也要用几次。
    func onstart() {
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
        
        Judy.log("进入信号量测试……")
        
        DispatchQueue.global().async {
            Judy.log("onstart")
            
            // 创建信号量，若初始化信号量时就小于0，则遇到 semaphore.wait() 就会崩溃
            let semaphore = DispatchSemaphore(value: 0)
            
            // 异步执行
            DispatchQueue.global().async {
                
                Judy.log("任务A执行中……")
                sleep(8)
                Judy.log("任务A执行完毕！")
                
                semaphore.signal()  // 信号量+1
            }
            
            DispatchQueue.global().async {
                
                Judy.log("任务B执行中……")
                sleep(10)
                Judy.log("任务B执行完毕！")
                
                semaphore.signal()  // 信号量+1
            }
            
            semaphore.wait()
            semaphore.wait()
            
            // 信号量 >0 了，等待结束，线程继续……
            
            Judy.log("over")
        }
        
    }
    
    
}
