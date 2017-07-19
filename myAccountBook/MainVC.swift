//
//  MainVC.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/3.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import UserNotifications

class MainVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentMonthLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
        
    // 一個月有哪幾天有紀錄
    var days: [String]! = []
    
    // 一天紀錄有幾筆
    var myRecords: [String:[[String:String]]]! = [:]
    
    // 每天的消費金額加總
    var dayCost: [String:String]! = [:]
    
    var newContentOffsetY: CGFloat = 0.0
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBAction func previousBtnPressed(_ sender: UIButton!) {
        var dateComponets = DateComponents()
        dateComponets.month = -1
        self.updateCurrentDate(dateComponets)
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton!) {
        var dateComponets = DateComponents()
        dateComponets.month = 1
        self.updateCurrentDate(dateComponets)
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem!) {
        myUserDefaults.set(0, forKey: "postID")
        myUserDefaults.synchronize()
        _ = self.navigationController?.pushViewController(PostVC(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupViews()
        createUserNotifications()
        
        if myUserDefaults.double(forKey: "limitCost") != 0.0 { return }
        myUserDefaults.set(5000.0, forKey: "limitCost")
        
        // 初次設定分類
        myUserDefaults.set(customCategories, forKey: "customCategories")
        
//        print(NSPersistentContainer.defaultDirectoryURL())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 決定顯示月份資料
        let displayYearMonth = myUserDefaults.object(forKey: "displayYearMonth") as? String
        if  displayYearMonth != nil && displayYearMonth != "" {
            dateFormatter.dateFormat = "yyyy-MM"
            currentDate = dateFormatter.date(from: displayYearMonth!)!
            
            myUserDefaults.set("", forKey: "displayYearMonth")
            myUserDefaults.synchronize()
        }
        
        myUserDefaults.set(0, forKey: "postID")
        myUserDefaults.synchronize()
        
        updateRecordsList()
        setupAudio()
    }
    
    func setupAudio() {
        // 音效
        if myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
            
            let deleteSoundPath = Bundle.main.path(forResource: "cutting-paper-2", ofType: "mp3")
            
            do {
                deleteSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath:     deleteSoundPath!))
                deleteSound.numberOfLoops = 0
            } catch {
                print("error")
            }
        } else {
            deleteSound = nil
        }
    }
    
    func setupViews() {
        // 變更返回標題
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        // 設定tableView分隔線
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets.zero
        
        // 日期設定
        currentMonthLbl.text = dateFormatter.stringWith(format: "yyyy 年 MM 月", date: currentDate)
    }
    
    // MARK: UserNotifications
    func createUserNotifications() {
        
        // 1.創建通知內容
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "早安，美好的早晨，今天記得記帳唷！"
        content.badge = 0
        content.sound = UNNotificationSound.default()
        
        // 2.創建推播觸發 每天早上八點半
        var date = DateComponents()
        date.hour = 8
        date.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        // 3.發送請求
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        // 4.將請求源添加到發送中心
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // MARK: 更新顯示紀錄
    func updateRecordsList() {
        
        let yearMonth = dateFormatter.stringWith(format: "yyyy-MM", date: currentDate)
        
        days = []
        myRecords = [:]
        var total = 0.0
        var okDayCost = 0.0
        var newDayCost = 0.0

        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        // 日期排序
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for result in results where result.yearMonth == "\(yearMonth)" {
                
                total += result.value(forKey: "amount") as! Double
                let id = result.value(forKey: "id") as! Int32
                let title = result.value(forKey: "title") as! String
                let amount = String(format: "%g", (result.value(forKey: "amount") as! Double))
                let createDate = result.value(forKey: "createDate") as! String
                
                if createDate != "" {
                    if !days.contains(createDate) {
                        days.append(createDate)
                        myRecords[createDate] = []
                    }
                    
                    myRecords[createDate]?.append([
                        "id":"\(id)",
                        "title":"\(title)",
                        "amount":"\(amount)"
                        ])
                   }
                
                // 暫存變數，每當新增一筆紀錄，金額會assign給okDayCost
                // 再新增第二筆時，okDayCost會是該筆記錄日期的最後一筆
                for i in 0 ..< myRecords[createDate]!.count {
                    okDayCost = Double((myRecords[createDate]?[i]["amount"])!)!
                }
                // 用於判定加總金額停止點，不同時間點即停止
                if let preSaveCreateDate = myUserDefaults.object(forKey: "CreateDate") {
                    if createDate == preSaveCreateDate as! String{
                        newDayCost += okDayCost
                        dayCost[createDate] = String(newDayCost)
                    } else {
                        newDayCost = 0.0
                        newDayCost += okDayCost
                        dayCost[createDate] = String(newDayCost)
                    }
                }
                
                // 儲存目前讀到的日期
                myUserDefaults.set(createDate, forKey: "CreateDate")

            }
            
            totalLbl.text = String(format: "%g",total)
            currentMonthLbl.text = dateFormatter.stringWith(format: "yyyy 年 MM 月", date: currentDate)
            
            tableView.reloadData()
        } catch {
            fatalError("\(error)")
        }
    }
    
    // MARK: 更新月份
    override func updateCurrentDate(_ dateComponents :DateComponents) {
        super.updateCurrentDate(dateComponents)
    
        currentMonthLbl.text = dateFormatter.stringWith(format: "yyyy 年 MM 月", date: currentDate)
        updateRecordsList()
    }
}

