//
//  UIView+Empty.swift
//  unipets-ios
//
//  Created by 浮东凯 on 2021/10/14.
//

import UIKit

protocol UIViewExtensionEmptyDelegate {
    func setEmptyView()-> UIView
    
}
extension UIView{
    
    weak open var emptyViewDelegate: UIViewExtensionEmptyDelegate?
    
    
    
}
