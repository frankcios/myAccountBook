//
//  MyAxisValueFormatter.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/7.
//  Copyright © 2017年 frankc. All rights reserved.
//

import Charts

class MyAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value)) $"
    }
}
