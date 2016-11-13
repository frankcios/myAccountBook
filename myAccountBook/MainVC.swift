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
    @IBOutlet weak var segment: UISegmentedControl!
    // 宣告 NSFetchedResultsController
    var controller: NSFetchedResultsController<Record>!
        
    // 宣告日期變數
    var currentDate = Date()
    
    // 輸出時間格式
    let dateFormatter = DateFormatter()
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        self.navigationController?.pushViewController(PostVC(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 變更返回標題
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.separatorColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets.zero
        
        // 讀取資料
        attemptFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        calculateTotalMoney()
    }
    
    func attemptFetch() {
        
        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        
        let newDateSort = NSSortDescriptor(key: "createTime", ascending: false)
        let oldDateSort = NSSortDescriptor(key: "createTime", ascending: true)

        
        if segment.selectedSegmentIndex == 0 {
            
            fetchRequest.sortDescriptors = [newDateSort]
            
        } else if segment.selectedSegmentIndex == 1 {
            
            fetchRequest.sortDescriptors = [oldDateSort]
            
        }
        
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
        
        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            for record in results {
                
                total += record.amount
                print("\(record.createDate) \(record.title) \(record.amount)")
            }
            
            totalLbl.text = String(format: "%g",total)
            
        } catch {
            
            fatalError("\(error)")
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        attemptFetch()
        tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = controller.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let sections = controller.sections {
            
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
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
        
        // 更新 cell
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

