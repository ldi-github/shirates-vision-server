//

import Foundation
import Vision
import AppKit

@available(macOS 15.0, *)
struct TextRecognizer {
    let input: String
    let language: String?
    
    init(input: String, language: String? = nil) {
        self.input = input
        self.language = language
    }
    
    /**
     recognizeText
     */
    func recognizeText() async throws -> Result {
        
        if(!FileManager.default.fileExists(atPath: input)){
            throw ExecutionError("File not found. (\(input))")
        }
        
        var request = RecognizeTextRequest()

        if(language != nil) {
            request.recognitionLanguages[0] = Locale.Language(identifier: language!)
        }
        
        let image = getCGImage(path: input)
        
        let observations = try await request.perform(on: image)
        
        var counter = 0
        let saveDirectoryURL = FileManager.default.urls(
            for: .downloadsDirectory,
            in: .userDomainMask
        ).first!
        
        let debug = false
        if debug {
            print(saveDirectoryURL)
        }

        let result = Result(input: input, language: language)
        for r in observations {
            let rect = r.boundingBox.toRect(cgImage: image)
            let c = Candidate(text: r.text, rect: rect, confidence: r.confidence)
            result.candidates.append(c)

            if debug {
                let cropped = image.cropping(to: r.boundingBox.toCGRect(cgImage: image))!
                let fileName = rect.toFileName()
                counter+=1
                let saveURL = saveDirectoryURL.appendingPathComponent(fileName)
                do{
                    try cropped.saveToUrl(saveURL)
                } catch {
                    print("saveToUrl failed. \(saveURL), \(error)")
                }
            }
        }
        return result
    }
    
    class Result: Codable {
        let input: String
        let language: String?
        var candidates: [Candidate] = []
        
        init(input: String, language: String?) {
            self.input = input
            self.language = language
        }
    }

    class Candidate: Codable {
        let text: String
        let rect: Rect
        let confidence: Float
        
        init(text: String, rect: Rect, confidence: Float) {
            self.text = text
            self.rect = rect
            self.confidence = confidence
        }
    }
}
