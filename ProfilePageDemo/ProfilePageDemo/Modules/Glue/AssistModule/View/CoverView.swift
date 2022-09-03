//
//  CoverView.swift
//  unipets-ios
//
//  Created by LRanger on 2022/5/7.
//

import Foundation
import UIKit
import APNGKit
import Kingfisher

class CoverView: FLAnimatedImageView {
    
    private var apngView: APNGImageView = APNGImageView()
    
    override var contentMode: UIView.ContentMode {
        didSet {
            apngView.contentMode = contentMode
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.apngView.contentMode = contentMode
        self.apngView.autoStartAnimationWhenSetImage = true
        self.addSubview(self.apngView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        apngView.frame = self.bounds
    }

    func setImage(remotePath: String?, placeholderImage: UIImage? = nil) {
        guard let remotePath = remotePath, let source = URL.with(remotePath) else {
            return
        }
        
        self.image = nil
        self.animatedImage = nil
        self.apngView.image = nil
        self.apngView.isHidden = true
        
        self.kf.cancelDownloadTask()

        let ext = remotePath.filePathExtension().lowercased()
        
        if ext == "apng" {
            if placeholderImage != nil {
                self.image = placeholderImage
            }
            KingfisherManager.shared.retrieveImage(with: source, options: [.cacheOriginalImage, .waitForCache, .processor(PetDefaultImageProcessor.default)], progressBlock: nil, downloadTaskUpdated: nil) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        do {
                            let path = KingfisherManager.shared.cache.cachePath(forKey: value.source.cacheKey)
                            let data = try Data.init(contentsOf: URL.fileURL(path))
                            let image = try APNGImage.init(data: data)
                            self.apngView.image = image
                            self.apngView.isHidden = false
                            self.image = nil
                            self.animatedImage = nil
                        } catch {
                            UPLog("apng error: \(error)")
                        }
                    case .failure(let error):
                        UPLog(error)
                    }
                }
            }
            
        } else if ext == "gif" {
            if placeholderImage != nil {
                self.image = placeholderImage
            }
            KingfisherManager.shared.retrieveImage(with: source, options: [.cacheOriginalImage, .waitForCache, .processor(PetDefaultImageProcessor.default)], progressBlock: nil, downloadTaskUpdated: nil) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        do {
                            let path = KingfisherManager.shared.cache.cachePath(forKey: value.source.cacheKey)
                            let data = try Data.init(contentsOf: URL.fileURL(path))
                            self.animatedImage = FLAnimatedImage.init(gifData: data)
                        } catch {
                            UPLog("gif error: \(error)")
                        }
                    case .failure(let error):
                        UPLog(error)
                    }
                }
            }
        } else {
            self.kf.setImage(with: source, placeholder: placeholderImage, options: [], completionHandler: nil)
        }
        
    }
    
    func setImage(localPath: String) {
        self.image = nil
        self.animatedImage = nil
        self.apngView.image = nil
        self.apngView.isHidden = true

        self.kf.cancelDownloadTask()

        let ext = localPath.filePathExtension().lowercased()

        if ext == "apng" {
            do {
                let data = try Data.init(contentsOf: URL.fileURL(localPath))
                let image = try APNGImage.init(data: data)
                self.apngView.image = image
                self.apngView.isHidden = false
            } catch {
                UPLog("apng error: \(error)")
            }
        } else if ext == "gif" {
            do {
                let data = try Data.init(contentsOf: URL.fileURL(localPath))
                self.animatedImage = FLAnimatedImage.init(gifData: data)
            } catch {
                UPLog("gif error: \(error)")
            }
        } else {
            self.image = UIImage.image(of: localPath)
        }
    }
    
    func setImage(localName: String) {
        self.image = nil
        self.animatedImage = nil
        self.apngView.image = nil
        self.apngView.isHidden = true
        
        self.kf.cancelDownloadTask()

        let ext = localName.filePathExtension().lowercased()

        if ext == "apng" {
            do {
                let localPath = Bundle.main.path(forResource: localName.filePathName(), ofType: localName.filePathExtension()) ?? ""
                let data = try Data.init(contentsOf: URL.fileURL(localPath))
                let image = try APNGImage.init(data: data)
                self.apngView.image = image
                self.apngView.isHidden = false
            } catch {
                UPLog("apng error: \(error)")
            }
        } else if ext == "gif" {
            do {
                let localPath = Bundle.main.path(forResource: localName.filePathName(), ofType: localName.filePathExtension()) ?? ""
                let data = try Data.init(contentsOf: URL.fileURL(localPath))
                self.animatedImage = FLAnimatedImage.init(gifData: data)
            } catch {
                UPLog("gif error: \(error)")
            }
        } else {
            self.image = UIImage.name(localName)
        }
    }

}

public struct PetDefaultImageProcessor: ImageProcessor {
    
    /// A default `DefaultImageProcessor` could be used across.
    public static let `default` = PetDefaultImageProcessor()
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public let identifier = "PetDefaultImageProcessor"
    
    /// Creates a `DefaultImageProcessor`. Use `DefaultImageProcessor.default` to get an instance,
    /// if you do not have a good reason to create your own `DefaultImageProcessor`.
    public init() {}
    
    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image.kf.scaled(to: options.scaleFactor)
        case .data(let data):
            return KingfisherWrapper.image(data: data, options: ImageCreatingOptions())
        }
    }
}
