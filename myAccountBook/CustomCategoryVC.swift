//
//  CustomCategoryVC.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/18.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit

class CustomCategoryVC: BaseVC, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let cellId = "CellId"
    let inputCellId = "inputCellId"


    lazy var insertTextField: UITextField = {
        let frame = CGRect(x: 15, y: 0, width: self.fullSize.width - 20, height: 40)
        let textField = UITextField(frame: frame)
        textField.tag = 102
        textField.placeholder = "請輸入文字以添加分類"
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        insertTextField.delegate = self
        
        // 註冊Cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: inputCellId)

        // 按一下空白處隱藏編輯狀態
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostVC.hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       loadcustomCategories()
    }
    
    func setCustomCategories() {
        // 儲存自定義分類
        myUserDefaults.set(customCategories, forKey: "customCategories")
        myUserDefaults.synchronize()
    }

    func loadcustomCategories() {
        // 讀取自定義分類
        if let okCategories = myUserDefaults.object(forKey: "customCategories") as? [String] {
            customCategories = okCategories
        }
    }
    
    @IBAction func dismissCustomCategoryVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func becomeEdit(_ sender: UIBarButtonItem) {
        
        let isEditing = tableView.isEditing
        tableView.setEditing(!isEditing, animated: true)
    }
    
    func popAlertForSelectedRow(at indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "修改", message: nil, preferredStyle: .alert)
        
        // 添加textfield
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].keyboardType = .default
        
        // assign value
        alert.textFields?[0].text = customCategories[indexPath.row]
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            guard let text = alert.textFields?[0].text else { return }
            self.customCategories[indexPath.row] = text
            
            self.setCustomCategories()
            
            // 刷新一行表格
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return customCategories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = nil
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: inputCellId)
            cell.accessoryType = .none
            cell.contentView.addSubview(insertTextField)
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            cell.textLabel?.text = customCategories[indexPath.row]
            cell.accessoryType = .disclosureIndicator
        }
        
//        print("cellForRowAt---", indexPath.row, cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      
        if section == 0 {
            return "新增"
        }
        return nil
    }
    
    // sorting
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let row = sourceIndexPath.row
        let sourceCategory = customCategories[row]
        customCategories.remove(at: row)
        customCategories.insert(sourceCategory, at: destinationIndexPath.row)
        
        setCustomCategories()
    }

    
    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        popAlertForSelectedRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            customCategories.remove(at: indexPath.row)
            
            let indexPath = IndexPath(row: indexPath.row, section: 1)
            tableView.deleteRows(at: [indexPath], with: .top)
            
            setCustomCategories()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      
        if textField.text == "" {
            textField.enablesReturnKeyAutomatically = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let text = textField.text {
            customCategories.insert(text, at: 0)
            
            setCustomCategories()
        }
        
        textField.text = ""
        
        tableView.reloadData()
        
        return true
    }
    
    // 按空白處會隱藏編輯狀態
    func hideKeyboard(_ tapG: UITapGestureRecognizer?) {
        self.view.endEditing(true)
    }
    
    

}
