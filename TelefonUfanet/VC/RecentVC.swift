//
//  RecentVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 04/07/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import SQLite3

class RecentVC: UIViewController {
    
    

    var db: OpaquePointer?
    var Names: [String] = []
    var Numbers: [String] = []
    var Descriptions: [String] = []
    var dataModels = [RecentContacModel]()
    var callview : CallVC!
    
    @IBOutlet weak var table_recent: UITableView!
    @IBOutlet weak var info: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RecentVC started")
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("TelefonUfanet.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Recent (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, number TEXT, description TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        self.readValues()
    }
    
    
    func readValues(){
        self.dataModels.removeAll()
        self.Names.removeAll()
        self.Numbers.removeAll()
        
        let queryString = "SELECT * FROM Recent"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let number = String(cString: sqlite3_column_text(stmt, 2))
            let description = String (cString: sqlite3_column_text(stmt, 3))
            self.Names.append(name)
            self.Numbers.append(number)
            self.Descriptions.append(description)
            self.dataModels.append(RecentContacModel(name: name, number: number, description: description))
        }
        
        if (self.Names.count == 0) {
            self.table_recent.isHidden = true
            self.info.isHidden = false
            self.table_recent.reloadData()
        }
        else {
            self.info.isHidden = true
            self.table_recent.isHidden = false
            self.table_recent.reloadData()
        }
        
        
    }
    
    

}
