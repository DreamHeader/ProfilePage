//
//  NotificationCoordinate.swift
//  unipets-ios
//
//  Created by LRanger on 2021/11/4.
//

import UIKit

class NotificationCoordinate {
    
    static let shared = NotificationCoordinate()
    
    private var info = [String: NSObjectProtocol]()
    
    init () {
        
    }
    
    @discardableResult
    func subscribe(key: String, forName: NSNotification.Name, once: Bool = false, _ response: @escaping (_ object: Any?) -> Void) -> NotificationCoordinate {
        let token = NotificationCenter.default.addObserver(forName: forName, object: nil, queue: nil) { not in
            response(not.object)
            if once {
                self.removeSubscribe(key: key)
            }
        }
        info[key] = token
        return self
    }
    
    func removeSubscribe(key: String) {
        info[key] = nil
    }
    
    func post(forName: NSNotification.Name, object: Any?) {
        NotificationCenter.default.post(name: forName, object: object)
    }
    

}
