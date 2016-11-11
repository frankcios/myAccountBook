//
//  RecordCell.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/5.
//  Copyright © 2016年 frankc. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configureCell(record: Record) {
        
        titleLabel.text = record.title
        priceLabel.text = String(format: "%g", record.amount)
    }
}
