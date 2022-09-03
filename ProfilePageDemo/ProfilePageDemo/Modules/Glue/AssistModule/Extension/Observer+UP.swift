//
//  Observer+UP.swift
//  unipets-ios
//
//  Created by LRanger on 2021/10/11.
//

import Foundation

extension NSObject {
    
    struct Key {
        static var observerInfo = "observerInfo"
        static var deInit = "deInit"

    }
    
    typealias ObserverResponse = ((_ obj: Any?, _ oldVal: Any?, _ newVal: Any?) -> Void)
    
    private var _observerInfo: [String: [ObserverTarget]]? {
        get {
            objc_getAssociatedObject(self, &Key.observerInfo) as? [String: [ObserverTarget]]
        }
        set {
            objc_setAssociatedObject(self, &Key.observerInfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var _deInitTarget: ObserverDeinitTarget? {
        get {
            objc_getAssociatedObject(self, &Key.deInit) as? ObserverDeinitTarget
        }
        set {
            objc_setAssociatedObject(self, &Key.deInit, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func willDeinit() {
        self.removeObserverBlocks()
    }
    
    func addObserverBlock(keyPath: String, response: @escaping (_ obj: Any?, _ oldVal: Any?, _ newVal: Any?) -> Void) {
        
        if self._deInitTarget == nil {
            self._deInitTarget = ObserverDeinitTarget.init(onDeinit: { [weak self] in
                self?.willDeinit()
            })
        }
        
        let target = ObserverTarget.init(block: response)
        var info = self._observerInfo ?? [String: [ObserverTarget]]()
        var arr = info[keyPath] ?? [ObserverTarget]()
        arr.append(target)
        info[keyPath] = arr
        self._observerInfo = info
        self.addObserver(target, forKeyPath: keyPath, options: [.old, .new], context: nil)
        
    }
    
    func removeObserverBlock(keyPath: String) {
        var info = self._observerInfo ?? [String: [ObserverTarget]]()
        let arr = info[keyPath] ?? [ObserverTarget]()
        arr.forEach { target in
            self.removeObserver(target, forKeyPath: keyPath)
        }
        info[keyPath] = nil
        self._observerInfo = info
    }

    func removeObserverBlocks() {
        let info = self._observerInfo ?? [String: [ObserverTarget]]()
        info.forEach { (key: String, value: [ObserverTarget]) in
            value.forEach { target in
                self.removeObserver(target, forKeyPath: key)
            }
        }
        self._observerInfo = nil
    }
    
}

class ObserverDeinitTarget: NSObject {

    var onDeinit: (() -> Void)?
    
    init(onDeinit: @escaping () -> Void) {
        super.init()
        self.onDeinit = onDeinit
    }
    
    deinit {
        self.onDeinit?()
    }
    
}

fileprivate class ObserverTarget: NSObject {
    
    private var block: ObserverResponse?
    
    init(block: @escaping ObserverResponse) {
        super.init()
        self.block = block
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let value = change?[NSKeyValueChangeKey.notificationIsPriorKey] as? Bool {
            if value {
                return
            }
        }
        
        if let value = change?[NSKeyValueChangeKey.kindKey] as? NSKeyValueChange {
            if value != NSKeyValueChange.setting {
                return
            }
        }
        
        let oldVal = change?[NSKeyValueChangeKey.oldKey]
        let newVal = change?[NSKeyValueChangeKey.newKey]
        
        self.block?(object, oldVal, newVal)
        
    }
    
}

