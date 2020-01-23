//
//  PjsipApp.swift
//  TelefonUfanet
//
//  Created by Almaz on 17/06/2019.
//

import Foundation
import UIKit
import UserNotifications
import AudioToolbox


class PjsipApp {

    static let shared = PjsipApp()
    
    var current_acc = pjsua_acc_get_default()
    var call_opt = pjsua_call_setting()
    
    var current_call: pjsua_call_id = PJSUA_INVALID_ID.rawValue
    var media_index: UInt32 = 0
    
    
    private init() {}
    

    
    func pjsuaStart(login: String, password: String) {
        var status: pj_status_t
        var accountID = pjsua_acc_id()
        var accountConfig = pjsua_acc_config()
        var pjsuaConfig = pjsua_config()
        var pjsuaMediaConfig = pjsua_media_config()
        var pjsuaLoggingConfig = pjsua_logging_config()
        var pjsuaTransportConfig = pjsua_transport_config()
        
        status = pjsua_create()
        if status != PJ_SUCCESS.rawValue {
            print("Error creating pjsua, status: \(status)")
        }
        
        
        pjsua_config_default(&pjsuaConfig)
        
        let user_agent = ("PBX" as NSString).utf8String
        pjsuaConfig.user_agent = pj_str(UnsafeMutablePointer<Int8>(mutating: user_agent))
        
    
        /* Initialize application callbacks */
        pjsuaConfig.cb.on_call_state = on_call_state
        pjsuaConfig.cb.on_incoming_call = on_incoming_call
        pjsuaConfig.cb.on_reg_state = on_reg_state

        
        
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
        
        
        pjsua_transport_config_default(&pjsuaTransportConfig)
        
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &pjsuaTransportConfig, nil)
        if status != PJ_SUCCESS.rawValue {
            print("Error creating UDP transport, status: \(status)")
        }

        
        status = pjsua_start()
        if status != PJ_SUCCESS.rawValue {
            print("Error starting pjsua, status: \(status)")
        }
        
        
        pjsua_acc_config_default(&accountConfig)
        
        
        
        let fullURL = ("sip:" + login + "@92.50.152.146:5401" as NSString).utf8String
        
        let uri = ("sip:" + login + "@92.50.152.146:5401;transport=UDP" as NSString).utf8String
        let realm = ("*" as NSString).utf8String
        let username = (login as NSString).utf8String
        let password = (password as NSString).utf8String
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
        
        status = pjsua_acc_add(&accountConfig, pj_bool_t(PJ_TRUE.rawValue), &accountID)
                
        
    }
    
    let on_call_state: @convention(c) (pjsua_call_id, UnsafeMutablePointer<pjsip_event>?) -> Void = { call_id, event in
        
        var call_info = pjsua_call_info()
        
        pjsua_call_get_info(call_id, &call_info)
        
        PjsipApp.shared.current_call = call_id
        
        
        if (call_info.state == PJSIP_INV_STATE_DISCONNECTED) {
            print("Call \(call_id) is DISCONNECTED [reason=\(call_info.last_status.rawValue) \(String(cString: call_info.last_status_text.ptr))]")
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            if (String(cString: call_info.last_status_text.ptr).contains("Terminated")) {
                print("Вызов сброшен со стороны айфона")
                if  UserDefaults.standard.string(forKey: "FromPush") == "true" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close_from_push"), object: nil)
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
                    
                }
            }
            if (String(cString: call_info.last_status_text.ptr).contains("Busy")) {
                print("Вызов сброшен со стороны абонента")
                if  UserDefaults.standard.string(forKey: "FromPush") == "true" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close_from_push"), object: nil)
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
                    
                }
            }
            if (String(cString: call_info.last_status_text.ptr).contains("Normal")) {
                print("Нормальное завершение вызова")
                if  UserDefaults.standard.string(forKey: "FromPush") == "true" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close_from_push"), object: nil)
                }
                else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "close"), object: nil)
                    
                }
            }

           
            
        
        } else {
            if (call_info.state == PJSIP_INV_STATE_EARLY) {
                var code: Int
                var reason: pj_str_t
                var msg: pjsip_msg
                let e = event!.pointee
                
                /* This can only occur because of TX or RX message */
                assert(e.type == PJSIP_EVENT_TSX_STATE)
                
                if (e.body.tsx_state.type == PJSIP_EVENT_RX_MSG) {
                    msg = e.body.tsx_state.src.rdata.pointee.msg_info.msg.pointee
                } else {
                    msg = e.body.tsx_state.src.tdata.pointee.msg.pointee
                }
                
                code = Int(msg.line.status.code)
                reason = msg.line.status.reason
                
                
                print("Call \(call_id) state changed to \(call_info.state_text.ptr.pointee) (\(code) \(reason))")
            } else {
                print("Call \(call_id) state changed to \(call_info.state_text.ptr.pointee)")
            }
            
            
        }
    }
    
    
    let on_reg_state: @convention(c) (pjsua_acc_id) -> Void = { accountID in
        var status = pj_status_t()
        var info = pjsua_acc_info()
        
        status = pjsua_acc_get_info(accountID, &info)
        
        if status != PJ_SUCCESS.rawValue {
            print("Error registration status: \(status)")
            
            return
        }
        
    }
    
    let on_incoming_call: @convention(c) (pjsua_acc_id, pjsua_call_id, UnsafeMutablePointer<pjsip_rx_data>?) -> Void = { acc_id, call_id, rdata in
        var call_info = pjsua_call_info()
        
        pjsua_call_get_info(call_id, &call_info)
        
        sleep(UInt32(0.2))
        pjsua_call_answer(call_id, 180, nil, nil)
        
        
        
        
    }
    
    func make_call (number : String) {
        var status: pj_status_t
        var callSetting = pjsua_call_setting()
        pjsua_call_setting_default(&callSetting);
        callSetting.aud_cnt = 1;

        
        var callID = pjsua_call_id()
        let destinationURI = "sip:" + number + "@92.50.152.146:5401"
        
        var calleeURI: pj_str_t = pj_str(UnsafeMutablePointer<Int8>(mutating: (destinationURI as NSString).utf8String))
        
        
        
        status = pjsua_call_make_call(current_acc, &calleeURI, &callSetting, nil, nil, &callID)
        
        if status != PJ_SUCCESS.rawValue {
            var errorMessage: [CChar] = []
            
            pj_strerror(status, &errorMessage, pj_size_t(PJ_ERR_MSG_SIZE))
            print("Outgoing call error, status: \(status), message: \(errorMessage)")
        }
        else {
            var callInfo = pjsua_call_info()
            pjsua_call_get_info(callID, &callInfo)
            sleep(UInt32(1.5))
            var callPort = pjsua_conf_port_id ()
            callPort = pjsua_call_get_conf_port(callID)
            pjsua_conf_connect(callPort, 0)
            pjsua_conf_connect(0, callPort)
            NSLog("CALLPORT STARTED SUCCESSFULLY")
        }
        
    }
    
    func answer () {
        
        pjsua_call_answer(current_call, 200, nil, nil)
        var callSetting = pjsua_call_setting()
        pjsua_call_setting_default(&callSetting);
        callSetting.aud_cnt = 1;
        

        var callInfo = pjsua_call_info()
        pjsua_call_get_info(current_call, &callInfo)
        sleep(UInt32(1.5))
        var callPort = pjsua_conf_port_id()
        callPort = pjsua_call_get_conf_port(current_call)
        pjsua_conf_connect(callPort, 0)
        pjsua_conf_connect(0, callPort)
        print("CALLPORT STARTED SUCCESSFULLY")
        
      
    }
    
    
    func pjsua_stop() {
        pjsua_destroy()
    }
    
}

