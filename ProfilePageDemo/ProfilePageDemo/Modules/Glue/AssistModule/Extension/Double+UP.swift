//
//  Double+UP.swift
//  unipets-ios
//
//  Created by Future on 2022/1/5.
//

import Foundation
 
extension Double {
    /// Rounds the double to decimal places value

    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))

        return (self * divisor).rounded() / divisor

    }

}

