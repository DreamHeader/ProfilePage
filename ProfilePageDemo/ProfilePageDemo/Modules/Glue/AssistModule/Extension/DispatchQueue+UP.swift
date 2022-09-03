//
//  DispatchQueue+UP.swift
//  unipets-ios
//
//  Created by Future on 2021/11/23.
//

import Foundation
extension DispatchQueue {
    private static var _onceToken = [String]()
    
    class func once(token: String = "\(#file):\(#function):\(#line)", block: ()->Void) {
        objc_sync_enter(self)
        
        defer
        {
            objc_sync_exit(self)
        }

        if _onceToken.contains(token)
        {
            return
        }

        _onceToken.append(token)
        block()
    }
}
