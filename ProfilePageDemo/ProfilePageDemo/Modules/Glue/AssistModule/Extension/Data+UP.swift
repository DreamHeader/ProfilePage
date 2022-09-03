//
//  Data+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/10/9.
//

import Foundation

extension Data {
    
    func stringValue() -> String? {
        return String.init(data: self, encoding: .utf8)
    }
    
    func jsonValueDecode() -> Any? {
        let value = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers)
        return value
    }
    
}
