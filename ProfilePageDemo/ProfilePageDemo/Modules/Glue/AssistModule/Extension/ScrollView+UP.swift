//
//  ScrollView+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/11/2.
//

import Foundation
import UIKit

extension UIScrollView {
    
    func scrollToBottom(animation: Bool) {
        
        if self.contentSize.height > self.height {
            self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.height + self.contentInset.bottom), animated: animation)
        } 
    }
    
    var bottomInset: CGFloat {
        set {
            var inset = self.contentInset
            inset.bottom = newValue
            self.contentInset = inset
        }
        get {
            contentInset.bottom
        }
    }
    
}
