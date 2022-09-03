//
//  PermissionsView.swift
//  unipets-ios
//
//  Created by FDK on 2021/10/18.
//

import UIKit
import SnapKit
import YYText
#if !(arch(i386) || arch(x86_64))

class PermissionsView: UIView {
    
    enum PermissionsType {
        case Location  // 位置权限
        case Camera // 相机权限
        case Notify // 通知权限
        case Photo   // 相册权限
        case Store  // 储存权限
        case Microphoe  // 麦克风权限
        case AppUpdate // App提示升级款
        case AppForceUpdate // App强制升级
        case getPraise    //  获赞
        func getMessage() -> String {
            
            var message = ""
            switch self {
            case .Location:
                message = "允许访问你的位置"
            case .Camera:
                message = "允许访问你的相机"
            case .Notify:
                message = "开启推送通知"
            case .Photo:
                message = "允许保存至相册权限"
            case .Store:
                message = "开启存储权限"
            case .Microphoe:
                message = "允许访问你的麦克风"
            default:
                message = ""
            }
            return message
        }
        func getIconName() -> String{
            var message = ""
            switch self {
            case .Location:
                message = "permission_icon_location"
            case .Camera:
                message = "permission_icon_camera"
            case .Notify:
                message = "permission_icon_notice"
            case .Photo:
                message = "permission_icon_album"
            case .Store:
                message = "permission_icon_store"
            case .Microphoe:
                message = "permission_icon_microphone"
            default:
                message = ""
            }
            return message
        }
    }
    
    // MARK: Property{
    private let contentView = UIView()
    private let bgView = UIImageView(image: UIImage.name("permission_bg"))
    private let topIconView = UIImageView(image: UIImage.name("permission_icon_update"))
    private let disagreeBtn = Button()
    private let specialDisagreeBtn = Button() // 类似版本升级还有第二个不再提醒的按钮
    private let agreeBtn = Button()
    private let onlyAgreeBtn = Button()
    private let tipLabel = YYLabel()
    private let textView = YYTextView()
    private var permissionType: PermissionsType = .Location
    private var appVersionInfo = VersionUpdateInfo()
    var agreeBlock: ((PermissionsType)->Void)?
    var disagreeBlock: ((PermissionsType)->Void)?
    // MARK: }
    // local Config
    var mediaPageSourceType = MedaiDataSource.video //用于拍摄编辑页保存时候请求相册权限埋点判断来源
    // MARK: System Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
// MARK: InitView
extension PermissionsView{
    private func createSubView(){
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        
        self.contentView.backgroundColor = UIColor.white
        self.addSubview(self.contentView)
        self.bgView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.bgView)
        
        self.topIconView.backgroundColor = UIColor.clear
        self.topIconView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.topIconView)
        
        self.disagreeBtn.layer.cornerRadius = 22
        self.disagreeBtn.titleColor = UIColor.theme
        self.disagreeBtn.backgroundColor = UIColor.theme.withAlphaComponent(0.15)
        self.disagreeBtn.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.disagreeBtn.addUpInsideTarget(self, action: #selector(abortAction))
        self.disagreeBtn.title = "稍后再说"
        self.contentView.addSubview(self.disagreeBtn)
        
        let text = "忽略此版本 30天内不再提醒"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.specialDisagreeBtn.attributeTitle = attributedString
        self.specialDisagreeBtn.titleColor = UIColor.hexColor("#99999C")
        self.specialDisagreeBtn.backgroundColor = UIColor.clear
        self.specialDisagreeBtn.titleFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        self.specialDisagreeBtn.addUpInsideTarget(self, action: #selector(specialAbortAction))
        self.contentView.addSubview(self.specialDisagreeBtn)
        
        
        self.agreeBtn.setDefaultShadowStyle(cornerRadius: 22)
        self.agreeBtn.titleColor = UIColor.white
        self.agreeBtn.backgroundColor = UIColor.theme
        self.agreeBtn.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.agreeBtn.addUpInsideTarget(self, action: #selector(agreeAction))
        self.agreeBtn.title = "立即升级"
        self.contentView.addSubview(self.agreeBtn)
        
        self.onlyAgreeBtn.layer.cornerRadius = 22
        self.onlyAgreeBtn.titleColor = UIColor.white
        self.onlyAgreeBtn.backgroundColor = UIColor.theme
        self.onlyAgreeBtn.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.onlyAgreeBtn.addUpInsideTarget(self, action: #selector(onlyAgreeAction))
        self.onlyAgreeBtn.title = "立即升级"
        self.contentView.addSubview(self.onlyAgreeBtn)
        
        self.tipLabel.text = "发现新版本"
        self.tipLabel.font = .systemFont(ofSize: 18, weight: .bold)
        self.tipLabel.textColor = UIColor.normalText
        self.tipLabel.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(self.tipLabel)
        
        
        self.textView.textColor = UIColor.hexColor("#666669")
        self.textView.isEditable = false
        self.textView.isSelectable = false
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(self.textView)
        
        self.contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(209)
        }
        self.bgView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.top)
            make.left.equalTo(self.contentView.snp.left)
            make.right.equalTo(self.contentView.snp.right)
            make.height.equalTo(180)
        }
        self.topIconView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.bgView.snp.centerY).offset(-20)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.width.equalTo(180)
            make.height.equalTo(180)
        }
        self.disagreeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView.snp.centerX).offset(-7)
            make.size.equalTo(CGSize(width: 140, height: 44))
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-64)
        }
        self.specialDisagreeBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.size.equalTo(CGSize(width: 170, height: 20))
            make.top.equalTo(self.disagreeBtn.snp.bottom).offset(12)
        }
        
        self.agreeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.centerX).offset(7)
            make.size.equalTo(CGSize(width: 140, height: 44))
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-64)
        }
        self.onlyAgreeBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.size.equalTo(CGSize(width: 295, height: 44))
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-64)
        }
        self.tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(10)
            make.bottom.equalTo(self.contentView.snp.top).offset(-8)
            make.right.equalTo(self.contentView.snp.right).offset(-10)
        }
        self.textView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(40)
            make.top.equalTo(self.tipLabel.snp.bottom).offset(13)
            make.right.equalTo(self.contentView.snp.right).offset(-40)
            make.bottom.equalTo(self.agreeBtn.snp.top).offset(-10)
        }
    }
}
// MARK: Function
extension PermissionsView {
    
    func updatePermissionsView(_ type: PermissionsType){
        self.permissionType = type
        self.tipLabel.text = self.permissionType.getMessage()
        
        // 弹窗暂未用到,具体文案待定
        let text1 = "欢迎登陆萌宠星球!\n盟宠星球非常重视与保障您的个人隐私，开始服务之前，请认真阅读"
        let text2 = "《用户协议》"
        let text3 = "、《隐私条款》"
        let text4 = "内容。"
        
        let att1 = NSMutableAttributedString.init(string: text1)
        att1.yy_color = UIColor.hexColor("#666669")
        
        let att2 = NSMutableAttributedString.init(string: text2)
        att2.yy_color = UIColor.hexColor("#FF7238")
        let h2 = YYTextHighlight.init()
        h2.setColor(UIColor.theme.withAlphaComponent(0.5))
        h2.tapAction = { _, _, _, _ in
            UIViewController.currentViewController.navigationController?.pushViewController(PrivacyPolicyWebViewController.defaultTerms(), animated: true)
        }
        att2.yy_setTextHighlight(h2, range: att2.yy_rangeOfAll())
        
        let att3 = NSMutableAttributedString.init(string: text3)
        att3.yy_color = UIColor.hexColor("#FF7238")
        let h3 = YYTextHighlight.init()
        h3.setColor(UIColor.theme.withAlphaComponent(0.5))
        h3.tapAction = { _, _, _, _ in
            UIViewController.currentViewController.navigationController?.pushViewController(PrivacyPolicyWebViewController.defaultPrivacy(), animated: true)
        }
        att3.yy_setTextHighlight(h3, range: att3.yy_rangeOfAll())
        
        let att4 = NSMutableAttributedString.init(string: text4)
        att4.yy_color = UIColor.lightText2
        
        att1.append(att2)
        att1.append(att3)
        att1.append(att4)
        att1.yy_lineSpacing = 6
        att1.yy_font = UIFont.systemFont(ofSize: 14)
        
        self.textView.attributedText = att1
        self.disagreeBtn.title = "暂不设置"
        self.agreeBtn.title = "去设置"
        self.disagreeBtn.isHidden = false
        self.agreeBtn.isHidden = false
        self.onlyAgreeBtn.isHidden = true
        self.specialDisagreeBtn.isHidden = true
        self.topIconView.image = UIImage.name(self.permissionType.getIconName())
        self.topIconView.contentMode = .scaleAspectFit
        self.disagreeBtn.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-44)
        }
        self.agreeBtn.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-44)
        }
    }
    
    // App更新的Reload
    func showAppUpdateView(_ info: VersionUpdateInfo?) {
        
        if let tempInfo = info , info != nil {
            self.permissionType = tempInfo.forceUpgrade == true ? .AppForceUpdate : .AppUpdate
            self.appVersionInfo = tempInfo
            self.tipLabel.text = info?.latestVersionInfo.popsTitle
            let message = NSMutableAttributedString.init(string: info?.latestVersionInfo.popsTitleDesc ?? "")
            message.yy_lineSpacing = 6
            message.yy_font = UIFont.systemFont(ofSize: 14)
            message.yy_color = UIColor.hexColor("#666666")
            self.textView.attributedText = message
            if (tempInfo.forceUpgrade == true) {
                self.disagreeBtn.isHidden = true
                self.agreeBtn.isHidden = true
                self.onlyAgreeBtn.isHidden = false
                self.specialDisagreeBtn.isHidden = true
            }else {
                self.disagreeBtn.isHidden = false
                self.agreeBtn.isHidden = false
                self.onlyAgreeBtn.isHidden = true
                self.specialDisagreeBtn.isHidden = false
            }
        }
    }
    
    func showPraiseAlert(message: String){
        self.permissionType = .getPraise
        self.tipLabel.text = "获赞"
        self.textView.text = "共获得\(message)赞"
        self.textView.textAlignment = .center
        self.onlyAgreeBtn.title = "好的"
        self.disagreeBtn.isHidden = true
        self.agreeBtn.isHidden = true
        self.onlyAgreeBtn.isHidden = false
        self.specialDisagreeBtn.isHidden = true
        self.topIconView.contentMode = .scaleAspectFit
        self.topIconView.image = UIImage.name("permission_icon_getPraise")
        self.onlyAgreeBtn.snp.updateConstraints { (make) in
            make.size.equalTo(CGSize(width: 140, height: 44))
        }
        self.contentView.snp.updateConstraints { (make) in
            make.height.equalTo(194)
        }
    }
    
    @objc private func agreeAction() {
        self.removeFromSuperview()
        
        if self.permissionType == .AppUpdate{
            enterAppStoreUpdate()
            // 埋点，离开页面
            DispatchQueue.global().async {
                SkyeyeAdapter.handle?.trackEvent(BuriedDataPointsEvenId.UpgradePromptPopupExposureAgaree.rawValue, label: "同意", parameters: BuriedDataPoints.getChangeBuriedData())
                SkyeyeAdapter.handle?.trackPageEnd("升级提示弹窗", parameters: BuriedDataPoints.getBuriedData())
            }
        }else if self.permissionType == .Photo {
            DispatchQueue.global().async {
                SkyeyeAdapter.handle?.trackEvent(self.mediaPageSourceType == .video ? "spjjy_qushezhi" : "tpjjy_qushezhi", label: self.mediaPageSourceType == .video ? "视频-保存-去设置" : "图片-保存-去设置", parameters: BuriedDataPoints.getChangeBuriedData())
            }
            openSystemSetting()
        }else{
            openSystemSetting()
        }
        if let block = self.agreeBlock {
            block(self.permissionType)
        }
    }
    
    @objc private func abortAction() {
        self.removeFromSuperview()
        if self.permissionType == .AppUpdate {
            // 埋点，离开页面
            DispatchQueue.global().async {
                SkyeyeAdapter.handle?.trackEvent(BuriedDataPointsEvenId.UpgradePromptPopupExposureLater.rawValue, label: "稍后再说", parameters: BuriedDataPoints.getChangeBuriedData())
                SkyeyeAdapter.handle?.trackPageEnd("升级提示弹窗", parameters: BuriedDataPoints.getBuriedData())
            }
            AppUpdateManage.saveAppUpdateNextAlertShowInfo(appVersion: self.appVersionInfo.latestVersionInfo.versionNo,obsKey: .LaterToSayAgain)
        }else if self.permissionType == .Photo {
            HUD.lightHUD(view: UIViewController.currentViewController.view , title: "保存失败", hiddenAfter: 1.0)
            DispatchQueue.global().async {
               
                SkyeyeAdapter.handle?.trackEvent(self.mediaPageSourceType == .video ? "spjjy_zanbubaocun" : "tpjjy_zanbubaocun", label: self.mediaPageSourceType == .video ? "视频-保存-暂不设置" : "图片-保存-暂不设置", parameters: BuriedDataPoints.getChangeBuriedData())
            }
        }
    }
    
    @objc private func specialAbortAction() {
        self.removeFromSuperview()
        // 埋点，离开页面
        DispatchQueue.global().async {
            SkyeyeAdapter.handle?.trackEvent("升级提示弹窗", label: "忽略此版本", parameters: BuriedDataPoints.getChangeBuriedData())
            SkyeyeAdapter.handle?.trackPageEnd("升级提示弹窗", parameters: BuriedDataPoints.getBuriedData())
        }
        AppUpdateManage.saveAppUpdateNextAlertShowInfo(appVersion: self.appVersionInfo.latestVersionInfo.versionNo,obsKey: .NoLongerRemind)
    }
    
    @objc private func onlyAgreeAction() {
        // 强制升级不removeFromeSuperView
        if self.permissionType == .AppForceUpdate {
            enterAppStoreUpdate()
            DispatchQueue.global().async {
                SkyeyeAdapter.handle?.trackEvent("升级提示弹窗", label: "同意强制升级", parameters: BuriedDataPoints.getChangeBuriedData())
                SkyeyeAdapter.handle?.trackPageEnd("升级提示弹窗", parameters: BuriedDataPoints.getBuriedData())
            }
        }else {
            self.removeFromSuperview()
        }
    }
    
    private func enterAppStoreUpdate(){
       OpenInAppStore()
    }
}
#endif
