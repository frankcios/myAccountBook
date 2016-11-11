//
//  DetailVC.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/3.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit
import CoreData

class PostVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var createTimeLbl: UILabel!
    
    // 儲存要編輯的紀錄
    var recordToEdit: Record?
    
    var createTime = Date()
    
    let myUserDefaults = UserDefaults.standard
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 金額輸入框
        priceTextField.attributedPlaceholder = NSAttributedString(string: "金額", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        priceTextField.delegate = self
        
        // 分類輸入框
        titleTextField.attributedPlaceholder = NSAttributedString(string: "分類", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        // 取得現在時間
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        createTimeLbl.text = dateFormatter.string(from: createTime)
        
        if recordToEdit != nil {
            
            loadRecordData()
            self.navigationItem.title = "更新"

        } else {
            
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.title = "新增"
        }
    }
    
    @IBAction func insertBtnPressed(_ sender: UIButton) {
        
        var record: Record!
    
        if !(titleTextField.text?.isEmpty)! && !(priceTextField.text?.isEmpty)! {
            
            if recordToEdit == nil {
                
                record = Record(context: context)
                
            } else {
                
                record = recordToEdit
            }
            
            record.title = titleTextField.text!
            record.amount = (priceTextField.text?.toDouble())!
            record.createTime = createTimeLbl.text!
            record.yearMonth = (record.createTime as NSString).substring(to: 7)
            record.createDate = (record.createTime as NSString).substring(to: 10)
            
            ad.saveContext()
            
        
            // 設定首頁要顯示這個記錄所屬的月份記錄列表
            myUserDefaults.set(record.yearMonth, forKey: "displayYearMonth")
            myUserDefaults.synchronize()
            
            _ = self.navigationController?.popViewController(animated: true)
            
            
            
        } else {
            
            let alert = UIAlertController(title: "警告", message: "輸入框不可為空", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)

        }
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "警告", message: "確定刪除此筆記錄？", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "確定", style: .default, handler: { (Action) in
            // 刪除資料
            if self.recordToEdit != nil {
                context.delete(self.recordToEdit!)
                ad.saveContext()
            }
            self.dismiss(animated: true, completion: nil)
            _ = self.navigationController?.popViewController(animated: true)
        })
        
        let noAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)

        present(alert, animated: true, completion: nil)
        
        
    }
    
    func loadRecordData() {
        
        if let record = recordToEdit {
            
            titleTextField.text = record.title
            // 格式化輸出字串 以一般格式顯示
            priceTextField.text = String(format: "%g", record.amount)
            createTimeLbl.text = record.createTime
        }
    }
    
    // 金額只能有一個小數點
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 101 {
            let oldString = textField.text as NSString? ?? ""
            let newString = oldString.replacingCharacters(in: range, with: string)
            var count = 0
            for c in newString.characters {
                if c == "." {
                    count = count + 1
                }
            }
            
            if count > 1 {
                return false
            }
        }
        
        return true
    }
}

// String convert to Double
extension String {
    
    func toDouble() -> Double? {
        
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
