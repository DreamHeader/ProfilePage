//
//  ProfileViewController.swift
//  ProfilePageDemo
//
//  Created by FDKCoder on 2022/9/3.
//

import UIKit

class ProfileViewController: BaseViewController {
    private var isHostScrollViewEnable = true
    private var isContainScrollViewEnable = false

    var childVCs: [PageContainScrollView] = []
    private var collectionView: PageScrollView!
    private var contentView: CollectionViewCellContentView!
    private var headerView: PageHeaderView?
    private var navigationView: UIView!

    private var navigationViewHeight: CGFloat {
//        if #available(iOS 11.0, *) {
//            return UIApplication.shared.statusBarFrame.height + 54
//        } else {
//            return 74
//        }
        return UIWindow.statusBarHeight + 54
    }

    private var headerViewHeight: CGFloat {
        return 980.0 / 750.0 * view.width
    }

    private var stopScrollOffset: CGFloat {
        return headerViewHeight - navigationViewHeight - segmentViewHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = PageScrollView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.register(PageHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PageHeaderView.description())
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        let returnBtn = UIButton(type: .system)
        returnBtn.setImage(R.image.return_icon40x40()?.withRenderingMode(.alwaysOriginal), for: .normal)
        returnBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(returnBtn)
        returnBtn.translatesAutoresizingMaskIntoConstraints = false
        returnBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        returnBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true

        navigationView = UIView()
        navigationView.backgroundColor = themeColor
        navigationView.isHidden = true
        view.insertSubview(navigationView, belowSubview: returnBtn)
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: navigationViewHeight).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = "我叫Abbily"
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = UIColor.white
        navigationView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: returnBtn.centerYAnchor).isActive = true

        contentView = CollectionViewCellContentView()
        contentView.hostScrollView = collectionView

        initSubViewController()
    }

    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }

    func initSubViewController() {
        let musicVC = DynamicViewController()
        childVCs.append(musicVC)

        let videoVC = VideoViewController()
        childVCs.append(videoVC)

        let timeLineVC = FavoriteViewController()
        childVCs.append(timeLineVC)

        childVCs.forEach { vc in
            addChild(vc)
            vc.scrollViewDidScroll(callBack: { [weak self] scrollview in
                self?.containScrollViewDidScroll(scrollview)
            })
        }
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: view.width, height: headerViewHeight)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: view.height - navigationViewHeight - segmentViewHeight - view.safeAreaInsets.bottom)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath)
        contentView.delegate = self
        cell.contentView.addSubview(contentView)
        contentView.frame = cell.contentView.bounds
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind _: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PageHeaderView.description(), for: indexPath) as? PageHeaderView
        headerView?.segmentView.delegate = self
        return headerView!
    }
}

extension ProfileViewController: CollectionViewCellContentViewDataSource {
    func collectionViewScroll(progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        headerView?.segmentView.setTitle(progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }

    func numberOfViewController() -> Int {
        return childVCs.count
    }

    func viewController(itemAt indexPath: IndexPath) -> UIViewController {
        return childVCs[indexPath.item]
    }
}

extension ProfileViewController {
    func containScrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        // 向上滑动时
        if offsetY > 0 {
            if isContainScrollViewEnable {
                scrollView.showsVerticalScrollIndicator = true

                if collectionView.contentOffset.y == 0 {
                    isHostScrollViewEnable = true
                    isContainScrollViewEnable = false

                    scrollView.contentOffset = .zero
                    scrollView.showsVerticalScrollIndicator = false
                } else {
                    collectionView.contentOffset = CGPoint(x: 0, y: stopScrollOffset)
                }

            } else {
                scrollView.contentOffset = CGPoint.zero
                scrollView.showsVerticalScrollIndicator = false
            }
        } else { // 向下滑动时
            isContainScrollViewEnable = false
            isHostScrollViewEnable = true
            scrollView.contentOffset = CGPoint.zero
            scrollView.showsVerticalScrollIndicator = false
        }
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        // 判断是否可以继续向上滑动
        if offsetY >= stopScrollOffset {
            scrollView.contentOffset.y = stopScrollOffset
            if isHostScrollViewEnable {
                isHostScrollViewEnable = false
                isContainScrollViewEnable = true
            }
        } else {
            if isContainScrollViewEnable {
                scrollView.contentOffset.y = stopScrollOffset
            }
        }
        // 导航栏相关逻辑
        if scrollView.contentOffset.y < 0 {
            headerView?.backgroundImageAnimation(offset: scrollView.contentOffset.y)
            navigationView.isHidden = true
        } else {
            navigationView.isHidden = false
            navigationView.alpha = scrollView.contentOffset.y / stopScrollOffset
        }
    }
}

extension ProfileViewController: PageSegmentViewDelegate {
    func pageSegment(selectedIndex index: Int) {
        contentView.switchPage(index: index)
    }
}
