//
//  UPProtocol.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/20.
//

import Foundation

protocol UPEquatable: Equatable {
            
}

extension UPEquatable where Self: AnyObject {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}

protocol EmptyViewContainerType {
    
    var containter: UIView? { get }
    var emptyView: EmptyView? { get set }
    
    func addEmptyView()
    
    func removeEmptyView()
    
}

extension EmptyViewContainerType {
    
    func removeEmptyView() {
        self.emptyView?.removeFromSuperview()
    }
    
}



