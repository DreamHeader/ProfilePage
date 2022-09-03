//
//  Button+UP.swift
//  unipets-ios
//
//  Created by Future on 2022/1/20.
//

import Foundation
import UIKit

extension UIButton {
    
    private struct associatedKeys {
        
        static let defaultAcceptEventInterval: Double = 0.0
        
        static var UIControl_acceptEventInterval = "UIControl_acceptEventInterval"
        
        static var UIControl_acceptEventTime = "UIControl_acceptEventTime"
    }
    // 外部设置事件触发的时间间隔
    var acceptEventInterval: Double {
        get {
            return (objc_getAssociatedObject(self, &associatedKeys.UIControl_acceptEventInterval )) as? Double ?? associatedKeys.defaultAcceptEventInterval
        }
        set(newValue) {
            objc_setAssociatedObject(self, &associatedKeys.UIControl_acceptEventInterval, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // 内部用于比较时间差   外部不要去设置这个属性!!!!
    private var acceptEventTime: Double {
        get {
            return (objc_getAssociatedObject(self, &associatedKeys.UIControl_acceptEventTime )) as? Double ?? 0.0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &associatedKeys.UIControl_acceptEventTime, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @objc private dynamic func ipet_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        
        if Date().timeIntervalSince1970 - self.acceptEventTime < self.acceptEventInterval {
            return
        }
        if self.acceptEventInterval > 0 {
            self.acceptEventTime = Date().timeIntervalSince1970
        }
        self.ipet_sendAction(action, to: target, for: event)
    }
    
    static func initializeMethod(){
        
        if self == UIButton.self{
             
            let systemSel = #selector(UIButton.sendAction(_:to:for:))
            
            let sSel = #selector(UIButton.ipet_sendAction(_: to: for:))
            
            let systemMethod = class_getInstanceMethod(self, systemSel)
            
            let sMethod = class_getInstanceMethod(self, sSel)
            
            let isTrue = class_addMethod(self, systemSel, method_getImplementation(sMethod!), method_getTypeEncoding(sMethod!))
            if isTrue{
                class_replaceMethod(self, sSel, method_getImplementation(systemMethod!), method_getTypeEncoding(systemMethod!))
            }else{
                method_exchangeImplementations(systemMethod!, sMethod!)
            }
        }
    }
}
