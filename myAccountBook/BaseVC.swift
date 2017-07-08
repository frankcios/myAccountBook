//
//  BaseVC.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/6.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    // 宣告日期變數
    var currentDate = Date()
    
    // 輸出時間格式
    let dateFormatter = DateFormatter()
    
    // 儲存音效開啟狀態
    let myUserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: 更新月份
    func updateCurrentDate(_ dateComponents :DateComponents) {
        let calendar = Calendar.current
        let newDate = (calendar as NSCalendar).date(byAdding: dateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))
        
        currentDate = newDate!
    }
}
