//
//  Date+UP.swift
//  unipets-ios
//
//  Created by FDKCoder on 2021/11/3.
//

import Foundation

extension Date {
    
    func dateToString(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date
    }
    
    func isExpire()->Bool{
       let cur = Date()
       // 如果 date与当前时间date比较 是升序 那么 self < cur， 证明过期了
       return (self.compare(cur) == .orderedAscending)
        
    }
}
