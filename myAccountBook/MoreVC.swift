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
    
    // MARK : Button Action
    func onSwitchChanged(_ sender: UISwitch) {
        
        myUserDefaults.set( (sender.isOn ? 1 : 0 ), forKey: "soundOpen")
        myUserDefaults.synchronize()
    }
    
    func goFlatIcon() {
        
        let requestUrl = URL(string: "http://www.flaticon.com")
        UIApplication.shared.open(requestUrl!, options: [:], completionHandler: nil)
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
    
    func popToCustomCategoryVC() {
        
        let customCategoryVC = self.storyboard?.instantiateViewController(withIdentifier: "custom")
        
        present(customCategoryVC!, animated: true, completion: nil)
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
        case .failed:
            print("Mail sent failure: \(error.debugDescription)")
        }
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 1
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.accessoryType = .none
        
        let frame = CGRect(x: 15, y: 0, width: fullSize.width, height: 40)
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let customBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.popToCustomCategoryVC), title: "分類管理", color: UIColor.black)
                cell.contentView.addSubview(customBtn)
                
            } else if indexPath.row == 1 {
                let limitCostBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.setLimitCost), title: "設定限制金額", color: UIColor.black)
                cell.contentView.addSubview(limitCostBtn)
            }
        
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                cell.textLabel?.text = "新增/刪除紀錄音效"
                cell.accessoryView = mySwitch
                
            } else if indexPath.row == 1 {
                
                let contactBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.contactMe), title: "寄信給開發者", color: UIColor.black)
                cell.contentView.addSubview(contactBtn)
                
            }
        } else if indexPath.section == 2 {
            
            let flatIconBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.goFlatIcon), title: "FLATICON", color: UIColor.black)
            cell.contentView.addSubview(flatIconBtn)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 2 {
            return "圖片來源"
        }
        
        return ""
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


