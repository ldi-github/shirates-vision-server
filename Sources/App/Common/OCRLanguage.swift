//

import Foundation
import Vision

@available(macOS 15.0, *)
class OCRLanguage {
    
    nonisolated(unsafe) static var _supportedRecognitionLanguages: [Locale.Language] = []

    static var supportedLanguages: [String] {

        if(_supportedRecognitionLanguages.isEmpty){
            _supportedRecognitionLanguages = RecognizeTextRequest().supportedRecognitionLanguages
        }
        let supprotedLanguages = Set(_supportedRecognitionLanguages.map{ $0.languageCode?.debugDescription ?? "" } )
        return supprotedLanguages.sorted().map { $0 }
    }

    /**
     isSupported
     */
    static func isSupported(language: String) -> Bool {
        if(language.isEmpty){
            return true
        }
        let lang = Language(language: language)
        let list = supportedLanguages.filter{ $0 == lang.languageCode }
        return list.count > 0
    }

    /**
     validateLanguage
     */
    static func validateLanguage(language: String) throws {
        if(isSupported(language: language)){
            return
        }
        let supportedLangage = OCRLanguage.supportedLanguages.map{ "\($0)" }.joined(separator: ", ")
        throw ExecutionError("\(language) is not supported. Supported languages: \(supportedLangage)")
    }
    
    class Language: CustomStringConvertible {

        let languageCode: String
        let script: String?
        let region: String?
        
        let localeLanguage: Locale.Language
        
        init(language: String) {

            let localeDic = language.getLocale()
            languageCode = localeDic["languageCode"] ?? ""
            script = localeDic["script"] ?? ""
            region = localeDic["region"] ?? ""
            localeLanguage = Locale.Language(identifier: language)
        }

        var description: String {
            return localeLanguage.localeString
        }
    }
    
}

extension String {
    
    func getLocale() -> [String: String] {

        var dic = [String: String]()
        
        var work = self

        if(work.contains("_")){
            let tokens = work.split(separator: "_")
            dic["region"] = String(tokens[1])
            work = String(tokens[0])
        }

        let tokens = work.split(separator: "-")
        dic["languageCode"] = String(tokens[0])
        if(tokens.count > 1) {
            dic["script"] = String(tokens[1])
        }
        return dic
    }
}

extension Locale.Language {

    var localeString: String {
        var result = "\(self.languageCode ?? "")"
        if(self.script != nil) {
            result = "\(result)-\(self.script!)"
        }
        if(self.region != nil) {
            result = "\(result)_\(self.region!)"
        }
        return result
    }
}
