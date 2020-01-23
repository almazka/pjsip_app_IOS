

import UIKit
import UserNotifications
import PushKit
import SwiftyJSON
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate{
    

    var window: UIWindow?
  
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }


    ///
    // Register for VoIP notifications
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let voiptoken = pushCredentials.token.reduce("") { $0 + String(format: "%02x", $1) }
        UserDefaults.standard.set(voiptoken, forKey: "voipToken")
        print(voiptoken)
        
    }
    
    // Handle incoming pushes
    func pushRegistry(registry: PKPushRegistry!, didReceiveIncomingPushWithPayload payload: PKPushPayload!, forType type: String!) {
        // Process the received push
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        NSLog("incoming voip notfication:, %@", payload.dictionaryPayload)
        let json = JSON(payload.dictionaryPayload)
        let aps = json["aps"].dictionaryValue
        let alert = aps["alert"]!.stringValue
        let body = aps["body"]!.stringValue
        let badge = aps["badge"]!.intValue
        
        let content = UNMutableNotificationContent()
        content.title = alert
        content.body = body
        content.sound = UNNotificationSound.default
        
        switch UIApplication.shared.applicationState {
        case .background, .inactive:
                UserDefaults.standard.set("back", forKey: "UIState")
                PjsipApp.shared.pjsua_stop()
                PjsipApp.shared.pjsuaStart(login: UserDefaults.standard.string(forKey: "sip_log")!, password: UserDefaults.standard.string(forKey: "sip_pass")!)
            break
        case .active:
                UserDefaults.standard.set("active", forKey: "UIState")
            break
        default:
            break
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "pushcall", content: content, trigger: trigger)
        
        UIApplication.shared.applicationIconBadgeNumber = badge
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    
    
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        debugPrint("invalidate")
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("granted: \(granted)")
       }
        
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.voipRegistration()
        
        return true
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "pushcall" {
    
            UIApplication.shared.applicationIconBadgeNumber = 0
            UserDefaults.standard.set("true", forKey: "FromPush")
            
            
            if (UserDefaults.standard.string(forKey: "UIState") == "back") {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Storyboard", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "CallVC") as! CallVC
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewControlleripad
                self.window?.makeKeyAndVisible()
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "incoming_view_present"), object: nil)
            }
            
            
            
        }
        else {
            print("false")
        }
        completionHandler()
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    

    func applicationDidEnterBackground(_ application: UIApplication) {
     
    }
    

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
         PjsipApp.shared.pjsua_stop()
         print("terminate")
    }
    
    

}

