//
//  UserThirdLogin.swift
//  unipets-ios
//
//  Created by Future on 2022/5/25.
//

import UIKit
import AuthenticationServices

typealias LoginSuccessBlock = (_ source: String,_ code: String,_ userId: String,_ email: String,_ fullName: String,_ identityToken: String,_ accessToken: String,_ refreshToken: String,_ unionId: String) -> Void


typealias LoginFailureBlock = (_ error: RuntimeError?) -> Void

enum UserThirdLoginType {
    case wechat
    case qq
    case weibo
    case apple
    case unknow
    func desType()-> String{
        var content = ""
        switch self {
        case .wechat:
            content = "wechat"
        case .qq:
            content = "qq"
        case .weibo:
            content = "weibo"
        case .apple:
            content = "apple"
        case .unknow:
            content = ""
        }
        return content
    }
}

class UserThirdLogin: NSObject {
    
    private static let _share = UserThirdLogin()
    static func shared() -> UserThirdLogin {
        return _share
    }
    private var successCompelecte: LoginSuccessBlock?
    private var failureCompelecte: LoginFailureBlock?
    private weak var parentController: UIViewController?
    private override init() {
    }
    
    override func copy() -> Any {
        return UserThirdLogin.shared // self
    }
    
    override func mutableCopy() -> Any {
        return UserThirdLogin.shared// self
    }
    
    // Optional
    public func reset() {
        // Reset all properties to default value
    }
    func startUnionLogin(loginType: UserThirdLoginType,success: LoginSuccessBlock? = nil, failure: LoginFailureBlock? = nil){
        switch loginType {
        case .wechat:
            self.showWXLogin(success: success, failure: failure)
        case .apple:
            self.showAppleLogin(success: success, failure: failure)
        case .qq:
            self.showQQLogin(success: success, failure: failure)
        case .weibo:
            self.showWeiBoLogin(success: success, failure: failure)
        case .unknow:
            break
        }
    }
}
// Apple Login {
extension UserThirdLogin {
    
    public func showAppleLogin(success: LoginSuccessBlock? = nil, failure: LoginFailureBlock? = nil) {
        self.successCompelecte = success
        self.failureCompelecte = failure
        let provider = ASAuthorizationAppleIDProvider.init()
        let request = provider.createRequest()
        let controller = ASAuthorizationController.init(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    public func isPast(userID: String) -> Void {
        let provider = ASAuthorizationAppleIDProvider.init()
        provider.getCredentialState(forUserID: userID) { (status, error) in
            switch status {
            case .revoked: do { // 已撤销
            }
            case .authorized: do {  // 已授权
            }
            case .notFound: do {    // 未发现
            }
            case .transferred: do { // 已转移
            }
            @unknown default:
                break
            }
        }
    }
}
@available(iOS 13, *)
extension UserThirdLogin: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return KeyWindow()
    }
}

@available(iOS 13, *)
extension UserThirdLogin: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let baseError = RuntimeError.init(error)
        self.failureCompelecte?(baseError)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if authorization.credential is ASAuthorizationAppleIDCredential {   // 登录
            let credential = authorization.credential as! ASAuthorizationAppleIDCredential
            // user只要用户与请求客户机连接，标识符就会保持稳定。
            // 当用户断开与标识提供者的连接时，该值可能会改变
            let user = credential.user
            let source = UserThirdLoginType.apple.desType()
            let fullName = credential.fullName?.nickname ?? ""
            let email = credential.email ?? ""
            guard let authorizationCode = credential.authorizationCode else {
                self.failureCompelecte?(RuntimeError.init("authorizationCode为空"))
                return
            }
            guard let code = String.init(data: authorizationCode, encoding: .utf8) else {
                self.failureCompelecte?(RuntimeError.init("authorizationCode为空"))
                return
            }
            guard let identityToken = credential.identityToken else {
                self.failureCompelecte?(RuntimeError.init("identityToken为空"))
                return
            }
            guard let token = String.init(data: identityToken, encoding: .utf8) else {
                self.failureCompelecte?(RuntimeError.init("identityToken为空"))
                return
            }
            self.successCompelecte?(source,code,user,email,fullName,token,"","","")
           
        }
        else if authorization.credential is ASPasswordCredential {  // 使用现有的iCloud密钥链凭证登录。
            // let credential = authorization.credential as! ASPasswordCredential
            // let user = credential.user
            // let password = credential.password
            let baseError = RuntimeError.init("授权失败")
            self.failureCompelecte?(baseError)
        }
        else {
            let baseError = RuntimeError.init("授权失败")
            self.failureCompelecte?(baseError)
        }
    }
}
//  Apple login }

// Wx Login {
extension UserThirdLogin {
    
    public func showWXLogin(success: LoginSuccessBlock? = nil, failure: LoginFailureBlock? = nil) {
        self.successCompelecte = success
        self.failureCompelecte = failure
        
        PetThirdShareManage.shared().wxLoginBlock = { code,error in
            // WX Login Fail
            if let error = error {
                self.failureCompelecte?(error)
            }else{
                self.successCompelecte?(UserThirdLoginType.wechat.desType(),code,"","","","","","","")
            }
        }
        PetThirdShareManage.shared().authWxLogin()
        
    }
}
// WeiBo Login {
extension UserThirdLogin {
    
    public func showWeiBoLogin(success: LoginSuccessBlock? = nil, failure: LoginFailureBlock? = nil) {
        self.successCompelecte = success
        self.failureCompelecte = failure
        
        PetThirdShareManage.shared().weiboLoginBlock = { userId,accessToken,refreshToken,error in
            // WX Login Fail
            if let error = error {
                self.failureCompelecte?(error)
            }else{
                self.successCompelecte?(UserThirdLoginType.weibo.desType(),"",userId,"","","",accessToken,refreshToken,"")
            }
        }
        PetThirdShareManage.shared().signWeiboLogin()
    }
}
// }
// QQ Login {
extension UserThirdLogin {
    
    public func showQQLogin(success: LoginSuccessBlock? = nil, failure: LoginFailureBlock? = nil) {
        self.successCompelecte = success
        self.failureCompelecte = failure
        PetThirdShareManage.shared().qqLoginBlock = { code,userID,accessToken,unionId,error in
            if let error = error {
                self.failureCompelecte?(error)
            }else{
                self.successCompelecte?(UserThirdLoginType.qq.desType(),code,userID,"","","",accessToken,"",unionId)
            }
        }
        PetThirdShareManage.shared().authQQLogin()
    }
}
// }
extension UserThirdLogin { // 目前此处的请求全部转移到小程序去做 暂时无用
    
    /// 请求第三方授权登陆认证
    /// - Parameters:
    ///   - source: 第三方平台 枚举(4)可选项：wechat/qq/weibo/apple
    ///   - code: 授权码 authorizationCode
    ///   - userId: [Apple]授权的用户唯一标识 当source=apple时要求必传
    ///   - email: [Apple]授权的用户邮箱 当source=apple时要求必传
    ///   - fullName: [Apple]授权的用户全名 当source=apple时要求必传
    ///   - identityToken: [Apple]授权用户的JWT凭证 当source=apple时要求必传
    ///   - accessToken:[新浪微博]Openapi授权访问token：access_token
    ///   - refreshToken: [新浪微博]access_token刷新token：refresh_token
    ///   - response: thirdPartyId 用户当前在第三方平台id标识 例如：微信openid、QQ openid、Apple us
    ///    isMobileBind 手机号是否绑定 若未绑定，则前端需要开启绑定手机号流程
    func requsetUnionLoginAuth(source: String, code: String,userId: String = "",email: String = "",fullName: String = "",identityToken: String = "",accessToken: String = "",refreshToken: String = "",response: @escaping (_ isMobileBind: Bool,_ thirdPartyId: String?, _ error:RuntimeError?) -> Void){
        
        guard let net: NetworkPortal = "NetworkPortal".getModule() else {
            UPLog("miss network module")
            return
        }
        
        struct param: Codable {
            let source: String
            let code: String
            let userId: String
            let email: String
            let fullName: String
            let identityToken: String
            let accessToken: String
            let refreshToken: String
        }
        
        let p = param(source: source, code: code, userId: userId, email: email, fullName: fullName, identityToken: identityToken,accessToken: accessToken,refreshToken: refreshToken)
        
        net.Net.request(api: ServiceName.QueryUnionAuthLogin, parameters: p, headers: nil, cachePolicy: .none, refreshPolicy: .init(policay: .onlyRefresh, resendRequest: true)) { error, data, _ in
            
            if error != nil {
                response(false,nil,error)
                return
            }
            var thirdPartyId: String = ""
            var isMobileBind: Bool = false
            if let data = data as? UPJson {
                thirdPartyId = data["thirdPartyId"] as? String ?? ""
                isMobileBind = data["isMobileBind"] as? Bool ?? false
            }
            response(isMobileBind, thirdPartyId, nil)
        }
    }
    /// 联合登陆 绑定手机号
    /// - Parameters:
    ///   - thirdPartyId: 用户当前在第三方平台id标识  例如：微信openid、QQ openid、Apple userId
    ///   - mobileNo: 手机号码 手机号格式有校验，regex：^1[3-9]\d{9}$
    ///   - verifyCode: 短信验证码 当isForce=false时，短信验证码要求必填，服务端会校验该短信验证
    ///   - isForce: 是否强制绑定 后端会校验是否输入 & 校验过手机验证码
    ///   - response: isBindSucess 是否绑定成功
    func requestUnionBindMobile(thirdPartyId: String,mobileNo: String,verifyCode: String,isForce: Bool = false,response: @escaping (_ isBindSucess: Bool, _ error:RuntimeError?) -> Void){
        
        guard let net: NetworkPortal = "NetworkPortal".getModule() else {
            UPLog("miss network module")
            return
        }
        
        struct param: Codable {
            let thirdPartyId: String
            let mobileNo: String
            let verifyCode: String
            let isForce: Bool
        }
        
        let p = param(thirdPartyId: thirdPartyId, mobileNo: mobileNo, verifyCode: verifyCode, isForce: isForce)
        
        net.Net.request(api: ServiceName.QueryUnionBindMobile, parameters: p, headers: nil, cachePolicy: .none, refreshPolicy: .init(policay: .onlyRefresh, resendRequest: true)) { error, data, _ in
            
            if error != nil {
                response(false,error)
                return
            }
            let isBindSucess = data as? Bool ?? false
            response(isBindSucess, nil)
        }
    }
    
    /// 请求联合登陆
    /// - Parameters:
    ///   - thirdPartyId: 第三方平台用户标识，例：微信/QQ openid、微博用户userID、Apple userID
    ///   - response: 登陆成功数据
    func requestUnionLogin(thirdPartyId: String,response: @escaping (_ id: String?,_ cid: String?,_ token: String?,_ refreshTokens: String?,_ thirdPartyId: String?,_ isMobileBind: Bool?, _ error:RuntimeError?) -> Void){
        
        guard let net: NetworkPortal = "NetworkPortal".getModule() else {
            UPLog("miss network module")
            return
        }
        
        struct param: Codable {
            let thirdPartyId: String
        }
        
        let p = param(thirdPartyId: thirdPartyId)
        
        net.Net.request(api: ServiceName.RequestUnionLogin, parameters: p, headers: nil, cachePolicy: .none, refreshPolicy: .init(policay: .onlyRefresh, resendRequest: true)) { error, data, _ in
            
            if error != nil {
                response(nil,nil,nil,nil,nil,false,error)
                return
            }
            var _id : String = ""
            var _cid : String  = ""
            var _token : String  = ""
            var _refreshToken : String  = ""
            var _thirdPartyId : String  = ""
            var _isMobileBind : Bool = false
            if let data = data as? UPJson {
                _id = safe(data["id"] as? String)
                _cid = safe(data["cid"] as? String)
                _token = safe(data["token"] as? String)
                _refreshToken = safe(data["refreshToken"] as? String)
                _thirdPartyId = safe(data["thirdPartyId"] as? String)
                _isMobileBind = data["isMobileBind"] as? Bool ?? false
            }
            response(_id,_cid,_token,_refreshToken,_thirdPartyId,_isMobileBind,nil)
        }
    }
    
}
