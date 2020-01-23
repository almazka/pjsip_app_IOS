//
//  WorkedContactVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 06/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class WorkedContactVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    
    var Names: [String] = []
    var Numbers: [String] = []
    var Descriptions: [String] = []
    var dataModels = [WorkedContacModel]()
    var callview : CallVC!
    var token: String!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var infolabel: UILabel!
    @IBOutlet weak var table_worked: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.token = (self.tabBarController?.viewControllers?[2] as? SoftPhoneVC)?.token
            self.LoadContactsFromPortal(token: self.token as String)
            
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.table_worked.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)

    }
    
    @objc func loadList(notification: NSNotification){
        if (self.infolabel.isHidden == false) {
            DispatchQueue.main.async {
                self.token = (self.tabBarController?.viewControllers?[2] as? SoftPhoneVC)?.token
                self.LoadContactsFromPortal(token: self.token as String)
            }
        }
       
    }
    
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.LoadContactsFromPortal(token: self.token as String)
            self.refreshControl.endRefreshing()
        }
        
    }
 
    
    func LoadContactsFromPortal (token: String) {
            self.dataModels.removeAll()
            self.Names.removeAll()
            self.Numbers.removeAll()
            self.Descriptions.removeAll()
            Alamofire.request("https://telefon.ufanet.ru/api/Contacts", method: .get, headers: ["Authorization": token]).responseJSON {
                (response) -> Void in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if (json.count == 0) {
                        self.table_worked.isHidden = true
                        self.infolabel.isHidden = false
                    }
                    else {
                        for i in 0..<json.count {
                        let dict_numbers = json[i].dictionaryValue
                        let email = dict_numbers["email"]!.stringValue
                        let company = dict_numbers["company"]!.stringValue
                        let position = dict_numbers["position"]!.stringValue
                        let lastname = dict_numbers["lastName"]!.stringValue
                        let firstName = dict_numbers["firstName"]!.stringValue
                        let finalarray = JSON(dict_numbers["phoneNumbers"] as Any)
                        let num_dic = finalarray[0].dictionaryValue
                        let num = num_dic["phoneNumber"]!.stringValue
                        print("        " + email)
                        print("        " + firstName)
                        print("        " + lastname)
                        print("        " + num)
                        print("        " + company)
                        print("        " + position)
                        print("        ")
                        self.Names.append(firstName + " " + lastname)
                        self.Numbers.append(num)
                        self.Descriptions.append(company + " " + position + " " + email)
                        }
                        self.infolabel.isHidden = true
                        self.table_worked.isHidden = false
                        self.refreshtable()
                    }
                    
                }
            }
            
        
    }
    
    
    /// Функция обновления списка контактов
    func refreshtable () {
        let count = self.Names.count
        for i in 0..<count{
            self.dataModels.append(WorkedContacModel(name: self.Names[i], number: self.Numbers[i], description: self.Descriptions[i]))
            //displaying data in tableview
            self.table_worked.reloadData()
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "worked_cell", for: indexPath) as! WorkedContactCell
        let model: WorkedContacModel
        
        model = dataModels [indexPath.row]
        
        // Отображение значений
        cell.Name.text = model.name
        cell.Number.text = model.number
        cell.Description.text = model.description
        
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


}
