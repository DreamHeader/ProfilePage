//
//  AlertController.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/10.
//

import UIKit

class AlertController: UIAlertController{

    static func alert(title: String?, message: String?) -> AlertController {
        let alert = AlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .theme
        return alert
    }
    
    static func actionSheet(title: String?, message: String?) -> AlertController {
        let alert = AlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        alert.view.tintColor = .theme
        return alert
    }
    
    func addAction(_ title: String, _ action: @escaping () -> Void) {
        self.addAction(.init(title: title, style: .default, handler: { _ in
            action()
        }))
    }
    
    func addDestructiveAction(_ title: String, _ action: @escaping () -> Void) {
        self.addAction(.init(title: title, style: .destructive, handler: { _ in
            action()
        }))
    }
    
    func addCancelAction() {
        self.addCancelAction("common.cancel".localized()) {
            
        }
    }
    
    func addConfirmAction(_ action: (() -> Void)? = nil) {
        self.addAction("common.confirm".localized()) {
            action?()
        }
    }
    
    func addCancelAction(_ title: String, _ action: @escaping () -> Void) {
        self.addAction(.init(title: title, style: .cancel, handler: { _ in
            action()
        }))
    }
    
    func show(_ viewController: UIViewController?) {
        if let vc = viewController {
            vc.present(self, animated: true, completion: nil)
        }
    }
    
    func show() {
        UIViewController.currentViewController.present(self, animated: true, completion: nil)
    }
    
}
