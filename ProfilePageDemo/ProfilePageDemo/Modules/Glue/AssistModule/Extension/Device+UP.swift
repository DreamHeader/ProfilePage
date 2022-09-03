//
//  Device+Up.swift
//  unipets-ios
//
//  Created by LRanger on 2021/10/9.
//

import Foundation
import UIKit
import CoreServices
import SystemConfiguration.CaptiveNetwork

extension UIDevice {
    
    
    func getSSID() -> String {
        let interfaces = CNCopySupportedInterfaces()
        var ssid = ""
        if interfaces != nil {
            let interfacesArray = CFBridgingRetain(interfaces) as! Array<AnyObject>
            if interfacesArray.count > 0 {
                let interfaceName = interfacesArray[0] as! CFString
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                if (ussafeInterfaceData != nil) {
                    let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                    ssid = interfaceData["SSID"]! as! String
                }
            }
        }
        return ssid
    }
    
    //获取本机ip
    func getIPAddress() -> String? {
        var address: String?
        // get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        
        guard let firstAddr = ifaddr else {
            return nil
        }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
//    static func deviceID() -> String {
//        
//        let localDeviceUDIDKey = "kLocalDeviceUDIDKey"
//        
//        let localUDID = UserDefaults.standard.object(forKey: localDeviceUDIDKey) as? String ?? ""
//        
//        guard localUDID.count > 0 else {
//             
//            let keyChainUDID = KeychainStore.keyChainReadData(identifier: localDeviceUDIDKey) as? String ?? ""
//            // 如果本地和钥匙串都没有 那么两个都更新
//            guard  keyChainUDID.count > 0 else {
//                
//                let customDeviceUDID = "\(String.uuid())-\(Date().timeIntervalSince1970)"
//
//                UserDefaults.standard.set(customDeviceUDID, forKey: localDeviceUDIDKey)
//                
//                KeychainStore.keyChainSaveData(data: customDeviceUDID, withIdentifier: localDeviceUDIDKey)
//                
//                return customDeviceUDID
//            }
//            // 如果本地没有 钥匙串有 那么主动更新本地
//            UserDefaults.standard.set(keyChainUDID, forKey: localDeviceUDIDKey)
//            
//            return keyChainUDID
//        }
//        return localUDID
//    }
    
}

public extension UIDevice {
    
    // https://www.theiphonewiki.com/wiki/Models
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
            
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
            
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,3":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPhone9,4":                               return "iPhone 7 Plus"
            
        case "iPhone10,1":                               return "iPhone 8"
        case "iPhone10,4":                               return "iPhone 8"
        case "iPhone10,2":                               return "iPhone 8 Plus"
        case "iPhone10,5":                               return "iPhone 8 Plus"
            
        case "iPhone10,3":                               return "iPhone X"
        case "iPhone10,6":                               return "iPhone X"
        case "iPhone11,8":                               return "iPhone iPhone XR"

        case "iPhone11,2":                               return "iPhone Xs"
        case "iPhone11,6":                               return "iPhone Xs Max"
        case "iPhone11,4":                               return "iPhone Xs Max"

        case "iPhone12,1":                               return "iPhone 11"
        case "iPhone12,3":                               return "iPhone 11 Pro"
        case "iPhone12,5":                               return "iPhone 11 Pro Max"
        case "iPhone12,8":                               return "iPhone SE2"

        case "iPhone13,1":                               return "iPhone 12 mini"
        case "iPhone13,2":                               return "iPhone 12"
        case "iPhone13,3":                               return "iPhone 12 Pro"
        case "iPhone13,4":                               return "iPhone 12 Pro Max"

        case "iPhone14,4":                               return "iPhone 13 mini"
        case "iPhone14,5":                               return "iPhone 13"
        case "iPhone14,2":                               return "iPhone 13 Pro"
        case "iPhone14,3":                               return "iPhone 13 Pro Max"

        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air"
        case "iPad5,3", "iPad5,4":                       return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                       return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                       return "iPad Pro"
        case "AppleTV5,3":                               return "Apple TV"
        case "i386", "x86_64":                           return "Simulator"
        default:                                         return identifier
        }
    }
    
}
