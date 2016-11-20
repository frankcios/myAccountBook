//
//  DetailVC.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/3.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class PostVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var createTimeTextField: UITextField!
    
    var addSound: AVAudioPlayer!
    var deleteSound: AVAudioPlayer!
    
    // 創建記錄時間
    var createTime = Date()
    
    // 儲存音效開啟狀態
    let myUserDefaults = UserDefaults.standard
    var soundOpen: Bool = false
    
    let dateFormatter = DateFormatter()
    
    var myDatePicker :UIDatePicker!
    
    var record: Record!
    
    var recordID: Int32?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 金額輸入框
        amountTextField.attributedPlaceholder = NSAttributedString(string: "金額", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        amountTextField.delegate = self
        
        // 分類輸入框
        titleTextField.attributedPlaceholder = NSAttributedString(string: "分類", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        // 取得現在時間
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        createTimeTextField.text = dateFormatter.string(from: createTime)
        
        // 按一下空白處隱藏編輯狀態
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostVC.hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(tap)
        
        // UIPickerView
        myDatePicker = UIDatePicker()
        myDatePicker.datePickerMode = .dateAndTime
        myDatePicker.locale = Locale(identifier: "zh_TW")
        myDatePicker.addTarget(self, action: #selector(PostVC.selectDate), for: .valueChanged)
        createTimeTextField.inputView = myDatePicker

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let open = myUserDefaults.object(forKey: "soundOpen") as? Int {
            soundOpen = open == 1 ? true : false
        }
        
        let recordID = Int32(myUserDefaults.integer(forKey: "postID"))
        
        //        print(recordID)
        
        if recordID > 0 {
            
            self.navigationItem.title = "更新"
            
            let fetchRequest: NSFetchRequest = Record.fetchRequest()
            
            let results = try? context.fetch(fetchRequest)
            
            for record in results! where record.id == recordID {
                
                titleTextField.text = record.title
                // 格式化輸出字串 以一般格式顯示
                amountTextField.text = String(format: "%g", record.amount)
                createTimeTextField.text = record.createTime
                
                // 取得該筆記錄後將時間設定給datePicker顯示
                myDatePicker.date = dateFormatter.date(from: record.createTime)!
            }
            
        } else {
            
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.title = "新增"
        }
        
        // 音效
        if soundOpen {
            
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
        } else {
            
            addSound = nil
            deleteSound = nil
        }
    }
    
    // create
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        if !(titleTextField.text?.isEmpty)! && !(amountTextField.text?.isEmpty)! {
            
            if myUserDefaults.integer(forKey: "postID") == 0 {
                
                record = Record(context: context)
                
                // ID Auto increment
                var seq: Int32 = 1
                let idSeq = myUserDefaults.integer(forKey: "seq")
                seq = idSeq + 1
                
                // 設定欄位值
                record.id = seq
                record.title = titleTextField.text!
                record.amount = Double(amountTextField.text!)!
                record.createTime = createTimeTextField.text!
                record.yearMonth = (record.createTime as NSString).substring(to: 7)
                record.createDate = (record.createTime as NSString).substring(to: 10)
                
                //            print("\(record.id) \(record.title) \(record.amount) \(record.yearMonth) \(record.createDate) \(record.createTime)")
                
                ad.saveContext()
                
                // 儲存id值
                myUserDefaults.set(seq ,forKey: "seq")
                
                // 設定首頁要顯示這個記錄所屬的月份記錄列表
                myUserDefaults.set(record.yearMonth, forKey: "displayYearMonth")
                myUserDefaults.synchronize()
                
            } else {
                
                let recordID = Int32(self.myUserDefaults.integer(forKey: "postID"))
                
                let fetchRequest: NSFetchRequest = Record.fetchRequest()
                
                let results = try! context.fetch(fetchRequest)
                
                for record in results where record.id == recordID {
                    
                    record.title = titleTextField.text!
                    record.amount = Double(amountTextField.text!)!
                    record.createTime = createTimeTextField.text!
                    record.yearMonth = (record.createTime as NSString).substring(to: 7)
                    record.createDate = (record.createTime as NSString).substring(to: 10)
                }
                
                ad.saveContext()
            }
            
            if myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
                addSound.play()
            }
            _ = self.navigationController?.popViewController(animated: true)
            
        } else {
            
            let alert = UIAlertController(title: "警告", message: "輸入框不可為空", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    // delete
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "警告", message: "確定刪除此筆記錄？", preferredStyle: .alert)
        
        // 刪除資料
        let yesAction = UIAlertAction(title: "確定", style: .default, handler: { (Action) in
            
            let recordID = Int32(self.myUserDefaults.integer(forKey: "postID"))
            
            if recordID > 0 {
                
                let fetchRequest: NSFetchRequest = Record.fetchRequest()
                
                let results = try! context.fetch(fetchRequest)
                
                for record in results where record.id == recordID {
                    
                    context.delete(record)
                }
                ad.saveContext()
            }
            self.dismiss(animated: true, completion: nil)
            _ = self.navigationController?.popViewController(animated: true)
            
            if self.myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
                self.deleteSound.play()
            }
            
        })
        
        let noAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
        
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
    
    // MARK: Functional Methods
    
    // 按空白處會隱藏編輯狀態
    func hideKeyboard(_ tapG: UITapGestureRecognizer?){
        self.view.endEditing(true)
    }
    
    
    func selectDate(_ sender: UIDatePicker) {
        
        createTimeTextField.text = dateFormatter.string(from: myDatePicker.date)
    }
    
}


/*
// String convert to Double
extension String {
    
    func toDouble() -> Double? {
        
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
*/
