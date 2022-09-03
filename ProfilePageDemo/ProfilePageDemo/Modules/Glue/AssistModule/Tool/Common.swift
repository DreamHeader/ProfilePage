//
//  UPCommon.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/10.
//

import UIKit

let Scheme = "unionpet"
 
/**
 这个类中会放一些通用的全局方法
 */
func UPLog<T>(_ message: T, file: String = #file, funcName: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):\(line)] \(message)")
    #endif
}

/// 测试需要
func isLRangerDebug() -> Bool {
    #if DEBUG
    return UIDevice.current.name.contains("Ranger")
    #else
    return false
    #endif
}
 
func pointSpace(point1: CGPoint, point2: CGPoint) -> CGFloat {
    let x = point1.x - point2.x
    let y = point1.y - point2.y
    return sqrt(x * x + y * y)
}

// p2 与 p1 x 轴夹角, x轴向右, y轴向下
func pointAngle(point1: CGPoint, point2: CGPoint) -> CGFloat {
    let x = point2.x - point1.x
    let y = point2.y - point1.y
    return atan2(y, x)
}

func KeyWindow() -> UIWindow {
    return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first ?? UIWindow()
}

func openSystemSetting() {
    if let url = URL.init(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

func getStatusBarHeight() -> CGFloat{
    
    if #available(iOS 13.0, *) {
        let statusBarManage = UIApplication.shared.windows.first?.windowScene?.statusBarManager
        return statusBarManage?.statusBarFrame.size.height ?? 0
    } else {
        return  UIApplication.shared.statusBarFrame.size.height;
    }
    
}

func AppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}

func AppBuild() -> String {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}

func AppBundleId() -> String {
    return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
}

@discardableResult
func OpenInAppStore() -> String {
    let link = "itms-apps://itunes.apple.com/app/id1589385461"
    if let url = URL.init(string: link) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    return link
}

func IsDebug() -> Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

struct AsyncResponse<T> {
    
    private let task: (_ data: Any?, @escaping (T) -> Void) -> Void
    
    init(_ task: @escaping (_ data: Any?, @escaping (T) -> Void) -> Void) {
        self.task = task
    }

    func requestData(data: Any? = nil, _ completion: @escaping ((T) -> Void)) {
        self.task(data, completion)
    }
    
}

enum DownLoadState {
    case none
    case downloading(CGFloat)
    case fail(RuntimeError)
    case success
}

func currentEnviroment() -> EnvConfigType {
    if let por: NetworkPortal = "NetworkPortal".getModule() {
        return por.Net.enviromentManager.environment
    }
    return .dev
}


struct Platform {
    enum API: Int, Encodable {
        case android = 1
        case iOS = 2
    }
}
