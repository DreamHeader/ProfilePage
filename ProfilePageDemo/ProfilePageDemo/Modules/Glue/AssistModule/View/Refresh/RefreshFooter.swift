//
//  RefreshFooter.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/29.
//

import UIKit
import MJRefresh

class RefreshFooter: MJRefreshAutoStateFooter {

    override func prepare() {
        super.prepare()
        self.setTitle("上拉加载更多", for: .idle)
        self.setTitle("努力加载中...", for: .refreshing)
        self.setTitle("到底啦~", for: .noMoreData)
    }
    
}
