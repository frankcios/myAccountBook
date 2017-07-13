//
//  String+Extension.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/6.
//  Copyright © 2017年 frankc. All rights reserved.
//

import Foundation

extension String {
    
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(startIndex, offsetBy: to-from)
        
        return self[startIndex...endIndex]
    }
}
