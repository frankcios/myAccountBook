//
//  URL+Extension.swift
//  myAccountBook
//
//  Created by  Frank Chuang on 2018/2/10.
//  Copyright © 2018年 frankc. All rights reserved.
//

import Foundation

extension URL {
    
    static func initPercent(string: String) -> URL
    {
        let urlwithPercentEscapes = string.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let url = URL.init(string: urlwithPercentEscapes!)
        return url!
    }

}
