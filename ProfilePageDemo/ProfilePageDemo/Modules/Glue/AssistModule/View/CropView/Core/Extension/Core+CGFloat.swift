//
//  UIKit.swift
//  UIKit
//
//  Created by FD on 2022/2/9.
//  Copyright ©  All rights reserved.
//

import UIKit

extension CGFloat {
    
    func roundTo(places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
