//
//  ViewController.swift
//  TelefonUfanet
//
//  Created by almaz on 14.09.2018.
//  Copyright © 2018 ufanet. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire



class LoginVC: UIViewController {

    
    @IBOutlet weak var tvLogin: UITextField!
    @IBOutlet weak var tvPassword: UITextField!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var b_login: UIButton!
    var tabbar : UITabBarController!
    
    var result : String = ""
    var token : String = ""
    var token1 : String = ""
    var sip_login: String = ""
    var sip_pass: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self .progressBar.stopAnimating()
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
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

    @IBAction func ButtonLogin(_ sender: Any) {
        self.result = ""
        if self.tvLogin.text?.count == 0 || self.tvPassword.text?.count == 0 {
           self.alert(title: "Ошибка", message: "Не введен логин или пароль", style: .alert)
        }
        else {
            if self.tvLogin.text?.contains("@") == false {
                self.alert(title: "Ошибка", message: "Войдите под учетной записью с типом Софтфон", style: .alert)
            }
            else {
              b_login.self.isEnabled = false
              progressBar.startAnimating()
              MakeGetQuery(address: "https://calltracking.ufanet.ru/includes/app.php?user=" + self.tvLogin.text! + "&pass=" + self.tvPassword.text!)
                let queue = DispatchQueue.global(qos: .utility)
                queue.async{
                    while self.result == "" {
                    }
                    DispatchQueue.main.async {
                        if self.result.count == 13 {
                            self.alert(title: "Ошибка", message: "Неверный логин или пароль", style: .alert)
                        }
                        else if self.result.count > 20 {
                            self.token = self.result
                            self.result = ""
                            self.MakeGetQuery(address: "https://calltracking.ufanet.ru/includes/app.php?user=api_user&pass=gl8LQwNY89")
                            let queue1 = DispatchQueue.global(qos: .utility)
                            queue1.async{
                                while self.result == "" {
                                }
                                DispatchQueue.main.async {
                                    self.token1 = self.result
                                    
                                    let url = URL (string: "https://telefon.ufanet.ru/api/Users/Get?username="+self.tvLogin.text!)
                                    var request = URLRequest(url: url!)
                                    request.httpMethod = "GET"
                                    
                                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                    request.addValue(self.token1, forHTTPHeaderField: "Authorization")
                                    
                                    
                                    
                                    Alamofire.request("https://telefon.ufanet.ru/api/Users/Get?username="+self.tvLogin.text!, method: .get, headers: ["Authorization": self.token1]).responseJSON {
                                        
                                        (response) -> Void in
                                        if let value = response.result.value {
                                            let json = JSON(value)
                                            let numbers = json["numbers"].arrayValue
                                            let dict_numbers = numbers[0].dictionaryValue
                                            
                                            self.sip_login = dict_numbers["sip_login"]!.stringValue
                                            print(self.sip_login)
                                          
                                            self.sip_pass = dict_numbers["sip_password"]!.stringValue
                                            print(self.sip_pass)
                                            self.b_login.self.isEnabled = true
                                            self.progressBar.stopAnimating()
                                            
                                            
                                            
                                            self.tabbar = UITabBarController()
                                            self.tabbar = (self.storyboard!.instantiateViewController(withIdentifier: "Tabbar") as? UITabBarController)
                                            (self.tabbar?.viewControllers?[2] as? SoftPhoneVC)?.sip_login = self.sip_login
                                            (self.tabbar?.viewControllers?[2] as? SoftPhoneVC)?.sip_pass = self.sip_pass
                                            self.tabbar.selectedIndex = 2
                                            self.present(self.tabbar, animated: true, completion: nil)
                                            
                                    
                                        }
                                    }
                                    
      
                                }
                            }
                       
                        }
                        
                    }
                    
                }
                
                
            }
        }
    }
    
    
    
    func MakeGetQuery (address: String) {
        
        
        let url = URL (string: address)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard data != nil else {
                print("data is empty")
                return
            }
            
            self.GetTokenQuery(address: "https://calltracking.ufanet.ru/app/token.txt")
            
            }.resume()
    }
    
    
    
    func GetTokenQuery (address: String) {
        
        
        let url = URL (string: address)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("data is empty")
                return
            }
            
            let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
            
            self.result = result as String
            
            
            }.resume()
        
    }
    
    func alert(title : String, message: String, style : UIAlertController.Style) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: style)
        let action = UIAlertAction (title: "ОК", style: .default) { (action) in
            
            self.b_login.self.isEnabled = true
            self.progressBar.stopAnimating()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    

    
}
