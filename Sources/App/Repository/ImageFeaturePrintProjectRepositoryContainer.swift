//

import Foundation

@available(macOS 15.0, *)
actor ImageFeaturePrintRepositoryContainer {

    private static var dictionary: [String: ImageFeaturePrintRepository] = [:]

    static func clear(){
        
        dictionary.removeAll()
    }
    
    static func getDictionary() -> [String: ImageFeaturePrintRepository] {
        
        var dic = [String: ImageFeaturePrintRepository]()
        for (k, v) in dictionary {
            dic[k] = v
        }
        return dic
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
