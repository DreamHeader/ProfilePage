//
//  UITableView+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2022/6/22.
//

import Foundation
import UIKit

extension UITableView {
    
    static func `default`(style: UITableView.Style = .plain) -> UITableView {
        let tb = UITableView(frame: .zero, style: style)
        tb.estimatedRowHeight = 44
        tb.estimatedSectionFooterHeight = 0
        tb.estimatedSectionHeaderHeight = 0
        tb.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tb.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tb.contentInsetAdjustmentBehavior = .never
        let headerView = UIView()
        headerView.size = CGSize(width: 1, height: 1)
        tb.tableHeaderView = headerView
        let footerView = UIView()
        footerView.size = CGSize(width: 1, height: 1)
        tb.tableFooterView = footerView
        return tb
    }
    
}
