//
//  PostVC+Extension.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/5.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit

extension PostVC: UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - UITextFieldDelegate
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
        
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customCategories.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        titleTextField.text = customCategories[row]
    }
    
}
