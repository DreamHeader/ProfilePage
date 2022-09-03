//
//  PermissionModel.swift
//  unipets-ios
//
//  Created by 浮东凯 on 2021/10/18.
//

import UIKit
import HandyJSON

class PermissionModel: HandyJSON, UPEquatable{
    
    var forceUpgrade = false // 是否强制更新
    var latestVersionInfo: PermissionDetailModel? // 最新APP版本信息
    var popsUpgrade = false // 是否弹窗提示更新
     
    required init() {
        
    }
    
}

class PermissionDetailModel: HandyJSON, UPEquatable{
    
    var popsTitle = "" // 弹窗标题
    var popsTitleDesc = "" // 弹窗内容
    var versionNo = "" // 版本号
    
    required init() {
        
    }
    
}
