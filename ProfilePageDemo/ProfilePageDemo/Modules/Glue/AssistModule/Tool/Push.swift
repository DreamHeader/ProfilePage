//
//  Push.swift
//  unipets-ios
//
//  Created by LRanger on 2021/10/9.
//

import Foundation
import UserNotifications
import UIKit

class Push: NSObject {
    /*
     AppKey
     AppKey 释义
     AppKey 为极光平台应用的唯一标识。
     */
    static let kAppKey = "21fe3eace1a8f506a9a7f7fc"

    private static let _push = Push()
    
    static func shared() -> Push {
        return _push
    }

    func register() {
        let config = JPUSHRegisterEntity.init()
        config.types = Int(JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue | JPAuthorizationOptions.alert.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: config, delegate: self)
        
//        // 推送模拟
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.handlePushMessage(message: ["moduleName": "media", "actionName": "record", "params": ""])
//        }
    }

    func setup(launchOptions: [AnyHashable: Any]?) {
        JPUSHService.setup(withOption: launchOptions ?? [:], appKey: Push.kAppKey, channel: "App Store", apsForProduction: true)
        if let opt = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? UPJson {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.handlePushMessage(message: opt)
            }
        }
    }
    
    static func jPushId() -> String {
        return safe(JPUSHService.registrationID())
    }
    
    static func deviceToken() -> String {
        return ""
    }
    
    static func pushAuthorizationSattus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            DispatchQueue.main.async {
                completion(setting.authorizationStatus == .authorized)
            }
        }
    }
    
}

extension Push: JPUSHRegisterDelegate {
    
    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        
    }
    
    // iOS12
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!) {
        
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!) -> Int {
        
        return Int(UNNotificationPresentationOptions.badge.rawValue)
    }
    
    /**
     {
         alert =     {
             body = Push;
             title = Push;
         };
         badge = 1;
         "interruption-level" = active;
         "mutable-content" = 1;
         sound = default;
     }
     */
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        // 处理通知消息
        if response != nil {
            let userInfo = response.notification.request.content.userInfo
            JPUSHService.handleRemoteNotification(userInfo)
            
            var messages: [AnyHashable: Any]?
            messages = userInfo["extras"] as? [AnyHashable: Any]
            if messages == nil {
                messages = userInfo
            }
            
            if let messages = messages {
                self.handlePushMessage(message: messages)
            }
            
        }
        completionHandler()
        
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        completionHandler(0)
    }

}

extension Push {
     func handlePushMessage(message: [AnyHashable: Any]) {
        if let por: LinkServicePortal = "LinkServicePortal".getModule() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                por.openModule(modle: message.stringValue("moduleName") ?? "", action: message.stringValue("actionName") ?? "", params: (message["params"] as? UPJson) ?? [:])
            }
        }
    }
}
