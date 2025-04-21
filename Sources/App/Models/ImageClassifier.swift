//

import Foundation
import Vision
import AppKit

struct ImageClassifier {
    let input: String
    let mlmodel: String
    let shardID: Int
    
    init(input: String, mlmodel: String?, shardID: Int = 0) throws {
        if mlmodel == nil {
            throw ExecutionError("mlmodel is not specified")
        }
        self.input = input
        self.mlmodel = mlmodel!
        self.shardID = shardID
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
        result.shardID = shardID
        for o in observations {
            let e = Candidate(identifier: o.identifier, confidence: o.confidence, shardID: shardID)
            result.candidates.append(e)
        }
        return result
    }
    
    class Result: Codable {
        
        var shardID: Int = 0
        var candidates: [Candidate] = []
    }
    
    class Candidate: Codable {
        
        let identifier: String
        let confidence: VNConfidence
        let shardID: Int
        
        init(identifier: String, confidence: VNConfidence, shardID: Int = 0) {
            self.identifier = identifier
            self.confidence = confidence
            self.shardID = shardID
        }
    }
}
