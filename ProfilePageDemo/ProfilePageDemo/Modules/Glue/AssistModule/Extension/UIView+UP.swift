//
//  View+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/11.
//

import Foundation
import UIKit

extension UIView {
    
    /// frame
    
    var width: CGFloat {
        get {
            self.frame.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            self.frame.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var centerX: CGFloat {
        get {
            self.frame.midX
        }
        set {
            self.frame.origin.x = newValue - self.width / 2
        }
    }
    
    var centerY: CGFloat {
        get {
            self.frame.midY
        }
        set {
            self.frame.origin.y = newValue - self.height / 2
        }
    }
    
    /// 视图右侧距离父视图右侧间距
    var left: CGFloat {
        get {
            self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    /// 视图右侧距离父视图左侧间距
    var right: CGFloat {
        get {
            self.frame.maxX
        }
        set {
            self.left = newValue - self.width
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.maxY
        }
        set {
            self.frame.origin.y = newValue - self.height
        }
    }
    
    var topPending: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    
    // 距离父视图bottm的间距
    var bottomPending: CGFloat {
        get {
            if let view = self.superview {
                return view.height - self.bottom
            }
            return 0
        }
        set {
            if let view = self.superview {
                self.bottom = view.height - newValue
            }
        }
    }
    
    /// 视图左侧距离父视图右侧间距
    var leading: CGFloat {
        get {
            return self.left
        }
        set {
            self.left = newValue
        }
    }
    
    /// 视图右侧距离父视图右侧间距
    var trailing: CGFloat {
        get {
            if let view = self.superview {
                return view.width - self.right
            } else {
                return 0
            }
        }
        set {
            if let view = self.superview {
                self.right = view.width - newValue
            } else {
                
            }
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
    
    var contentCenter: CGPoint {
        return .init(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }
    
    func removeAllSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func clearSublayerColors(){
        self.layer.sublayers?.forEach({ sublayer in
            sublayer.removeFromSuperlayer()
        }) 
    }
}

extension CGRect {
    
    var center: CGPoint {
        get {
            return CGPoint(x: self.minX + self.width / 2, y: self.minY + self.height / 2)
        }
        set {
            let point = CGPoint(x: newValue.x - self.width / 2, y: newValue.y - self.height / 2)
            self.origin = point
        }
    }
    
}

extension UIView {
    
    // 底部默认缩进
    var safeBottomInsetForTab: CGFloat {
        return max(34, self.safeAreaInsets.bottom)
    }
    
}
extension UIView {
    // 通过UIBezierPath添加圆角
    func addBezierLayerCorner(roundingCorners: UIRectCorner , cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
}

extension UIView {
    
    enum UIViewTrianglePosition {
        case top
        case bottom
        case left
        case right
    }
    /// 绘制图形的周边小三角
    func drawTrianglePosition(position: UIViewTrianglePosition,showView: UIView, shapeHeight: CGFloat,shapeWidth: CGFloat ) -> CAShapeLayer {
        
        let viewWidth = CGFloat(showView.frame.size.width)
        let viewHeight = CGFloat(showView.frame.size.height)
        let path = UIBezierPath()
        switch position {
        case .top:
            let point1 = CGPoint(x: 0, y: viewHeight)
            let point2 = CGPoint(x: 0, y: shapeHeight)
            let point3 = CGPoint(x: (viewWidth / 2) - (shapeWidth / 2), y: shapeHeight)
            let point4 = CGPoint(x: (viewWidth / 2) , y: 0)
            let point5 = CGPoint(x: (viewWidth / 2) + (shapeWidth / 2), y: shapeHeight)
            let point6 = CGPoint(x: viewWidth, y: shapeHeight)
            let point7 = CGPoint(x: viewWidth, y: shapeHeight)
            path.move(to: point1)
            path.addLine(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.addLine(to: point4)
            path.addLine(to: point5)
            path.addLine(to: point6)
            path.addLine(to: point7)
        case .bottom:
            let point1 = CGPoint(x: 0, y: 0)
            let point2 = CGPoint(x: 0, y: viewHeight - shapeHeight)
            let point3 = CGPoint(x: (viewWidth / 2) - (shapeWidth / 2), y: viewHeight - shapeHeight)
            let point4 = CGPoint(x: (viewWidth / 2) , y: viewHeight)
            let point5 = CGPoint(x: (viewWidth / 2) + (shapeWidth / 2), y: viewHeight - shapeHeight)
            let point6 = CGPoint(x: viewWidth, y: viewHeight - shapeHeight)
            let point7 = CGPoint(x: viewWidth, y: 0)
            path.move(to: point1)
            path.addLine(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.addLine(to: point4)
            path.addLine(to: point5)
            path.addLine(to: point6)
            path.addLine(to: point7)
        case .left:
            let point1 = CGPoint(x: viewWidth, y: 0)
            let point2 = CGPoint(x: shapeHeight, y: 0)
            let point3 = CGPoint(x: shapeHeight, y: viewHeight / 3 - shapeWidth / 2)
            let point4 = CGPoint(x: 0 , y: viewHeight / 3)
            let point5 = CGPoint(x: shapeHeight, y: viewHeight / 3 + shapeWidth / 2)
            let point6 = CGPoint(x: shapeHeight, y: viewHeight)
            let point7 = CGPoint(x: viewWidth, y: viewHeight)
            path.move(to: point1)
            path.addLine(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.addLine(to: point4)
            path.addLine(to: point5)
            path.addLine(to: point6)
            path.addLine(to: point7)
        case .right:
            let point1 = CGPoint(x: 0, y: 0)
            let point2 = CGPoint(x: viewWidth - shapeHeight, y: 0)
            let point3 = CGPoint(x: viewWidth - shapeHeight, y: viewHeight / 3 - shapeWidth / 2)
            let point4 = CGPoint(x: viewWidth , y: viewHeight / 3)
            let point5 = CGPoint(x: viewWidth - shapeHeight, y: viewHeight / 3 - shapeWidth / 2)
            let point6 = CGPoint(x: viewWidth - shapeHeight, y: viewHeight)
            let point7 = CGPoint(x: 0, y: viewHeight)
            path.move(to: point1)
            path.addLine(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.addLine(to: point4)
            path.addLine(to: point5)
            path.addLine(to: point6)
            path.addLine(to: point7)
        }
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        return layer
    }
}
