//
//  EmptyView.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/24.
//

import Foundation
import UIKit

class EmptyView: BaseView {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let actionButton = Button()
    /// 自定义布局信息
    var onCustomLayout: ((EmptyView, UIView) -> Void)?
    /// 图标大小
    var imageSize = CGSize(width: 120, height: 120)
    /// 标题距离上一个视图距离
    var titleTopSpace: CGFloat = 40
    var messageTopSpace: CGFloat = 25
    var actionTopSpace: CGFloat = 25
    /// 默认整体居中
    var centerInset: CGFloat = 0
    
    private let contentView = UIView()
    
    override func didInit() {
        configSubview()
    }
    
    // MARK: - Load
    override func didLoadFinish() {
        configSubviewsFrame()
    }
    
    override func viewWillTransition() {
        configSubviewsFrame()
    }
    
    func reload(image: UIImage?, title: String?, message: String?, actiontitle: String?) {
        self.imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        actionButton.title = safe(actiontitle)
        reload()
    }
    
    func reload() {
        self.configSubviewsFrame()
    }
    
    // MARK: - ViewConfig
    override func configSubview() {
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.textColor = UIColor.lightText1
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                                                          
        messageLabel.textColor = UIColor.lightText4
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.numberOfLines = 3
        
        actionButton.titleColor = UIColor.white
        actionButton.titleFont = UIFont.systemFont(ofSize: 15)
        
        self.addSubview(contentView)
    }
    
    override func configSubviewsFrame() {
        if let action = onCustomLayout {
            action(self, contentView)
        } else {
            contentView.removeAllSubviews()
            var currentaTop: CGFloat = 0
            contentView.size = CGSize(width: self.width, height: 0)
            if imageView.image != nil {
                contentView.addSubview(imageView)
                imageView.size = imageSize
                imageView.top = 0
                imageView.centerX = contentView.width / 2
                currentaTop = imageView.bottom
            }
            
            if titleLabel.text != nil {
                contentView.addSubview(titleLabel)
                titleLabel.sizeToFit()
                titleLabel.width = min(titleLabel.width, contentView.width - 100)
                titleLabel.top = currentaTop + titleTopSpace
                titleLabel.centerX = contentView.width / 2
                currentaTop = titleLabel.bottom
            }
            
            if messageLabel.text != nil {
                contentView.addSubview(messageLabel)
                messageLabel.size = CGSize(width: contentView.width - 100, height: CGFloat.greatestFiniteMagnitude)
                messageLabel.sizeToFit()
                messageLabel.width = min(messageLabel.width, contentView.width - 100)
                messageLabel.top = currentaTop + messageTopSpace
                messageLabel.centerX = contentView.width / 2
                currentaTop = messageLabel.bottom
            }
            
            if actionButton.title != "" || actionButton.image != nil {
                contentView.addSubview(actionButton)
                actionButton.sizeToFit()
                actionButton.width += 50
                actionButton.height = 40
                actionButton.top = currentaTop + actionTopSpace
                actionButton.centerX = contentView.width / 2
                actionButton.setDefaultShadowStyle(cornerRadius: actionButton.height / 2)
                currentaTop = actionButton.bottom
            }
            
            contentView.height = currentaTop
            contentView.left = 0
            contentView.centerY = self.height / 2 + centerInset
            
        }
    }
}
