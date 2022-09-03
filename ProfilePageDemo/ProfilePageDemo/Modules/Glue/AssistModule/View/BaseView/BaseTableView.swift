//
//  TableView.swift
//  unipets-ios
//
//  Created by FDKCoder on 2021/10/28.
//

import UIKit

typealias TableViewProtocol = UITableViewDelegate & UITableViewDataSource

protocol EmptyViewProtocol: NSObjectProtocol {
    /// 用以判断是会否显示空视图
    func showEmptyView(tableView: UITableView) -> Bool

    /// 配置空数据提示图用于展示
    func configEmptyView(tableView: UITableView) -> UIView
}

extension EmptyViewProtocol {
    func configEmptyView() -> UIView {
        return UIView()
    }
}

class TableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.separatorStyle = .none
        self.separatorColor = .clear
        self.estimatedRowHeight = 44
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.sectionHeaderHeight = 0
        self.sectionFooterHeight = 0
        self.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 34, right: 0)
    }
     
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension TableView {
    // 用于runtime关联属性的key
    private enum associatedKeys {
        static var emptyDelegateKey: Void?
    }
    private var emptyDelegate: EmptyViewProtocol? {
        get {
            return (objc_getAssociatedObject(self, &associatedKeys.emptyDelegateKey) as? EmptyViewProtocol)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &associatedKeys.emptyDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    func setEmtpyViewDelegate(target: EmptyViewProtocol){
        emptyDelegate = target
        DispatchQueue.once(token: #function) {
            TableView.exchangeMethod(targetSel: #selector(layoutSubviews), newSel: #selector(re_layoutSubviews))
        }
    }
    
    @objc func re_layoutSubviews() {
        re_layoutSubviews()
        if let delegate = emptyDelegate {
            if delegate.showEmptyView(tableView: self) {
                let emptyView = delegate.configEmptyView(tableView: self)
                let emptyViewTag = 10_231_343
                if let v = viewWithTag(emptyViewTag), v != emptyView {
                    v.removeFromSuperview()
                }
                if emptyView.superview == nil {
                    emptyView.tag = emptyViewTag
                    addSubview(emptyView)
                }
            }
        }
    }
}
