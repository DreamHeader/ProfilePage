//
//  FileManager+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2022/7/7.
//

import Foundation

extension FileManager {
    
    func fileSize(_ path: String) -> UInt {
        let att = try? self.attributesOfItem(atPath: path)
        return att?[FileAttributeKey.size] as? UInt ?? 0
    }
    
    func folderSize(_ path: String) -> UInt {
        var isFolder: ObjCBool = false
        if !fileExists(atPath: path, isDirectory: &isFolder) {
            return 0
        }
        if isFolder.boolValue == false {
            return self.fileSize(path)
        } else {
            var fileSize: UInt = 0
            let enumerator = self.enumerator(atPath: path)
            while enumerator?.nextObject() != nil {
                fileSize += enumerator?.fileAttributes?[FileAttributeKey.size] as? UInt ?? 0
            }
            return fileSize
        }
    }
    
    static func formattedSize(_ size: UInt) -> String {
        if size > 1024 * 1024 * 1024 {
            let val = (Double(size) / (1024 * 1024 * 1024))
            return String.init(format: "%.2f GB", val)
        }
        else if size > 1024 * 1024 {
            let val = (Double(size) / (1024 * 1024 ))
            return String.init(format: "%.2f MB", val)
        }
        else  {
            let val = (Double(size) / (1024))
            return String.init(format: "%.2f KB", val)
        }
    }
    
}
