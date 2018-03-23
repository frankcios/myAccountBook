//
//  SQLiteManager.swift
//  myAccountBook
//
//  Created by frankchuang on 2017/12/11.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit
import CoreData

class SQLiteManager: NSObject {
    let manager = FileManager.default

    static let sharedInstance: SQLiteManager = {
        let instance = SQLiteManager()
        return instance
    }()
    
    override private init() {
        super.init()
    }
    
    // Returns the URL to the application's Documents directory.
    func applicationSupportDirectory() -> URL? {
        return manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    }
    
    
    func copySqliteFile(url: URL?, completionHandler: ((Bool) -> ())?) {
        
        if (url != nil) {
            
            // retrieve the store URL
            guard let persistentStore = context.persistentStoreCoordinator?.persistentStores.last else { return }
            guard let storeURL = context.persistentStoreCoordinator?.url(for: persistentStore) else { return }
            print("storeURL: \(storeURL)")
            
            context.performAndWait {
                context.reset()
                // delete the store from the current managedObjectContext
                do {
                    try context.persistentStoreCoordinator?.remove(persistentStore)
                    try manager.removeItem(at: storeURL)
                    // create the new store
                    try context.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                    
        
                    guard let copyToStoreURL = applicationSupportDirectory()?.appendingPathComponent("myAccountBook.sqlite") else { return }
                    
                    removeAllSQLiteDocumentsFiles()

                    // 從 inbox 複製到 application support
                    try manager.copyItem(at: url!, to: copyToStoreURL)
                    
                    
                } catch let error as NSError {
                    print("Error: \(error.localizedDescription)")
                }
                guard let handler = completionHandler else { return }
                handler(true)
            }
        }

    }
    
    /** 移除 Application Support 資料夾裡所有 myAccountBook.sqlite 開頭的檔案 */
    func removeAllSQLiteDocumentsFiles() {
        
        let match = "myAccountBook.sqlite-*"
        
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0]
        print(documentsDirectory)

        var allFiles: NSArray?
        // 取得 Application Support 資料夾裡的所有檔案
        do {
            allFiles = try manager.contentsOfDirectory(atPath: documentsDirectory) as NSArray
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        // filter the array for only sqlite files
        let fltr = NSPredicate(format: "self ENDSWITH '.sqlite' OR SELF like %@", match)
        
        guard let sqliteFiles = allFiles?.filtered(using: fltr) as? [String] else { return }
        
        var count = 0
        
        // use fast enumeration to iterate the array and delete the files
        for sqliteFile in sqliteFiles
        {

            // 注意URL有特殊字元會unwrap nil，此處用extension解決
            let deleteFileURL = URL.initPercent(string: "file://\(documentsDirectory)/\(sqliteFile)")
            print("deleteFileURL:", deleteFileURL)
            do {
                try manager.removeItem(at: deleteFileURL)
                count += 1
                print("Delete file success! count:\(count)")
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    /** 移除 Documents/Inbox 資料夾裡所有 .sqlite 結尾的檔案 */
    func removeAllSQLiteInboxFiles() {
        
        // the preferred way to get the apps documents directory
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = "\(paths[0])/Inbox/"
        print(documentsDirectory)
        // grab all the files in the documents dir
        var allFiles: NSArray?
        do {
            allFiles = try manager.contentsOfDirectory(atPath: documentsDirectory) as NSArray
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        // filter the array for only sqlite files
        let fltr = NSPredicate(format: "self ENDSWITH '.sqlite'", argumentArray: nil)
        
        guard let sqliteFiles = allFiles?.filtered(using: fltr) as? [String] else { return }
        
        // use fast enumeration to iterate the array and delete the files
        for sqliteFile in sqliteFiles
        {
            let deleteFileURL = URL.initPercent(string: "file://\(documentsDirectory)/\(sqliteFile)")
            print("deleteFileURL:", deleteFileURL)
            
            do {
                try manager.removeItem(at: deleteFileURL)

            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // 複製檔案到App時調用，檔案會複製到 Documents/Inbox 資料夾
    func handleOpenURL(url: URL) {
        
        print("handle url:", url)
        AlertHelper.shared.alertWith(controller: ad.findViewController()!, title: "您確定要回復嗎？", message: "回復將刪除當前數據", buttonTitle: ["不", "確定"], buttonStyle: [.destructive, .default]) { (index) in
            if (index == 1) {
                self.performSelector(onMainThread: #selector(self.restoreFromAttachedEmail(url:)), with: url, waitUntilDone: false)
            }
        }

    }
    
    func restoreFromAttachedEmail(url: URL) {
        copySqliteFile(url: url) { (finished) in
            if finished {
                // 複製完成把 Documents/Inbox 資料夾裡的檔案刪除
                // 不然會每複製檔案到App就增加一個檔案
                self.removeAllSQLiteInboxFiles()
                
                // update UI
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: refreshRecordNotification), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: refreshChartNotification), object: nil)
                
                AlertHelper.shared.alertWith(controller: ad.findViewController()!, title: "回復完成", message: nil, buttonTitle: ["OK"], buttonStyle: nil, completionHandler: nil)
                print("Database restore is successful!")
            } else {
                print("Fail to restore database!")
            }
        }
    }
    
}
