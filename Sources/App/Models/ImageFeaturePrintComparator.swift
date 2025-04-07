//

import Foundation

@available(macOS 15.0, *)
struct ImageFeaturePrintComparator {

    /**
     getDistance
     */
    func getDistance(imageFile1: String, imageFile2: String) async throws -> Result {
        
        if(!FileManager.default.fileExists(atPath: imageFile1)){
            throw ExecutionError("imageFile1 not found. (\(imageFile1))")
        }
        if(!FileManager.default.fileExists(atPath: imageFile2)){
            throw ExecutionError("imageFile2 not found. (\(imageFile2))")
        }

        let fpObservation1 = try await ImageFeaturePrintMatcher.getFeaturePrintObservation(file: imageFile1)
        let fpObservation2 = try await ImageFeaturePrintMatcher.getFeaturePrintObservation(file: imageFile2)
        let distance = try fpObservation1.distance(to: fpObservation2)

        let result = Result(distance: distance, file1: imageFile1, file2: imageFile2)
        return result
    }
    
    class Result: Codable {
        
        let distance: Double
        let imageFile1: String
        let imageFile2: String
    
        init(distance: Double, file1: String, file2: String) {
            self.distance = distance
            self.imageFile1 = file1
            self.imageFile2 = file2
        }
    }
    
}
