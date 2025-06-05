//

import Foundation

@available(macOS 15.0, *)
actor CustomWordsRepository {
    
    private static var customWordsDictionary: [String: [String]] = [:]
    
    static func clear() {
        
        customWordsDictionary.removeAll()
    }

    static func getCustomWords(file: String) throws -> [String] {

        let list = customWordsDictionary[file]
        if(list != nil) {
            return list!
        }

        if(FileManager.default.fileExists(atPath: file) == false) {
            throw ExecutionError("customWordsFile not found. (\(file))")
        }

        let csvText = try String(contentsOfFile: file, encoding: .utf8)
        let customWords = csvText.split { $0 == "\n" || $0 == "\r\n" }.map { String($0)}.filter { !$0.isEmpty }
        customWordsDictionary[file] = customWords
        return customWords
    }
}
