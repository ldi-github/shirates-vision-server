//

import Foundation
import Vision
import AppKit

@available(macOS 15.0, *)
struct ImageFeaturePrintMatcher {
    let template: String
    let inputDirectory: String
    
    init(template: String, inputDirectory: String) throws {
        self.template = template
        self.inputDirectory = inputDirectory
    }

    /**
     matchWithTemplate
     */
    func matchWithTemplate() async throws -> Result {
        
        if(!FileManager.default.fileExists(atPath: template)){
            throw ExecutionError("template not found. (\(template))")
        }
        if(!FileManager.default.fileExists(atPath: inputDirectory)){
            throw ExecutionError("inputDirectory not found. (\(inputDirectory))")
        }

        let templateObservation = try await ImageFeaturePrintMatcher.getFeaturePrintObservation(file: template)
        
        let result = Result()
        
        let fileList = try FileManager.default.contentsOfDirectory(atPath: inputDirectory)
            .filter{ $0.starts(with: "[") && ($0.hasSuffix(".jpg") || $0.hasSuffix(".png")) }
        for file in fileList {
            let inputFile = inputDirectory + "/" + file
            let fpObservation = try await ImageFeaturePrintMatcher.getFeaturePrintObservation(file: inputFile)
            let distance = try templateObservation.distance(to: fpObservation)
            let c = Candidate(distance: distance, file: inputFile, confidence: fpObservation.confidence)
            result.candidates.append(c)
        }
        result.candidates.sort(by: { $0.distance < $1.distance})
        return result
    }
    
    static func getFeaturePrintObservation(file: String) async throws -> FeaturePrintObservation {

        let imageUrl = URL(fileURLWithPath: file)
        let ciImage = CIImage(contentsOf: imageUrl)!
        let cgImage = ciImage.toCGImage()!
        let request = GenerateImageFeaturePrintRequest()
        let result = try await request.perform(on: cgImage)
        
        return result
    }
    
    class Result: Codable {
        
        var candidates: [Candidate] = []
    }
    
    class Candidate: Codable {
        
        let distance: Double
        let file: String
        let confidence: Float
        
        init(distance: Double, file: String, confidence: Float) {
            self.distance = distance
            self.file = file
            self.confidence = confidence
        }
    }

}

