//
//  ConfigDict.swift
//  unipets-ios
//
//  Created by LRanger on 2021/11/12.
//

import Foundation
import HandyJSON

class ConfigDict: HandyJSON {
    
    var categoryId = 0
    var categoryName = ""
    var sort = 0
    var isHot = false
    required init() {
        
    }
    
}
