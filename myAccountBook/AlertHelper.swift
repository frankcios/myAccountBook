//
//  AlertHelper.swift
//  myAccountBook
//
//  Created by  Frank Chuang on 2017/12/24.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit

class AlertHelper: NSObject {
    
    static let shared = AlertHelper()
    
    override init() {
        super.init()
    }
    
    func alertWith(controller: UIViewController, title: String?, message: String?, buttonTitle: [String]?, buttonStyle: [UIAlertActionStyle]? = nil, completionHandler: ((NSInteger) -> ())?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var isShowing = false
        
        for (index, value) in (buttonTitle?.enumerated())! {
            
            if buttonStyle == nil {
                let action = UIAlertAction(title: value, style: .default) { (_) in
                    guard let handler = completionHandler else { return }
                    handler(index)
                }
                alert.addAction(action)
            }
            else {
                let action = UIAlertAction(title: value, style: buttonStyle![index]) { (_) in
                    guard let handler = completionHandler else { return }
                    handler(index)
                }
                alert.addAction(action)
            }
        }
        
        if !isShowing {
            controller.present(alert, animated: true, completion: {
                isShowing = true
            })
        }
    }
    
}
