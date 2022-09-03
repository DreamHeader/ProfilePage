//
//  Bundle+Ext.swift
//  ProfilePageDemo
//
//  Created by FDKCoder on 2022/9/3.
//

import Foundation

public extension Bundle {
    /// 应用名称
    static var appBundleName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }

    /// 应用ID
    static var appBundleID: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    }

    /// 应用版本号
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    /// 应用构建版本号
    static var appBuildVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
