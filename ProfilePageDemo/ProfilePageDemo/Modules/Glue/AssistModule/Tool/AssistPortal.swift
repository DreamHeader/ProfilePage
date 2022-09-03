//
//  AssistModule.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/23.
//

import UIKit
import Combine

class AssistPortal: ModulePortal {

    var loginStateSubscribeToken: AnyCancellable?
    
    required init(_ option: Dictionary<String, Any>?) {
        
    }
    
    // 所有跟用户环境数据相关的设置写到这里, 启动app会默认调用, 每次登录登出也会调用
    func setupWithDefaultUser() {
        
        setupRealmDB()
        
        if LoginCache.shared().didLogin {
            Performance(label: "已登录用户刷新Token", instance: self).record {
                LoginCache.shared().refreshTokensOnly { _, _ in
                    
                }
                // 拉取用户信息
                LoginCache.shared().updateUserDetail()
            }
            BuglyAdapter.setUserIdentifer(GlobalCache.shared().currentUser()?.cid)
        }
        
        // 监听登录登出状态
        if let por: LoginPortal = "LoginPortal".getModule() {
            Performance(label: "监听登录登出状态", instance: self).record(printAllBuf: true) {
                self.loginStateSubscribeToken = por.stateSubject.sink(receiveValue: { [weak self] didLogin in
                    guard let self = self else {
                        return
                    }
                    if didLogin {
                        self.setupRealmDB()
                        LoginCache.shared().updateUserDetail()
                    }
                    BuglyAdapter.setUserIdentifer(GlobalCache.shared().currentUser()?.cid)
                })
            }
        }
        
    }
    
    private func setupRealmDB() {
        if let dbPortal: RealmPortal = "RealmPortal".getModule() {
            Performance(label: "DB初始化", instance: self).record {
                try? dbPortal.dbClient.setup()
            }
        }
    }
    
}
