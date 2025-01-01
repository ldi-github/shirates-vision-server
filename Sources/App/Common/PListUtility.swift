//

import Foundation

struct PListUtility {
    
    /**
     getDictionary
     */
    static func getDictionary(_ name: String) -> NSDictionary {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
              FileManager.default.fileExists(atPath: path) == false,
              let dic = NSDictionary(contentsOfFile: path)
        else {
            return NSDictionary()
        }
        
        return dic
    }
    
}
