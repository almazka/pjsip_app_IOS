//
//  SoftPhoneVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 20/05/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


class SoftPhoneVC: UIViewController {
    
    
    var sip_login : String!
    var sip_pass : String!
    var sip_status : UInt32!
    var token : String!
    var call_state : Bool!
    var callview : CallVC!
    
    @IBOutlet weak var b_delete: UIButton!
    @IBOutlet weak var label_number: UILabel!
    @IBOutlet weak var b_makecall: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label_number.text = ""
        self.b_delete.self.isHidden = true
        print ("started SoftPhoneVc")
        
        self.sip_login = UserDefaults.standard.string(forKey: "sip_log")
        self.sip_pass = UserDefaults.standard.string(forKey: "sip_pass")
        self.token = UserDefaults.standard.string(forKey: "token")
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(incoming_view_present), name: NSNotification.Name(rawValue: "incoming_view_present"), object: nil)
        
        PjsipApp.shared.pjsuaStart(login: self.sip_login , password: self.sip_pass)
    
    }
    
    
    @IBAction func b_one(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "1"
        AudioServicesPlaySystemSound(1201)
            self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_two(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "2"
        AudioServicesPlaySystemSound(1202)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_three(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "3"
        AudioServicesPlaySystemSound(1203)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_four(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "4"
        AudioServicesPlaySystemSound(1204)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_five(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "5"
        AudioServicesPlaySystemSound(1205)
        self.b_delete.self.isHidden = false
        }
    }

    @IBAction func b_six(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "6"
        AudioServicesPlaySystemSound(1206)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_seven(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "7"
        AudioServicesPlaySystemSound(1207)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_eight(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "8"
        AudioServicesPlaySystemSound(1208)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_nine(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "9"
        AudioServicesPlaySystemSound(1209)
        self.b_delete.self.isHidden = false
        }
    }
    
    
    @IBAction func b_noll(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "0"
        AudioServicesPlaySystemSound(1200)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_aster(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "*"
        AudioServicesPlaySystemSound(1201)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_hash(_ sender: Any) {
        if(self.label_number.text!.count < 14) {
        self.label_number.text = self.label_number.text! + "#"
        AudioServicesPlaySystemSound(1203)
        self.b_delete.self.isHidden = false
        }
    }
    
    @IBAction func b_makecall(_ sender: Any) {
        let current_acc = pjsua_acc_get_default()
        var info = pjsua_acc_info()
        
       pjsua_acc_get_info(current_acc, &info)
        
        if (info.status.rawValue == 200){
            
            if (self.label_number.text != "") {
                UserDefaults.standard.set("false", forKey: "FromPush")
                PjsipApp.shared.make_call(number: self.label_number.text!)
                self.callview = (self.storyboard!.instantiateViewController(withIdentifier: "CallVC") as? CallVC)
                self.present(self.callview, animated: true, completion: nil)
                
            }
            else {
                self.alert(title: "Ошибка", message: "Введите номер телефона", style: .alert)
            }
        }
        else {
            self.alert(title: "Ошибка", message: "Регистрация не удалась", style: .alert)
        }
        
    }
    
    @IBAction func b_delete(_ sender: Any) {
        if (self.label_number.text!.count > 1) {
            let string: String = self.label_number.text!
            let endIndex = string.index(string.endIndex, offsetBy: -1)
            let truncated = string.substring(to: endIndex)
            self.label_number.text = truncated
            
        }
        else {
            self.label_number.text = ""
            self.b_delete.self.isHidden = true
        }
    }
    
    
    func hangup() {
        pjsua_call_hangup_all()
        
    }
    

    func alert(title : String, message: String, style : UIAlertController.Style) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: style)
        let action = UIAlertAction (title: "ОК", style: .default) { (action) in
            
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    

    @objc func incoming_view_present() {
        self.callview = (self.storyboard!.instantiateViewController(withIdentifier: "CallVC") as? CallVC)
        self.present(self.callview, animated: true, completion: nil)
    
    }
    
    


}
