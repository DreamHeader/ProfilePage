//
//  Graview.swift
//  unipets-ios
//
//  Created by LRanger on 2022/2/28.
//

import Foundation

class GradientView: UIView {
    
    enum GradientStyle {
        /// 从左至右
        case line
        /// 对角(左上右下渐变)
        case down
        /// 对角(左下右上渐变)
        case up
        /// 中心
        case center
    }
    
    struct Border {
        let width: CGFloat
        let innerCornerRadius: CGFloat
        let outCornerRadius: CGFloat
        let cornerCurve: CALayerCornerCurve
    }
        
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    private var color1 = UIColor.hexColor("#FB851E")
    private var color2 = UIColor.hexColor("#FFA10A")

    private var border: Border?
    private var style = GradientStyle.line
    
    
    /// init
    /// - Parameters:
    ///   - frame: frame
    ///   - style: 样式
    ///   - border: 非作为选中的背景border, 传nil
    init(frame: CGRect, style: GradientStyle = .line, border: Border? = nil) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.style = style
        self.border = border
        
        self.gradientLayer.frame = self.bounds
        self.layer.addSublayer(self.gradientLayer)

        switch style {
        case .line:
            self.gradientLayer.colors = [color1.cgColor, color2.cgColor]
            self.gradientLayer.locations = [NSNumber.init(value: 0), NSNumber.init(value: 1)]
            self.gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
            self.gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
            self.gradientLayer.type = CAGradientLayerType.axial

        case .down:
            self.gradientLayer.colors = [color1.cgColor, color2.cgColor]
            self.gradientLayer.locations = [NSNumber.init(value: 0), NSNumber.init(value: 1)]
            self.gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
            self.gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
            self.gradientLayer.type = CAGradientLayerType.axial

        case .up:
            self.gradientLayer.colors = [color1.cgColor, color2.cgColor]
            self.gradientLayer.locations = [NSNumber.init(value: 0), NSNumber.init(value: 1)]
            self.gradientLayer.startPoint = CGPoint.init(x: 0, y: 1)
            self.gradientLayer.endPoint = CGPoint.init(x: 1, y: 0)
            self.gradientLayer.type = CAGradientLayerType.axial

        case .center:
            self.gradientLayer.colors = [color2.cgColor, color1.cgColor]
            self.gradientLayer.locations = [NSNumber.init(value: 0), NSNumber.init(value: 1)]
            self.gradientLayer.startPoint = CGPoint.init(x: 0.5, y: 0.5)
            self.gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
            self.gradientLayer.type = CAGradientLayerType.radial
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.gradientLayer.frame = self.bounds 
        resetMask()
    }
    
    private func resetMask() {
        guard let border = border else {
            return
        }
        let maskLayer = CAShapeLayer()
        maskLayer.frame = gradientLayer.bounds
        let path1 = UIBezierPath.init(roundedRect: self.layer.bounds, cornerRadius: border.outCornerRadius)
        if border.width > 0 {
            let path2 = UIBezierPath.init(roundedRect: self.layer.bounds.insetBy(dx: border.width, dy: border.width), cornerRadius: border.innerCornerRadius)
            path1.append(path2)
        }
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path1.cgPath
        self.gradientLayer.mask = maskLayer
    }
    
}
