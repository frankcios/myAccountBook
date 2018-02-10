//
//  MoreVC.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/13.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit
import MessageUI

class MoreVC: BaseVC, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate  {
    
    var mySwitch: UISwitch!
    var soundOpen: Int? = 0
    
    let cellId = "Cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    fileprivate func setupViews() {
                
        tableView.delegate = self
        tableView.dataSource = self
        
        // 音效開關
        mySwitch = UISwitch()
        soundOpen = myUserDefaults.object(forKey: "soundOpen") as? Int
        mySwitch.isOn = soundOpen == 1 ? true : false
        mySwitch.addTarget(self, action: #selector(MoreVC.onSwitchChanged), for: .touchUpInside)
    }
    
    func popToCustomCategoryVC() {
        
        let customCategoryVC = self.storyboard?.instantiateViewController(withIdentifier: "custom")
        
        present(customCategoryVC!, animated: true, completion: nil)
    }
    
    func setLimitCost() {
        
        let alert = UIAlertController(title: "每月限制金額", message: "請輸入金額 (顯示在圖表上的紅色虛線)", preferredStyle: .alert)
        
        // 添加textfield
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].keyboardType = .numberPad
        alert.textFields?[0].text = myUserDefaults.string(forKey: "limitCost")
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            self.myUserDefaults.set(alert.textFields?[0].text, forKey: "limitCost")
            self.myUserDefaults.synchronize()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func onSwitchChanged(_ sender: UISwitch) {
        
        myUserDefaults.set( (sender.isOn ? 1 : 0 ), forKey: "soundOpen")
        myUserDefaults.synchronize()
    }
    
    func contactMe() {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        composeVC.setSubject("聯絡開發者")
        composeVC.setToRecipients(["pk15678@gmail.com"])
        composeVC.setMessageBody("\n\n\n System Version: \(systemVersion)\n App Version: \(version!)", isHTML: false)
        
        // present
        present(composeVC, animated: true, completion: nil)
    }
    
    func goFlatIcon() {
        
        let requestUrl = URL(string: "http://www.flaticon.com")
        UIApplication.shared.open(requestUrl!, options: [:], completionHandler: nil)
    }
    
    func emailSqliteFile() {
        
        // We must always check whether the current device is configured for sending emails
        if MFMailComposeViewController.canSendMail() {
            
            displayComposerSheet()
            
        } else {
            AlertHelper.shared.alertWith(controller: self, title: "Email Failure", message: "Your device is not setup to send Email!\nPlease Activiate Email Through Settings.", buttonTitle: ["OK"], completionHandler: nil)
        }
        
    }
    
    // Displays an email composition interface inside the application. Populates all the Mail fields.
    func displayComposerSheet() {
        
        // Attach The CSV File to the email
        let tempFileName = "myAccountBook.sqlite";
        guard let supDirectory =  FileManager().urls(for: .applicationSupportDirectory, in: .userDomainMask).last else { return }

        let tempFile = supDirectory.appendingPathComponent(tempFileName)
        print("file path: \(tempFile.path)")

        let fileExists = FileManager().fileExists(atPath: tempFile.path)
      
        if (!fileExists)
        {
            AlertHelper.shared.alertWith(controller: self, title: "提示", message: "備份檔案不存在", buttonTitle: ["OK"], completionHandler: nil)

            print("File does not Exists")
            return
        }
        
        
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        
        picker.setSubject("myAccountBook Backup")
        picker.setToRecipients(["pk15678@yahoo.com.tw"])
//        picker.setCcRecipients(["pk15678@gmail.com", "pk15678@yahoo.com.tw"])
        
        
        guard let data = try? Data(contentsOf: tempFile) else { return }
        let time = DateFormatter().stringWith(format: "yyyyMMdd_HHmm", date: currentDate)
        picker.addAttachmentData(data ,mimeType: "application/x-sqlite3", fileName: "myAccountBook_\(time).sqlite")

        picker.setMessageBody("", isHTML: false)
        
        // present
        present(picker, animated: true, completion: nil)
    }
    
    // Mark: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch (result)
        {
        case .cancelled:
            print("Mail Cancelled")
        case .saved:
            print("Mail Saved")
        case .sent:
            print("Mail Sent")
            SQLiteManager.sharedInstance.removeAllSQLiteInboxFiles()
        case .failed:
            print("Mail sent failure: \(error.debugDescription)")
        }
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            return 1
        default:
            print("wrong section \(section)")
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.accessoryType = .none
        
        let frame = CGRect(x: 15, y: 0, width: fullSize.width, height: 40)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let customBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.popToCustomCategoryVC), title: "分類管理", color: UIColor.black)
            cell.contentView.addSubview(customBtn)
        case (0, 1):
            let limitCostBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.setLimitCost), title: "設定限制金額", color: UIColor.black)
            cell.contentView.addSubview(limitCostBtn)
        case (1, 0):
            cell.textLabel?.text = "新增/刪除紀錄音效"
            cell.accessoryView = mySwitch
        case (1, 1):
            let contactBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.contactMe), title: "寄信給開發者", color: UIColor.black)
            cell.contentView.addSubview(contactBtn)
        case (1, 2):
            cell.textLabel?.text = "版本"
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
            label.text = "\(version!)"
            cell.accessoryView = label
        case (2, 0):
            let flatIconBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.goFlatIcon), title: "FLATICON", color: UIColor.black)
            cell.contentView.addSubview(flatIconBtn)
        case (3, 0):
                let emailSqliteBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.emailSqliteFile), title: "備份", color: UIColor.black)
                cell.contentView.addSubview(emailSqliteBtn)
        default:
            print("wrong section \(indexPath.section)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 2 {
            return "圖片來源"
        } else if section == 3 {
            return "檔案備份"
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3 {
            return "如何回復備份？\n1.找到備份檔案\n2.點擊文件\n3.選擇\"拷貝到記帳小幫手\""
        }
        
        return ""
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


