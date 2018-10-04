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

// 限制金額線
let limitCost = 5000.0

class MainVC: BaseVC, PostVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentMonthLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    
    let cellId = "RecordCell"

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecordsList), name: NSNotification.Name(rawValue: refreshRecordNotification), object: nil)
        
        print(NSPersistentContainer.defaultDirectoryURL())

        tableView.delegate = self
        tableView.dataSource = self
        
        setupViews()
        createUserNotifications()
        
        if myUserDefaults.double(forKey: "limitCost") != 0.0 { return }
        myUserDefaults.set(limitCost, forKey: "limitCost")
        
        // 初次設定分類
        myUserDefaults.set(customCategories, forKey: "customCategories")
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
        print("myRecord: \(myRecords)")
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
                print("result:", result)
                total += result.value(forKey: "amount") as! Double
                let id = result.value(forKey: "id") as! Int32
                let title = result.value(forKey: "title") as! String
                let amount = String(format: "%g", (result.value(forKey: "amount") as! Double))
                let createDate = result.value(forKey: "createDate") as! String
                let desc = result.value(forKey: "desc") as? String ?? ""
                
                if createDate != "" {
                    if !days.contains(createDate) {
                        days.append(createDate)
                        myRecords[createDate] = []
                    }
                    
                    myRecords[createDate]?.append([
                        "id":"\(id)",
                        "title":"\(title)",
                        "amount":"\(amount)",
                        "desc":"\(desc)"
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

extension MainVC: UITableViewDelegate, UITableViewDataSource {

    // MARK: - UITableViewDataSource
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecordCell

        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return cell
        }

        // 顯示的格式與內容
        cell.titleLabel.text = records[indexPath.row]["title"]
        cell.amountLabel.text = String(format: "%g", Double(records[indexPath.row]["amount"]!)!)
        cell.descLabel.text = records[indexPath.row]["desc"]
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if dayCost[days[section]] != nil {
            let dayTotal = String(format: "%g", Double(dayCost[days[section]]!)!)
            return "  " + days[section] + " " + "(共計\(dayTotal)元)"
        }
        return "  " + days[section]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }


    // MARK: - UITableViewDelegate
    // 滑動刪除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let fetchRequest: NSFetchRequest = Record.fetchRequest()
            // 篩選某個Section(日期)裡的紀錄
            fetchRequest.predicate = NSPredicate(format: "createDate == %@", days[indexPath.section])
            // 只抓出該日期的紀錄
            let results = try! context.fetch(fetchRequest)

            // 刪除該日期裡選擇的該列記錄
            context.delete(results[indexPath.row])
            ad.saveContext()
            updateRecordsList()

            if myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
                deleteSound.play()
            }
        }
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

        print("recordID: \(records[indexPath.row]["id"]!)")

        performSegue(withIdentifier: "PostVC", sender: nil)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        newContentOffsetY = scrollView.contentOffset.y
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

        // 向上滑動時隱藏
        if scrollView.contentOffset.y > newContentOffsetY {
            UIView.animate(withDuration: 0.3, animations: {
                self.tabBarController?.tabBar.frame = CGRect(x: 0, y: self.fullSize.height, width: self.fullSize.width, height: 49)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.tabBarController?.tabBar.frame = CGRect(x: 0, y: self.fullSize.height - 49, width: self.fullSize.width, height: 49)
            })
        }
    }
}
