//
//  Dictionary+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/16.
//

import Foundation

typealias UPJson = [String: Any]

extension Dictionary {
    
    func nsDesription() -> String {
        let dic = self as NSDictionary
        return dic.description
    }
    
    func jsonStringEncode() -> String? {
        return self.jsonDataEncode()?.stringValue()
    }
    
    func jsonDataEncode() -> Data? {
        let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return data
    }
    
    static func jsonValueDecode(_ string: String?) -> [String: Any]? {
        return string?.dataValue()?.jsonValueDecode() as? [String: Any]
    }
    
    static func jsonValueDecode(_ data: Data?) -> [String: Any]? {
        return data?.jsonValueDecode() as? [String: Any]
    }
    
    func stringValue(_ key: Key) -> String? {
        return self[key] as? String
    }
    func boolValue(_ key: Key) -> Bool? {
        return self[key] as? Bool
    }
}

extension Encodable {
    
    func decodeToJson() -> Any? {
        try? JSONEncoder().encode(self).jsonValueDecode()
    }
    
    func decodeToString() -> String? {
        try? JSONEncoder().encode(self).stringValue()
    }
    
    func decodeToDictionary() -> UPJson? {
        try? JSONEncoder().encode(self).jsonValueDecode() as? UPJson
    }
    
}
