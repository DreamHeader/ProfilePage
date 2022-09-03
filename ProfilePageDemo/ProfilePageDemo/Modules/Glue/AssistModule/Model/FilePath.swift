//
//  FilePath.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/23.
//

import UIKit

class FilePath {

    static func libraryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
    }
    
    static func libraryPath(cid: String) -> String {
        let path = self.libraryPath() + "/\(cid)"
        try? FileManager.default.createDirectory(at: URL.init(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        return path
    }
    
    enum Domain: String {
        case cache = "/Cache"
        case uplaodCache = "/Cache/Upload"
        case downlaodCache = "/Cache/Download"
    }
    
    static func path(domain: Domain) -> String {
        if var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
            path += domain.rawValue
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.createDirectory(at: URL.init(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
                } catch  {
                    UPLog(error)
                }
            }
            return path
        }
        return ""
    }
    
}
