//
//  Runtime+Up.swift
//  unipets-ios
//
//  Created by Future on 2021/11/24.
//

import UIKit
 
public extension NSObject {
    /// 类实例方法交换
    ///   - targetSel: 目标方法
    ///   - newSel: 替换方法
    @discardableResult
    static func exchangeMethod(targetSel: Selector, newSel: Selector) -> Bool {
        guard let before: Method = class_getInstanceMethod(self, targetSel),
              let after: Method = class_getInstanceMethod(self, newSel)
        else {
            return false
        }

        method_exchangeImplementations(before, after)
        return true
    }
}

