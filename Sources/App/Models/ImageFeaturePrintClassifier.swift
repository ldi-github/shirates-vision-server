//

import Foundation
import Vision
import AppKit

@available(macOS 15.0, *)
struct ImageFeaturePrintClassifier {

    /**
     getImageFeaturePrintDistances
     */
    func getImageFeaturePrintDistances(project: String, baseFeaturePrintInfo: ImageFeaturePrintInfo) async throws -> [ImageFeaturePrintInfo] {

        let repo = ImageFeaturePrintRepositoryContainer.getRepository(project: project)
        var list = repo.getImageFeaturePrintInfoList()
        for info in list {
            try info.updateDistance(targetFeaturePrintInfo: baseFeaturePrintInfo)
        }
        list.sort(by: { $0.distance < $1.distance})
        return list
    }

    class ClassiryResult {
        
        let textMatchingRequiredDiffThreshold: Double = 0.05
        var withTextMatching: Bool = false
        
        var baseFeaturePrintInfo: ImageFeaturePrintInfo
        var candidates: [ImageFeaturePrintInfo] = []
        
        var first: ImageFeaturePrintInfo? {
            if candidates.isEmpty { return nil }
            return candidates[0]
        }
        
        var second: ImageFeaturePrintInfo? {
            if candidates.count < 2 { return nil }
            return candidates[1]
        }
        
        var diffBetweenFirstAndSecond: Double {
            if second == nil { return Double.nan }
            return abs(second!.distance - first!.distance)
        }
        
        var isTextMatchingRequired: Bool {
            return textMatchingRequiredDiffThreshold > diffBetweenFirstAndSecond
        }
        
        init(_ baseFeaturePrintInfo: ImageFeaturePrintInfo) {
            self.baseFeaturePrintInfo = baseFeaturePrintInfo
        }
        
        func sortCandidatesByDistance() {
            if(withTextMatching){
                candidates.sort(by: { $0.textDistance < $1.textDistance })
            } else {
                candidates.sort(by: { $0.distance < $1.distance })
            }
        }
    }
    
    /**
     classify
     */
    func classify(project: String, inputFile: String, withTextMatching: Bool = false, language: String?) async throws -> ClassiryResult {

        let maxCandidatesCount = 3
        
        let sw = Stopwatch("baseFeaturePrintInfo")
        let baseFeaturePrintInfo = try await getImageFeaturePrintInfo(file: inputFile)
        sw.printInfo()

        let classifyResult = ClassiryResult(baseFeaturePrintInfo)
        classifyResult.candidates = try await getImageFeaturePrintDistances(
            project: project,
            baseFeaturePrintInfo: baseFeaturePrintInfo)
        if(classifyResult.candidates.count < 2) {
            return ClassiryResult(baseFeaturePrintInfo)
        }

        classifyResult.withTextMatching = withTextMatching || classifyResult.isTextMatchingRequired

        if(classifyResult.withTextMatching) {
            print("maxCandidatesCount: \(maxCandidatesCount)")
            if(classifyResult.candidates.count >= maxCandidatesCount) {
                classifyResult.candidates = classifyResult.candidates.prefix(upTo: maxCandidatesCount).map { $0 }
            }
            try await baseFeaturePrintInfo.getTextObservations(language: language)

            for imageFeaturePrintInfo in classifyResult.candidates {
                try await imageFeaturePrintInfo.matchTexts(imageFeaturePrintInfo: baseFeaturePrintInfo, language: language)
                imageFeaturePrintInfo.refresh()
            }
        }
        classifyResult.sortCandidatesByDistance()
        if(classifyResult.candidates.count > 1) {
            print("diff: \(classifyResult.diffBetweenFirstAndSecond) fisrt: \(classifyResult.first!.distance) second: \(classifyResult.second!.distance)")
        }
        
        return classifyResult
    }
    
    private func getImageFeaturePrintInfo(file: String) async throws -> ImageFeaturePrintInfo {
        
        let imageUrl = URL(fileURLWithPath: file)
        let ciImage = CIImage(contentsOf: imageUrl)!
        let cgImage = ciImage.toCGImage()!
        let request = GenerateImageFeaturePrintRequest()
        let observation = try await request.perform(on: cgImage)
        
        let name = file.name()
        let result = ImageFeaturePrintInfo(
            name : name,
            imageFile : file,
            featurePrint : observation
        )
        return result
    }

}
    
