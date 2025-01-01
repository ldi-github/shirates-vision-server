//

import Foundation
import Vision
import AppKit

struct ImageClassifier {
    let input: String
    let mlmodel: String
    
    init(input: String, mlmodel: String?) throws {
        if mlmodel == nil {
            throw ExecutionError("mlmodel is not specified")
        }
        self.input = input
        self.mlmodel = mlmodel!
    }
    
    func classifyImage() throws -> Result {
        
        if(!FileManager.default.fileExists(atPath: input)){
            throw ExecutionError("File not found. (\(input))")
        }
        if(!FileManager.default.fileExists(atPath: mlmodel)){
            throw ExecutionError("File not found. (\(mlmodel))")
        }
        
        let compiledUrl = try MLModel.compileModel(at: URL(fileURLWithPath: mlmodel))
        let mlModel = try MLModel(contentsOf: compiledUrl)
        let coremlModel = try VNCoreMLModel(for: mlModel)
        let request = VNCoreMLRequest(model: coremlModel)
        
        let imageUrl = URL(fileURLWithPath: input)
        let image = CIImage(contentsOf: imageUrl)!
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        try! handler.perform([request])
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            throw ExecutionError("VNClassificationObservation not found.")
        }
        
        let result = Result()
        for o in observations {
            let e = Candidate(identifier: o.identifier, confidence: o.confidence)
            result.candidates.append(e)
        }
        return result
    }
    
    class Result: Codable {
        
        var candidates: [Candidate] = []
    }
    
    class Candidate: Codable {
        
        let identifier: String
        let confidence: VNConfidence
        
        init(identifier: String, confidence: VNConfidence) {
            self.identifier = identifier
            self.confidence = confidence
        }
    }
}
