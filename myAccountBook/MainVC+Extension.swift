//
//  MainVC+Extension.swift
//  myAccountBook
//
//  Created by Frank on 2017/6/21.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit
import CoreData

extension MainVC: UITableViewDelegate, UITableViewDataSource  {
    
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
        
        let cellId = "RecordCell" 
        
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return cell
        }
        
        // 顯示的格式與內容
        cell.textLabel?.text = records[indexPath.row]["title"]
        cell.detailTextLabel?.text = String(format: "%g", Double(records[indexPath.row]["amount"]!)!)
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
        
        performSegue(withIdentifier: "PostVC", sender: nil)
    }
}
