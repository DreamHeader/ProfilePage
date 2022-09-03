//
//  AVAudioSessionManage.swift
//  unipets-ios
//
//  Created by Future on 2021/12/24.
//

import Foundation
import AVFoundation


class AVAudioSessionManage {
    
    private static let _manage = AVAudioSessionManage()
    
    static func shared() -> AVAudioSessionManage {
        return _manage
    }
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(observeAudioSessionRouteChange(nofi:)), name: AVAudioSession.routeChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeVolumeChange(nofi:)), name: .VolumeChange, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK:设置AVAudioSession默认配置  category最好只设置一次 不然会出现很多恶心的声音问题
    func setAVAudioConfig(isDefaultToSpeaker: Bool = true){
        let audioSession = AVAudioSession.sharedInstance()
        let options:AVAudioSession.CategoryOptions = [.allowBluetooth,.defaultToSpeaker,.allowBluetoothA2DP]
        try? audioSession.setCategory(.playAndRecord, options: options )
        if isDefaultToSpeaker {
            try? audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }  else {
            try? audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        // 这个东西一定放到最后，因为你如果把配置处理放在他之后，就没有作用
        try? audioSession.setActive(true)
    }
    //MARK: 是否为外接设备连接中
    func isHeadPlugOutput() -> Bool {
        return self.isBlueToothOutput()||self.isHeadSetOutput()
    }
    //MARK: 是否为有线耳机的连接
    func isHeadSetOutput() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
            if desc.portType == AVAudioSession.Port.headphones {
                return true
            }
        }
        return false
    }
    //MARK: 是否为蓝牙耳机的连接
    func isBlueToothOutput() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for desc in route.outputs {
            if desc.portType == AVAudioSession.Port.bluetoothA2DP || desc.portType == AVAudioSession.Port.bluetoothLE || desc.portType == AVAudioSession.Port.bluetoothHFP {
                return true
            }
        }
        return false
    }
}
extension AVAudioSessionManage {
    // MARK: 监听音频路由改变
    @objc private func observeAudioSessionRouteChange(nofi: Notification){
        let userInfo = nofi.userInfo
        if let userInfo = userInfo {
            //获取前一个线路的设备
            let routeDes = userInfo["AVAudioSessionRouteChangePreviousRouteKey"]
            if let routeDesc = routeDes as? AVAudioSessionRouteDescription  {
                for desc in routeDesc.outputs {
                    // 发出改变后的上一个路由设备的路由类型
                    NotificationCenter.default.post(name: .ObservePreviousRouteType , object: desc.portType)
                }
            }
        }
    }
    @objc private func observeVolumeChange(nofi: Notification){
        let userInfo = nofi.userInfo
        if let userInfo = userInfo {
            if let  value = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? NSString {
                if value == "ExplicitVolumeChange" {
                    // 远程控制拍照
                    NotificationCenter.default.post(name: .remoteControlRecord , object: nil)
                }
            }
        }
    }
}
 

