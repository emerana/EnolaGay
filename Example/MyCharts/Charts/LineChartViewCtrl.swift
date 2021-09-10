//
//  LineChartViewCtrl.swift
//  emerana
//
//  Created by 醉翁之意 on 2018/11/27.
//  Copyright © 2018 艾美拉娜.王仁洁. All rights reserved.
//

import Foundation
import Charts

/// 折线图界面
class LineChartViewCtrl: UIViewController {
    // 折线图
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //生成20条随机数据
        var dataEntries = [ChartDataEntry]()
        for i in 0..<20 {
            let y = arc4random()%100
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            dataEntries.append(entry)
        }
        //这50条数据作为1根折线里的所有数据
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "图例1")

        // 描绘折现下方的区域颜色
        let gradientColors = [UIColor.blue.cgColor, UIColor.blue.cgColor]
        // 注意，至少要大于两个颜色
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        chartDataSet.fillAlpha = 1
        chartDataSet.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        chartDataSet.drawFilledEnabled = true
        // 禁止折线出的小圆点
        chartDataSet.drawCirclesEnabled = false
        // 折线颜色
        chartDataSet.setColor(UIColor.red)
        
        //折线图只包括1根折线
        let chartData = LineChartData(dataSets: [chartDataSet])
        //设置折现图数据
        lineChartView.data = chartData

        // 配置x轴
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DateValueFormatter() //DayAxisValueFormatter(chart: chartView)
        /// X 轴线颜色
        xAxis.axisLineColor = .red
        xAxis.gridLineWidth = 0

        
        // 左侧轴
        let leftAxis = lineChartView.leftAxis
        leftAxis.enabled = true
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        leftAxis.axisLineWidth = 0

        // 右侧轴
        let rightAxis = lineChartView.rightAxis
        rightAxis.enabled = false

        
    }
    
}
