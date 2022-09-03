//
//  PetThirdShareManage.swift
//  unipets-ios
//
//  Created by Future on 2021/12/3.
//

import Foundation
import SwiftUI
import HandyJSON
import WebKit
typealias ThirdLoginBlock = (_ code: String,_ error: RuntimeError?) -> Void
class PetThirdShareManage: NSObject, TencentSessionDelegate,WeiboSDKDelegate, WBMediaTransferProtocol, WXApiDelegate {
    
    let sinaWeiboAppKey = "9697694"
    let sinaWeiboAppSecret = "60d2d7f9e4eb9294f5e45e5b9be49d5b"
    let sinaWeiboRedirectURI = "https://api.weibo.com/oauth2/default.html"
    let signaUniversalLinks = "https://www.ipetapi.com/link/"
    private static let _share = PetThirdShareManage()
    static func shared() -> PetThirdShareManage {
        return _share
    }
    var tencentOAuth: TencentOAuth?
    
    var wxLoginBlock: ThirdLoginBlock?
    var qqLoginBlock: ((_ code: String,_ userID: String,_ accessToken: String,_ unionId: String,_ error: RuntimeError?) -> Void)?
    var weiboLoginBlock: ((_ userID: String,_ accessToken: String,_ refreshToken: String,_ error: RuntimeError?) -> Void)?
    
    func registerLib(){
        registerWxApp()
        registerQQLib()
        registerWeiboLib()
    }
    func getShareVideoUrl(videoUrl: String ,propId: String,channelId: String, musicName: String, musicId: String)-> String {
        
        let encodeUrl = videoUrl.addingPercentEncoding(withAllowedCharacters: .AppURLQueryAllowed)
        let encodeMusicName = musicName.addingPercentEncoding(withAllowedCharacters: .AppURLQueryAllowed)
        var AppShareUrl = ""
        if ConfigManager.shared.currentEnv == .stg {
            AppShareUrl = "https://qa-api.ipetapi.com/pages/app/appShare?propId=\(propId)&videoUrl=\(safe(encodeUrl))&channelId=\(channelId)&musicName=\(safe(encodeMusicName))&musicId=\(musicId)"
        }else{
            AppShareUrl = "https://oia.ipetapi.com/pages/app/appShare?propId=\(propId)&videoUrl=\(safe(encodeUrl))&channelId=\(channelId)&musicName=\(safe(encodeMusicName))&musicId=\(musicId)"
        }
        return AppShareUrl
    }
}
// 微信分享
extension PetThirdShareManage{
    
    func registerWxApp(){
        /*
         iOS平台
         iPhone
         应用下载地址：未填写
         Bundle ID：com.pacp.unionpet
         测试版本Bundle ID：com.pacp.unionpet.dev
         Universal Links：https://www.ipetapi.com/link/
         AppID：wx53391d3b3c713508
         */
        let WXAPPID = "wx53391d3b3c713508"
        let WXUniversalLinks = "https://www.ipetapi.com/link/"
        WXApi.startLog(by: .detail) { log in
            UPLog("WXApi: \(log)")
        }
        WXApi.registerApp(WXAPPID, universalLink: WXUniversalLinks)
        //        WXApi.checkUniversalLinkReady { step , result in  UPLog("WXApi:\(step),\(result.success),\(result.errorInfo),\(result.suggestion)")
        //        }
    }
    // 授权微信登陆
    func authWxLogin(){
        if WXApi.isWXAppInstalled() {
            let rep = SendAuthReq()
            //这两个参数 可以照抄 第一个是固定的，第二个随意写
            rep.scope = "snsapi_userinfo"
            rep.state = "wx_oauth_authorization_state"
            WXApi.send(rep, completion: nil)
            WXApi.send(rep) { isSuccess in
                UPLog("FDK WXApi login\(isSuccess)")
            }
        }
        else {
            //弹框提示 未安装微信应用或版本过低
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "未安装微信应用或版本过低")
            }
        }
    }
    //MARK:微信回调
    func onResp(_ resp: BaseResp) {
        if resp.isKind(of: SendAuthResp.self){
            //这里是授权登录的回调
            let aresp = resp as! SendAuthResp
            DispatchQueue.main.async {
                if aresp.errCode == 0 {
                    if let code = aresp.code {
                        //这里拿到code之后 对接服务器接口
                        //这步 相当于账号密码登录的流程 返回用户信息
                        //后端这个接口返回的数据需要判断是第一次授权还是 不是第一次授权，第一次授权需要去绑定手机号界面，不是第一次授权就直接跳转到首页，登录成功
                        //如果是第一次授权，服务器再给个绑定手机号的接口
                        //大概就这个流程
                        if  let block = self.wxLoginBlock {
                            block(code,nil)
                        }
                    } else {
                        if  let block = self.wxLoginBlock {
                            block("",nil)
                        }
                        HUD.lightHUD(view:UIViewController.currentViewController.view , title: "微信授权失败")
                    }
                }
                else {
                    if  let block = self.wxLoginBlock {
                        block("",nil)
                    }
                    HUD.lightHUD(view:UIViewController.currentViewController.view , title: "微信授权失败")
                }
            }
        }
    }
    private var shareTitle: String {
        //        let infoDictionary = Bundle.main.infoDictionary!
        //        let appDisplayName = infoDictionary["CFBundleDisplayName"] //程序名称
        //        if let appDisplayName = appDisplayName {
        //            return "我在\(appDisplayName)上拍摄了新作品，分享给你"
        //        }
        //        return "我在XXX上拍摄了新作品，分享给你"
        return "快来看看我的新作品"
    }
    private var shareContent: String {
        //        let infoDictionary = Bundle.main.infoDictionary!
        //        let appDisplayName = infoDictionary["CFBundleDisplayName"] //程序名称
        //        if let appDisplayName = appDisplayName {
        //            return "\(appDisplayName)是我们的App新名字"
        //        }
        //        return "XXX是我们的App新名字"
        return "快来看看我的新作品"
    }
    // 分享到微信的公共请求接口
    private func sendToWeChat(bText: Bool,message: WXMediaMessage,scene: WXScene){
        let  sendMessageToWXReq = SendMessageToWXReq()
        sendMessageToWXReq.scene = Int32(scene.rawValue)
        sendMessageToWXReq.bText = false
        sendMessageToWXReq.message = message
        WXApi.send(sendMessageToWXReq) { isSucess in
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "分享\(isSucess == true ? "成功" : "失败")")
            }
        }
    }
    // WX图片类型分享
    func wx_shareImage(image:UIImage,title: String = "",description: String = "", shareType: WXScene){
        guard WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() else {
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "未安装微信或者微信版本过低,去安装或升级")
            }
            return
        }
        
        let imageData = UIImage.compressImage(image: image, maxLength: 25*1024*1024)
        let wxImageObject = WXImageObject.init()
        guard let imageData = imageData else {
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "图片有问题")
            }
            return
        }
        wxImageObject.imageData = imageData
        
        let wxMdediaMessage = WXMediaMessage()
        // 内容大小不超过10MB
        let thumImageData =  UIImage.compressImage(image: image, maxLength: 32)
        wxMdediaMessage.thumbData = thumImageData
        wxMdediaMessage.mediaObject = wxImageObject
        wxMdediaMessage.title = self.shareTitle
        wxMdediaMessage.description = self.shareContent
        if let thumImageData = thumImageData {
            let thumbImage = UIImage(data: thumImageData)
            if let thumbImage = thumbImage {
                wxMdediaMessage.setThumbImage(thumbImage)
            }
        }
        self.sendToWeChat(bText: false, message: wxMdediaMessage, scene: shareType)
    }
    
    // WX视频类型分享
    // 注意：videoUrl和videoLowBandUrl不能同时为空
    func wx_shareVideo(videoUrl:String,videoLowBandUrl:String,image:UIImage, shareType: WXScene,propId: String = "",propName: String = "",channelId: String, musicName: String, musicId: String){
        guard WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() else {
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "未安装微信或者微信版本过低,去安装或升级")
            }
            return
        }
        var shareTitle = "拍得好萌啊"
        var description = "盟咔相机放大了我崽的颜值"
        if propId.count > 0 {
            shareTitle = "\(propName)"
            description = "快用宝藏道具捕捉毛孩子瞬间"
        }
        let videoObject = WXWebpageObject.init()
        videoObject.webpageUrl = getShareVideoUrl(videoUrl: videoUrl, propId: propId,channelId: channelId,musicName: musicName,musicId: musicId)
        
        let wxMdediaMessage = WXMediaMessage()
        wxMdediaMessage.title = shareTitle
        wxMdediaMessage.description = description
        let thumImageData =  UIImage.compressImage(image: image, maxLength: 32)
        if let thumImageData = thumImageData {
            let thumbImage = UIImage(data: thumImageData)
            if let thumbImage = thumbImage {
                wxMdediaMessage.setThumbImage(thumbImage)
            }
        }
        wxMdediaMessage.mediaObject = videoObject
        self.sendToWeChat(bText: false, message: wxMdediaMessage, scene: shareType)
    }
    
    func isShareAvailable() -> Bool {
        guard WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() else {
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "未安装微信或者微信版本过低, 去安装或升级")
            }
            return false
        }
        return true
    }
    
    func shareEmoji(url: URL, postImage: UIImage) {
        guard isShareAvailable() else {
            return
        }
        guard let data = try? Data.init(contentsOf: url) else {
            return
        }
        let emoji = WXEmoticonObject()
        emoji.emoticonData = data
        
        let message = WXMediaMessage()
        message.mediaObject = emoji
        if let imgData = postImage.compressImageOnlength(maxLength: 64 * 1024) {
            message.thumbData = imgData
        }
        else if let img = UIImage.name("WXFriend") {
            message.setThumbImage(img)
        }
        self.sendToWeChat(bText: false, message: message, scene: WXSceneSession)
    }
}
// QQ分享
extension PetThirdShareManage{
    
    enum QQShareType {
        case qq
        case qqZone
    }
    
    
    func registerQQLib(){
        // let qqAppKey = "hDCGgBJ4OA5YVy4g"
        // AppId
        let qqAppid = "1112210618"
        self.tencentOAuth = TencentOAuth.init(appId: qqAppid, andDelegate: self)
    }
    func authQQLogin(){
        if self.tencentOAuth?.isCachedTokenValid() == true {
            self.tencentOAuth?.deleteCachedToken()
        }
        let permissionsArr = ["get_user_info","get_simple_userinfo"]
        self.tencentOAuth?.authMode = TencentAuthMode.authModeClientSideToken
        self.tencentOAuth?.authorize(permissionsArr)
    }
    // 分享图片
    // QQ图片类型分享
    func qq_shareImage(image:UIImage,title: String = "快来看看我的新作品",description: String = "快来看看我的新作品", shareType: QQShareType){
        if !QQApiInterface.isQQInstalled() || !QQApiInterface.isSupportShareToQQ() {
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "未安装QQ或者QQ版本过低,去安装或升级")
            }
            return
        }
        // 原内容
        let imageData = UIImage.compressImage(image: image, maxLength: 25*1024*1024)
        // 内容大小不超过10MB
        let thumImageData =  UIImage.compressImage(image: image, maxLength: 32)
        
        let imgObj = QQApiImageObject.init(data: imageData, previewImageData: thumImageData, title: title, description: description)
        let req = SendMessageToQQReq.init(content: imgObj)
        DispatchQueue.main.async {
            var sent: QQApiSendResultCode = .EQQAPISENDFAILD
            if shareType == .qq {
                sent = QQApiInterface.send(req)
            }else if shareType == .qqZone{
                //                imgObj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart)
                sent = QQApiInterface.sendReq(toQZone: req)
            }else{
                // 未知类型 不处理
            }
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "分享\(sent == .EQQAPISENDSUCESS ? "成功" : "失败")")
            }
        }
    }
    // QQ分享视频
    func qq_shareVideo(videoUrl:String,videoLowBandUrl:String,image:UIImage,shareType: QQShareType,propId: String = "",propName: String = "",channelId: String, musicName: String, musicId: String){
        
        if !QQApiInterface.isQQInstalled() || !QQApiInterface.isSupportShareToQQ() {
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "未安装QQ或者QQ版本过低,去安装或升级")
            }
            return
        }
        var shareTitle = "我在盟咔拍摄了新作品"
        var description = "盟咔相机提高了我崽的颜值"
        if propId.count > 0 {
            shareTitle = "\(propName)"
            description = "快用宝藏道具捕捉毛孩子瞬间"
        }
        let imageData = UIImage.compressImage(image: image, maxLength: 24*1024)
        let AppShareUrl = getShareVideoUrl(videoUrl: videoUrl, propId: propId,channelId: channelId,musicName: musicName,musicId: musicId)
        let videoObj = QQApiNewsObject.object(with: URL(string: AppShareUrl), title: shareTitle, description: description, previewImageData: imageData)
        
        let req = SendMessageToQQReq(content: videoObj as? QQApiObject)
        DispatchQueue.main.async {
            var sent: QQApiSendResultCode = .EQQAPISENDFAILD
            if shareType == .qq {
                sent = QQApiInterface.send(req)
            }else if shareType == .qqZone{
                sent = QQApiInterface.sendReq(toQZone: req)
            }else{
                // 未知类型 不处理
            }
            DispatchQueue.main.async {
                HUD.lightHUD(view:UIViewController.currentViewController.view , title: "分享\(sent == .EQQAPISENDSUCESS ? "成功" : "失败")")
            }
        }
    }
    // TencentSessionDelegate {
    //登录功能没添加，但调用TencentOAuth相关方法进行分享必须添加<TencentSessionDelegate>，则以下方法必须实现，尽管并不需要实际使用它们
    //登录成功
    func tencentDidLogin() {
        //        let authorizeCode = self.tencentOAuth?.getServerSideCode(), authorizeCode.count > 0
        if let accessToken = self.tencentOAuth?.accessToken,accessToken.count > 0 {
            let userId = self.tencentOAuth?.getUserOpenID() ?? ""
            let unionId = self.tencentOAuth?.unionid ?? ""
            if let block = self.qqLoginBlock {
                block("",userId,accessToken,unionId,nil)
            }
        }else {
            if let block = self.qqLoginBlock {
                block("","","","",RuntimeError.init("授权登陆失败"))
            }
        }
    }
    //非网络错误导致登录失败
    func tencentDidNotLogin(_ cancelled: Bool) {
        if let block = self.qqLoginBlock {
            block("","","","",RuntimeError.init("授权登陆失败"))
        }
    }
    //网络错误导致登录失败
    func tencentDidNotNetWork() {
        if let block = self.qqLoginBlock {
            block("","","","",RuntimeError.init("授权登陆失败"))
        }
    }
    func onResp(_ resp: QQBaseResp!) {
        UPLog("FDK:\(resp.description)")
    }
    
}
// 微博分享
extension PetThirdShareManage{
    
    func registerWeiboLib(){
        // TODO: AppKey universalLink
        WeiboSDK.registerApp(sinaWeiboAppKey, universalLink: signaUniversalLinks) // 注册应用时申请的AppKey
        WeiboSDK.enableDebugMode(true)
    }
    func signWeiboLogin(){
        let request = WBAuthorizeRequest()
        request.scope = "all"
        // 此字段的内容可自定义, 在请求成功后会原样返回, 可用于校验或者区分登录来源
        request.userInfo = ["SSO_From": "ViewControllerClassName",
                            "Other_Info_1": 123,
                            "Other_Info_2": ["obj1","obj2"],
                            "Other_Info_3": [["key1":"obj1","key2":"obj2"]]]
        request.redirectURI = sinaWeiboRedirectURI
        WeiboSDK.send(request)
    }
    // 分享图片到微博
    func shareImageToSina(image: UIImage) {
        let authReq = WBAuthorizeRequest()
        authReq.redirectURI = sinaWeiboRedirectURI
        authReq.scope = "all"
        let message = WBMessageObject()
        message.text = "我在盟咔app为宠物拍摄了专属照片，快来看看吧！"
        let img = WBImageObject()
        // 不能超过10M
        let imgData =  UIImage.compressImage(image: image, maxLength: 25*1024*1024)
        img.imageData = imgData!
        message.imageObject = img
        
        let req: WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authReq, access_token: nil) as! WBSendMessageToWeiboRequest
        // 自定义的请求信息字典， 会在响应中原样返回
        req.userInfo = ["info": "分享的图片"]
        // 当未安装客户端时是否显示下载页
        req.shouldOpenWeiboAppInstallPageIfNotInstalled = false
        WeiboSDK.send(req)
    }
    // 分享视频到微博
    func shareVideoToSina(url: String,image:UIImage,propId: String = "",channelId: String, musicName: String, musicId: String) {
        let authReq = WBAuthorizeRequest()
        authReq.redirectURI = sinaWeiboRedirectURI
        authReq.scope = "all"
        
        let message = WBMessageObject()
        message.text = ""
        
        let AppDownloadUrl = "https://oia.ipetapi.com/pages/app/download"
        let AppShareUrl = getShareVideoUrl(videoUrl: url, propId: propId,channelId: channelId,musicName: musicName,musicId: musicId)
        let videoObj = WBWebpageObject()
        videoObj.objectID = url
        videoObj.title = "这个萌宠道具也太有趣了吧！@盟咔相机，有盟咔，陪Ta一起造&\(AppShareUrl)（这里还有超多宝藏特效！）&应用详情"
        videoObj.description = ""
        videoObj.webpageUrl = "\(AppDownloadUrl)"
        videoObj.thumbnailData = UIImage.compressImage(image: image, maxLength: 20)
        message.mediaObject = videoObj
        
        let req: WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authReq, access_token: nil) as! WBSendMessageToWeiboRequest
        // 自定义的请求信息字典， 会在响应中原样返回
        req.userInfo = ["info": "分享的图片"]
        // 当未安装客户端时是否显示下载页
        req.shouldOpenWeiboAppInstallPageIfNotInstalled = false
        WeiboSDK.send(req)
    }
    /**
     收到一个来自微博客户端程序的请求
     
     收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
     @param request 具体的请求对象
     */
    func didReceiveWeiboRequest(_ request: WBBaseRequest?) {
        
    }
    func didReceiveWeiboResponse(_ response: WBBaseResponse?) {
        // 登陆请求后的返回相应类型
        guard let res = response as? WBAuthorizeResponse else { return  }
        guard let uid = res.userID else {
            if let block = self.weiboLoginBlock {
                block("","","",RuntimeError.init("授权登陆失败"))
            }
            return
        }
        guard let accessToken = res.accessToken else {
            if let block = self.weiboLoginBlock {
                block("","","",RuntimeError.init("授权登陆失败"))
            }
            return
        }
        guard let refreshToken = res.refreshToken else {
            if let block = self.weiboLoginBlock {
                block("","","",RuntimeError.init("授权登陆失败"))
            }
            return
        }
        self.weiboLoginBlock?(uid,accessToken,refreshToken,nil)
    }
    
    func wbsdk_TransferDidReceive(_ object: Any?) {
        
    }
    
    func wbsdk_TransferDidFailWith(_ errorCode: WBSDKMediaTransferErrorCode, andError error: Error?) {
        
    }
}
