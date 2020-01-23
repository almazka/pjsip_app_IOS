//
//  CallVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 02/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit

class CallVC: UIViewController {
        var tabbar : UITabBarController!

    @IBOutlet weak var b_answer: UIButton!
    
    @IBOutlet weak var endcall_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: NSNotification.Name(rawValue: "close"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(close_from_push), name: NSNotification.Name(rawValue: "close_from_push"), object: nil)
        
        if  UserDefaults.standard.string(forKey: "FromPush") == "true" {
            self.b_answer.isHidden = false
        }
        else {
            b_answer.isHidden = true
        }

    }
    
    @IBAction func answer(_ sender: Any) {
        self.b_answer.isHidden = true
        PjsipApp.shared.answer()
        
    }
    @IBAction func endcall(_ sender: Any) {
        pjsua_call_hangup_all()
        
    }
    
    
    @objc func close(notification: NSNotification) {

        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func close_from_push(notification: NSNotification) {
        
        if (UserDefaults.standard.string(forKey: "UIState") == "back") {
            exit(0)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }

}
