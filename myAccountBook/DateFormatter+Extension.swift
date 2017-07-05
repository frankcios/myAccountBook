//
//  DateFormatter+Extension.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/5.
//  Copyright © 2017年 frankc. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    func stringWith(format: String, date: Date) -> String {
        self.dateFormat = format
        return self.string(from: date)
    }
}

