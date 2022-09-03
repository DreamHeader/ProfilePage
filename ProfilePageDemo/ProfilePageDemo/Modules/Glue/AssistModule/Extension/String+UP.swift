//
//  String+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/11.
//

import Foundation

func safe(_ str: Any?) -> String {
    return (str as? String) ?? ""
}

extension String {
    
    static func uuid() -> String {
        return UUID.init().uuidString
    }
    
    func isImageExtension() -> Bool {
        let val = self.lowercased()
        return UTI.imageTypes.contains(val)
    }
    
    func isAnimationImageExtension() -> Bool {
        let val = self.lowercased()
        return UTI.animationImageTypes.contains(val)
    }
    
    func isVideoExtension() -> Bool {
        let val = self.lowercased()
        return UTI.videoTypes.contains(val)
    }
    
    func isAudioExtension() -> Bool {
        let val = self.lowercased()
        return UTI.audioTypes.contains(val)
    }
    
    /// xxx.jpg -> jpg
    func filePathExtension() -> String {
        return (self as NSString).pathExtension
    }
    
    /// xxx.jpg -> xxx
    func filePathName() -> String {
        let ext = "." + self.filePathExtension()
        return (self as NSString).lastPathComponent.replacingOccurrences(of: ext, with: "")
    }
    
    func lastPathComponent() -> String {
        return (self as NSString).lastPathComponent
    }
    
    func dataValue() -> Data? {
        return self.data(using: .utf8)
    }
    
    func jsonValueDecode() -> Any? {
        return self.dataValue()?.jsonValueDecode()
    }
    
    func jsonDictionaryValueDecode() -> [String: Any]? {
        return self.jsonValueDecode() as? [String: Any]
    }
    
    func maskPhoneNumber() -> String {
        if self.count >= 11 {
            let firstIndex = self.startIndex
            let start = self.index(firstIndex, offsetBy: 3)
            let end = self.index(start, offsetBy: 4)
            return self.replacingCharacters(in: start..<end, with: "****")
        }
        return self
    }
    /**
     获取 字符串 的给定宽度情况下的高度
     
     @param attribute 字符串 的字典属性 比如attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:18.f]}
     @param width 字符串  给定宽度
     @return 字符串 的字符串高度
     */
//    func getStringHeight(attribute: [NSAttributedString.Key: Any] , labelWidth: CGFloat) -> CGFloat {
//        var height: CGFloat = 0
//        let string = self as NSString
//        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
//        let lead = NSStringDrawingOptions.usesFontLeading
//        let ssss = NSStringDrawingOptions.usesDeviceMetrics
//        if self.count > 0 {
//            let rect = string.boundingRect(with: CGSize(width: labelWidth, height: CGFloat(MAXFLOAT)), options: [origin,lead,ssss], attributes: attribute, context: nil)
//            height = rect.size.height
//        }
//        return height
//    }
    /**
     获取一行的高度
     
     @param attribute 字符串 的字典属性 比如attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:18.f]}
     @return 字符串 的字符串宽度
     */
    func getOneLineStringHeight(attribute: [NSAttributedString.Key: Any]) -> CGFloat {
        var height: CGFloat = 0
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let ssss = NSStringDrawingOptions.usesDeviceMetrics
        let rect = "string".boundingRect(with: CGSize(width: 200, height: CGFloat(MAXFLOAT)), options: [origin,lead,ssss], attributes: attribute, context: nil)
        height = rect.size.height
        return height
    }
    /**
     获取 字符串 的给定高度情况下的宽度
     
     @param font 字体 和 大小
     @param labelHeight 字符串  给定高度
     @return 字符串 的字符串宽度
     */
    func getStringWidth(font: UIFont, labelHeight: CGFloat) -> CGFloat {
        
        var width: CGFloat = 0
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let ssss = NSStringDrawingOptions.usesDeviceMetrics
        if self.count > 0 {
            let rect = string.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height:labelHeight ), options: [origin,lead,ssss], attributes: [NSAttributedString.Key.font: font], context: nil)
            width = rect.size.width
        }
        return width
        
    }
    /**
     获取 字符串 的给定宽度情况下的高度
     
     @param font 字体 和 大小
     @param width 字符串  给定宽度
     @return 字符串 的字符串高度
     */
    func getStringHeight(font: UIFont, labelWidth: CGFloat) -> CGFloat {
        
        var height: CGFloat = 0
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let ssss = NSStringDrawingOptions.usesDeviceMetrics
        if self.count > 0 {
            let rect = string.boundingRect(with: CGSize(width: labelWidth, height: CGFloat(MAXFLOAT)), options: [origin,lead,ssss], attributes: [NSAttributedString.Key.font: font], context: nil)
            height = rect.size.height
        }
        return height
        
    }
    
    /**
     获取 字符串 一行的总长度
     
     @param font 字体 和 大小
     @return 字符串 的字符串宽度
     */
    func getOneLineStringHeight(font: UIFont) -> CGFloat {
        
        var height: CGFloat = 0
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let ssss = NSStringDrawingOptions.usesDeviceMetrics
        let rect = "string".boundingRect(with: CGSize(width: 200, height: CGFloat(MAXFLOAT)), options: [origin,lead,ssss], attributes: [NSAttributedString.Key.font: font], context: nil)
        height = rect.size.height
        return height
    }
    
    static func secondsDisplay(_ sec: Int) -> String {
        if sec > 60 * 60 {
            let hour = sec / 3600
            let minute = (sec - hour * 3600) / 60
            let seconds = sec - (minute * 60 + hour * 3600)
            return String.init(format: "%.2ld:%.2ld:%.2ld", hour, minute, seconds)
        } else {
            let minute = sec / 60
            let seconds = sec - (minute * 60)
            return String.init(format: "%.2ld:%.2ld", minute, seconds)
        }

    }
    /// 服务器返回的时间Time字段多余很多东西 用此方法处理下
    /// - Returns: App使用的时间 2023-09-24T00:00+08:00
    func splitServerTimeData() -> String {
        var newTime = ""
        let dataArr = self.split(separator: "T")
        if dataArr.count > 1 {
            let one = String(dataArr[0])
            let two = String(dataArr[1])
            let twoSplitArr = two.split(separator: "+")
            if twoSplitArr.count > 1 {
                var thirdString = twoSplitArr[1]
                let thirdSplitArr = thirdString.split(separator: ":")
                var targetNum = 3 - thirdSplitArr.count
                while targetNum > 0 {
                    thirdString = thirdString + ":00"
                    targetNum -= 1
                }
                newTime = "\(one) \(thirdString)"
                return newTime
            }
        }
        return self
    }
    // 日期字符串转化为Date类型
    func toDate(dateFormate: String = "yyyy-MM-dd HH:mm:ss")->Date? {
        let dateFormater = DateFormatter.init()
        dateFormater.dateFormat = dateFormate
        let date = dateFormater.date(from: self)
        return date 
    }
}


