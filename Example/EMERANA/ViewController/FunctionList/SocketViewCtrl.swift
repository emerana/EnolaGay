//
//  SocketViewCtrl.swift
//  emerana
//
//  Created by 艾美拉娜 on 2018/10/17.
//  Copyright © 2018 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import SocketRocket

/// Socket 使用
class SocketViewCtrl: JudyBaseViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet

    // MARK: - public var property - 公开var

    override var viewTitle: String? {
        return "Socket"
    }

    // MARK: - private var property - 私有var

    var socket = SRWebSocket.init(urlRequest: URLRequest.init(url: URL.init(string: "ws://47.244.35.32:8111/websocket")!))

    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket?.delegate = self

        socket?.open()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - override - 重写重载父类的方法

    // MARK: - Intial Methods - 初始化的方法
    
    // MARK: - Target Methods - 点击事件或通知事件

    // MARK: - Event response - 响应事件
    
    // MARK: - Delegate - 代理事件，将所有的delegate放在同一个pragma下
    
    // MARK: - Method - 私有方法的代码尽量抽取创建公共class。

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - SRWebSocketDelegate
extension SocketViewCtrl: EMERANASocket {
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        Judy.log("收到消息\(String(describing: message))")
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        Judy.log("连接成功")
        
        // 向服务器发送以下消息 trade.btcusdt
        let json = JSON(["type":"kline.btcusdt.1min", "id":"s9b9wW+QMNYloQYTl33s7Q=="])
        socket?.send(json.rawString())
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        Judy.log("连接失败:\(error.localizedDescription)")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        Judy.log("连接被关闭")
        
    }

}

/*
 所有订阅的值
 kline开头的是k线，
 trade开头的是k线中的分时线
 
 kline.btcusdt.1min
 kline.btcusdt.5min
 kline.btcusdt.15min
 kline.btcusdt.30min
 kline.btcusdt.60min
 kline.btcusdt.1day
 kline.btcusdt.1mon
 kline.btcusdt.1week
 kline.btcusdt.1year
 kline.ethusdt.1min
 kline.ethusdt.5min
 kline.ethusdt.15min
 kline.ethusdt.30min
 kline.ethusdt.60min
 kline.ethusdt.1day
 kline.ethusdt.1mon
 kline.ethusdt.1week
 kline.ethusdt.1year
 kline.eosusdt.1min
 kline.eosusdt.5min
 kline.eosusdt.15min
 kline.eosusdt.30min
 kline.eosusdt.60min
 kline.eosusdt.1day
 kline.eosusdt.1mon
 kline.eosusdt.1week
 kline.eosusdt.1year
 kline.xrpusdt.1min
 kline.xrpusdt.5min
 kline.xrpusdt.15min
 kline.xrpusdt.30min
 kline.xrpusdt.60min
 kline.xrpusdt.1day
 kline.xrpusdt.1mon
 kline.xrpusdt.1week
 kline.xrpusdt.1year
 kline.bchusdt.1min
 kline.bchusdt.5min
 kline.bchusdt.15min
 kline.bchusdt.30min
 kline.bchusdt.60min
 kline.bchusdt.1day
 kline.bchusdt.1mon
 kline.bchusdt.1week
 kline.bchusdt.1year
 kline.ltcusdt.1min
 kline.ltcusdt.5min
 kline.ltcusdt.15min
 kline.ltcusdt.30min
 kline.ltcusdt.60min
 kline.ltcusdt.1day
 kline.ltcusdt.1mon
 kline.ltcusdt.1week
 kline.ltcusdt.1year
 kline.adausdt.1min
 kline.adausdt.5min
 kline.adausdt.15min
 kline.adausdt.30min
 kline.adausdt.60min
 kline.adausdt.1day
 kline.adausdt.1mon
 kline.adausdt.1week
 kline.adausdt.1year
 kline.neousdt.1min
 kline.neousdt.5min
 kline.neousdt.15min
 kline.neousdt.30min
 kline.neousdt.60min
 kline.neousdt.1day
 kline.neousdt.1mon
 kline.neousdt.1week
 kline.neousdt.1year
 kline.etcusdt.1min
 kline.etcusdt.5min
 kline.etcusdt.15min
 kline.etcusdt.30min
 kline.etcusdt.60min
 kline.etcusdt.1day
 kline.etcusdt.1mon
 kline.etcusdt.1week
 kline.etcusdt.1year
 kline.trxusdt.1min
 kline.trxusdt.5min
 kline.trxusdt.15min
 kline.trxusdt.30min
 kline.trxusdt.60min
 kline.trxusdt.1day
 kline.trxusdt.1mon
 kline.trxusdt.1week
 kline.trxusdt.1year
 trade.btcusdt
 trade.ethusdt
 trade.eosusdt
 trade.xrpusdt
 trade.bchusdt
 trade.ltcusdt
 trade.adausdt
 trade.neousdt
 trade.etcusdt
 trade.trxusdt
 trade.list

 这个是对应的10个交易价

 trade.list.btcusdt
 trade.list.ethusdt
 trade.list.eosusdt
 trade.list.xrpusdt
 trade.list.bchusdt
 trade.list.ltcusdt
 trade.list.adausdt
 trade.list.neousdt
 trade.list.etcusdt
 trade.list.trxusdt
 */
