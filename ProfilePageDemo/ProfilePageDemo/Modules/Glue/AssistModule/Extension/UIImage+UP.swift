//
//  UIImage+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/26.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    
    static func name(_ name: String) -> UIImage? {
        UIImage.init(named: name)
    }

    static func imageWith(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        if size.width == 0 || size.height == 0 {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func image(of path: String?) -> UIImage? {
        guard let _path = path else {
            return nil
        }
        if let data = try? Data(contentsOf: URL.init(fileURLWithPath: _path)) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func renderOriginal() -> UIImage {
        return self.withRenderingMode(.alwaysOriginal)
    }
    
    func scaleToSize(size: CGSize) -> UIImage {
        if self.size.width > size.width {
            UIGraphicsBeginImageContext(size)
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let res = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return res ?? self
        } else {
            return self
        }
    }
    
    func scaleToWidth(width: CGFloat) -> UIImage {
        return self.scaleToSize(size: CGSize(width: width, height: width * self.size.height / self.size.width))
    }
    
    /// 压缩图片到指定的大小btye
    /// - Parameter maxLength: size  单位是M
    /// - Returns: 返回压缩好的
    func compressImageOnlength(maxLength: Int) -> Data? {
        let maxL = maxLength * 1024 * 1024
        var compress:CGFloat = 0.9
        let maxCompress:CGFloat = 0.1
        var imageData = self.jpegData(compressionQuality: maxCompress)
        while (imageData?.count)! > maxL && compress > maxCompress {
            compress -= 0.1
            imageData = self.jpegData(compressionQuality: compress)
        }
        return imageData
    }

    
    /// 添加图层
    /// - Parameters:
    ///   - img: 要添加的图层
    ///   - rect: 图层坐标
    /// - Returns: 合成结果, 失败返回原始图片
    func drawImage(img: UIImage, rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        img.draw(in: rect)
        let res = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return res ?? self
    }

    func cropToRect(_ rect: CGRect) -> UIImage {
        if let val = self.cgImage?.cropping(to: rect) {
            return .init(cgImage: val)
        }
        return self
    }
    
}
extension UIImage {

    ///对指定图片进行拉伸
    func resizableImage(name: String) -> UIImage {

        var normal = UIImage(named: name)!
        let imageWidth = normal.size.width * 0.5
        let imageHeight = normal.size.height * 0.5
        normal = resizableImage(withCapInsets: UIEdgeInsets(top: imageHeight, left: imageWidth, bottom: imageHeight, right: imageWidth))
        return normal
    }

    /**
     *  压缩上传图片到指定字节
     *
     *  image     压缩的图片
     *  maxLength 压缩后最大字节大小
     *
     *  return 压缩后图片的二进制
     */
//    class func compressImage(image: UIImage, maxLength: Int) -> Data? {
//        
//        let newSize = self.scaleImage(image: image, imageLength:CGFloat(maxLength))
//        let newImage = image.byResize(to: newSize) ?? image
//        var compress:CGFloat = 0.9
//        let data = newImage.jpegData(compressionQuality: compress)
//        if var compressData = data {
//            while compressData.count > maxLength && compress > 0.01 {
//                compress -= 0.01
//                if let newData = newImage.jpegData(compressionQuality: compress){
//                    compressData = newData
//                }
//            }
//            return compressData
//        } else {
//            return data
//        }
//        
//    }

    /**
     *  通过指定图片最长边，获得等比例的图片size
     *
     *  image       原始图片
     *  imageLength 图片允许的最长宽度（高度）
     *
     *  return 获得等比例的size
     */
    class func scaleImage(image: UIImage, imageLength: CGFloat) -> CGSize {

        var newWidth:CGFloat = 0.0
        var newHeight:CGFloat = 0.0
        let width = image.size.width
        let height = image.size.height

        if (width > imageLength || height > imageLength){

            if (width > height) {

                newWidth = imageLength;
                newHeight = newWidth * height / width;

            }else if(height > width){

                newHeight = imageLength;
                newWidth = newHeight * width / height;

            }else{

                newWidth = imageLength;
                newHeight = imageLength;
            }

        }
        return CGSize(width: newWidth, height: newHeight)
    }

}
 
