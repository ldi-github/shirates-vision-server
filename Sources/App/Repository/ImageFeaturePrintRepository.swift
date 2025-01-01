//

import Foundation

@available(macOS 15.0, *)
class ImageFeaturePrintRepository {
    
    static var dictionary: [String: ImageFeaturePrintInfo] = [:]

    static func clear(){
    
        dictionary.removeAll()
    }
    
    static func getImageFeaturePrintInfo(name: String) -> ImageFeaturePrintInfo? {
        
        if dictionary.keys.contains(name) {
            return dictionary[name]
        }
        return nil
    }
    
    static func getImageFeaturePrintInfoList() -> [ImageFeaturePrintInfo] {
        
        return dictionary.values.compactMap { $0 }
    }
    
}
