//
//  BuriedDataPoints.swift
//  unipets-ios
//
//  Created by FDKCoder on 2021/11/3.
//  数据埋点

import Foundation
import CoreTelephony.CTCarrier
import CoreTelephony.CTTelephonyNetworkInfo

struct BuriedDataPoints {
     
    /* 数据埋点的基础必传参数
     * A:不变的: 设备id(did) 操作系统(os) 系统版本(os_ver) 设备品牌(brand) 设备型号(model) 屏幕分辨率(dpi) 运营商(net_brand)
     * B:变的:   用户id(uid) 时间(time) ip(ip)  网络环境(net_type) 渠道(channel) 具体事件对应业务参数
     */
    
    static var noChangeBaseBuriedData: [String:String] {
        //MARK
        let deviceId = UIDevice.deviceID()
        let system = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let deviceBrand = UIDevice.current.localizedModel
        let deviceModel = UIDevice.current.model
        // 手机分辨率
        let deviceResolution = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        // 获取手机运营商
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        var deviceCarrier = "无运营商"
        if let _ = carrier?.isoCountryCode {
            deviceCarrier = carrier?.carrierName ?? "无运营商"
        }
        // MARK
        let buriedData = [
            "did": deviceId,
            "os": system,
            "os_ver": systemVersion,
            "brand": deviceBrand,
            "model": deviceModel,
            "dpi": "\(deviceResolution.width * scale)x\(deviceResolution.height * scale)",
            "net_brand": deviceCarrier,
        ]
        return buriedData
        
    }
    // 获取随时在变动的埋点数据 （因为埋点Api在使用的时候已经通过 setGlobalKV： 把不变的设置过）
    static func getChangeBuriedData(channel: String = "App", extensionParam: [String:String] = [String:String]()) -> [String:String]{
        var baseData = [String:String]()
        baseData["uid"] = LoginCache.shared().cid
        baseData["time"] = Date().dateToString()
        let device = UIDevice.current
        baseData["ip"] = device.getIPAddress() ?? "127.0.0.1"
        baseData["net_type"] = "\(NetworkCore.shared.networkStatus)"
        baseData["channel"] = channel
        for (key,value) in extensionParam {
            baseData[key] = value
        }
        return baseData
    }
    // 获取 不动 + 随时变动的 埋点 整合数据
    static func getBuriedData(channel: String = "App", extensionParam: [String:String] = [String:String]()) -> [String:String]{
        
        var baseData = BuriedDataPoints.noChangeBaseBuriedData
        let changeBaseData = BuriedDataPoints.getChangeBuriedData(channel: channel)
        for (key,value) in changeBaseData {
            baseData[key] = value
        }
        for (key,value) in extensionParam {
            baseData[key] = value
        }
        return baseData
    }
}

enum BuriedDataPointsEvenId: String {
    case PrivacyAgreementSignedAndExposed = "1" // 隐私协议签署
    case PrivacyAgreementSignedAgree = "2" // 隐私协议签署-同意
    case PrivacyAgreementSignedDisagree = "3" // 隐私协议签署-拒绝
    case PrivacyAgreementSignedTwicePopupExposure = "4" // 隐私协议签署2次弹窗    曝光
    case PrivacyAgreementTwiceSignedAgree = "5" // 隐私协议2次签署-同意
    case PrivacyAgreementTwiceSignedDisagree = "6" // 隐私协议2次签署-拒绝
    case UpgradePromptPopupExposure = "7" // 升级提示弹窗
    case UpgradePromptPopupExposureAgaree = "8" // 升级提示弹窗-同意    点击
    case UpgradePromptPopupExposureLater = "9" // 升级提示弹窗-稍后再说    点击
    case PermissionGetPopupExposure = "shouquantc_ios" // 权限获取弹窗    曝光
    case PermissionGetPopupExposureAgaree = "shouquantckq_ios" // 权限获取弹窗-同意    点击
    case PermissionGetPopupExposureDisagaree = "shouquantcjj_ios" // 权限获取弹窗-拒绝    点击
    case MyPage = "34" // 我的
    case MyPage_TabClick = "35" // 我的页面-我的tab    点击
    case MyPage_MyFocusClick = "36" // 我的页面-我的关注    点击
    case MyPage_MyFansClick = "37" // 我的页面-我的粉丝    点击
    case MyPage_GetLikeClick = "38" // 我的页面-获赞    点击
    case MyPage_VideoClick = "39" // 我的-视频点击    点击
    case MyPage_ClaimIdClick = "40" // 我的-领取身份    点击
    case MyPage_SelectPet = "41" // 我的页面-选择宠物    点击
    case MyPage_AddPetClick = "42" // 我的页面-添加宠物    点击
    case MyPage_MsgNotifyClick = "xiaoxizhongxin" // 我的页面-消息通知    点击
    case MyPage_SetClick = "shezhi" // 我的页面-设置
    case MyDraftExposure = "50"// 我的草稿列表   曝光
    case MyDraftExposure_VideoClick = "51" // 我的草稿列表-视频点击    点击
    case MusicRecomment = "58" // 音乐推荐
    case MusicRecomment_TabClick = "spjjy_yinyuefenlei" // 音乐推荐-音乐tab    点击
    case MusicRecomment_Listen = "60" // 音乐推荐-试听音乐
    case MusicRecomment_Pause = "61" // 音乐推荐-暂停音乐    点击
    case MusicRecomment_FavoritesOrCollect = "spjjy_shoucang" // 音乐推荐-收藏/取收音乐    点击
    case MusicRecomment_UseMusic = "63" // 音乐推荐-使用音乐    点击
    case MusicRecomment_MoreMusicClick = "64" // 音乐推荐-更多音乐    点击
    case MusicRecomment_DelMusic = "65" // 音乐推荐-删除使用音乐    点击
    case MsgNotifyPageExposure = "83" // 消息通知列表    曝光
    case MsgNotifyPage_LikeMessageClick = "84" // 消息通知-点赞消息    点击
    case MsgNotifyPage_AttentionMessageClick = "85" // 消息通知-关注消息    点击
    case MsgNotifyPage_MsgContentClick = "86" // 消息通知-消息内容
    case MsgNotifyPage_SetClick = "87" // 消息通知-消息设置    点击
    case MsgNotifyPage_BackClick = "88" // 消息通知列表-后退
    case MsgNotifyPageLickListExposure = "89" // 点赞消息列表    曝光
    case MsgNotifyPageLikeListBack = "91" // 点赞消息列表后退
    case MsgNotifyPageAttentionListExposure = "92" // 关注消息列表    曝光
    case MsgNotifyPageAttentionFollowOrTakeOff = "93" // 关注消息列表-关注/取关
    case MsgNotifyPageAttentionListBack = "94" // 关注消息列表-后退    点击
    case MsgNotifyPageMsgDetailExposure = "95" // 消息详情    曝光
    case MsgNotifyPageMsgDetailOpen = "96" // 消息详情-展开消息    点击
    case MsgNotifyPageMsgDetailBack = "97" // 消息详情-后退    点击
}




