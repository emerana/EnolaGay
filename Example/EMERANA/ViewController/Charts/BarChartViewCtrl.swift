//
//  BarChartViewCtrl.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import EnolaGay
import Charts

/// 条形图
class BarChartViewCtrl: ChartsBaseViewCtrl {
    
    @IBOutlet var chartView: BarChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Bar Chart"
        
        self.options = [.toggleValues,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleData,
                        .toggleBarBorders]
        
        self.setup(barLineChartView: chartView)
        
        chartView.delegate = self
        // 如果设置为true，则在每个条后面绘制一个灰色区域，表示最大值
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.maxVisibleCount = 10
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"

        // 配置x轴
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DateValueFormatter() //DayAxisValueFormatter(chart: chartView)
        /// X 轴线颜色
        xAxis.axisLineColor = .red
//        xAxis.axisLineDashLengths = [0]
//        xAxis.drawAxisLineEnabled = true
//        xAxis.gridColor = .red
        // 网格线宽度
        xAxis.gridLineWidth = 0

        // 左侧轴
        let leftAxis = chartView.leftAxis
        leftAxis.enabled = false
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        // 右侧轴
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        // 图标下方图标
        let l = chartView.legend
        l.enabled = false
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
//        chartView.legend = l

        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        // 在图表上单击某个值时显示的标记
        chartView.marker = marker
        
//        sliderX.value = 12
//        sliderY.value = 50
//        slidersValueChanged(nil)
        setDataCount(8, range: 28)
    }
    
//    override func updateChartData() {
//        if self.shouldHideData {
//            chartView.data = nil
//            return
//        }
//
//        self.setDataCount(Int(sliderX.value) + 1, range: UInt32(sliderY.value))
//    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let yVals = (1..<count + 1).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))

            return BarChartDataEntry(x: Double(i), y: val)
        }
        
//        var set1: BarChartDataSet! = nil
//        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
//            set1 = set
//            //            不知为何报错
//            //            set1.values = yVals
//            chartView.data?.notifyDataChanged()
//            chartView.notifyDataSetChanged()
//        } else {
//            // 不知为何报错
//            //            set1 = BarChartDataSet(values: yVals, label: "The year 2017")
//            set1.colors = [UIColor.blue]  //ChartColorTemplates.material()
//            set1.drawValuesEnabled = false
//            
//            let data = BarChartData(dataSet: set1)
//            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
//            data.barWidth = 0.9
//            
//            chartView.data = data
//        }
        
//        chartView.setNeedsDisplay()
    }
    
    override func optionTapped(_ option: Option) {
        super.handleOption(option, forChartView: chartView)
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
//        sliderTextX.text = "\(Int(sliderX.value + 2))"
//        sliderTextY.text = "\(Int(sliderY.value))"
//
//        self.updateChartData()
    }
}
