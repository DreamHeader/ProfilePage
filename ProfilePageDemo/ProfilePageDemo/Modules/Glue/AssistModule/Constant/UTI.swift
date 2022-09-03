//
//  UTI.swift
//  unipets-ios
//
//  Created by LRanger on 2022/6/28.
//

import Foundation

struct UTI {
    
    static var videoTypes: [String] {
        return ["mp4", "mov", "m4v", "3gp", "3g2"]
    }
    
    static var audioTypes: [String] {
        return ["mp3", "aac", "ape", "wav", "m4a", "caf"]
    }
    
    static var imageTypes: [String] {
        return ["png", "jpg", "jpeg"]
    }
    
    static var animationImageTypes: [String] {
        return ["gif", "apng"]
    }
    
}
