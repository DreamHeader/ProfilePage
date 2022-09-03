//
//  StickerContextMenu.swift
//  unipets-ios
//
//  Created by LRanger on 2021/12/7.
//

import Foundation
import UIKit
import SwiftUI

class ContextMenu: Button {
    
    struct Action: Equatable {
        
        let iden = String.uuid()
        
        let title: String
        let cell: UIView
        let action: () -> Void
        let showBadge: Bool
        
        static func == (lhs: ContextMenu.Action, rhs: ContextMenu.Action) -> Bool {
            lhs.iden == rhs.iden
        }
        
    }
    
    private var items = [Action]()
    private let arrowHeight: CGFloat = 7
    private let arrowWidth: CGFloat = 8
    private let blurView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
    private let contentView = UIView()
    
    func addAction(_ title: String, icon: UIImage?, showBadge: Bool = false, _ action: @escaping () -> Void) {
        let view = CV.source()
            .backgroundColor(UIColor.white.withAlphaComponent(0))
            .isUserInteractionEnabled(false)
            .height(44)
            .result()
        
        let btn = CB.source()
            .image(icon)
            .title(title)
            .titleColor(.white)
            .fontSize(14, weight: .medium)
            .isUserInteractionEnabled(false)
            .contentSpace(8)
            .sizeToFit()
            .bind(view)
            .left(12)
            .centerY(view.height / 2)
            .result()
        
        view.width = btn.right + 24
        
        if showBadge {
            CV.source()
                .backgroundColor(UIColor.red)
                .cornerRadius(3)
                .width(6)
                .height(6)
                .bind(view)
                .top(12)
                .leading(19 + btn.left)
        }
    
        let ac = Action.init(title: title, cell: view, action: action, showBadge: showBadge)
        self.items.append(ac)
    }
    
    private func layout(isTop: Bool, arrowCenterX: CGFloat, blendBackground: Bool = false) {
        
        self.adjustsAlphaWhenHilight = false
        
        contentView.removeAllSubviews()
        
        blurView.isUserInteractionEnabled = false
        self.addSubview(contentView)
        
        contentView.addSubview(blurView)

        var maxWidth: CGFloat = 0
        var allHeihgt: CGFloat = 0
        items.forEach { ac in
            if ac.cell.width > maxWidth  {
                maxWidth = ac.cell.width
            }
            blurView.contentView.addSubview(ac.cell)
            ac.cell.top = allHeihgt + (isTop ? arrowHeight : 0)
            allHeihgt += ac.cell.height
        }
        items.forEach { ac in
            if ac != items.last {
                CV.source()
                    .backgroundColor(UIColor.white.withAlphaComponent(0.10))
                    .size(.init(width: self.width, height: 1))
                    .bottom(ac.cell.bottom)
                    .bind(self.contentView)
            }
            ac.cell.width = maxWidth
        }
        contentView.size = CGSize(width: maxWidth, height: allHeihgt + arrowHeight)
        blurView.frame = CGRect(x: 0, y: 0, width: maxWidth, height: contentView.height)
        self.size = contentView.size
        self.resetMask(isTop: isTop, arrowCenterX: arrowCenterX)
        
    }
    
    
    /// 显示
    /// - Parameters:
    ///   - view: 父视图
    ///   - sourceRect: 显示的锚点区域
    ///   - touchPoint: 手势点击点
    ///   - safeArea: 父视图安全缩进区域
    ///   - blendBackground: 是否遮罩整个父视图
    func show(view: UIView, sourceRect: CGRect, touchPoint: CGPoint, safeArea: UIEdgeInsets = .zero, blendBackground: Bool = false) {
        
        self.layout(isTop: true, arrowCenterX: 0, blendBackground: blendBackground)

        // 判断上面是否可用
        var sourceCenterX: CGFloat = 0
        var isTop = false
        let topSpace = sourceRect.top - safeArea.top
        let bottomSpace = view.height - sourceRect.bottom - safeArea.bottom
        if  topSpace > bottomSpace && topSpace > self.height {
            // 上
            self.centerX = sourceRect.center.x
            self.bottom = sourceRect.top
            isTop = false
        } else if bottomSpace >= topSpace && bottomSpace > self.height {
            // 下
            self.centerX = sourceRect.center.x
            self.top = sourceRect.bottom
            isTop = true
        } else {
            // 点击点位
            self.centerX = touchPoint.x
            self.top = touchPoint.y
            isTop = true
        }
        
        sourceCenterX = self.centerX
        
        view.addSubview(self)
        
        self.left = max(safeArea.left, self.left)
        self.trailing = max(safeArea.right, self.trailing)
        self.top = max(safeArea.top, self.top)
        self.bottomPending = max(safeArea.bottom, self.bottomPending)
        
        var arrowCenterX: CGFloat = 0
        if self.centerX - sourceCenterX > (self.width / 2 - 10 - arrowWidth / 2) {
            arrowCenterX = 10 + arrowWidth / 2
        }
        else if sourceCenterX - self.centerX > (self.width / 2 -  10 - arrowWidth / 2)  {
            arrowCenterX = self.width - 10 - arrowWidth / 2
        }
        else {
            arrowCenterX = sourceCenterX - self.left
        }
        
        self.layout(isTop: isTop, arrowCenterX: arrowCenterX, blendBackground: blendBackground)
        
        // 遮挡整个背景
        if blendBackground {
            self.contentView.frame = self.frame
            self.frame = view.bounds
        } else {
            self.contentView.center = self.contentCenter
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.alpha = 0
            
        } completion: { _ in
            self.removeFromSuperview()
        }

    }
    
    func resetMask(isTop: Bool, arrowCenterX: CGFloat) {
        
        let layer = CAShapeLayer.init()
        layer.frame = self.bounds

        let arrowX = arrowCenterX
        
        let radius: CGFloat = 8
        if isTop {
            var angle = -CGFloat.pi / 2
            let angleUnit = CGFloat.pi / 2
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: radius, y: arrowHeight))
            path.addLine(to: .init(x: arrowX - arrowWidth / 2, y: arrowHeight))
            // arrow
            path.addQuadCurve(to: .init(x: arrowX + arrowWidth / 2, y: arrowHeight), controlPoint: .init(x: arrowX, y: -arrowHeight / 2))
            path.addLine(to: .init(x: self.width - radius, y: arrowHeight))
            path.addArc(withCenter: .init(x: self.width - radius, y: radius + arrowHeight), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            angle += angleUnit
            path.addLine(to: .init(x: self.width, y: self.height - radius))
            path.addArc(withCenter: .init(x: self.width - radius, y: self.height - radius), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            angle += angleUnit
            path.addLine(to: .init(x: radius, y: self.height))
            path.addArc(withCenter: .init(x: radius, y: self.height - radius), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            angle += angleUnit
            path.addLine(to: .init(x: 0, y: self.height - radius - arrowHeight))
            path.addArc(withCenter: .init(x: radius, y: radius + arrowHeight), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            path.fill()
            layer.path = path.cgPath
        } else {
            var angle = -CGFloat.pi / 2
            let angleUnit = CGFloat.pi / 2
            
            let path = UIBezierPath()
            path.move(to: .init(x: radius, y: 0))
            path.addLine(to: .init(x: self.width - radius, y: 0))
            angle = -CGFloat.pi / 2
            path.addArc(withCenter: .init(x: self.width - radius , y: radius), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            path.addLine(to: .init(x: self.width, y: self.height - radius - arrowHeight))
            angle += angleUnit
            path.addArc(withCenter: .init(x: self.width - radius, y: self.height - radius - arrowHeight), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            path.addLine(to: .init(x: arrowX + arrowWidth / 2, y: self.height - arrowHeight))
            // arrow
//            path.addLine(to: .init(x: arrowX, y: self.height))
            path.addQuadCurve(to: .init(x: arrowX - arrowWidth / 2, y: self.height - arrowHeight), controlPoint: .init(x: arrowX, y: self.height + arrowHeight / 2))
//            path.addLine(to: .init(x: arrowX - arrowWidth / 2, y: self.height - arrowHeight))
            path.addLine(to: .init(x: radius, y: self.height - arrowHeight))
            angle += angleUnit
            path.addArc(withCenter: .init(x: radius, y: self.height - radius - arrowHeight), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            angle += angleUnit
            path.addLine(to: .init(x: 0, y: radius))
            path.addArc(withCenter: .init(x: radius, y: radius), radius: radius, startAngle: angle, endAngle: angle + angleUnit, clockwise: true)
            path.fill()
            layer.path = path.cgPath
        }
        
        blurView.layer.mask = layer
    }
    
    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        for ac in items {
            if ac.cell.bounds.contains(touch.location(in: ac.cell)) {
                ac.cell.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        for ac in items {
            if ac.cell.bounds.contains(touch.location(in: ac.cell)) {
                ac.cell.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            } else {
                ac.cell.backgroundColor = UIColor.white.withAlphaComponent(0)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        for ac in items {
            UPLog("1 \(touch.location(in: ac.cell)), title: \(ac.title)")
            if ac.cell.bounds.contains(touch.location(in: ac.cell)) {
                ac.cell.backgroundColor = UIColor.white.withAlphaComponent(0)
                ac.action()
                break
            } else {
                ac.cell.backgroundColor = UIColor.white.withAlphaComponent(0)
            }
        }
        self.dismiss()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for ac in items {
            ac.cell.backgroundColor = UIColor.white.withAlphaComponent(0)
        }
    }

    
}
