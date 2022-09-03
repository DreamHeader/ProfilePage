//
//  Array+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/20.
//

import Foundation
import CoreVideo

extension Array {
    
    @discardableResult
    mutating func remove(item: Element) -> Bool where Element: Equatable {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    func at(_ index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
    
    func nsDesription() {
        let data = self as NSArray
        print(data)
    }
    
    @discardableResult
    mutating func deleteLast() -> Element? {
        if self.count > 0 {
            return self.removeLast()
        }
        return nil
    }
    
    @discardableResult
    mutating func deleteFirst() -> Element? {
        if self.count > 0 {
            return self.removeFirst()
        }
        return nil
    }

    
}

//extension Array where Element: Copyable {
//    func copyWithItems() -> [Element] {
//        return self.map { $0.generateCopy() }
//    }
//}
