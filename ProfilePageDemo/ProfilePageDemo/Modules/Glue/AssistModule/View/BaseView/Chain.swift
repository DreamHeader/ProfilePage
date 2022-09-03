//
//  Chain.swift
//  unipets-ios
//
//  Created by LRanger on 2021/12/1.
//

import Foundation
import UIKit
import Kingfisher

// MARK: - ViewChainBuilder
protocol ViewChainBuilder {
    
    associatedtype Source: UIView
    
    var source: Source { get set }
}

extension ViewChainBuilder {
    
    @discardableResult
    func isUserInteractionEnabled(_ val: Bool) -> Self {
        source.isUserInteractionEnabled = val
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        source.backgroundColor = color
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ val: Bool = true) -> Self {
        source.clipsToBounds = val
        return self
    }
    
    @discardableResult
    func cornerRadius(_ val: CGFloat) -> Self {
        source.layer.cornerRadius = val
        return self
    }
    
    @discardableResult
    func cornerCurve(_ val: CALayerCornerCurve) -> Self {
        source.layer.cornerCurve = val
        return self
    }
    
    @discardableResult
    func shadow(_ color: UIColor, opacity: Float, radius: CGFloat, offset: CGSize) -> Self {
        source.layer.shadowColor = color.cgColor
        source.layer.shadowOffset = offset
        source.layer.shadowRadius = radius
        source.layer.shadowOpacity = opacity
        return self
    }
    
    @discardableResult
    func border(_ color: UIColor, width: CGFloat) -> Self {
        source.layer.borderColor = color.cgColor
        source.layer.borderWidth = width
        return self
    }
    
    @discardableResult
    func maskedCorners(_ val: CACornerMask) -> Self {
        source.layer.maskedCorners = val
        return self
    }
    
    @discardableResult
    func topMaskedCorners(radius: CGFloat) -> Self {
        source.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        source.layer.cornerRadius = radius
        source.layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func bind(_ view: UIView?) -> Self {
        view?.addSubview(source)
        return self
    }
    
    func result() -> Source {
        return source
    }
    
}

// MARK: - FrameChainBuilder
protocol FrameChainBuilder {
    
    associatedtype Source: UIView
    
    var source: Source { get set }
}

extension FrameChainBuilder {
    
    @discardableResult
    func sizeToFit() -> Self {
        source.sizeToFit()
        return self
    }
    
    @discardableResult
    func frame(_ frame: CGRect) -> Self {
        source.frame = frame
        return self
    }
    
    @discardableResult
    func size(_ size: CGSize) -> Self {
        source.size = size
        return self
    }
    
    @discardableResult
    func top(_ val: CGFloat) -> Self {
        source.top = val
        return self
    }
    
    @discardableResult
    func bottom(_ val: CGFloat) -> Self {
        source.bottom = val
        return self
    }
    
    @discardableResult
    func leading(_ val: CGFloat) -> Self {
        source.leading = val
        return self
    }
    
    @discardableResult
    func left(_ val: CGFloat) -> Self {
        source.left = val
        return self
    }
    
    @discardableResult
    func right(_ val: CGFloat) -> Self {
        source.right = val
        return self
    }
    
    @discardableResult
    func trailing(_ val: CGFloat) -> Self {
        source.trailing = val
        return self
    }
    
    @discardableResult
    func center(_ val: CGPoint) -> Self {
        source.center = val
        return self
    }
    
    @discardableResult
    func centerX(_ val: CGFloat) -> Self {
        source.centerX = val
        return self
    }
    
    @discardableResult
    func centerY(_ val: CGFloat) -> Self {
        source.centerY = val
        return self
    }
    
    @discardableResult
    func width(_ val: CGFloat) -> Self {
        source.width = val
        return self
    }
    
    @discardableResult
    func height(_ val: CGFloat) -> Self {
        source.height = val
        return self
    }
    
    @discardableResult
    func trim(_ action: (Source) -> Void) -> Self {
        action(source)
        return self
    }
  
}

// chain label
enum CL {

    static func source(_ view: UILabel? = nil) -> Builder {
        return Builder(view)
    }
    
    struct Builder : ViewChainBuilder, FrameChainBuilder {
        
        internal var source: UILabel
                
        init(_ source: UILabel? = nil) {
            if let source = source {
                self.source = source
            } else {
                self.source = UILabel()
            }
        }
        
        @discardableResult
        func text(_ val: String?) -> Self {
            source.text = val
            return self
        }
        
        @discardableResult
        func font(_ size: CGFloat, weight: UIFont.Weight = .medium) -> Self {
            source.font = UIFont.systemFont(ofSize: size, weight: weight)
            return self
        }
        
        @discardableResult
        func color(_ color: UIColor?) -> Self {
            source.textColor = color
            return self
        }
        
        @discardableResult
        func numberOflines(_ val: Int) -> Self {
            source.numberOfLines = val
            return self
        }
        
        @discardableResult
        func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
            source.textAlignment = textAlignment
            return self
        }
        
    }
}

// chain image
enum CI {

    static func source(_ source: UIImageView? = nil) -> Builder {
        return Builder(source)
    }
    
    struct Builder : ViewChainBuilder, FrameChainBuilder {
        
        internal var source: UIImageView
                
        init(_ source: UIImageView? = nil) {
            if let source = source {
                self.source = source
            } else {
                self.source = UIImageView()
            }
        }
        
        @discardableResult
        func image(_ val: UIImage?) -> Self {
            source.image = val
            return self
        }
        
        @discardableResult
        func image(_ val: String?) -> Self {
            if let val = val {
                source.image = UIImage.name(val)
            }
            return self
        }
        
        @discardableResult
        func contentMode(_ mode: UIView.ContentMode) -> Self {
            source.contentMode = mode
            return self
        }
        
    }
}

// chain view
enum CV {

    static func source(_ source: UIView? = nil) -> Builder {
        return Builder(source)
    }
    
    struct Builder : ViewChainBuilder, FrameChainBuilder {
        
        internal var source: UIView
                
        init(_ source: UIView? = nil) {
            if let source = source {
                self.source = source
            } else {
                self.source = UIView()
            }
        }
        
    }
}

// chain button
enum CB {

    /**
     let btn = CB.source()
         .title("123")
         .fontSize(12, weight: .medium)
         .touchupInside { view in
         
         }.result()
     */
    static func source(_ button: Button? = nil) -> Builder {
        return Builder(button)
    }
    
    struct Builder : ViewChainBuilder, FrameChainBuilder {
        
        internal var source: Button
                
        init(_ source: Button? = nil) {
            if let source = source {
                self.source = source
            } else {
                self.source = Button()
            }
        }
        
        @discardableResult
        func titleColor(_ color: UIColor) -> Builder {
            source.titleColor = color
            return self
        }
        
        @discardableResult
        func fontSize(_ size: CGFloat, weight: UIFont.Weight = .regular) -> Builder {
            source.titleFont = UIFont.systemFont(ofSize: size, weight: weight)
            return self
        }
        
        @discardableResult
        func title(_ text: String) -> Builder {
            source.title = text
            return self
        }
        
        @discardableResult
        func touchupInside(_ target: Any?, action: Selector) -> Builder {
            source.addTarget(target, action: action, for: .touchUpInside)
            return self
        }
        
        @discardableResult
        func touchupInside(_ on: @escaping (Button) -> Void) -> Builder {
            source.onTouchUpInside = on
            return self
        }
        
        @discardableResult
        func inset(_ inset: UIEdgeInsets) -> Builder {
            source.overInset = inset
            return self
        }

        @discardableResult
        func imagePostition(_ pos: Button.ImagePosition) -> Builder {
            source.imagePosition = pos
            return self
        }
        
        @discardableResult
        func alignment(_ ali: Button.Alignment) -> Builder {
            source.alignment = ali
            return self
        }
        
        @discardableResult
        func defaultShadowStyle(cornerRadius: CGFloat) -> Builder {
            source.setDefaultShadowStyle(cornerRadius: cornerRadius)
            return self
        }
        
        @discardableResult
        func image(_ image: UIImage?) -> Builder {
            source.image = image
            return self
        }
        
        @discardableResult
        func image(_ imageName: String) -> Builder {
            source.image = UIImage.name(imageName)
            return self
        }
        
        @discardableResult
        func imageSize(_ size: CGSize) -> Builder {
            source.imageSize = size
            return self
        }
        
        @discardableResult
        func selectedImage(_ imageName: String) -> Builder {
            source.selectedImage = UIImage.name(imageName)
            return self
        }
        
        @discardableResult
        func selectedImage(_ image: UIImage?) -> Builder {
            source.selectedImage = image
            return self
        }
        
        @discardableResult
        func image(_ url: String?, placeholderImage: UIImage? = nil) -> Builder {
            if let val = url {
                source.setImage(url: URL.init(string: val), placeholderImage: placeholderImage)
            }
            return self
        }
        
        @discardableResult
        func selectStateChange(_ on: @escaping (Button) -> Void) -> Builder {
            source.onSelectStateChange = on
            return self
        }
        
        @discardableResult
        func isSelected(_ isSelected: Bool) -> Builder {
            source.isSelected = isSelected
            return self
        }
        
        @discardableResult
        func contentSpace(_ val: CGFloat) -> Builder {
            source.contentSpace = val
            return self
        }
        
        @discardableResult
        func asBarItem() -> UIBarButtonItem {
            return UIBarButtonItem.init(customView: self.source)
        }
        
        @discardableResult
        func throttleTime(_ val: TimeInterval) -> Builder {
            source.throttleTime = val
            return self
        }
        
    }
    
}
