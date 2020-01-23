

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
            })
        }
    
    }
    
    @IBAction func testSip(_ sender: Any) {
        var status: pj_status_t
        
        status = pjsua_create()
        if status != PJ_SUCCESS.rawValue {
            print("Error creating pjsua, status: \(status)")
        }
        
        var pjsuaConfig = pjsua_config()
        var pjsuaMediaConfig = pjsua_media_config()
        var pjsuaLoggingConfig = pjsua_logging_config()
        
        pjsua_config_default(&pjsuaConfig)
        let user_agent = ("PBX" as NSString).utf8String
        pjsuaConfig.user_agent = pj_str(UnsafeMutablePointer<Int8>(mutating: user_agent))
        
        
        // Have to add proxy in order to use "sip" instead of "sips" for full URI
        
        
        // Media config
        pjsua_media_config_default(&pjsuaMediaConfig)
        pjsuaMediaConfig.clock_rate = 16000
        pjsuaMediaConfig.snd_clock_rate = 0
        
        // Logging config
        pjsua_logging_config_default(&pjsuaLoggingConfig)
        #if DEBUG
        pjsuaLoggingConfig.msg_logging = pj_bool_t(PJ_TRUE.rawValue)
        pjsuaLoggingConfig.console_level = 4
        pjsuaLoggingConfig.level = 4
        #else
        pjsuaLoggingConfig.msg_logging = pj_bool_t(PJ_FALSE.rawValue)
        pjsuaLoggingConfig.console_level = 0
        pjsuaLoggingConfig.level = 0
        #endif
        
        // Init
        status = pjsua_init(&pjsuaConfig, &pjsuaLoggingConfig, &pjsuaMediaConfig)
        
        if status != PJ_SUCCESS.rawValue {
            print("Error initializing pjsua, status: \(status)")
    
        }
        
        // Transport config
        var pjsuaTransportConfig = pjsua_transport_config()
        
        pjsua_transport_config_default(&pjsuaTransportConfig)
        
         status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &pjsuaTransportConfig, nil)
         if status != PJ_SUCCESS.rawValue {
         print("Error creating UDP transport, status: \(status)")
         }
        
        
        status = pjsua_start()
        if status != PJ_SUCCESS.rawValue {
            print("Error starting pjsua, status: \(status)")
        }
        
        
        var accountID = pjsua_acc_id()
        var accountConfig = pjsua_acc_config()
        
        pjsua_acc_config_default(&accountConfig)
        
        let fullURL = ("sip:3805@92.50.152.146:5401" as NSString).utf8String
        // Always use "sips" for server
        let uri = ("sip:3805@92.50.152.146:5401;transport=UDP" as NSString).utf8String
        let realm = ("*" as NSString).utf8String
        let username = ("3805" as NSString).utf8String
        let password = ("9TAAWyDq4j" as NSString).utf8String
        let scheme = ("Digest" as NSString).utf8String
        
        
        accountConfig.id = pj_str(UnsafeMutablePointer<Int8>(mutating: fullURL))
        accountConfig.reg_uri = pj_str(UnsafeMutablePointer<Int8>(mutating: uri))
        accountConfig.reg_retry_interval = 0
        accountConfig.cred_count = 1
        accountConfig.cred_info.0.realm = pj_str(UnsafeMutablePointer<Int8>(mutating: realm))
        accountConfig.cred_info.0.scheme = pj_str(UnsafeMutablePointer<Int8>(mutating: scheme))
        accountConfig.cred_info.0.username = pj_str(UnsafeMutablePointer<Int8>(mutating: username))
        accountConfig.cred_info.0.data_type = Int32(PJSIP_CRED_DATA_PLAIN_PASSWD.rawValue)
        accountConfig.cred_info.0.data = pj_str(UnsafeMutablePointer<Int8>(mutating: password))
        accountConfig.allow_via_rewrite = 0
        accountConfig.allow_contact_rewrite = 0
        // Show incoming video
        accountConfig.vid_in_auto_show = pj_bool_t(PJ_TRUE.rawValue)
        accountConfig.vid_out_auto_transmit = pj_bool_t(PJ_TRUE.rawValue)
        accountConfig.vid_wnd_flags = PJMEDIA_VID_DEV_WND_BORDER.rawValue | PJMEDIA_VID_DEV_WND_RESIZABLE.rawValue
        accountConfig.vid_cap_dev = PJMEDIA_VID_DEFAULT_CAPTURE_DEV.rawValue
        accountConfig.vid_rend_dev = PJMEDIA_VID_DEFAULT_RENDER_DEV.rawValue
        
        
       status = pjsua_acc_add(&accountConfig, pj_bool_t(PJ_TRUE.rawValue), &accountID)
        
        if status != PJ_SUCCESS.rawValue {
            print("Register error, status: \(status)")
        }
        
        sleep(2)
        
        
        var callSetting = pjsua_call_setting()
        pjsua_call_setting_default(&callSetting);
        callSetting.aud_cnt = 1;
        callSetting.vid_cnt = 0; // TODO: Video calling support?
        
  
        var callID = pjsua_call_id()
        let destinationURI = "sip:3006@92.50.152.146:5401"
        
        var calleeURI: pj_str_t = pj_str(UnsafeMutablePointer<Int8>(mutating: (destinationURI as NSString).utf8String))
        
        status = pjsua_call_make_call(accountID, &calleeURI, &callSetting, nil, nil, &callID)
        
        if status != PJ_SUCCESS.rawValue {
            var errorMessage: [CChar] = []
            
            pj_strerror(status, &errorMessage, pj_size_t(PJ_ERR_MSG_SIZE))
            print("Outgoing call error, status: \(status), message: \(errorMessage)")
            fatalError()
        }
        
        var callInfo = pjsua_call_info()
        pjsua_call_get_info(callID, &callInfo)
        
        
        sleep(3)
        var callPort = pjsua_conf_port_id ()
        callPort = pjsua_call_get_conf_port(callID)
        pjsua_conf_connect(callPort, 0)
        pjsua_conf_connect(0, callPort)
        NSLog("CALLPORT STARTED SUCCESSFULLY")
        

    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        save()
    }
    
    func save(){
        UserDefaults.standard.set(emailField.text, forKey: "email")
    }

}

