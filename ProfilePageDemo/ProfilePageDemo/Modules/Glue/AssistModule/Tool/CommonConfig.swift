//
//  CommonConfig.swift
//  unipets-ios
//
//  Created by FDK on 2021/10/14.
//

import UIKit

let AmapWebKey = "bc96349d8ef4aec28728fd4b24db971a"
let AmapKey = "dd2003bac92e3fc1f9f774c82ae634cf"

// 宏
let SCREEN_WIDTH = CommonConfig.UI.screenWidth
let SCREEN_HEIGHT = CommonConfig.UI.screenHeight
let TABBAR_HEIGHT = CommonConfig.UI.tabBarHeight
let NAVBAR_HEIGHT = CommonConfig.UI.navigationBarHeight
let SCREEN_SCALE = UIScreen.main.scale
let STATUSBAR_HEIGHT = CommonConfig.UI.statusBarHeight
let SAFEAREA_BOTTOM_HEIGHT = CommonConfig.UI.safeAreaBottom
let IS_FULL_SCREEN = CommonConfig.UI.isFullScreen
let kUserHeadPlaceHolder = "userHeadPlaceHolder" // 人的头像默认图
let kUserHeadDogPlaceHolder = "dogHeadPlaceholder" // 主宠为狗的头像默认图
let kUserHeadCatPlaceHolder = "catHeadPlaceholder" // 主宠为猫的头像默认图
struct CommonConfig{
}
// MARK: UI通用高度配置
extension CommonConfig{
    
    struct UI{
        // 屏幕宽度
        static let screenWidth = UIScreen.main.bounds.width
        // 屏幕高度
        static let screenHeight = UIScreen.main.bounds.height
        // 状态栏高度
        static let statusBarHeight = CGFloat(getStatusBarHeight())
        // 导航栏高度
        static let navigationBarHeight = CGFloat(CommonConfig.UI.statusBarHeight + 44)
        // Tab 高度
        static let tabBarHeight = CGFloat(CommonConfig.UI.statusBarHeight > 20 ? 83 : 49)
        // 屏幕比例
        static let screenWidthRatio = CGFloat(CommonConfig.UI.screenWidth / 375)
        static var safeAreaBottom: CGFloat {
            var height: CGFloat = 0
            if #available(iOS 11.0, *) {
                height = KeyWindow().safeAreaInsets.bottom
            } else {
            }
            return height
        }
        static let isFullScreen = CommonConfig.UI.safeAreaBottom > 0
    }
}
