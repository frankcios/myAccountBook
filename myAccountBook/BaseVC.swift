//
//  BaseVC.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/6.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit
import AVFoundation

class BaseVC: UIViewController {
    
    // 取得螢幕尺寸
    let fullSize: CGSize = UIScreen.main.bounds.size
    
    let myUserDefaults = UserDefaults.standard
    
    // 宣告日期變數
    var currentDate = Date()
    
    // 輸出時間格式
    let dateFormatter = DateFormatter()
    
    // MARK: - sound variable
    var addSound: AVAudioPlayer!
    var deleteSound: AVAudioPlayer!
    
    // 判斷音效是否開啟
    var isSoundOpen: Bool = false
    
    // 自定義類別
    var customCategories = ["早餐", "午餐", "晚餐", "飲料", "娛樂", "交通", "醫療", "教育", "日用品", "房租", "電話費"]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentDate = Date()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    // MARK: 更新月份
    func updateCurrentDate(_ dateComponents: DateComponents) {
        let calendar = Calendar.current
        let newDate = (calendar as NSCalendar).date(byAdding: dateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))
        
        currentDate = newDate!
    }
    
    func setupAudio() {
        // 音效
        let addSoundPath = Bundle.main.path(forResource: "bottle_pop_3", ofType: "wav")
        let deleteSoundPath = Bundle.main.path(forResource: "cutting-paper-2", ofType: "mp3")
        
        do {
            addSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: addSoundPath!))
            addSound.numberOfLoops = 0
            
            deleteSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: deleteSoundPath!))
            deleteSound.numberOfLoops = 0
        } catch {
            print("error")
        }
    }
}
