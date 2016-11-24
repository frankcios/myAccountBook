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

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentMonthLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!

    // 取得螢幕尺寸
    let fullSize: CGSize = UIScreen.main.bounds.size
    
    // 宣告日期變數
    var currentDate = Date()
    
    // 輸出時間格式
    let dateFormatter = DateFormatter()
    
    // 儲存音效開啟狀態
    let myUserDefaults = UserDefaults.standard
    
    var deleteSound: AVAudioPlayer!
    
    // 一個月有哪幾天有紀錄
    var days: [String]! = []
    
    // 一天紀錄有幾筆
    var myRecords: [String:[[String:String]]]! = [:]
    
    @IBAction func previousBtnPressed(_ sender: UIButton?) {
        
        var dateComponets = DateComponents()
        dateComponets.month = -1
        self.updateCurrentDate(dateComponets)
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton?) {
        
        var dateComponets = DateComponents()
        dateComponets.month = 1
        self.updateCurrentDate(dateComponets)
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        myUserDefaults.set(0, forKey: "postID")
        myUserDefaults.synchronize()
        _ = self.navigationController?.pushViewController(PostVC(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 變更返回標題
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // 日期格式設定
        dateFormatter.dateFormat = "yyyy 年 MM 月"
        currentMonthLbl.text = dateFormatter.string(from: currentDate)
        
        tableView.separatorColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets.zero
        
        // 向左滑動手勢
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        // 向右滑動手勢
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
//        print(NSPersistentContainer.defaultDirectoryURL())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        // 音效
        if myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
            
            let deleteSoundPath = Bundle.main.path(forResource: "cutting-paper-2", ofType: "mp3")
            
            do {
                deleteSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: deleteSoundPath!))
                deleteSound.numberOfLoops = 0
                
            } catch {
                print("error")
            }
        } else {
            
            deleteSound = nil
        }
    }
    
    // 更新顯示紀錄
    func updateRecordsList() {
        
        dateFormatter.dateFormat = "yyyy-MM"
        let yearMonth = dateFormatter.string(from: currentDate)
        
        days = []
        myRecords = [:]
        var total = 0.0

        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        // 日期排序
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            for result in results where result.yearMonth == "\(yearMonth)" {
                
                total += result.value(forKey: "amount") as! Double
                let id = result.value(forKey: "id") as! Int
                let title = result.value(forKey: "title") as! String
                let amount = String(format: "%g", (result.value(forKey: "amount") as! Double) )
                let createDate = result.value(forKey: "createDate") as! String
//                print("\(title) \(amount) \(createDate) \(yearMonth)")
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
//                print(days)
//                print(myRecords)
            }
            
            totalLbl.text = String(format: "%g",total)
            
            dateFormatter.dateFormat = "yyyy 年 MM 月"
            currentMonthLbl.text = dateFormatter.string(from: currentDate)
            
            tableView.reloadData()
            
        } catch {
            
            fatalError("\(error)")
        }
    }
    
    // 切換月份
    func updateCurrentDate(_ dateComponents :DateComponents) {
        let calendar = Calendar.current
        let newDate = (calendar as NSCalendar).date(byAdding: dateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))
        
        currentDate = newDate!
        
        dateFormatter.dateFormat = "yyyy 年 MM 月"
        currentMonthLbl.text = dateFormatter.string(from: currentDate)
        
        updateRecordsList()
    }
    
    // 定義section數量
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return days.count
    }
    
    // 定義每個section內的列數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let date = days[section]
        guard let records = myRecords[date] else {
            return 0
        }
        
        return records.count
    }
    
    // 定義每個cell要顯示的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return cell
        }
        
        // 顯示的格式與內容
        cell.textLabel?.text = records[indexPath.row]["title"]
        cell.detailTextLabel?.text = String(format: "%g", Double(records[indexPath.row]["amount"]!)!)
        return cell
    }
    
    // 滑動刪除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let fetchRequest: NSFetchRequest = Record.fetchRequest()
            // 篩選某個Section(日期)的紀錄
            fetchRequest.predicate = NSPredicate(format: "createDate == %@", days[indexPath.section])
            let results = try! context.fetch(fetchRequest)
            
            // 刪除Section裡的某筆記錄
            context.delete(results[indexPath.row])
            
            ad.saveContext()
            
            updateRecordsList()
            
            if myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
                deleteSound.play()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "刪除"
    }
    
    // 選擇某列時的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)

        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return
        }
        
        myUserDefaults.set(records[indexPath.row]["id"]!, forKey: "postID")
        myUserDefaults.synchronize()
        
        performSegue(withIdentifier: "PostVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "  " + days[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    func swipe(_ recognizer: UISwipeGestureRecognizer) {
        
        if recognizer.direction == .left {
            
            nextBtnPressed(nil)
            
        } else if recognizer.direction == .right {
            
            previousBtnPressed(nil)
            
        }
    }
}

