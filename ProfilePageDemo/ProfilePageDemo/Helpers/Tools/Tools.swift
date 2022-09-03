//
//  String+.swift
//  ProfilePageDemo
//
//  Created by FDKCoder on 2022/9/3.
//

import Foundation
import UIKit

/// 文档目录
let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString

/// 缓存目录
let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString

/// 临时目录
let tempPath = NSTemporaryDirectory() as NSString

/// 打印
func dlog<T>(_ message: T, file: StaticString = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        let fileName = (file.description as NSString).lastPathComponent
        print("\n💚\(fileName)\(method)[\(line)]:\n💙 \(message)")
    #endif
}
