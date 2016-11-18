//
//  Record+CoreDataProperties.swift
//  myAccountBook
//
//  Created by Frank on 2016/11/3.
//  Copyright © 2016年 frankc. All rights reserved.
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record");
    }
    
    @NSManaged public var id: Int32 
    @NSManaged public var title: String
    @NSManaged public var amount: Double
    @NSManaged public var yearMonth: String
    @NSManaged public var createDate: String
    @NSManaged public var createTime: String

}
