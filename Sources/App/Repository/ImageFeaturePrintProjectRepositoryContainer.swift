//

import Foundation

@available(macOS 15.0, *)
class ImageFeaturePrintRepositoryContainer {

    nonisolated(unsafe) static var dictionary: [String: ImageFeaturePrintRepository] = [:]

    static func clear(){
        
        dictionary.removeAll()
    }
    
    static func getRepository(project: String) -> ImageFeaturePrintRepository {
        
        if dictionary.keys.contains(project) {
            return dictionary[project]!
        }
        let repo = ImageFeaturePrintRepository()
        dictionary[project] = repo
        return repo
    }
    
    static func getImageFeaturePrintInfoList() -> [ImageFeaturePrintRepository] {
        
        return dictionary.values.compactMap { $0 }
    }
}
