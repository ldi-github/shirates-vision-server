//

import Foundation

@available(macOS 15.0, *)
class ImageFeaturePrintRepository {
    
    var dictionary: [String: ImageFeaturePrintInfo] = [:]

    func clear(){
    
        dictionary.removeAll()
    }
    
    func getImageFeaturePrintInfo(name: String) -> ImageFeaturePrintInfo? {
        
        if dictionary.keys.contains(name) {
            return dictionary[name]
        }
        return nil
    }
    
    func getImageFeaturePrintInfoList() -> [ImageFeaturePrintInfo] {
        
        return dictionary.values.compactMap { $0 }
    }
    
}
