//
//  ChartsViewCtrl.swift
//  emerana
//
//  Created by 艾美拉娜 on 2018/10/15.
//  Copyright © 2018 艾美拉娜.王仁洁. All rights reserved.
//

import UIKit
import EnolaGay

/// Charts 列表
class ChartsViewCtrl: JudyBaseTableViewCtrl {
    
    // MARK: - let property and IBOutlet - 常量和IBOutlet

    // MARK: - public var property - 公开var

    override var viewTitle: String? {
        return "Charts"
    }

    // MARK: - private var property - 私有var
    
    
    // MARK: - Life Cycle - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [
            ["title": "Bar Chart 条形图Style1.", "subTitle": "A simple demonstration of the bar chart.", "segue": "showBarChartViewCtrl"],
            ["title": "Pie Chart 馅饼图.", "subTitle": "A simple demonstration of the pie chart.", "segue": "showPieChartViewCtrl"],
            ["title": "蜡烛图.", "subTitle": "适用于K线图的绘制.", "segue": "showCandleStickChartViewCtrl"],
            ["title": "K线图示例", "subTitle": "K线研究所Demo", "segue": "showKLineViewCtrl", ],
            ["title": "MyY_KLine", "subTitle": "截止目前为止，最为专业的K线图了", "segue": "showMyY_KLineViewCtrl", ],
            ["title": "折线图", "subTitle": "折线图的使用", "segue": "showLineChartViewCtrl", ],


            
        ]
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

// MARK: - tableView dataSource
extension ChartsViewCtrl {
    /*
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // 父类已设置为dataSource.count，如需修改请，重写此方法，但要注意cellFor里面DataSource[indexPath.row]越界
     return <#T##dataSource.count#>
     }
     */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 此方法可以不判断cell == nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.json = dataSource[indexPath.row]
        cell.textLabel?.text = dataSource[indexPath.row]["title"].stringValue
        cell.detailTextLabel?.text = dataSource[indexPath.row]["subTitle"].stringValue

        
        return cell
    }
    
    
}

// MARK: delegate
extension ChartsViewCtrl {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ident = dataSource[indexPath.row]["segue"].stringValue
        if ident != "" {
            performSegue(withIdentifier: ident, sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}

