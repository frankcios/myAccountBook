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

protocol PostVCDelegate {
    func updateRecordsList()
}


class PostVC: BaseVC {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var createTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var delegate: MainVC!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBOutlet weak var saveBtn: UIButton! {
        didSet {
            // 儲存按鈕
            saveBtn.layer.cornerRadius = 20
            saveBtn.layer.masksToBounds = true
            saveBtn.layer.borderWidth = 1.5
            saveBtn.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    var myDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "zh_TW")
        datePicker.addTarget(self, action: #selector(PostVC.selectDate), for: .valueChanged)
        return datePicker
    }()
    
    // MARK: - tapRecongnizer for pickerView
    var tapRecongnizer: UITapGestureRecognizer!
    
    lazy var myPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        self.tapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(PostVC.tappedToSelectRow(_:)))
        pickerView.addGestureRecognizer(self.tapRecongnizer)
        return pickerView
    }()
    
    // MARK: - record variable
    var record: Record!
    var recordID: Int32?
    
    // the property for store textfield text value
    var category: String?
    var amount: String?
    var desc: String?
    
    // MARK: 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        // 分類輸入框
        titleTextField.attributedPlaceholder = NSAttributedString(string: "分類", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        // 金額輸入框
        amountTextField.attributedPlaceholder = NSAttributedString(string: "金額", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])

        titleTextField.delegate = self
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        
        myPickerView.delegate = self
        myPickerView.dataSource = self

        tapRecongnizer.delegate = self
        tapRecongnizer.cancelsTouchesInView = false
        
        createTimeTextField.tintColor = .clear
        // 取得現在時間
        createTimeTextField.text = dateFormatter.stringWith(format: "yyyy-MM-dd HH:mm", date: currentDate)
        // 把DatePicker嵌入在TextField中
        createTimeTextField.inputView = myDatePicker
        titleTextField.inputView = myPickerView
        
        // 按一下空白處隱藏編輯狀態
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostVC.hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(tap)
        
        // 設定代理
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let open = myUserDefaults.object(forKey: "soundOpen") as? Int {
            isSoundOpen = open == 1 ? true : false
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
                descriptionTextField.text = record.desc
                // 取得該筆記錄後將時間設定給datePicker顯示
                myDatePicker.date = dateFormatter.date(from: record.createTime)!
            }
        } else {
            // 如果是新增資料時，隱藏刪除按鈕
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.title = "新增"
        }
        
        // 讀取自定義分類
        if let okCategories = myUserDefaults.object(forKey: "customCategories") as? [String] {
            customCategories = okCategories
        }
        
        // 記住textField的值，以防再次編輯被清空
        copyTextFieldText()
    }

    func copyTextFieldText() {
        category = titleTextField.text
        amount = amountTextField.text
        desc = descriptionTextField.text 
    }
    
    // 儲存紀錄
    @IBAction func saveBtnPressed(_ sender: UIButton) {
    
        if titleTextField.text != "" && amountTextField.text != "" {
            
            if myUserDefaults.integer(forKey: "postID") == 0 {
                record = Record(context: context)
            
                // ID Auto increment
                print("lastRecordID:", ad.getLastRecordID())
                var seq: Int32 = 1
                let idSeq = ad.getLastRecordID()
                seq = Int32(idSeq + 1)
                
                // 設定欄位值
                record.id = Int32(seq)
                record.title = titleTextField.text!
                record.amount = Double(amountTextField.text!) ?? 0
                record.createTime = createTimeTextField.text!
                record.yearMonth = (record.createTime as NSString).substring(to: 7)
                record.createDate = (record.createTime as NSString).substring(to: 10)
                record.desc = descriptionTextField.text
                
                // 儲存id值
                myUserDefaults.set(seq ,forKey: "seq")
                
                // 設定首頁要顯示這個記錄所屬的月份記錄列表
                myUserDefaults.set(record.yearMonth, forKey: "displayYearMonth")
                // 設定判別統計金額的邊界標準
                myUserDefaults.set(record.createDate , forKey: "CreateDate")
                myUserDefaults.synchronize()
                
            } else {
                // 記錄存在就覆蓋掉
                let recordID = Int32(self.myUserDefaults.integer(forKey: "postID"))
                let fetchRequest: NSFetchRequest = Record.fetchRequest()
                let results = try! context.fetch(fetchRequest)
                
                var count = 0
                // 將已存在紀錄拿出來修改
                /// bug fixes: ID duplicate
                for record in results where record.id == recordID {
                    count += 1
                    print("迴圈繞了\(count)次")
                    record.title = titleTextField.text!
                    record.amount = Double(amountTextField.text!)!
                    record.createTime = createTimeTextField.text!
                    record.yearMonth = (record.createTime as NSString).substring(to: 7)
                    record.createDate = (record.createTime as NSString).substring(to: 10)
                    record.desc = descriptionTextField.text
                }
            }
        
            ad.saveContext()
                        
            if isSoundOpen {
                addSound.play()
            }
            _ = self.navigationController?.popViewController(animated: true)
            
        } else {
            let alert = UIAlertController(title: "未輸入分類與金額", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }

    // 刪除紀錄
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "警告", message: "確定刪除此筆記錄？", preferredStyle: .alert)
        
        // 按下刪除後做的事
        let yesAction = UIAlertAction(title: "確定", style: .default, handler: { (action) in
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
            
            if self.isSoundOpen {
                self.deleteSound.play()
            }
        })
        
        let noAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
    }

    // 按空白處會隱藏編輯狀態
    func hideKeyboard(_ tapG: UITapGestureRecognizer?) {
        self.view.endEditing(true)
    }
    
    // datePicker
    func selectDate(_ sender: UIDatePicker) {
        createTimeTextField.text = dateFormatter.string(from: myDatePicker.date)
    }
    
    // pickerView tap selected row
    func tappedToSelectRow(_ tapRecognizer: UITapGestureRecognizer) {
        if tapRecongnizer.state == .ended {
            let rowHeight: CGFloat = myPickerView.rowSize(forComponent: 0).height
            let selectedRowFrame: CGRect = myPickerView.bounds.insetBy(dx: 0.0, dy: (myPickerView.frame.height - rowHeight) / 2.0 )
            let userTappedOnSelectedRow = (selectedRowFrame.contains(tapRecognizer.location(in: myPickerView)))
            if (userTappedOnSelectedRow)
            {
                let selectedRow = myPickerView.selectedRow(inComponent: 0)
                titleTextField.text = customCategories[selectedRow]
                print(selectedRow)
            }
        }
    }

}
