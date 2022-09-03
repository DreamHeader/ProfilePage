//
//  SystemSoundPlayer.swift
//  unipets-ios
//
//  Created by LRanger on 2021/12/9.
//

import Foundation
import AudioToolbox

struct SystemSoundPlayer{

    enum SoundType {
        case lightVibrate
        case light2Vibrate
        case vibrate
    }
    
    static func play(_ type: SoundType) {
        switch type {
        case .lightVibrate:
            AudioServicesPlaySystemSound(1519);
            
        case .light2Vibrate:
            AudioServicesPlaySystemSound(1000);
            
        case .vibrate:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

        }
    }
    
}
