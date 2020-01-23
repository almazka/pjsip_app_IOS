//
//  StarContactVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 07/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import SQLite3
import Toast_Swift


class StarContactVC: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    var db: OpaquePointer?
    var dataModels = [StarContactsModel]()
    var Names: [String] = []
    var Numbers: [String] = []
    var callview : CallVC!
    
    @IBOutlet weak var infolabel: UILabel!
    
    @IBOutlet weak var table_star: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("TelefonUfanet.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Star (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, number TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
       self.readValues()
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name(rawValue: "update"), object: nil)
       
    }
    
    @objc func update(notification: NSNotification) {
            DispatchQueue.main.async {
                self.readValues()
        }
        
    }
    
    
    
    func readValues(){
        self.dataModels.removeAll()
        self.Names.removeAll()
        self.Numbers.removeAll()
        
        let queryString = "SELECT * FROM Star"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let number = String(cString: sqlite3_column_text(stmt, 2))
            self.Names.append(name)
            self.Numbers.append(number)
            self.dataModels.append(StarContactsModel(name: name, number: number))
        }
        
        if (self.Names.count == 0) {
            self.table_star.isHidden = true
            self.infolabel.isHidden = false
            self.table_star.reloadData()
        }
        else {
            self.infolabel.isHidden = true
            self.table_star.isHidden = false
            self.table_star.reloadData()
        }
        
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "star_cell", for: indexPath) as! StarContactsCell
        let model: StarContactsModel
        
        model = self.dataModels [indexPath.row]
        
        // Отображение значений
        cell.Name.text = model.name
        cell.Number.text = model.number
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let num = self.Numbers[indexPath.row]
        var new_number = num.replacingOccurrences(of: "-", with: "")
        new_number = new_number.replacingOccurrences(of: " ", with: "")
        new_number = new_number.replacingOccurrences(of: "(", with: "")
        new_number = new_number.replacingOccurrences(of: ")", with: "")
        new_number = new_number.replacingOccurrences(of: "+7", with: "8")
        
        let current_acc = pjsua_acc_get_default()
        var info = pjsua_acc_info()
        
        pjsua_acc_get_info(current_acc, &info)
        
        if (info.status.rawValue == 200){
            
            PjsipApp.shared.make_call(number: new_number)
            self.callview = (self.storyboard!.instantiateViewController(withIdentifier: "CallVC") as? CallVC)
            self.present(self.callview, animated: true, completion: nil)
            
        }
        else {
            self.view.makeToast("Ошибка регистрации!", duration: 1.5, position: .bottom)
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Удалить"
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if sqlite3_exec(self.db, "DELETE FROM Star WHERE name = '\(self.Names[indexPath.row])'", nil, nil, nil) != SQLITE_OK {
                
            }
            else {
            self.view.makeToast("Удалено!", duration: 1.5, position: .bottom)
            self.readValues()
            }
        }
    }

    

}
