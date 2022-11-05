//
//  DateValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: IntAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MM"// HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let days = Int(value)
        let month = "09"
        
        return String(format: "%d\(days)- \(month)")
        //        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }

    

}
