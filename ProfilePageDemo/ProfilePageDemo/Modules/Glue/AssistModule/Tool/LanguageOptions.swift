//
//  LanguageOptions.swift
//  unipets-ios
//
//  Created by Future on 2022/6/16.
//

import Foundation


// MARK: - 根据语言文件 和 key 值获取 相对应的 字符串
class LanguageManager {
    
    static func localizedLanguage(key: String) -> String {
        
        let languageBundle = Bundle.getLanguageBundle() ?? Bundle.main
        
        return NSLocalizedString(key, tableName: "Localizable", bundle: languageBundle, comment: "")
        
    }
}

// MARK: - 字符串扩展（简化本地化写法）
extension String {
    
    func localized() -> String {
        
        // 如果用户未设置字体，则使用系统默认字体
        //  if Defaults[.currentLanguage] == "" {
        //  return NSLocalizedString(self, comment: "")
        //        }
        
        // 如果用户设置过字体，则使用用户选择的字体
        return LanguageManager.localizedLanguage(key: self)
    }
}



enum LanguageOptions: String {
    case english = "English"               // 英语
    case chinese = "中文(简体)"             // 中文(简体)
    
    static func getFileName(title: String) -> String {
        switch title {
        case "English":
            return "en"
        case "中文(简体)":
            return "zh-Hans"
        default:
            return "zh-Hans"
        }
    }
}

extension Bundle {
    
    class func getLanguageBundle() -> Bundle? {
        // 根据用户选择的不同语言，获取不同的语言的文件
        let language = LanguageOptions.getFileName(title: "中文(简体)")
        
        let languageBundlePath = Bundle.main.path(forResource: language, ofType: "lproj")
        
        guard languageBundlePath != nil else {
            return nil
        }
        
        let languageBundle = Bundle.init(path: languageBundlePath!)
        
        guard languageBundle != nil else {
            return nil
        }
        
        return languageBundle!
    }
}
