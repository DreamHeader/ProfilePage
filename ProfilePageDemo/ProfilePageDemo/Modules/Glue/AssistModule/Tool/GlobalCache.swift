//
//  GloableCache.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/23.
//

import UIKit
import Kingfisher

class GlobalCache {
    
    private static let cache = GlobalCache()
    private var user: User?
    
    static func shared() -> GlobalCache {
        return cache
    }
    
    init() {
        
    }
    
    func clear() {
        self.user = nil
    }
    
    /// 当前登录的用户
    func currentUser() -> User? {
        if let user = user {
            return user
        }
        let cid = LoginCache.shared().cid
        if cid.isEmpty == false && LoginCache.shared().token.isEmpty == false {
            guard let dbPortal: RealmPortal = "RealmPortal".getModule() else {
                return nil
            }
            if let user = try? dbPortal.dbClient.query(type: User.self).filter(NSPredicate(format: "cid == %@", cid)).first {
                self.user = user
                return user
            }
            
            let user = User()
            user.cid = cid
            user.phoneNo = LoginCache.shared().phoneNo
            self.user = user
            return user
        }
        return nil
    }
    
    func clearUserCache() {
        self.user = nil
    }
    
    // 本地缓存大小: byte
    func getDiskCacheSize(_ completion: @escaping (UInt) -> Void ) {
        ImageCache.default.calculateDiskStorageSize { res in
            switch res {
            case .success(let size):
                completion(size)
            case .failure(_):
                completion(0)
            }
        }
    }
    
    func clearDiskCache(completion: @escaping () -> Void) {
        ImageCache.default.clearDiskCache {
            completion()
        }
    }

}

extension GlobalCache {
    
    struct Key {
        // 一些偏好设置
        // 是否已经同意并阅读隐私协议政策
        static var PrivacyPolicy = "PrivacyPolicy"
        // 是否显示水印. 默认true
        static var ShowWatermark = "ShowWatermark"
        // 上次使用的镜头
        static var CameraPosition = "CameraPosition"
        // 收藏的本地道具
        static var collectedPropIds = "collectedPropIds"
        // 是否显示拍照声音. 默认true
        static var TakePicMusic = "TakePicMusic"
        // 是否显示新人道具使用引导
        static var PropUseGuide = "PropUseGuide"
        // 设置拍照是否自动保存到相册
        static var AutoSavePhotoLibrary = "AutoSavePhotoLibrary"
        // 设置自拍动画是否打开
        static var SelfieAnimate = "SelfieAnimate"
        // 设置人脸美颜程度
        static var FacialBeautyDegree = "FacialBeautyDegree"
    }
}

// 隐私协议
extension GlobalCache {
    
    private var ignoreVersions: [String] {
        return []
    }
    
    func readPrivacyPolicyConfig(version: String) -> Bool {
        if let info: UPJson = self.readConfig(key: Key.PrivacyPolicy) {
            let res = info[version] as? Bool
            return res ?? false
        }
        return false
    }
    
    func setPrivacyPolicyConfig(version: String, didAgree: Bool) {
        self.setConfig(key: Key.PrivacyPolicy) { (_ val: UPJson?) in
            var info = val ?? UPJson()
            info[version] = didAgree
            return info
        }
    }
}


// 水印设置
extension GlobalCache {

    func readWatermarkConfig() -> Bool {
        return self.readConfig(key: Key.ShowWatermark) ?? true
    }
    
    func setWatermarkConfig(show: Bool) {
        self.setConfig(key: Key.ShowWatermark) { val in
            return show
        }
    }
}

// 音乐设置
extension GlobalCache {

    func readTakePicMusicConfig() -> Bool {
        return self.readConfig(key: Key.TakePicMusic) ?? true
    }
    
    func setTakePicMusicConfig(show: Bool) {
        self.setConfig(key: Key.TakePicMusic) { val in
            return show
        }
    }
}

// 设置拍照是否自动保存到相册
extension GlobalCache {

    func readAutoSavePhotoLibrary() -> Bool {
        return self.readConfig(key: Key.AutoSavePhotoLibrary) ?? false
    }
    
    func setAutoSavePhotoLibrary(show: Bool) {
        self.setConfig(key: Key.AutoSavePhotoLibrary) { val in
            return show
        }
    }
}

// 设置自拍动画是否打开
extension GlobalCache {

    func readSetSelfieAnimate() -> Bool {
        return self.readConfig(key: Key.SelfieAnimate) ?? true
    }
    
    func setSelfieAnimate(show: Bool) {
        self.setConfig(key: Key.SelfieAnimate) { val in
            return show
        }
    }
}

// 设置人脸美颜程度
extension GlobalCache {

    func readSetFacialBeautyDegree() -> Double {
        return self.readConfig(key: Key.FacialBeautyDegree) ?? 7.0
    }
    
    func setFacialBeautyDegree(beautyDegree: Double) {
        self.setConfig(key: Key.FacialBeautyDegree) { val in
            return beautyDegree
        }
    }
}
// 本地收藏的道具
extension GlobalCache {

    func collectedPropIds() -> [String] {
        return self.readConfig(key: Key.collectedPropIds) ?? [String]()
    }
    
    func setCollectedPropIds(ids: [String]) {
        self.setConfig(key: Key.collectedPropIds) { val in
            return ids
        }
    }
}
// 镜头设置
extension GlobalCache {

    func readCameraPositionIsBack() -> Bool {
        return self.readConfig(key: Key.CameraPosition) ?? true
    }
    
    func setCameraPositionIsBack(isBack: Bool) {
        self.setConfig(key: Key.CameraPosition) { val in
            return isBack
        }
    }
}

// 新人道具使用引导
extension GlobalCache {

    func readPropUseGuide() -> Bool {
        return self.readConfig(key: Key.PropUseGuide) ?? false
    }
    
    func setPropUseGuide(isUse: Bool) {
        self.setConfig(key: Key.PropUseGuide) { val in
            return isUse
        }
    }
}


extension GlobalCache {
    
    // 配置的key, 返回对用的类型
    private func readConfig<T>(key: String) -> T? {
        let userDefault = UserDefaults.standard
        return (userDefault.value(forKey: "PrefrredConfig") as? UPJson)?[key] as? T
    }
    
    // 根据配置的key更新设置
    private func setConfig<T>(key: String, _ handler: (T?) -> T?) {
        let userDefault = UserDefaults.standard
        var config = (userDefault.value(forKey: "PrefrredConfig") as? UPJson) ?? UPJson()
        let res = handler(config[key] as? T)
        config[key] = res
        userDefault.setValue(config, forKey: "PrefrredConfig")
        userDefault.synchronize()
    }
    
}


