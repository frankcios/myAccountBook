//
//  MoreVC.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/13.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit
import MessageUI

class MoreVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate  {

    // 取得螢幕尺寸
    let fullSize: CGSize = UIScreen.main.bounds.size
    
    let myUserDefaults = UserDefaults.standard
    
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
        UIApplication.shared.open(requestUrl!, options: ["" : ""], completionHandler: nil)
    }
    
    // Mark: - Email
    func contactMe() {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        composeVC.setSubject("聯絡開發者")
        composeVC.setToRecipients(["pk15678@gmail.com"])
        composeVC.setMessageBody("app Version: \(version!) (\(build!))", isHTML: false)
        
        // present
        present(composeVC, animated: true, completion: nil)
    }
    
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
    
    func pushToChartVC() {
        performSegue(withIdentifier: "showChart", sender: nil)
    }

    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.accessoryType = .none
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "音效"
            cell.accessoryView = mySwitch
            
        } else if indexPath.section == 1 {
            
            let frame = CGRect(x: 15, y: 0, width: fullSize.width, height: 40)
            let flatIconBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.goFlatIcon), title: "FLATICON", color: UIColor.black)
            cell.contentView.addSubview(flatIconBtn)
            
        } else if indexPath.section == 2 {
            
            let frame = CGRect(x: 15, y: 0, width: fullSize.width, height: 40)
            let contactBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.contactMe), title: "寄信給開發者", color: UIColor.black)
            cell.contentView.addSubview(contactBtn)
            
        } else if indexPath.section == 3 {
            
            let frame = CGRect(x: 15, y: 0, width: fullSize.width, height: 40)
            let chartBtn = UIButton.buttonWith(frame: frame, target: self, action: #selector(MoreVC.pushToChartVC), title: "圖表分析", color: UIColor.black)
            cell.contentView.addSubview(chartBtn)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = "圖表"
        if section == 0 {
            title = "設定"
        } else if section == 1 {
            title = "圖片來源"
        } else if section == 2 {
            title = "聯絡"
        }
        
        return title
    }
}


