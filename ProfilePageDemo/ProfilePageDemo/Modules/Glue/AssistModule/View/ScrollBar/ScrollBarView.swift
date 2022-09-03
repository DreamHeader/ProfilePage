//
//  MedaiScrollBarView.swift
//  unipets-ios
//
//  Created by LRanger on 2021/9/2.
//

import UIKit

class ScrollBarView<Item>: BaseView, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private var placeholderViews = [UIView]()
    let bar = ScrollBar<Item>()
    var customBarPosition = false
    var lazyLoad = false
    private var items = [ScrollBarItem<Item>]()
    private var _index = 0
    private var views = [UIView]()
    var onIndexDidChange: ((Int) -> Void)?
    var index: Int {
        return _index
    }
    
    override func didInit() {
        
    }
    
    // MARK: - Load
    override func didLoadFinish() {
        configSubview()
        configSubviewsFrame()
        
    }
    
    override func viewWillTransition() {
        configSubviewsFrame()
    }
    
    // MARK: - Reload
    
    func reload(items: [ScrollBarViewItem<Item>], index: Int = 0) {
        self.reload(items: items.map { $0.item }, views: items.map { $0.view }, index: index)
    }
    
    func reload(items: [ScrollBarItem<Item>], views: [UIView], index: Int = 0) {
        if !customBarPosition {
            self.addSubview(bar)
        } else if bar.superview == self {
            bar.removeFromSuperview()
        }
        configSubviewsFrame()
        bar.reload(items: items, index: index)
        self.items = items
        _index = bar.index
        self.views = views
        reloadScrollViews()
    }
    
    
    func reload() {
        reload(items: items, views: views, index: _index)
    }
    
    private func reloadScrollViews() {
        placeholderViews.forEach { $0.removeFromSuperview() }
        placeholderViews.removeAll()
        
        for (index, _) in items.enumerated() {
            let placeholderView = UIView()
            scrollView.addSubview(placeholderView)
            let inset = self.bar.config.pageInset
            placeholderView.frame = CGRect(x: inset.left + scrollView.width * CGFloat(index), y: inset.top, width: scrollView.width - inset.left - inset.right, height: scrollView.height - inset.top - inset.bottom)
            placeholderViews.append(placeholderView)
            if !lazyLoad, let pageView = views.at(index) {
                pageView.frame = placeholderView.bounds
                placeholderView.addSubview(pageView)
                placeholderView.setNeedsLayout()
                placeholderView.layoutIfNeeded()
            }
        }
        scrollView.contentSize = CGSize(width: CGFloat(items.count) * scrollView.width, height: scrollView.height)
        scrollView.contentOffset = CGPoint(x: CGFloat(self.index) * scrollView.width, y: 0)
        if lazyLoad {
            checkViewIsLoad()
        }

    }
    
    private func checkViewIsLoad() {
        if let pageView = self.views.at(index), let placeholderView = placeholderViews.at(index), pageView.superview == nil {
            pageView.frame = placeholderView.bounds
            placeholderView.addSubview(pageView)
            placeholderView.setNeedsLayout()
            placeholderView.layoutIfNeeded()
        }
    }
    
    func updateIndex(index: Int, animation: Bool) {
        bar.updateIndex(index: index, animation: animation)
        _index = bar.index
        if lazyLoad {
            checkViewIsLoad()
        }
        scrollView.setContentOffset(.init(x: CGFloat(self.index) * scrollView.width, y: 0), animated: animation)
        self.onIndexDidChange?(self._index)
    }

    
    // MARK: - ViewConfig
    override func configSubview() {
        
        if !customBarPosition {
            self.addSubview(bar)
        }
        bar._onIndexChangeWhenTouch = { index, _ in
            self.scrollView.setContentOffset(CGPoint(x: CGFloat(index) * self.scrollView.width, y: 0), animated: true)
            self._index = index
            if self.lazyLoad {
                self.checkViewIsLoad()
            }
            self.onIndexDidChange?(self._index)
        }
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        
    }
    
    override func configSubviewsFrame() {
        if customBarPosition {
            scrollView.frame = self.bounds
        } else {
            bar.frame = CGRect(x: 0, y: 0, width: self.width, height: 44 )
            scrollView.frame = CGRect(x: 0, y: bar.bottom, width: self.width, height: self.height - bar.bottom)
        }
        let inset = self.bar.config.pageInset
        for (i, pageView) in self.views.enumerated() {
            if let placeholderView = placeholderViews.at(i) {
                placeholderView.frame = CGRect(x: inset.left + scrollView.width * CGFloat(i), y: inset.top, width: scrollView.width - inset.left - inset.right, height: scrollView.height - inset.top - inset.bottom)
                if pageView.superview != nil {
                    pageView.frame = placeholderView.bounds
                }
            }
        }

    }
    
   
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }

//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        endScroll()
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        endScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            endScroll()
        }
    }
    
    private func endScroll() {
        let index = Int(self.scrollView.contentOffset.x / self.scrollView.width)
        if index == _index {
            return
        }
        
        _index = index
        bar.updateIndex(index: Int(index), animation: true)
        if lazyLoad {
            checkViewIsLoad()
        }
        self.onIndexDidChange?(_index)
    }
    
}

struct ScrollBarViewItem<Item> {
    let item: ScrollBarItem<Item>
    let view: UIView
}
