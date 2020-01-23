//
//  PrivateContactVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 06/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import Contacts
import SwiftyJSON
import Alamofire
import SQLite3
import Toast_Swift


class PrivateContactVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var table_private: UITableView!
    @IBOutlet weak var infolabel: UILabel!
    @IBOutlet weak var not_found: UILabel!
    @IBOutlet weak var search: UITextField!
    
    var Names: [String] = []
    var Numbers: [String] = []
    var Find_Names: [String] = []
    var Find_Numbers: [String] = []
    var token : String!
    var dataModels = [PrivateContactModel]()
    var callview : CallVC!
    var db: OpaquePointer?
    var selected_item : Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()

        let store = CNContactStore()
        
        //Запросить разрешение у пользователя на доступ к контактам
        store.requestAccess(for: CNEntityType.contacts) { (granted:Bool, error:Error?) in
            
            //Если пользователь отказался, то отображаем сообщение
            if (!granted) {
                print("Denied")
                DispatchQueue.main.async {
                self.table_private.isHidden = true
                self.not_found.isHidden = true
                self.search.isHidden = true
                self.infolabel.isHidden = false
               }
                
            }
            else {
                print ("Granted")
                DispatchQueue.main.async {
                    self.infolabel.isHidden = true
                    self.table_private.isHidden = false
                    self.not_found.isHidden = false
                    self.search.isHidden = false
                    self.loadContacts()
                    self.refreshtable()
                }
            }
        }
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        self.table_private.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.table_private)
            if let indexPath = table_private.indexPathForRow(at: touchPoint) {
                
                print("Long pressed row: \(indexPath.row)")
                self.selected_item = indexPath.row
                self.alert(title: "Добавить в избранное?", message: "Контакт: " + self.dataModels[indexPath.row].name!  + " Телефон: " + self.dataModels[indexPath.row].number! , style: .alert)
            }
        }
    }
    
    @IBAction func editing(_ sender: Any) {
        if self.search.text?.count != 0 {
            self.FindContacts(str: self.search.text!)
            
        }
        else {
            loadContacts()
            self.refreshtable()
        }
    }
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    /// Функция загрузки контактов
    func loadContacts() {
        self.Names.removeAll()
        self.Numbers.removeAll()
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        request.sortOrder = CNContactSortOrder.givenName
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        self.Names.append(contact.givenName + " " + contact.familyName)
                        self.Numbers.append(number.stringValue)
                    }
                }
            }
        } catch {
            print("unable to fetch contacts")
        }
        
    }
    
    /// Функция обновления списка контактов
    func refreshtable () {
        let count = self.Names.count
        self.dataModels.removeAll()
        for i in 0..<count{
            self.dataModels.append(PrivateContactModel(name: self.Names[i], number: self.Numbers[i]))
            //displaying data in tableview
            self.table_private.reloadData()
            
        }
        if (dataModels.count < 1) {
            self.table_private.isHidden = true
            self.not_found.isHidden = false
        }
        else {
            self.table_private.isHidden = false
            self.not_found.isHidden = true
        }
    }
    
    /// Функция загрузки контактов
    func FindContacts(str : String) {
        if (str.count == 0) {
            self.refreshtable()
        }
        else {
            let count = self.Names.count
            self.dataModels.removeAll()
            for i in 0..<count{
                if (self.Names[i].contains(str)) {
                    self.dataModels.append(PrivateContactModel(name: self.Names[i], number: self.Numbers[i]))
                    self.table_private.reloadData()
                }
                
            }
            
            if (self.dataModels.count < 1) {
                self.table_private.isHidden = true
                self.not_found.isHidden = false
            }
            else {
                self.table_private.isHidden = false
                self.not_found.isHidden = true
            }
            
            
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PrivateContactCell
        let model: PrivateContactModel
        
        model = dataModels [indexPath.row]
        
         // Отображение значений
         cell.Name.text = model.name
         cell.Number.text = model.number
        
         return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        print(self.dataModels[indexPath.row].number!)
        let num = self.dataModels[indexPath.row].number
        var new_number = num!.replacingOccurrences(of: "-", with: "")
        new_number = new_number.replacingOccurrences(of: " ", with: "")
        new_number = new_number.replacingOccurrences(of: "(", with: "")
        new_number = new_number.replacingOccurrences(of: ")", with: "")
        new_number = new_number.replacingOccurrences(of: "+7", with: "8")
        print(new_number)
        
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
    
    
    /// Всплывающее окно
    func alert(title : String, message: String, style : UIAlertController.Style) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: style)
        let action_add = UIAlertAction (title: "Добавить", style: .default) { (action) in
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("TelefonUfanet.sqlite")
            
            if sqlite3_open(fileURL.path, &self.db) != SQLITE_OK {
                print("error opening database")
            }
            else {
                sqlite3_exec(self.db, "INSERT INTO Star (name, number) VALUES ('\(self.dataModels[self.selected_item].name!)', '\(self.dataModels[self.selected_item].number!)')", nil, nil, nil)
                self.view.makeToast("Добавлено!", duration: 1.5, position: .bottom)
        
            }

           
            
        }
        let action_dismiss = UIAlertAction (title: "Отмена", style: .destructive) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            
        }
        alertController.addAction(action_add)
        alertController.addAction(action_dismiss)
        self.present(alertController, animated: true, completion: nil)
    }
    
    

}
