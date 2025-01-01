//

import Foundation
import Vision
import AppKit

@available(macOS 15.0, *)
struct ImageFeaturePrintConfigurator {
    let inputDirectory: String
    let language: String? = nil
    
    init(inputDirectory: String) {
        self.inputDirectory = inputDirectory
    }
   
    /**
     setupImageFeaturePrintConfig
     */
    func setupImageFeaturePrintConfig() async throws -> Result {
        
        if(!FileManager.default.fileExists(atPath: inputDirectory)){
            throw ExecutionError("Directory not found. (\(inputDirectory))")
        }

        ImageFeaturePrintRepository.clear()

        let inputImageFiles = try getAllFilesRecursively(at: inputDirectory)
        
        for inputImageFile in inputImageFiles {

            let image = getCGImage(path: inputImageFile)

            /**
             FeaturePrint
             */
            let fp = try await getFeaturePrintObservation(file: inputImageFile, cgImage: image)
            let name = inputImageFile.name()
        
            ImageFeaturePrintRepository.dictionary[name] = fp
        }

        let count = ImageFeaturePrintRepository.dictionary.keys.count
        let result = Result(message: "Initialized. (image count: \(count))")
        return result
    }

    /**
     getAllFilesRecursively
     */
    func getAllFilesRecursively(at path: String) throws -> [String] {
        let fileManager = FileManager.default
        var allFiles: [String] = []
        
        do {
            let contents = try fileManager.subpathsOfDirectory(atPath: path)
            for content in contents {
                if (content.hasSuffix(".jpg") || content.hasSuffix(".png")){
                    let fullPath = (path as NSString).appendingPathComponent(content)
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory), !isDirectory.boolValue {
                        allFiles.append(fullPath)
                    }
                }
            }
        } catch {
            throw ExecutionError("Error while enumerating files. (inputDirectory=\(inputDirectory), \(error.localizedDescription))")
        }
        
        return allFiles
    }

    private func getFeaturePrintObservation(file: String, cgImage: CGImage? = nil) async throws -> ImageFeaturePrintInfo {
        
        let image = cgImage ?? getCGImage(path: file)
        
        let request = GenerateImageFeaturePrintRequest()
        let observation = try await request.perform(on: image)

        let name = file.name()
        let result = ImageFeaturePrintInfo(
            name : name,
            imageFile : file,
            featurePrint : observation
        )
        return result
    }
    
    class Result: Codable {
        
        let message: String
        
        init(message: String) {
            self.message = message
        }
    }

}
