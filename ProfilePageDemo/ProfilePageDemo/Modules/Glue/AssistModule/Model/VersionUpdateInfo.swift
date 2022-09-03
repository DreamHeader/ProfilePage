//
//  VersionUpdateInfo.swift
//  unipets-ios
//
//  Created by LRanger on 2021/10/12.
//

import Foundation
import HandyJSON

class VersionUpdateInfo: HandyJSON {
        
    // 强制更新
    var forceUpgrade = false
    // 显示更新弹窗
    var popsUpgrade = false
    
    var latestVersionInfo = VersionUpdateProps()
    
    
    required init() {
        
    }
    
}

class VersionUpdateProps: HandyJSON {
    
    var popsTitle = ""
    var popsTitleDesc = ""
    var versionNo = ""
    
    required init() {
        
    }
    
}
