//
//  PetThirdShareView.swift
//  unipets-ios
//
//  Created by Future on 2021/12/2.
//

import UIKit

class PetThirdShareView: BaseView {
    
    private let toolBgView = UIScrollView()
    private let cancelBtn = Button()
    private let WXBtn = Button()
    private let WXFriendBtn = Button()
    private let QQBtn = Button()
    private let QQZoneBtn = Button()
    private let WeiBoBtn = Button()
    var clickShare: ((ThirdShareType)->Void)?
    var clickCancle: (()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func createSubView(){
        self.backgroundColor = UIColor.hexColor("#000000", 0.6)
        self.toolBgView.backgroundColor = UIColor.hexColor("#FFFFFF", 0.9)
        self.toolBgView.showsHorizontalScrollIndicator = false
        self.toolBgView.layer.cornerRadius = 12
        self.toolBgView.layer.masksToBounds = true
        self.addSubview(self.toolBgView)
        self.cancelBtn.backgroundColor = UIColor.hexColor("#FFFFFF", 1.0)
        self.cancelBtn.layer.cornerRadius = 12
        self.cancelBtn.layer.masksToBounds = true
        self.cancelBtn.title = "取消".localized()
        self.cancelBtn.addUpInsideTarget(self, action: #selector(dismissSelf))
        self.addSubview(self.cancelBtn)
        
        self.WXBtn.image = UIImage.name("WXIcon")
        self.WXBtn.imagePosition = .top
        self.WXBtn.contentSpace = 10
        self.WXBtn.titleFont = UIFont.systemFont(ofSize: 11)
        self.WXBtn.title = "微信好友".localized()
        self.WXBtn.titleColor = UIColor.hexColor("#666666")
        self.WXBtn.addUpInsideTarget(self, action: #selector(clickWXShareBtn))
        self.toolBgView.addSubview(self.WXBtn)
        
        self.WXFriendBtn.image = UIImage.name("WXFriend")
        self.WXFriendBtn.imagePosition = .top
        self.WXFriendBtn.contentSpace = 10
        self.WXFriendBtn.titleFont = UIFont.systemFont(ofSize: 11)
        self.WXFriendBtn.title = "朋友圈".localized()
        self.WXFriendBtn.titleColor = UIColor.hexColor("#666666")
        self.WXFriendBtn.addUpInsideTarget(self, action: #selector(clickWXFriendShareBtn))
        self.toolBgView.addSubview(self.WXFriendBtn)
        
        self.QQBtn.image = UIImage.name("qqIcon")
        self.QQBtn.imagePosition = .top
        self.QQBtn.contentSpace = 10
        self.QQBtn.titleFont = UIFont.systemFont(ofSize: 11)
        self.QQBtn.title = "QQ好友".localized()
        self.QQBtn.titleColor = UIColor.hexColor("#666666")
        self.QQBtn.addUpInsideTarget(self, action: #selector(clickQQShareBtn))
        self.toolBgView.addSubview(self.QQBtn)
        
        self.QQZoneBtn.image = UIImage.name("qqZoneIcon")
        self.QQZoneBtn.imagePosition = .top
        self.QQZoneBtn.contentSpace = 10
        self.QQZoneBtn.titleFont = UIFont.systemFont(ofSize: 11)
        self.QQZoneBtn.title = "QQ空间".localized()
        self.QQZoneBtn.titleColor = UIColor.hexColor("#666666")
        self.QQZoneBtn.addUpInsideTarget(self, action: #selector(clickQQZoneShareBtn))
        self.toolBgView.addSubview(self.QQZoneBtn)
        
        self.WeiBoBtn.image = UIImage.name("WeiBoIcon")
        self.WeiBoBtn.imagePosition = .top
        self.WeiBoBtn.contentSpace = 10
        self.WeiBoBtn.titleFont = UIFont.systemFont(ofSize: 11)
        self.WeiBoBtn.title = "微博".localized()
        self.WeiBoBtn.titleColor = UIColor.hexColor("#666666")
        self.WeiBoBtn.addUpInsideTarget(self, action: #selector(clickWeiboShareBtn))
        self.toolBgView.addSubview(self.WeiBoBtn)
        
        self.toolBgView.frame = CGRect(x: 8, y: SCREEN_HEIGHT - 98 - 8 - 109, width: SCREEN_WIDTH - 16, height: 109)
        
        self.cancelBtn.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.bottom.equalTo(-42)
            make.height.equalTo(56)
        }
        let height: CGFloat = 85
        let width: CGFloat =  50
        let top: CGFloat = 12
        let space: CGFloat = 17
        let lead = (SCREEN_WIDTH - 8 * 2 - width * 5 - space * 4 ) / 2
        self.WXBtn.frame = CGRect(x: lead, y: top, width: width, height: height)
        
        self.WXFriendBtn.frame = CGRect(x: self.WXBtn.frame.maxX + space, y: top, width: width, height: height)
        
        self.QQBtn.frame = CGRect(x: self.WXFriendBtn.frame.maxX + space, y: top, width: width, height: height)
        
        self.QQZoneBtn.frame = CGRect(x: self.QQBtn.frame.maxX + space, y: top, width: width, height: height)
        
        self.WeiBoBtn.frame = CGRect(x: self.QQZoneBtn.frame.maxX + space, y: top, width: width, height: height)
        
        self.toolBgView.contentSize = CGSize(width: self.WeiBoBtn.frame.maxX + 20, height: 109)
    }
    
    func show(view: UIView){
        let isInstallWx =  (WXApi.isWXAppInstalled() && WXApi.isWXAppSupport())
        self.WXBtn.isEnabled = isInstallWx
        self.WXBtn.titleColor = isInstallWx ? UIColor.hexColor("#666666") : UIColor.hexColor("#99999C")
        self.WXBtn.image = isInstallWx ? UIImage.name("WXIcon") : UIImage.name("WXIcon_Disable")
        
        
        self.WXFriendBtn.isEnabled =  isInstallWx
        self.WXFriendBtn.image = isInstallWx ? UIImage.name("WXFriend") : UIImage.name("WXFriendn_Disable")
        self.WXFriendBtn.titleColor = isInstallWx ? UIColor.hexColor("#666666") : UIColor.hexColor("#99999C")
        
        let isInstallQQ = (TencentOAuth.iphoneQQInstalled())
        self.QQBtn.isEnabled = isInstallQQ
        self.QQBtn.titleColor = isInstallQQ ? UIColor.hexColor("#666666") : UIColor.hexColor("#99999C")
        self.QQBtn.image = isInstallQQ ? UIImage.name("qqIcon") : UIImage.name("disqqIcon")
        
        
        self.QQZoneBtn.isEnabled =  isInstallQQ
        self.QQZoneBtn.image = isInstallQQ ? UIImage.name("qqZoneIcon") : UIImage.name("disqqZoneIcon")
        self.QQZoneBtn.titleColor = isInstallQQ ? UIColor.hexColor("#666666") : UIColor.hexColor("#99999C")
        
        let isInstallWeibo = (WeiboSDK.isWeiboAppInstalled())
        self.WeiBoBtn.isEnabled = isInstallWeibo
        self.WeiBoBtn.titleColor = isInstallWeibo ? UIColor.hexColor("#666666") : UIColor.hexColor("#99999C")
        self.WeiBoBtn.image = isInstallQQ ? UIImage.name("WeiBoIcon") : UIImage.name("disWeiBoIcon")
        view.addSubview(self)
    }
    
    @objc func clickWXShareBtn(){
        if let block = self.clickShare {
            block(.WXSessionType)
        }
        self.removeFromSuperview()
    }
    
    @objc func clickWXFriendShareBtn(){
        if let block = self.clickShare {
            block(.WXTimeLineType)
        }
        self.removeFromSuperview()
    }
    @objc func clickQQShareBtn(){
        if let block = self.clickShare {
            block(.QQType)
        }
        self.removeFromSuperview()
    }
    @objc func clickQQZoneShareBtn(){
        if let block = self.clickShare {
            block(.QQZoneType)
        }
        self.removeFromSuperview()
    }
    @objc func clickWeiboShareBtn(){
        if let block = self.clickShare {
            block(.WeiboType)
        }
        self.removeFromSuperview()
    }
    @objc func dismissSelf(){
        if let block = self.clickCancle {
            block()
        }
        self.removeFromSuperview()
    }
}
