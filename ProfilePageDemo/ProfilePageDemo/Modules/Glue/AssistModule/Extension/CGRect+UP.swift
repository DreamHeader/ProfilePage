//
//  CGRect+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/29.
//

import Foundation

extension CGRect {
    
    var left: CGFloat {
        get {
            self.minX
        }
        set {
            self.origin.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            self.maxX
        }
        set {
            self.origin.x = newValue - self.width
        }
    }
    
    var top: CGFloat {
        get {
            return self.minY
        }
        set {
            self.origin.y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.maxY
        }
        set {
            self.origin.y = newValue - self.height
        }
    }
    
    // ratio: 宽高比
    func aspectFitSize(ratio: CGFloat) -> CGRect {
        
        // 原始宽高比
        let originalRatio = self.width / self.height
        
        if originalRatio < ratio {
            // 原尺寸较窄, 取上下中间部分
            let resSize = CGSize(width: self.width, height: self.width / ratio)
            let resRect = CGRect(x: self.left, y: self.top + self.height / 2 - resSize.height / 2, width: resSize.width, height: resSize.height)
            return resRect
        } else {
            // 原尺寸较宽, 取左右中间部分
            let resSize = CGSize(width: ratio * self.height, height: self.height)
            let resRect = CGRect(x: self.left + self.width / 2 - resSize.width / 2, y: self.top, width: resSize.width, height: resSize.height)
            return resRect
        }
        
    }
    
    // ratio: 宽高比
    func aspectFillSize(ratio: CGFloat) -> CGRect {
        
        // 原始宽高比
        let originalRatio = self.width / self.height
        
        if originalRatio < ratio {
            // 原尺寸较窄, 两边拉伸
            let resSize = CGSize(width: self.height * ratio, height: self.height)
            let resRect = CGRect(x: self.left - (resSize.width / 2 - self.width / 2), y: 0, width: resSize.width, height: resSize.height)
            return resRect
        } else {
            // 原尺寸较宽, 上下拉伸
            let resSize = CGSize(width: self.width, height: self.width / ratio)
            let resRect = CGRect(x: self.left, y: self.top - (resSize.height / 2 - self.height / 2), width: resSize.width, height: resSize.height)
            return resRect
        }
        
    }
    
    func scaledBy(_ scale: CGFloat) -> CGRect {
        return .init(x: self.left * scale, y: self.top * scale, width: self.width * scale, height: self.height * scale)
    }
    
}

#if !(arch(i386) || arch(x86_64))

extension CMTimeRange {
    
    func stringValue() -> String {
        return String.init(format: "%ld|%ld|%ld|%ld", self.start.value, self.start.timescale, self.end.value, self.end.timescale)
    }
    
    static func fromString(_ value: String) -> CMTimeRange {
        let res = value.components(separatedBy: "|")
        if res.count == 4 {
            let start = CMTime(value: Int64(res[0]) ?? 0, timescale: Int32(res[1]) ?? 0)
            let end = CMTime(value: Int64(res[2]) ?? 0, timescale: Int32(res[3]) ?? 0)
            return CMTimeRange(start: start, end: end)
        }
        return .zero
    }
    
    var formatedDescription: String {
        return "start: \(start.seconds), duration: \(duration.seconds), end: \(end.seconds)"
    }
    
}

extension CMTime {
    var formatedDescription: String {
        return "seconds: \(seconds), value: \(value), timescale: \(timescale)"
    }
    
    static prefix func -(val: CMTime) -> CMTime {
        return CMTime.init(value: -val.value, timescale: val.timescale)
    }
    
}

#endif

extension CGRect {
    
    func stringValue() -> String {
        return String.init(format: "%f|%f|%f|%f", self.minX, self.minY, self.width, self.height)
    }
    
    static func fromString(_ value: String) -> CGRect {
        let res = value.components(separatedBy: "|")
        if res.count == 4 {
            let x = Double(res[0]) ?? 0
            let y = Double(res[1]) ?? 0
            let w = Double(res[2]) ?? 0
            let h = Double(res[3]) ?? 0
            return CGRect(x: x, y: y, width: w, height: h)
        }
        return .zero
    }
}

extension CGSize {
    
    func stringValue() -> String {
        return String.init(format: "%f|%f", self.width, self.height)
    }
    
    static func fromString(_ value: String) -> CGSize {
        let res = value.components(separatedBy: "|")
        if res.count == 2 {
            let w = Double(res[0]) ?? 0
            let h = Double(res[1]) ?? 0
            return CGSize(width: w, height: h)
        }
        return .zero
    }
}

extension CGPoint {
    
    func stringValue() -> String {
        return String.init(format: "%f|%f", self.x, self.y)
    }
    
    static func fromString(_ value: String) -> CGPoint {
        let res = value.components(separatedBy: "|")
        if res.count == 2 {
            let x = Double(res[0]) ?? 0
            let y = Double(res[1]) ?? 0
            return CGPoint(x: x, y: y)
        }
        return .zero
    }
}

extension CGAffineTransform {
    
    func stringValue() -> String {
        return String.init(format: "%f|%f|%f|%f|%f|%f", a, b, c, d, tx, ty)
    }
    
    static func fromString(_ value: String) -> CGAffineTransform {
        let res = value.components(separatedBy: "|")
        if res.count == 6 {
            let a = CGFloat(Double(res[0]) ?? 0)
            let b = CGFloat(Double(res[1]) ?? 0)
            let c = CGFloat(Double(res[2]) ?? 0)
            let d = CGFloat(Double(res[3]) ?? 0)
            let x = CGFloat(Double(res[4]) ?? 0)
            let y = CGFloat(Double(res[5]) ?? 0)
            return CGAffineTransform.init(a: a, b: b, c: c, d: d, tx: x, ty: y)
        }
        return .identity
    }
    
    var rotate: CGFloat {
        return -atan2(self.b, self.a)
    }
    
    var scaleX: CGFloat {
        sqrt(self.a * self.a + self.c * self.c)
    }
    
    var scaleY: CGFloat {
        sqrt(self.b * self.b + self.d * self.d)
    }
}


