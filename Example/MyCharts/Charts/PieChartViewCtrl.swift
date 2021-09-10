//
//  PieChartViewCtrl.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import EnolaGay
import Charts

/// 馅饼图
class PieChartViewCtrl: ChartsBaseViewCtrl {

    @IBOutlet var chartView: PieChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Pie Chart"
        
        self.options = [.toggleValues,
                        .toggleXValues,
                        .togglePercent, 
                        .toggleHole,
                        .toggleIcons,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .spin,
                        .drawCenter,
                        .saveToGallery,
                        .toggleData]
        
        self.setup(pieChartView: chartView)
        
        chartView.delegate = self
        
        // 图标
        let l = chartView.legend
//        l.enabled = false
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0

        
        // 这是啥 entry label styling
        chartView.entryLabelColor = .black
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        
        // 不要洞
        chartView.drawHoleEnabled = false
        chartView.drawCenterTextEnabled = false
        
        
//        sliderX.value = 4
//        sliderY.value = 100
//        self.slidersValueChanged(nil)
        self.setDataCount(2, range: 100)

//        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4)

    }
    
//    override func updateChartData() {
//        if self.shouldHideData {
//            chartView.data = nil
//            return
//        }
//
//        self.setDataCount(Int(sliderX.value), range: UInt32(sliderY.value))
//    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        
//        let entries = (0..<count).map { (i) -> PieChartDataEntry in
//            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
//            return PieChartDataEntry(value: Double(arc4random_uniform(range) + range / 5),
//                                     label: parties[i % parties.count],
//                                     icon: #imageLiteral(resourceName: "stopwatch-1"))
//        }
        let entries = [
            PieChartDataEntry(value: 25, label: "错误率25%"),
            PieChartDataEntry(value: 75, label: "正确率75%"),
        ]

        
        // 数据源，片的数量
        let set = PieChartDataSet(entries: entries, label: nil)
        set.drawIconsEnabled = false
        // 片之间的间隙，默认0
//        set.sliceSpace = 0
        
        
//        set.colors = ChartColorTemplates.vordiplom()
//            + ChartColorTemplates.joyful()
//            + ChartColorTemplates.colorful()
//            + ChartColorTemplates.liberty()
//            + ChartColorTemplates.pastel()
//            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        set.colors = [.red, .green]

        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        // 片上面的文本颜色
        data.setValueTextColor(.purple)
        // 为这个数据对象包含的所有数据集启用/禁用绘图值(值-文本)。
        data.setDrawValues(false)

        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleXValues:
            chartView.drawEntryLabelsEnabled = !chartView.drawEntryLabelsEnabled
            chartView.setNeedsDisplay()

        case .togglePercent:
            chartView.usePercentValuesEnabled = !chartView.usePercentValuesEnabled
            chartView.setNeedsDisplay()

        case .toggleHole:
            chartView.drawHoleEnabled = !chartView.drawHoleEnabled
            chartView.setNeedsDisplay()

        case .drawCenter:
            chartView.drawCenterTextEnabled = !chartView.drawCenterTextEnabled
            chartView.setNeedsDisplay()

        case .animateX:
            chartView.animate(xAxisDuration: 1.4)

        case .animateY:
            chartView.animate(yAxisDuration: 1.4)

        case .animateXY:
            chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4)

        case .spin:
            chartView.spin(duration: 2,
                           fromAngle: chartView.rotationAngle,
                           toAngle: chartView.rotationAngle + 360,
                           easingOption: .easeInCubic)

        default:
            break
//            handleOption(option, forChartView: chartView)
        }
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
//        sliderTextX.text = "\(Int(sliderX.value))"
//        sliderTextY.text = "\(Int(sliderY.value))"
//        
//        self.updateChartData()
    }
}
