//

import Foundation
import Vision
import AppKit

@available(macOS 15.0, *)
struct RectangleDetector {
    let input: String

    init(input: String) {
        self.input = input
    }

    /**
     detectRectangles
     */
    func detectRectangles() async throws -> Result {
        
        if(!FileManager.default.fileExists(atPath: input)){
            throw ExecutionError("File not found. (\(input))")
        }
        
        var request = DetectRectanglesRequest()
        request.maximumObservations = 100
        request.minimumSize = 0.1
        request.minimumAspectRatio = 0.01
        request.maximumAspectRatio = 1

        let imageUrl = URL(fileURLWithPath: input)
        let ciImage = CIImage(contentsOf: imageUrl)!
        let cgImage = ciImage.toCGImage()!

        let rectangles = try await request.perform(on: cgImage)
        
        let result = Result()
        let sortedList = rectangles.sorted { $0.boundingBox.origin.x < $1.boundingBox.origin.x }
        for i in 0..<sortedList.count {
            let observation = sortedList[i]
            let rect = observation.boundingBox.toRect(cgImage: cgImage)
            rect.printInfo()
            result.rectangles.append(rect)
        }

        return result
    }

    class Result: Codable {
        
        var rectangles: [Rect] = []
    }

    /**
     detectRectanglesIncludingRect
     */
    func detectRectanglesIncludingRect(
        rectString: String
    ) async throws -> ResultWithRect {
        
        if(!FileManager.default.fileExists(atPath: input)){
            throw ExecutionError("File not found. (\(input))")
        }
        
        let rectangleResult = try await detectRectangles()

        let result = try ResultWithRect(rectString: rectString)
        result.baseRectangle = try Rect(rectString)
        
        for rect in rectangleResult.rectangles {
            if result.baseRectangle.isIncludedIn(rect) {
                result.rectangles.append(rect)
            }
        }

        result.rectangles.sort { $0.area < $1.area}
        return result
    }
    
    class ResultWithRect: Codable {
        var baseRectangle: Rect = Rect()
        var rectangles: [Rect] = []
        
        init(rectString: String) throws {
            
            baseRectangle = try Rect(rectString)
        }
    }
    
    /**
     detectRectanglesIncludingText
     */
    func detectRectanglesIncludingText(
        text: String,
        language: String?,
        customWordsFile: String?
    ) async throws -> ResultWithText {
        
        if(!FileManager.default.fileExists(atPath: input)){
            throw ExecutionError("File not found. (\(input))")
        }

        let rectangleResult = try await detectRectangles()
        let textResult = try await TextRecognizer(input: input, language: language, customWordsFile: customWordsFile).recognizeText()
        
        let result = ResultWithText(text: text, language: language)
        let firstCandidate = textResult.candidates.first { $0.text.lowercased().contains(text.lowercased()) }
        if firstCandidate == nil {
            return result
        }
        result.textRectangle = firstCandidate!.rect

        for rect in rectangleResult.rectangles {
            if result.textRectangle.isIncludedIn(rect) {
                result.rectangles.append(rect)
            }
        }

        result.rectangles.sort { $0.area < $1.area}
        return result
    }

    class ResultWithText: Codable {
        var text: String
        var language: String?
        var textRectangle: Rect = Rect()
        var rectangles: [Rect] = []
        
        init(text: String, language: String? = nil) {
            self.text = text
            self.language = language
        }
    }
  
}
    
