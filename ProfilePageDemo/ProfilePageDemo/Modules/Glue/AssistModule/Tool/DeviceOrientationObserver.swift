//
//  DeviceOrientationObserver.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/17.
//

import Foundation
import CoreMotion

class DeviceOrientationObserver {
    
    static let observer = DeviceOrientationObserver()
    
    private let manager = CMMotionManager()
    private(set) var orientation = UIDevice.current.orientation
    private var _orientation: UIDeviceOrientation?
    private var onUpdates = [String: ((UIDeviceOrientation) -> Void)]()
    
    static func shared() -> DeviceOrientationObserver {
        return observer
    }
    
    private init() {
        print("\(self.orientation)")
    }
    
    func updateOrientation(_ orientation: UIDeviceOrientation) {
        self.orientation = orientation
//        print("orientation: \(self.orientation.name())")
        self.onUpdates.values.forEach { (action) in
            action(orientation)
        }
    }
    
    func subscribeUpdate(_ action: @escaping (UIDeviceOrientation) -> Void, key: String) {
        self.onUpdates[key] = action
    }
    
    func removeSubscribe(key: String) {
        self.onUpdates[key] = nil
    }
    
    func start() {
        if manager.isDeviceMotionActive {
            UPLog("CoreMotion is active")
            return
        }
        if manager.isDeviceMotionAvailable {
            let queue = OperationQueue.current ?? OperationQueue.init()
            manager.gyroUpdateInterval = 1.0 / 10;
            manager.startAccelerometerUpdates(to: queue) { (data, error) in
                
                if let e = error {
                    UPLog("CoreMotion observer  error: \(e)")
                    return
                }
                
                if let data = data {
                    let currentOrientation: UIDeviceOrientation
                    let acceleration = data.acceleration
                    if acceleration.x >= 0.75 {
                        // home button left
                        currentOrientation = .landscapeRight
                    }
                    else if acceleration.x <= -0.75 {
                        // home button right
                        currentOrientation = .landscapeLeft
                    }
                    else if acceleration.y <= -0.75 {
                        currentOrientation = .portrait
                    }
                    else if acceleration.y >= 0.75 {
                        currentOrientation = .portraitUpsideDown
                    }
                    else {
                        currentOrientation = .unknown
                    }
                    
//                    UPLog("\(acceleration)")
                    
                    if currentOrientation != .unknown {
                        if let lastOrientation = self._orientation {
                            if lastOrientation != currentOrientation {
                                self._orientation = currentOrientation
                                self.updateOrientation(currentOrientation)
                            }
                        } else {
                            self._orientation = currentOrientation
                            self.updateOrientation(currentOrientation)
                        }
                    }
                }
                
            }
        }
    }
    
    func stop() {
        manager.stopAccelerometerUpdates()
    }
    
    private var activityInfo = [String: Bool]()
    func start(key: String) {
        self.start()
        self.activityInfo[key] = true
    }
    
    // 添加计数 当无人使用的时候停止监听
    func stop(key: String) {
        self.activityInfo.removeValue(forKey: key)
        if self.activityInfo.isEmpty {
            self.stop()
        }
    }
}

extension UIDeviceOrientation {
    
    func name() -> String {
        switch self {
        case .portrait:
            return "portrait"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .faceUp:
            return "faceUp"
        case .faceDown:
            return "faceDown"
        default:
            return "unknow"
        }
    }
}
