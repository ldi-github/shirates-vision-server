//

import Foundation

struct ConfigUtility {
    
    static func getPort() -> Int {
        let dic = PListUtility.getDictionary("config")
        let port = dic["port"] as? Int ?? Const.port
        return port
    }
}
