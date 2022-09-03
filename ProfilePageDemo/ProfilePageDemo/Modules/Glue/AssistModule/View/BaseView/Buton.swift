//
//  Button.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/18.
//

import Foundation
import UIKit
import CoreMedia
import SwiftUI
import Kingfisher

class Button: UIButton {
    
    enum ImagePosition {
        case left
        case right
        case top
        case bottom
        case center
    }
    
    enum Alignment {
        case center
        case left
        case right
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.alpha = 1
                self.isUserInteractionEnabled = true
            } else {
                self.alpha = 0.35
                self.isUserInteractionEnabled = false
            }
        }
    }
    
    var imageSize = CGSize.zero {
        didSet {
            if imageSize != oldValue {
                _layout(sizeToFit: false)
            }
        }
    }
    var contentSpace: CGFloat = 8 {
        didSet {
            if contentSpace != oldValue {
                _layout(sizeToFit: false)
            }
        }
    }
    var alignment = Alignment.center {
        didSet {
            if alignment != oldValue {
                _layout(sizeToFit: false)
            }
        }
    }
    var imagePosition = ImagePosition.left {
        didSet {
            if imagePosition != oldValue {
                _layout(sizeToFit: false)
            }
        }
    }
    var imageContentMode: UIView.ContentMode {
        set {
            _imageView.contentMode = newValue
        }
        get {
            _imageView.contentMode
        }
    }
    var titleFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            if titleFont != oldValue {
                _titleLabel.font = titleFont
                _layout(sizeToFit: false)
            }
        }
    }
    var titleColor = UIColor.black {
        didSet {
            _titleLabel.textColor = titleColor
        }
    }
    var _title = ""
    var title: String {
        get {
            _title
        }
        set {
            if newValue != _title {
                _title = newValue
                _attributeTitle = nil
                _titleLabel.attributedText = nil
                _titleLabel.text = _title
                _layout(sizeToFit: false)
            }
        }
    }
    var _attributeTitle: NSAttributedString?
    var attributeTitle: NSAttributedString? {
        get {
            _attributeTitle
        }
        set {
            if _attributeTitle != newValue {
                _attributeTitle = newValue
                _title = ""
                _titleLabel.text = nil
                _titleLabel.attributedText = _attributeTitle
                _layout(sizeToFit: false)
            }
        }
    }
    var image: UIImage? {
        didSet {
            if image != oldValue {
                if !self.isSelected || self.selectedImage == nil {
                    _imageView.image = image
                    _layout(sizeToFit: false)
                }
            }
        }
    }
    var selectedImage: UIImage? {
        didSet {
            if let img = selectedImage {
                if self.isSelected {
                    _imageView.image = img
                    _layout(sizeToFit: false)
                }
            } else {
                _imageView.image = image
                _layout(sizeToFit: false)
            }
        }
    }
    var overInset = UIEdgeInsets.zero {
        didSet {
            if overInset != oldValue {
                _layout(sizeToFit: false)
            }
        }
    }
    var numberOfLines = 1
    var imageCornerRadius: CGFloat {
        set {
            _imageView.layer.cornerRadius = newValue
            _imageView.layer.cornerCurve = .continuous
        }
        get {
            return _imageView.layer.cornerRadius
        }
    }
    
    var imageBackGroundColor: UIColor? {
        set {
            _imageView.backgroundColor = newValue
        }
        get {
            return _imageView.backgroundColor
        }
    }
    
    var backgroundImage: UIImage? {
        set {
            _contentView.image = newValue
        }
        get {
            _contentView.image
        }
    }
    
    var backgroundContentMode: UIView.ContentMode {
        set {
            _contentView.contentMode = newValue
        }
        get {
            _contentView.contentMode
        }
    }
    
    var backgroundCornerRadius: CGFloat {
        set {
            _contentView.layer.cornerRadius = newValue
        }
        get {
            _contentView.layer.cornerRadius
        }
    }
    
    var adjustsAlphaWhenHilight = true
    // 内阴影
    private var _innerShadowView: GradientView?
    var showInnerShadow = false {
        didSet {
            if showInnerShadow {
                _innerShadowView?.removeFromSuperview()
                let view = GradientView.init(frame: _contentView.bounds, style: .line)
                view.isUserInteractionEnabled = false
                _contentView.addSubview(view)
                _contentView.sendSubviewToBack(view)
                _innerShadowView = view
            } else {
                _innerShadowView?.removeFromSuperview()
                _innerShadowView = nil
            }
        }
    }
    
    var entity: Any?
    
    private let _imageView = UIImageView()
    var contentImageView: UIImageView {
        return _imageView
    }
    private let _titleLabel = UILabel()
    var contentTitleLabel: UILabel {
        return _titleLabel
    }
    private var _placeholerImage: UIImage?
    private var _imageUrl: URL?
    private let _nilImageSize = CGSize(width: 20, height: 20)
    private let _contentView = UIImageView()
    
    var onTouchUpInside: ((Button) -> Void)?
    var onSelectStateChange: ((Button) -> Void)?
    
    var debugId = ""
    
    private var didSetup = false
    
    /// 节流时间, 一段时间内不可再次点击
    var throttleTime: TimeInterval = 0
    private var isThrottleTime = false

    override var isSelected: Bool {
        didSet {
            if self.selectedImage != nil {
                if self.isSelected {
                    _imageView.image = self.selectedImage
                } else {
                    _imageView.image = self.image
                }
                self.layoutSubviews()
            }
            if let action = self.onSelectStateChange {
                action(self)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _contentView.clipsToBounds = true
        self.addSubview(_contentView)
        
        _titleLabel.font = titleFont
        _titleLabel.textColor = titleColor
        _titleLabel.numberOfLines = 1
        
        imageContentMode = .scaleAspectFit
        _imageView.clipsToBounds = true
        
        #if DEBUG
        //        self.backgroundColor = UIColor.orange.withAlphaComponent(0.25)
        #endif
        
        self.addTarget(self, action: #selector(_touchAction), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func _layout(sizeToFit: Bool) {
        
        if !didSetup {
            return
        }
        
        if !sizeToFit && self.size == .zero {
            return
        }
        
        _imageView.removeFromSuperview()
        _titleLabel.removeFromSuperview()
        
        let hasImage = _placeholerImage != nil || _imageUrl != nil || imageSize != .zero || _imageView.image != nil
        let hasTitle = title.count > 0 || attributeTitle != nil
        
        if !hasImage && !hasTitle {
            return
        }
        
        let horAdding = overInset.left + overInset.right
        let verAdding = overInset.top + overInset.bottom
        _titleLabel.sizeToFit()
        var wantImageSize: CGSize = imageSize
        
        _contentView.frame = self.bounds
        _contentView.layer.cornerRadius = self.layer.cornerRadius
        _innerShadowView?.frame = _contentView.bounds
        
        /// image
        if (hasImage && !hasTitle) {
            
            _contentView.addSubview(_imageView)
            
            if !sizeToFit {
                if imageSize != .zero {
                    _imageView.size = imageSize
                    switch alignment {
                    case .left:
                        _imageView.leading = overInset.left
                    case .right:
                        _imageView.trailing = overInset.right
                    case .center:
                        _imageView.center = self.contentCenter
                    }
                } else {
                    _imageView.frame = self.bounds.inset(by: overInset)
                }
                return
            }
            
            
            if imageSize == .zero {
                let currentImage = image ?? _placeholerImage
                if let aImage = currentImage {
                    wantImageSize = aImage.size
                } else {
                    wantImageSize = _nilImageSize
                }
            }
            
            self.size = CGSize(width: wantImageSize.width + overInset.left + overInset.right, height: wantImageSize.height + overInset.top + overInset.bottom)
            _contentView.frame = self.bounds
            _imageView.size = wantImageSize
            _imageView.center = self.contentCenter
            
            return
        }
        
        /// title
        if hasTitle && !hasImage {
            _contentView.addSubview(_titleLabel)
            if !sizeToFit {
                _titleLabel.sizeToFit()
                _titleLabel.width = min(_titleLabel.width, self.width - overInset.left - overInset.right)
                _titleLabel.height = min(_titleLabel.height, self.height - overInset.top - overInset.bottom)
                _titleLabel.centerY = self.height / 2
                
                switch alignment {
                case .left:
                    _titleLabel.leading = overInset.left
                case .right:
                    _titleLabel.trailing = overInset.right
                case .center:
                    _titleLabel.centerX = self.width / 2
                }
                return
            }
            
            _titleLabel.sizeToFit()
            self.size = CGSize(width: _titleLabel.width + overInset.left + overInset.right, height: _titleLabel.height + overInset.top + overInset.bottom)
            _contentView.frame = self.bounds
            _titleLabel.center = self.contentCenter
            
            return
        }
        
        _contentView.addSubview(_imageView)
        _contentView.addSubview(_titleLabel)
        
        if !sizeToFit {
            
            var wantImageSize = CGSize.zero
            if imageSize != .zero {
                wantImageSize = imageSize
            } else if let aImage = image ?? _placeholerImage {
                wantImageSize = aImage.size
                if wantImageSize.width > self.width - horAdding {
                    /// 宽度超了
                    wantImageSize.width = self.width - horAdding
                }
                if wantImageSize.height > self.height - verAdding {
                    /// 高度超了
                    wantImageSize.height = self.height - verAdding
                }
            } else {
                wantImageSize = _nilImageSize
            }
            _imageView.size = wantImageSize
            
            switch imagePosition {
            case .left:
                _titleLabel.width = min(_titleLabel.width, self.width - horAdding - contentSpace - _imageView.width)
                switch alignment {
                case .left:
                    _imageView.left = overInset.left
                    _titleLabel.left = _imageView.right + contentSpace
                case .center:
                    _imageView.left = (self.width - horAdding - contentSpace - _imageView.width - _titleLabel.width) / 2
                    _titleLabel.left = _imageView.right + contentSpace
                case .right:
                    _titleLabel.trailing = overInset.right
                    _imageView.right = _titleLabel.left - contentSpace
                }
                _imageView.centerY = self.height / 2
                _titleLabel.centerY = self.height / 2
            case .right:
                _titleLabel.width = min(_titleLabel.width, self.width - horAdding - contentSpace - _imageView.width)
                switch alignment {
                case .left:
                    _titleLabel.left = overInset.left
                    _imageView.left = _titleLabel.right + contentSpace
                case .center:
                    _titleLabel.left = (self.width - horAdding - contentSpace - _imageView.width - _titleLabel.width) / 2
                    _imageView.left = _titleLabel.right + contentSpace
                case .right:
                    _imageView.trailing = overInset.right
                    _titleLabel.right = _imageView.left - contentSpace
                }
                _imageView.centerY = self.height / 2
                _titleLabel.centerY = self.height / 2
            case .top:
                
                let contentTop = (self.height - contentSpace - _imageView.height - _titleLabel.height) / 2
                _titleLabel.width = min(_titleLabel.width, self.width)
                switch alignment {
                case .left:
                    _imageView.frame = CGRect(x: overInset.left, y: contentTop, width: _imageView.width, height: _imageView.height)
                    _titleLabel.frame = CGRect(x: overInset.left, y: _imageView.bottom + contentSpace, width: _titleLabel.width, height: _titleLabel.height)
                case .center:
                    _imageView.top = contentTop
                    _imageView.centerX = self.width / 2
                    _titleLabel.top = _imageView.bottom + contentSpace
                    _titleLabel.centerX = self.width / 2
                case .right:
                    _imageView.top = contentTop
                    _imageView.trailing = overInset.right
                    _titleLabel.top = _imageView.bottom + contentSpace
                    _titleLabel.right = _imageView.right
                }
            case .bottom:
                _titleLabel.width = min(_titleLabel.width, self.width)
                let contentTop = (self.height - contentSpace - _imageView.height - _titleLabel.height) / 2
                switch alignment {
                case .left:
                    _titleLabel.left = overInset.left
                    _titleLabel.top = contentTop
                    _imageView.left = _titleLabel.left
                    _imageView.top = _titleLabel.bottom + contentSpace
                case .right:
                    _titleLabel.trailing = overInset.right
                    _titleLabel.top = contentTop
                    _imageView.top =  _titleLabel.bottom + contentSpace
                    _imageView.right = _titleLabel.right
                case .center:
                    _titleLabel.top = contentTop
                    _titleLabel.centerX = self.width / 2
                    _imageView.top = _titleLabel.bottom + contentSpace
                    _imageView.centerX = self.width / 2
                }
            case .center:
                _imageView.center = self.contentCenter
                _titleLabel.center = self.contentCenter
                _titleLabel.width = min(_titleLabel.width, self.width)
                _titleLabel.height = min(_titleLabel.height, self.height)
            }
            
            return
        }
        
        /// sizeToFit
        if imageSize != .zero {
            wantImageSize = imageSize
        } else if let aImage = image ?? _placeholerImage {
            wantImageSize = aImage.size
        } else {
            wantImageSize = _nilImageSize
        }
        _imageView.size = wantImageSize
        
        switch imagePosition {
        case .left, .right:
            self.size = CGSize(width: _titleLabel.width + contentSpace + _imageView.width + horAdding, height: max(_imageView.height, _titleLabel.height) + verAdding)
            _contentView.frame = self.bounds
            _imageView.leading = overInset.left
            _titleLabel.leading = _imageView.right + contentSpace
            _imageView.centerY = self.height / 2
            _titleLabel.centerY = self.height / 2
            
        case .top, .bottom:
            self.size = CGSize(width: max(_titleLabel.width, _imageView.width) + horAdding, height: _titleLabel.height + contentSpace + _imageView.height + verAdding)
            _contentView.frame = self.bounds
            _imageView.top = overInset.top
            _titleLabel.top = _imageView.bottom + contentSpace
            _imageView.centerX = self.width / 2
            _titleLabel.centerX = self.width / 2
            
        case .center:
            self.size = CGSize(width: max(_titleLabel.width, _imageView.width), height: max(_titleLabel.height, _imageView.height))
            _contentView.frame = self.bounds
            _imageView.center = self.contentCenter
            _titleLabel.center = self.contentCenter
            _titleLabel.width = min(_titleLabel.width, self.width)
            _titleLabel.height = min(_titleLabel.height, self.height)
        }
        
    }
    
    override func sizeToFit() {
        didSetup = true
        _layout(sizeToFit: true)
    }
    
    override var intrinsicContentSize: CGSize {
        return self.size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        didSetup = true
        _layout(sizeToFit: false)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        didSetup = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isThrottleTime { return; }
        if adjustsAlphaWhenHilight { self.alpha = 0.5 }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isThrottleTime { return; }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isThrottleTime { return; }
        if adjustsAlphaWhenHilight { self.alpha = 1 }
        super.touchesEnded(touches, with: event)
        if self.throttleTime > 0 {
            self.isThrottleTime = true
            DispatchQueue.main.asyncAfter(deadline: .now() + self.throttleTime) {
                self.isThrottleTime = false
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isThrottleTime { return; }
        if adjustsAlphaWhenHilight { self.alpha = 1 }
        super.touchesCancelled(touches, with: event)
    }
    
    @objc func _touchAction() {
        if let action = self.onTouchUpInside {
            action(self)
        }
    }
    
    func addUpInsideTarget(_ target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setImage(url: URL?, placeholderImage: UIImage?) {
        self._imageUrl = url
        self._placeholerImage = placeholderImage
        self._imageView.kf.setImage(with: url, placeholder: placeholderImage, options: nil) { _ in
            
        }
    }
    
    func cancelImageDownload() {
        self._imageView.kf.cancelDownloadTask()
    }
    
}


// 默认双阴影样式
extension Button {
    
    func setDefaultShadowStyle(cornerRadius: CGFloat) {
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.theme.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.5
        
        self.showInnerShadow = true
        self._contentView.layer.cornerRadius = cornerRadius
        
    }
    
    func clearDefaultShadowStyle() {
        self.layer.shadowColor = nil
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0
        self.showInnerShadow = false
    }
    
}
// MARK: 给文本增加下划线
extension UIButton {
    func underline() {
        
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
        
    }
    
}



