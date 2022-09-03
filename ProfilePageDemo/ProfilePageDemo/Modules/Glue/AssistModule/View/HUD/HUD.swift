//
//  HUD.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/27.
//

import UIKit
import MBProgressHUD

class HUD: MBProgressHUD {
    
    // 自定义进度条中间的进度数值展示文本
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    @discardableResult
    static func hud(view: UIView?, title: String, hiddenAfter: TimeInterval = 2) -> HUD {
        let resView = view ?? KeyWindow()
        let hud = HUD.init(view: resView)
        hud.bezelView.style = .blur
        hud.bezelView.blurEffectStyle = UIBlurEffect.Style.dark
        hud.animationType = .fade
        hud.mode = .text
        hud.detailsLabel.text = title
        hud.detailsLabel.textColor = UIColor.white
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 13)
        resView.addSubview(hud)
        hud.progressLabel.isHidden = true
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: hiddenAfter)
        hud.removeFromSuperViewOnHide = true
        return hud
    }
    
    // 允许父视图交互的HUD
    @discardableResult
    static func lightHUD(view: UIView?, title: String, hiddenAfter: TimeInterval = 2) -> HUD {
        return self.hud(view: view, title: title, hiddenAfter: hiddenAfter).enableSuperTouch()
    }
    
    @discardableResult
    static func hud(view: UIView?, error: RuntimeError, hiddenAfter: TimeInterval = 2) -> HUD {
        var title = error.localizedDescription
        if error.message != title && IsDebug() {
            title += "\n(debug: \(error.debugLocalizedDescription))"
        }
        return HUD.hud(view: view, title: title, hiddenAfter: hiddenAfter)
    }
    
    @discardableResult
    static func lightHUD(view: UIView?, error: RuntimeError, hiddenAfter: TimeInterval = 2) -> HUD {
        return self.hud(view: view, error: error, hiddenAfter: hiddenAfter).enableSuperTouch()
    }
    
    static func loadingHUD(view: UIView?, title: String? = nil) -> HUD {
        let resView = view ?? KeyWindow()
        let hud = HUD.init(view: resView)
        hud.bezelView.style = .blur
        hud.bezelView.blurEffectStyle = UIBlurEffect.Style.dark
        hud.animationType = .fade
        hud.mode = .indeterminate
        hud.contentColor = .white
        hud.detailsLabel.textColor = UIColor.white
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
        hud.detailsLabel.text = title
        hud.bezelView.addSubview(hud.progressLabel)
        resView.addSubview(hud)
        hud.show(animated: true)
        return hud
    }
    
    func checkBaseSetting() {
        self.minSize = CGSize.zero
        self.progressLabel.isHidden = true
        
        if self.mode == .annularDeterminate {
            self.minSize = CGSize(width: 120, height: 120)
            var curHudView: UIView?
            let bezelViewSubviewArr = self.bezelView.subviews
            if bezelViewSubviewArr.count > 0  {
                for subView in bezelViewSubviewArr {
                    if subView is MBRoundProgressView {
                        curHudView = subView
                        subView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                        break
                    }
                }
            }
            self.bezelView.layer.cornerRadius = 12
            self.bezelView.layer.masksToBounds = true
            self.progressLabel.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 25, height: 25))
                if let curHudView = curHudView {
                    make.centerX.equalTo(curHudView.snp.centerX)
                    make.centerY.equalTo(curHudView.snp.centerY)
                }else{
                    make.centerX.equalTo(self.bezelView.snp.centerX)
                    make.centerY.equalTo(self.bezelView.snp.centerY).offset(-10)
                }
            }
            let xValue: CGFloat = 0
            let yValue: CGFloat = 5
            self.detailsLabel.transform = CGAffineTransform(translationX: xValue , y: yValue)
            self.progressLabel.isHidden = false
        } else {
            self.detailsLabel.transform = .identity
            self.bezelView.layer.cornerRadius = 6
        }
    }
    
    func displayTitle(title: String, hiddenAfter: TimeInterval = 2) {
        self.mode = .text
        checkBaseSetting()
        self.detailsLabel.text = title
        if hiddenAfter > 0 {
            self.hide(animated: true, afterDelay: hiddenAfter)
        }
    }
    
    func displayError(error: NSError, hiddenAfter: TimeInterval = 2) {
        self.mode = .text
        checkBaseSetting()
        self.detailsLabel.text = error.localizedDescription
        if hiddenAfter > 0 {
            self.hide(animated: true, afterDelay: hiddenAfter)
        }
    }
    
    func displayError(error: RuntimeError, hiddenAfter: TimeInterval = 2) {
        var title = error.localizedDescription
        if error.message != title && IsDebug() {
            title += "\n(debug: \(error.debugLocalizedDescription))"
        }
        self.mode = .text
        checkBaseSetting()
        self.detailsLabel.text = title
        if hiddenAfter > 0 {
            self.hide(animated: true, afterDelay: hiddenAfter)
        }
    }
    
    func displayLoadProgress(progress: Float, tip: String) {
        self.mode = .annularDeterminate
        checkBaseSetting()
        self.detailsLabel.text = tip
        self.progress = progress
        self.progressLabel.isHidden = false
        self.progressLabel.text = "\(Int(progress*100))%"
        
    }
    
    func dismiss() {
        self.hide(animated: true)
    }
    
    
}

// CustomView
extension HUD {
    
    @discardableResult
    static func hud(view: UIView?, content: UIView, hiddenAfter: TimeInterval = 2) -> HUD {
        let resView = view ?? KeyWindow()
        let hud = HUD.init(view: resView)
        hud.bezelView.style = .blur
        hud.bezelView.blurEffectStyle = UIBlurEffect.Style.dark
        hud.bezelView.layer.cornerRadius = 12
        hud.animationType = .fade
        hud.mode = .customView
        hud.customView = content
        resView.addSubview(hud)
        hud.show(animated: true)
        hud.hide(animated: true, afterDelay: hiddenAfter)
        hud.removeFromSuperViewOnHide = true
        return hud
    }
    
    /// 同时显示文字和图片的hud
    /// - Parameters:
    ///   - view: 父视图
    ///   - content: 图片
    ///   - size: 图片大小, nil则取图片本身大小
    ///   - title: 文字
    ///   - hiddenAfter: 隐藏延时
    /// - Returns: 实例
    @discardableResult
    static func hud(view: UIView?, content: UIImage?, size: CGSize? = nil, title: String? = nil, hiddenAfter: TimeInterval = 2) -> HUD {
        let customView = Button()
        customView.isUserInteractionEnabled = false
        customView.image = content
        customView.title = title ?? ""
        customView.titleColor = .white
        customView.titleFont = UIFont.systemFont(ofSize: 14)
        customView.imagePosition = .top
        customView.imageSize = size ?? (content?.size ?? .zero)
        customView.sizeToFit()
        customView.width = max(customView.width, customView.height)
        customView.height = max(customView.width, customView.height)
        return HUD.hud(view: view, content: customView, hiddenAfter: hiddenAfter)
    }
    
}

extension HUD {
    
    @discardableResult
    func enableSuperTouch() -> HUD {
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        if let superView = self.superview {
            self.offset = .zero
            let center = superView.convert(self.bezelView.center, to: superView)
            self.frame = self.bezelView.frame.insetBy(dx: -20, dy: -20)
            self.center = center
        }
        
        return self
    }
    
}
