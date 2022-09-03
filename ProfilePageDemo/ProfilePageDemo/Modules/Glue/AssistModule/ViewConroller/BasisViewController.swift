//
//  BasisViewController.swift
//  unipets-ios
//
//  Created by FDK on 2021/10/28.
//

import UIKit
/// 作为项目VC的基类
//## 此文件只做埋点等超级基础业务
class BasisViewController: UIViewController, _BaseNavigationViewControllerEdgePanDelegate {
    
    var onWillAppear: (() -> Void)?
    var onWillDisappear: (() -> Void)?
    var sideDragBackBlock: (() -> Void)? // 侧滑返回的回调
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInit()
    }
    
    /// 无论是xib还是代码初始化最终都会执行这个方法
    func didInit() {
        self.modalPresentationStyle = .fullScreen
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 埋点，进入页面
        DispatchQueue.global().async {
            SkyeyeAdapter.handle?.trackPageBegin(self.getCustomDesciption(), parameters:self.getBuriedDataPointsParam())
        }
        onWillAppear?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onWillDisappear?()
        // 埋点，离开页面
        DispatchQueue.global().async {
            SkyeyeAdapter.handle?.trackPageEnd(self.getCustomDesciption(), parameters:self.getBuriedDataPointsParam())
        }
    }
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if(parent == nil){
            if let back = sideDragBackBlock {
                back()
            }
        }
    }
    
    // ##  MARK 数据埋点 如果子类需要重写这个描述的参数自己设置
    func getCustomDesciption(msg: String = "") -> String {
        if msg.count > 0 {
            return msg
        }
        return self.description
    }
    
    // ##  MARK 数据埋点 如果子类需要重写这个汇报的参数自己设置
    func getBuriedDataPointsParam( param:[String:String] = BuriedDataPoints.getBuriedData() ) -> [String:String] {
        let buriedDataPointsParam = BuriedDataPoints.getBuriedData(channel: "App", extensionParam: param)
        return buriedDataPointsParam
    }
    
    // _BaseNavigationViewControllerEdgePanDelegate
    func navigationController(_ navigtionViewController: _BaseNavigationViewController, shouldPopItemByPanGesture item: UINavigationItem) -> Bool {
        return true
    }
}
