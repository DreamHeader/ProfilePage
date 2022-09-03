//
//  ScrollBar.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/2.
//

import UIKit

class ScrollBar<Item>: BaseView,UIScrollViewDelegate {
    
    var leftView: UIView? {
        willSet {
            if newValue == nil {
                self.leftView?.removeFromSuperview()
                configSubviewsFrame()
            }
        }
        didSet {
            if let view = self.leftView {
                self.addSubview(view)
            }
            configSubviewsFrame()
        }
    }
    private let scrollView = UIScrollView()
    private let slider = GradientView.init(frame: .zero)
    private var buttons = [Button]()
    
    private var _index = 0
    private var _lastIndex = 0
    private var items = [ScrollBarItem<Item>]()
    
    var config = ScrollBarConfig.sliderConfig()
    
    var _onIndexChangeWhenTouch: ((Int, ScrollBarItem<Item>) -> Void)?
    
    var index: Int {
        return _index
    }
    var lastIndex: Int {
        return _lastIndex
    }
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
    
    
    // MARK: - Reload
    func relaod() {
        reload(items: items, index: _index)
    }
    
    func reload(items: [ScrollBarItem<Item>], index: Int = 0) {
        let finalIndex = max(0, min(index, items.count))
        self.items = items
        configSubviewsFrame()
        configItemViews()
        updateIndex(index: finalIndex, animation: false)
        resetSliderFrame(animation: false)
    }
    
    private func configItemViews() {
        buttons.forEach { $0.removeFromSuperview() }
        items.forEach { item in
            item.badge?.removeFromSuperview()
        }
        buttons.removeAll()
        
        for (index, item) in items.enumerated() {
            let button = Button()
            button.title = item.name
            button.titleFont = config.font
            button.titleColor = config.unselectColor
            button.tag = index
            button.entity = item
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            button.sizeToFit()
            button.height = self.height
            button.imageSize = config.btnImageSize
            if config.isNeedShadow {
                button.contentImageView.layer.shadowColor = UIColor.hexColor("#000000").cgColor
                button.contentImageView.layer.shadowRadius = 5
                button.contentImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.contentImageView.layer.shadowOpacity = 0.1
                
                button.contentTitleLabel.layer.shadowColor = UIColor.hexColor("#000000").cgColor
                button.contentTitleLabel.layer.shadowRadius = 5
                button.contentTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.contentTitleLabel.layer.shadowOpacity = 0.1
            }
            switch config.style {
            case .slider:
                break
            case .background:
                button.backgroundColor = config.unselectBackgroundColor
            }
            
            scrollView.addSubview(button)
            buttons.append(button)
            if let badge = item.badge {
                scrollView.addSubview(badge)
            }
        }
        
        scrollView.bringSubviewToFront(slider)
        
        switch config.style {
        case .slider:
            scrollView.addSubview(slider)
            break
        case .background:
            slider.removeFromSuperview()
        }
        configItemsFrame()
    }
    
    func configItemsFrame() {
        var containerWidth: CGFloat = 0
        var leading: CGFloat = config.inset.left
        
        for (_, button) in buttons.enumerated() {
            button.sizeToFit()
            switch config.style {
            case .slider:
                button.frame = CGRect(x: leading, y: 0, width: button.width + config.buttonAppendingSpace, height: scrollView.height)
                break
            case .background:
                button.frame = CGRect(x: leading, y: 0, width: button.width + config.buttonAppendingSpace, height: 28)
                button.centerY = self.scrollView.height / 2
                button.layer.cornerRadius = button.height / 2
            }
            leading = button.right + config.buttonSpace
            containerWidth = button.right
            if let item = button.entity as? ScrollBarItem<Item>, let badge = item.badge {
                badge.centerX = button.right + item.badgeCenterOffset.x - config.buttonAppendingSpace / 2
                badge.centerY = button.centerY - 8 + item.badgeCenterOffset.y
            }
        }
        let orignalWidth = max(containerWidth + config.inset.right, SCREEN_WIDTH)
        if config.customScrollWidth > 0 {
            if orignalWidth <  config.customScrollWidth{
                scrollView.contentSize = CGSize(width: config.customScrollWidth, height: scrollView.height)
            }else{
                scrollView.contentSize = CGSize(width: orignalWidth, height: scrollView.height)
            }
        }else {
            scrollView.contentSize = CGSize(width: orignalWidth, height: scrollView.height)
        } 
        let contentLeading = leftView?.right ?? 0
        
        if scrollView.contentSize.width < scrollView.width {
            switch config.alignment {
            case .center:
                scrollView.width = scrollView.contentSize.width
                scrollView.centerX = (self.width - contentLeading) / 2
            case .left:
                scrollView.left = contentLeading
            case .right:
                scrollView.width = scrollView.contentSize.width
                scrollView.right = self.width
            }
        }
        
        resetSliderFrame(animation: false)
        
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    func updateIndex(index: Int, animation: Bool) {
        let oldIndex = _index
        _lastIndex = oldIndex
        _index = index
        
        UIView.animate(withDuration: animation ? 0.25 : 0) {
            if let button = self.buttons.at(oldIndex) {
                button.titleColor = self.config.unselectColor
            }
            if let button = self.buttons.at(index) {
                button.titleColor = self.config.selectColor
            }
            switch self.config.style {
            case .slider:
                break
            case .background:
                if let button = self.buttons.at(oldIndex) {
                    button.backgroundColor = self.config.unselectBackgroundColor
                }
                if let button = self.buttons.at(index) {
                    button.backgroundColor = self.config.selectedBackgroundColor
                }
            }
        }
        trimIndexPosition(animation: animation)
        resetSliderFrame(animation: animation)
    }
    
    private func trimIndexPosition(animation: Bool = true) {
        if let button = self.buttons.at(index) {
            var x = CGPoint(x: button.centerX - self.scrollView.width / 2, y: 0).x
            if self.config.isAcceptItemClickedBeCenter == false {
                x = min(x, self.scrollView.contentSize.width - self.scrollView.width)
                x = max(0, x)
            }
            if animation {
                UIView.animate(withDuration: 0.25) {
                    self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
                    
                }
            }else {
                self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
            }
        }
    }
    
    private func resetSliderFrame(animation: Bool) {
        if config.isHiddenSlider {
            slider.isHidden = true
        }else{
            slider.isHidden = buttons.count <= 0
            if let button = buttons.at(_index) {
                if config.isNeedSliderAnimate {
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn) {
                        self.slider.centerX = button.centerX
                        self.slider.bottom = self.height - self.config.sliderBottomSpace
                    } completion: { (_) in
                    }
                }else{
                    self.slider.centerX = button.centerX
                    self.slider.bottom = self.height - self.config.sliderBottomSpace
                }
            }
        }
        
    }
    
    // MARK: - Action
    @objc private func buttonAction(_ button: Button) {
        if let index = buttons.firstIndex(of: button)  {
            if !config.unSeletIndexArr.contains(index) {
                updateIndex(index: index, animation: true)
            }
            if let action = _onIndexChangeWhenTouch, index < self.items.count {
                action(index, self.items[index])
            }
        }
    }
    
    // MARK: - ViewConfig
    override func configSubview() {
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.delegate = self
        slider.backgroundColor = .theme
        scrollView.addSubview(slider)
        
        if let view = leftView {
            self.addSubview(view)
        }
    }
     
    override func configSubviewsFrame() {
        var leading: CGFloat = 0
        if let view = leftView {
            view.left = 0
            leading = view.right
        }
        scrollView.leading = leading
        scrollView.size = CGSize(width: self.width - leading, height: self.height)
        
        slider.size = config.sliderSize
        slider.layer.cornerRadius = config.sliderCornerRadius
        slider.layer.masksToBounds = config.sliderMasksToBounds
        
        configItemsFrame()
    }
    
    
    
}

class ScrollBarItem<Item> {
    
    var name: String = ""
    var isSelect: Bool = false
    var item: Item?
    var badge: UIView?
    // 角标中心点, 默认按钮右上角
    var badgeCenterOffset = CGPoint.zero
    
    init(name: String, item: Item?) {
        self.name = name
        self.item = item
    }
    
}


struct ScrollBarConfig {
    
    enum Style {
        case slider
        case background
    }
    
    enum Alignment {
        case left
        case center
        case right
    }
    
    // 每个item之间的间距
    var buttonSpace: CGFloat = 14
    // 每个item的左右内间距
    var buttonAppendingSpace: CGFloat = 20
    // item字体
    var font = UIFont.systemFont(ofSize: 16, weight: .medium)
    // item选中颜色
    var selectColor = UIColor.normalText
    // item未选中颜色
    var unselectColor = UIColor.normalText.withAlphaComponent(0.5)
    // 整个滚动条的缩进, 左右有效
    var inset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    // 各个页面的缩进
    var pageInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    // 当内容显示不足时左右位置偏好设置
    var alignment = Alignment.left
    // 滚动条样式
    var style = Style.slider
    // slider为背景色时选中的颜色
    var selectedBackgroundColor = UIColor.theme.withAlphaComponent(0.2)
    // slider为背景色时未选中的颜色
    var unselectBackgroundColor = UIColor.lightText4.withAlphaComponent(0.2)
    // slider为条时的size
    var sliderSize: CGSize = CGSize(width: 14, height: 4)
    // slider的圆角
    var sliderCornerRadius: CGFloat = 2
    // slider是否切掉
    var sliderMasksToBounds: Bool = true
    // 是否允许Item被点击的时候自动切换到屏幕中间
    var isAcceptItemClickedBeCenter: Bool = false
    // 按钮的图片大小尺寸
    var btnImageSize: CGSize = CGSize.zero
    // 是否需要阴影
    var isNeedShadow: Bool = false
    // 自定义scrollview的contentSize的width
    var customScrollWidth: CGFloat = 0
    // slider滑动是否需要动画
    var isNeedSliderAnimate: Bool = true
    // 自定义slider距离底部的间距
    var sliderBottomSpace: CGFloat = 3
    // 隐藏掉slider
    var isHiddenSlider: Bool = false
    // 选择某些下标按钮 不去触发点击事件
    var unSeletIndexArr = [Int]()
    static func sliderConfig() -> ScrollBarConfig {
        let con = ScrollBarConfig()
        return con
    }
    
    static func backgroundConfig() -> ScrollBarConfig {
        var con = ScrollBarConfig()
        con.style = .background
        con.font = UIFont.systemFont(ofSize: 12)
        con.buttonAppendingSpace = 32
        return con
    }
    
    
}
