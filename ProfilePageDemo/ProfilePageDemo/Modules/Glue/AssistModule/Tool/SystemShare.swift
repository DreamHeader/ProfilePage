//
//  SystemShare.swift
//  unipets-ios
//
//  Created by LRanger on 2022/6/14.
//

import Foundation

extension UIActivityViewController {
    
    static func share(file url: URL, from vc: UIViewController) {
        let activity = UIActivityViewController.init(activityItems: [url], applicationActivities: nil)
        vc.present(activity, animated: true)
    }
    
}
