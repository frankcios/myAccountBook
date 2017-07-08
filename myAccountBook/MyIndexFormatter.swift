//
//  MyIndexFormatter.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/6.
//  Copyright © 2017年 frankc. All rights reserved.
//

import Charts

class MyIndexFormatter: IndexAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(value)"
    }
}
