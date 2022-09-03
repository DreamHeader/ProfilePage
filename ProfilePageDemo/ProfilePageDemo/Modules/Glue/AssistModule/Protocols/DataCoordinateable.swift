//
//  Protocols.swift
//  unipets-ios
//
//  Created by LRanger on 2022/7/1.
//

import Foundation

protocol DataCoordinateable {
    
    associatedtype T
    associatedtype State

    var willSelectItem: ((T) -> Bool)? { get set }
    
    var didSelectItem: ((T) -> Bool)? { get set }
    
    func requestSelectItem(_ item: T) -> Bool
    
    func requestUnSelectItem(_ item: T) -> Bool

    func requestUpdateState(_ state: State)
    
}
