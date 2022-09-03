//
//  User.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/3.
//

import UIKit
import RealmSwift

class User: Object, UPEquatable {

    @Persisted(primaryKey: true) var cid = "" // 目标用户cid
    @Persisted var phoneNo = "" // 用户手机号，脱敏处理
    @Persisted var nickName = "" // 用户昵称
    @Persisted var petNo = "" // 用户主宠号
    @Persisted var gender = "" // 用户性别
    @Persisted var birthday = "" // 用户出生日期，格式：yyyy-MM-dd
    @Persisted var info = "" // 用户简介
    @Persisted var photo = "" // 用户头像url
    @Persisted var isVip = false // 用户是否为Vip会员
    @Persisted var vipExpireAt = "" // 用户Vip有效期
    required override init() {
        super.init()
    }
    
    
    static func deserializeFrom(dic: [String: Any]?) -> User? {
        guard let dic = dic else {
            return nil
        }
        let user = User()
        user.cid = dic.stringValue("cid") ?? ""
        user.phoneNo = dic.stringValue("phoneNo") ?? ""
        user.nickName = dic.stringValue("nickName") ?? ""
        user.petNo = dic.stringValue("petNo") ?? ""
        user.gender = dic.stringValue("gender") ?? ""
        user.birthday = dic.stringValue("birthday") ?? ""
        user.info = dic.stringValue("info") ?? ""
        user.photo = dic.stringValue("photo") ?? ""
        user.isVip = dic.boolValue("isVip") ?? false
        user.vipExpireAt = (dic.stringValue("vipExpireAt") ?? "").splitServerTimeData()
        return user
    }

}

