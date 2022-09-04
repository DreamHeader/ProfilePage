//
//  DynamicViewController.swift
//  ProfilePageDemo
//
//  Created by FDKCoder on 2022/9/3.
//

import UIKit

class  DynamicViewController: BaseViewController{
    
    fileprivate var didScroll: ((UIScrollView) -> Void)?
     
    private let LINE_SPACE: CGFloat = 2
    private let ITEM_SPACE: CGFloat = 1
    private var itemWidth: CGFloat {
        return view.width / 3 - ITEM_SPACE * 2
    }

    private var itemHeight: CGFloat {
        return itemWidth * (330.0 / 248.0)
    }

    private let VideoListCellId = "VideoListCellId"
    private var collectionView: UICollectionView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
    }
     
    
}

// MARK: - PageContainScrollView

extension DynamicViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView)
    }
}

extension DynamicViewController: PageContainScrollView {
    func scrollView() -> UIScrollView {
        return collectionView
    }

    func scrollViewDidScroll(callBack: @escaping (UIScrollView) -> Void) {
        didScroll = callBack
    }
}
