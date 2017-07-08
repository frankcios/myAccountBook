//
//  UIButton+Extension.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/5.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit

extension UIButton {
    class func buttonWith(frame: CGRect, target: Any?, action: Selector, title: String, color: UIColor) -> UIButton {
        let btn = UIButton(frame: frame)
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.contentHorizontalAlignment = .left
        return btn
    }
}
