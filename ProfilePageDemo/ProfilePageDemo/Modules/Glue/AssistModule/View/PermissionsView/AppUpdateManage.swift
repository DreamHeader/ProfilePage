//
//  AppUpdateManage.swift
//  unipets-ios
//
//  Created by FDK on 2021/10/20.
//

import Foundation

struct AppUpdateManage {
    
    
    static let obsKey = "AppUpdateNextShowInfo"
    
    enum AppUpdateObsKey {
        case NoLongerRemind // 30天内不再提醒
        case LaterToSayAgain // 稍后再说
        func getTimeInterval() -> Int{
            var timeInterval: Int = 0
            switch self {
            case .NoLongerRemind:
                timeInterval = Int(Date().timeIntervalSince1970 + 30 * 60 * 60 * 24 ) // [版本:下次30日后要提醒的时间戳]
            case .LaterToSayAgain:
                timeInterval = Int(Date().timeIntervalSince1970 + 2 * 60 * 60 * 24) // [版本:下次2日后要提醒的时间戳]
            }
            return timeInterval
        }
    }
    // MARK: 存储用户点击升级版本case的“不再提醒”/“稍后再说”等 记录
    static func saveAppUpdateNextAlertShowInfo(appVersion: String?,obsKey: AppUpdateObsKey){
        
        guard let appVersion = appVersion else {
            return
        }
        
        var localData = UserDefaults.standard.object(forKey: AppUpdateManage.obsKey) as? [String:Int]
        
        let current = obsKey.getTimeInterval()
        
        localData = [appVersion:current]
        
        UserDefaults.standard.set(localData, forKey: AppUpdateManage.obsKey)
    }
    // MARK: 获取本地记录的上次点击升级版本的“不再提醒”/“稍后再说”等的数据
    static func getAppUpdateNextAlertShowInfo(appVersion: String?) -> Int {
        var time = 0
        
        let localData = UserDefaults.standard.object(forKey: AppUpdateManage.obsKey) as? [String:Int]
        
        if let localData = localData, let appVersion = appVersion {
            
            time = localData[appVersion] ?? 0
        }
        return time
    }
    //  检测当前的版本是否到了 点击“不再提醒”/“稍后再说”等 按钮后 再提醒的日期
    static func isCurAppVerisionAchieveShowTime(appVersion: String?) -> Bool {
        if let appVersion = appVersion {
            let appTime = getAppUpdateNextAlertShowInfo(appVersion: appVersion)
            
            if appTime == 0 {
                return true
            }
            let current = Date().timeIntervalSince1970
            return appTime < Int(current)
        }
        return true
    }
}
