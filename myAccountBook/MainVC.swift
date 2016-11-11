//
//  MainVC.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/3.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentMonthLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    
    var days :[String]! = []
    var myRecords :[String:[[String:String]]]! = [:]
    
    // 宣告 NSFetchedResultsController
    var controller: NSFetchedResultsController<Record>!
    
    var record: [Record] = []
    
    // 宣告日期變數
    var currentDate = Date()
    
    let myUserDefaults = UserDefaults.standard
    
    let dateFormatter = DateFormatter()
    
    @IBAction func previousBtnPressed(_ sender: UIButton) {
        
        var dateComponets = DateComponents()
        dateComponets.month = -1
        self.updateCurrentDate(dateComponets)
    }
    
    @IBAction func nextBtnPressed(_ sender: UIButton!) {
        
        var dateComponets = DateComponents()
        dateComponets.month = 1
        self.updateCurrentDate(dateComponets)
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        self.navigationController?.pushViewController(PostVC(), animated: true)
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
        
        // 讀取資料
        attemptFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //calculateTotalMoney()
        
        let displayYearMonth = myUserDefaults.object(forKey: "displayYearMonth") as? String
        if displayYearMonth != nil && displayYearMonth != "" {
            dateFormatter.dateFormat = "yyyy-MM"
            currentDate = dateFormatter.date(from: displayYearMonth!)!
            
            myUserDefaults.set("", forKey: "displayYearMonth")
            myUserDefaults.synchronize()
        }
        
        updateRecordsList()
    }
    
    func updateRecordsList() {
        
        dateFormatter.dateFormat = "yyyy-MM"
        let yearMonth = dateFormatter.string(from: currentDate)
       
        days = []
        myRecords = [:]
        var total = 0.0

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        
        do {
            
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            for result in results {
                
                total += result.value(forKey: "amount") as! Double
                
                let title = result.value(forKey: "title")
                let amount = result.value(forKey: "amount")
                let createDate = result.value(forKey: "createDate") as! String
                print(createDate)
                if createDate != "" {
                    if !days.contains(createDate) {
                        days.append(createDate)
                        myRecords[createDate] = []
                    }
                    
                    myRecords[createDate]?.append([
                        "title":"\(title)",
                        "amount":"\(amount)"
                        ])
                }
                
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
        
        updateRecordsList()
    }
    
    func attemptFetch() {
        
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do {

            try controller.performFetch()
            
        } catch {
            
            let error = error as NSError
            
            print("\(error)")
        }
    }
    
    func calculateTotalMoney() {
        
        var total = 0.0
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        
        do {
            
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            for result in results {
                
                total += result.value(forKey: "amount") as! Double
                print(result.value(forKey: "yearMonth"))
            }
            
            totalLbl.text = String(format: "%g",total)
            
        } catch {
            
            fatalError("\(error)")
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = controller.sections {
            return sections.count
        }
        
        return 0
 
        /*
        return days.count
 */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let sections = controller.sections {
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
 /*
        let date = days[section]
        guard let records = myRecords[date] else {
            return 0
        }
        
        return records.count
*/
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let objs = controller.fetchedObjects , objs.count > 0 {
            let record = objs[indexPath.row]
            performSegue(withIdentifier: "PostVC", sender: record)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
       
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PostVC" {
            if let destination = segue.destination as? PostVC {
                if let record = sender as? Record {
                    destination.recordToEdit = record
                }
            }
        }
    }
    
    func configureCell(cell: RecordCell, indexPath: NSIndexPath) {
        
        // update cell
        let record = controller.object(at: indexPath as IndexPath)
        cell.configureCell(record: record)
        
    }

    // MARK: NSFetchedResultsController
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at:indexPath) as! RecordCell
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
}

