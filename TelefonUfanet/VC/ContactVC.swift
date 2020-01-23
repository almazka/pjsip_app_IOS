//
//  ContactVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 23/05/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import Contacts
import SwiftyJSON
import Alamofire


class ContactVC: UIViewController {
    
    
    //a list to store DataModel
    
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var PrivateView: UIView!
    @IBOutlet weak var StarView: UIView!
    @IBOutlet weak var WorkedView: UIView!

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func SegmentIndexChange(_ sender: Any) {
        
        switch self.SegmentController.selectedSegmentIndex
        {
        case 0:
            self.StarView.isHidden = false
            self.WorkedView.isHidden = true
            self.PrivateView.isHidden = true
            view.endEditing(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
        case 1:
            self.StarView.isHidden = true
            self.WorkedView.isHidden = false
            self.PrivateView.isHidden = true
            view.endEditing(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        case 2:
            self.StarView.isHidden = true
            self.WorkedView.isHidden = true
            self.PrivateView.isHidden = false
            view.endEditing(true)
        default:
            break
        }
    }
    

    
    
    /// Всплывающее окно предупреждения
    func alert(title : String, message: String, style : UIAlertController.Style) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: style)
        let action = UIAlertAction (title: "ОК", style: .default) { (action) in
            
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
}

