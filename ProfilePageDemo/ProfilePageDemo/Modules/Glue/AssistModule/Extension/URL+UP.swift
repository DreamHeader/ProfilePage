//
//  URL+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/23.
//

import Foundation

extension URL {
    
    func filePath() -> String {
        return self.absoluteString.replacingOccurrences(of: "file://", with: "", options: .caseInsensitive, range: nil).removingPercentEncoding ?? ""
    }
    
    static func fileURL(_ path: String) -> URL {
        return URL.init(fileURLWithPath: path)
    }
    
    static func with(_ path: String) -> URL? {
        if path.hasPrefix("http") {
            if let url = URL.init(string: path) {
                return url
            }
            if let url = URL.init(string: safe(path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed))) {
                return url
            }
        } else {
            return URL.init(fileURLWithPath: path)
        }
        return nil
    }
    
//    func copyFile() -> URL? {
//        if FileManager.default.fileExists(atPath: self.filePath()) == false {
//            return nil
//        }
//        do {
//            let fileName = String.uuid() + "." + self.filePath().filePathExtension()
//            let resPath = FilePath.path(domain: .uplaodCache) + "/" + fileName
//            let resUrl = URL.init(fileURLWithPath: resPath)
//            try FileManager.default.copyItem(at: self, to: resUrl)
//            return resUrl
//        } catch  {
//            return nil
//        }
//    }
    
}
