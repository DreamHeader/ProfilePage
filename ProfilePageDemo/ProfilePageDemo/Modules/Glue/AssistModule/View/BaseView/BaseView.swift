//
//  BaseView.swift
//  unipets-ios
//
//  Created by LRanger on 2021/8/27.
//

import UIKit
import Combine

class BaseView: UIView {
    
    private var lastFrame = CGRect.zero
    private(set) var didLayout = false
    var bag = [AnyCancellable]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit()
    }
    
    deinit {
        UPLog("\(self) deinit")
    }
    
    func didInit() {
        
    }
    
    /// 视图第一次layout时调用, 这个特性决定了可以像ViewController一样init之后传递参数, 都可以在这个方法中读取到
    func didLoadFinish() {
        
    }
    
    /// 在此方法中生成子视图
    func configSubview() {
        
    }
    
    /// 在此方法中更新子视图布局
    func configSubviewsFrame() {

    }
    
    func viewWillTransition() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayout {
            didLayout = true
            self.didLoadFinish()
            lastFrame = frame
        }
        
        if !lastFrame.equalTo(frame) {
            viewWillTransition()
            lastFrame = frame
        }
        
    }

    
    
    
}

