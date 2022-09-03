//
//  Color+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/26.
//

import Foundation
import UIKit

extension UIColor {
    
    static func name(_ name: String) -> UIColor {
        if let color = UIColor.init(named: name) {
            return color
        } else {
            assert(false, "color from \(name) is nil")
            return .white
        }
    }
    
    /// 从asset中读取颜色
    /// 主题色 ffa10a
    static var theme: UIColor {
        return UIColor.name("theme")
    }
    
    /// #333333
    static var normalText: UIColor {
        return UIColor.name("normalText")
    }
    
    /// #99999b
    static var lightText1: UIColor {
        return UIColor.name("lightText1")
    }
    
    /// #666666
    static var lightText2: UIColor {
        return UIColor.name("lightText2")
    }
    
    /// #999999
    static var lightText3: UIColor {
        return UIColor.name("lightText3")
    }
    
    /// #cccccf
    static var lightText4: UIColor {
        return UIColor.name("lightText4")
    }
    
    /// #99999c
    static var lightText5: UIColor {
        return UIColor.name("lightText5")
    }
    
    /// #f5f5f8
    static var background1: UIColor {
        return UIColor.name("background1")
    }
    
    /// #dddddd
    static var disable: UIColor {
        return UIColor.name("disable")
    }
    
    /// #333336
    static var lightText6: UIColor {
        return UIColor.name("lightText6")
    }
    
    /// #0d0d0d
    static var background2: UIColor {
        return UIColor.name("background2")
    }
    
    static var randomColor: UIColor {
        let colors = ["#05F5F5", "#16BFBF", "#BF6416", "#D14511", "#5265F2", "#C152F2", "#F252D9", "#F25296", "#F25258"]
        let index = Int.random(in: 0..<colors.count)
        let color = colors[index]
        return hexColor(color)
    }
    
    static func hexColor(_ hex: String, _ alpha: CGFloat = 1) -> UIColor {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet.init(charactersIn: "#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        let color = UIColor.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: alpha
        )
        return color
    }
}
