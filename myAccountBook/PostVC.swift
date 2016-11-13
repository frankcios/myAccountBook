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
    @IBOutlet weak var createTimeLbl: UILabel!
    
    var addSound: AVAudioPlayer!
    var deleteSound: AVAudioPlayer!
    
    // 儲存要編輯的紀錄
    var recordToEdit: Record?
    
    var createTime = Date()
    
    // 儲存音效開啟狀態
    let myUserDefaults = UserDefaults.standard
    var soundOpen: Bool = false
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 金額輸入框
        amountTextField.attributedPlaceholder = NSAttributedString(string: "金額", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        amountTextField.delegate = self
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let open = myUserDefaults.object(forKey: "soundOpen") as? Int {
            soundOpen = open == 1 ? true : false
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
    @IBAction func insertBtnPressed(_ sender: UIButton) {
        
        var record: Record!
        
        if !(titleTextField.text?.isEmpty)! && !(amountTextField.text?.isEmpty)! {
            
            if recordToEdit == nil {
                
                record = Record(context: context)
                
            } else {
                
                record = recordToEdit
            }
            
            // 設定欄位值
            record.title = titleTextField.text!
            record.amount = (amountTextField.text?.toDouble())!
            record.createTime = createTimeLbl.text!
            record.yearMonth = (record.createTime as NSString).substring(to: 7)
            record.createDate = (record.createTime as NSString).substring(to: 10)
            
            ad.saveContext()
            
            _ = self.navigationController?.popViewController(animated: true)
            
            if myUserDefaults.object(forKey: "soundOpen") as? Int == 1 {
                addSound.play()
            }
            
            
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
        
        let yesAction = UIAlertAction(title: "確定", style: .default, handler: { (Action) in
            // 刪除資料
            if self.recordToEdit != nil {
                context.delete(self.recordToEdit!)
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
    
    func loadRecordData() {
        
        if let record = recordToEdit {
            
            titleTextField.text = record.title
            // 格式化輸出字串 以一般格式顯示
            amountTextField.text = String(format: "%g", record.amount)
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
