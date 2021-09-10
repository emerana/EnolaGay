//
//  KLineViewCtrl.swift
//  emerana
//
//  Created by 艾美拉娜 on 2018/10/18.
//  Copyright © 2018 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay
import SwiftyJSON

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height

/// K线图示例
class KLineViewCtrl: JudyBaseViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet
    @IBOutlet private weak var segmentMenu: SegmentMenu!
    
    @IBOutlet private weak var showView: UIView!
    
    // MARK: - public var property - 公开var
    
    var controllerArray : [ChartViewController] = []

//    var socket = SRWebSocket.init(urlRequest: URLRequest.init(url: URL.init(string: "ws://47.244.35.32:8111/websocket")!))

    override var viewTitle: String? {
        return "K线图"
    }

    // MARK: - private var property - 私有var
    
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        socket?.delegate =  self
//        socket?.open()
        
        addChartController()
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K"]
        segmentMenu.delegate = self

//        addNoticficationObserve()
        segmentMenu.setSelectButton(index: 0)
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
    
    func addChartController() {
        // 分时线
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        controllerArray.append(timeViewcontroller)
        
        // 五日分时线
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        controllerArray.append(fiveDayTimeViewController)
        
        // 日 K 线
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        controllerArray.append(kLineViewController)
        
        // 周 K 线
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        controllerArray.append(weeklyKLineViewController)
        
        // 月 K 线
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        controllerArray.append(monthlyKLineViewController)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    deinit {
//        socket?.close()
        print("释放")
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

extension KLineViewCtrl: SegmentMenuDelegate {
    
    /// 选择事件
    ///
    /// - Parameter index: 索引
    func menuButtonDidClick(index: Int) {

        showView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        var view = UIView()
        if index != 0 {
            
            view = HSKLineView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: showView.frame.size), kLineType: .kLineForDay)

            let jsonFile = "kLineForDay"
            let allDataK = getKLineModelArray(getJsonDataFromFile(jsonFile))
            let tmpDataK = Array(allDataK[allDataK.count-70..<allDataK.count])
            (view as! HSKLineView).configureView(data: tmpDataK)
            
        } else {
            view = HSTimeLine(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: showView.frame.size))
            //        timeLineView?.dataT = modelArray
            view.isUserInteractionEnabled = true
            //        view?.tag = chartType.rawValue
            //        timeLineView?.isLandscapeMode = self.isLandscapeMode
        }

        view.isUserInteractionEnabled = true

        showView.addSubview(view)
    }

}


//extension KLineViewCtrl: EMERANASocket {
//
//    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
//        Judy.log("收到消息\(String(describing: message))")
//
//        let str = message as! String
//        guard let messageData = str.data(using: .utf8, allowLossyConversion: false) else {
//            return
//        }
//
//        let data = JSON(messageData)
//        if data["data"].null == nil {
//
////            let timeLineView = showView.subviews.last as? HSTimeLine
////
//////            let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
////            //            let modelArray = getTimeLineModelArray(getJsonDataFromFile("timeLineForDay"), type: .timeLineForDay, basicInfo: stockBasicInfo)
////            let modelArray = getTimeLineList(json: data)
////
////            timeLineView?.dataT = modelArray
//
//
//            // K线
////            let kLineView = showView.subviews.last as? HSKLineView
////
////            let dataK = getKLineList(json: data)
////            kLineView?.configureView(data: dataK)
//
//        }
//    }
//
//    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
//        Judy.log("连接成功")
//
//        // 向服务器发送以下消息
//        let json = JSON(["type":"kline.btcusdt.1min", "id":"s9b9wW+QMNYloQYTl33s7Q=="])
//        socket?.send(json.rawString())
//    }
//
//    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
//        Judy.log("连接失败:\(error.localizedDescription)")
//    }
//
//    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
//        Judy.log("连接被关闭")
//
//    }
//
//}

extension KLineViewCtrl {
    
    func getTimeLineList(json: JSON) -> [HSTimeLineModel] {
        
        return json["data"].arrayValue.map({ data in
            let model = HSTimeLineModel()
            model.time = Date.hschart.toDate(data["date"].stringValue, format: "HH:mm:ss SSS").hschart.toString("HH:mm")
//            model.avgPirce = CGFloat(data["price"].doubleValue)
            model.price = CGFloat(data["price"].doubleValue)
            model.volume = CGFloat(data["amount"].doubleValue)
            //            model.rate = (model.price - toComparePrice) / toComparePrice
            model.preClosePx = CGFloat(data["price"].doubleValue)
            model.days = (data["days"].arrayObject as? [String]) ?? [""]

            return model
        })
    }
    
    func getTimeLineModelArray(_ json: JSON, type: HSChartType, basicInfo: HSStockBasicInfoModel) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
//        var toComparePrice: CGFloat = 0
        
//        if type == .timeLineForFiveday {
//            toComparePrice = CGFloat(json["chartlist"][0]["current"].doubleValue)
//
//        } else {
//            toComparePrice = basicInfo.preClosePrice
//        }
        
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = Date.hschart.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").hschart.toString("HH:mm")
//            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
//            model.rate = (model.price - toComparePrice) / toComparePrice
            model.preClosePx = CGFloat(jsonData["current"].doubleValue)
//            model.preClosePx = basicInfo.preClosePrice
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        
        return modelArray
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        
        do {
            return try JSON(data: jsonContent)
            
        } catch {
            return JSON()
        }
    }

    func getKLineModelArray(_ json: JSON) -> [HSKLineModel] {
        var models = [HSKLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSKLineModel()
            model.date = Date.hschart.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").hschart.toString("yyyyMMddHHmmss")
            model.open = CGFloat(jsonData["open"].doubleValue)
            model.close = CGFloat(jsonData["close"].doubleValue)
            model.high = CGFloat(jsonData["high"].doubleValue)
            model.low = CGFloat(jsonData["low"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.ma5 = CGFloat(jsonData["ma5"].doubleValue)
            model.ma10 = CGFloat(jsonData["ma10"].doubleValue)
            model.ma20 = CGFloat(jsonData["ma20"].doubleValue)
            model.ma30 = CGFloat(jsonData["ma30"].doubleValue)
            model.diff = CGFloat(jsonData["dif"].doubleValue)
            model.dea = CGFloat(jsonData["dea"].doubleValue)
            model.macd = CGFloat(jsonData["macd"].doubleValue)
            model.rate = CGFloat(jsonData["percent"].doubleValue)
            models.append(model)
        }
        return models
    }
    
    func getKLineList(json: JSON) -> [HSKLineModel] {
        
        
        return json["data"].arrayValue.map({ data in
            let model = HSKLineModel()
            model.date = Date.hschart.toDate(data["date"].stringValue, format: "MM-dd HH:mm").hschart.toString("HH:mm")
            /*
             
             "amount" : 10.4316,
             "id" : 0,
             "high" : 6602.2200000000003,
             "vol" : 68822.289999999994,
             "date" : "01-19 03:45",
             "count" : 82,
             "open" : 6600.1899999999996,
             "low" : 6595.3500000000004,
             "close" : 6597.8699999999999

             */
            model.open = CGFloat(data["open"].doubleValue)
            model.close = CGFloat(data["close"].doubleValue)
            model.high = CGFloat(data["high"].doubleValue)
            model.low = CGFloat(data["low"].doubleValue)
            model.volume = CGFloat(data["amount"].doubleValue)
//            model.ma5 = CGFloat(data["ma5"].doubleValue)
//            model.ma10 = CGFloat(data["ma10"].doubleValue)
//            model.ma20 = CGFloat(data["ma20"].doubleValue)
//            model.ma30 = CGFloat(data["ma30"].doubleValue)
//            model.diff = CGFloat(data["dif"].doubleValue)
//            model.dea = CGFloat(data["dea"].doubleValue)
//            model.macd = CGFloat(data["macd"].doubleValue)
            model.rate = 10//CGFloat(data["percent"].doubleValue)

            return model
        })

        /*
         var models = [HSKLineModel]()
         for (_, jsonData): (String, JSON) in json["chartlist"] {
         let model = HSKLineModel()
         model.date = Date.hschart.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").hschart.toString("yyyyMMddHHmmss")
         model.open = CGFloat(jsonData["open"].doubleValue)
         model.close = CGFloat(jsonData["close"].doubleValue)
         model.high = CGFloat(jsonData["high"].doubleValue)
         model.low = CGFloat(jsonData["low"].doubleValue)
         model.volume = CGFloat(jsonData["volume"].doubleValue)
         model.ma5 = CGFloat(jsonData["ma5"].doubleValue)
         model.ma10 = CGFloat(jsonData["ma10"].doubleValue)
         model.ma20 = CGFloat(jsonData["ma20"].doubleValue)
         model.ma30 = CGFloat(jsonData["ma30"].doubleValue)
         model.diff = CGFloat(jsonData["dif"].doubleValue)
         model.dea = CGFloat(jsonData["dea"].doubleValue)
         model.macd = CGFloat(jsonData["macd"].doubleValue)
         model.rate = CGFloat(jsonData["percent"].doubleValue)
         models.append(model)
         }
         return models
         */
    }


}
