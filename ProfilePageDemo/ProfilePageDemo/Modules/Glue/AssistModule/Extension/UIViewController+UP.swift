//
//  UIViewController+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/10/20.
//

import Foundation
import UIKit

extension UIViewController {
    
    // 寻找最上层VC
    static var currentViewController: UIViewController {
        return _getBestViewController(source: KeyWindow().rootViewController) ?? UIViewController()
    }
    
    private static func _getBestViewController(source: UIViewController?) -> UIViewController? {
        if let tab = source as? UITabBarController {
            return _getBestViewController(source: tab.selectedViewController)
        }
        else if let nav = source as? UINavigationController {
            return _getBestViewController(source: nav.topViewController)
        }
        else if let vc = source?.presentedViewController {
            return _getBestViewController(source: vc)
        } else {
            return source
        }
    }
    
    func showAsNavigation(vc: UIViewController) {
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = BaseNavigationViewController.root(vc)
            self.present(nav, animated: true, completion: nil)
        }
    }
}
