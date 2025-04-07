//

import Foundation
import Vapor


@available(macOS 15.0, *)
struct Controller {
    
    /**
     setupImageFeaturePrintConfig
     */
    static func setupImageFeaturePrintConfig(req: Request) async throws -> String {
        
        guard let project = req.query("project") else {
            throw ExecutionError("Parameter `project` not found.")
        }
        guard let inputDirectory = req.query("inputDirectory") else {
            throw ExecutionError("Parameter `inputDirectory` not found.")
        }
        
        let imageFeaturePrintConfigurator = ImageFeaturePrintConfigurator(project: project, inputDirectory: inputDirectory)
        let result = try await imageFeaturePrintConfigurator.setupImageFeaturePrintConfig()
        print("[imageFeaturePrintConfigurator] setup complete. \(result.message)")

        let jsonString = try result.toJsonString()
        return jsonString
    }

    /**
     classifyScreen
     */
    static func classifyScreen(req: Request) async throws -> String {

        guard let inputFile = req.query("inputFile") else {
            throw ExecutionError("Parameter `inputFile` not found.")
        }
        guard let mlmodel = req.query("mlmodel") else {
            throw ExecutionError("Parameter `mlmodel` not found.")
        }

        let screenClassifier = try ScreenClassifier(input: inputFile, mlmodel: mlmodel)
        
        let classifyResult = try screenClassifier.classifyScreen()
        
        let result = Result()
        result.baseImageFile = screenClassifier.input
        
        if classifyResult.candidates.isEmpty {
            return try! result.toJsonString()
        }

        for r in classifyResult.candidates {
            result.candidates.append(r)
        }
        result.candidates.sort { $0.confidence > $1.confidence }

        let jsonString = try result.toJsonString()
        return jsonString

        
        class Result: Encodable {
            var baseImageFile: String = ""
            var candidates: [ScreenClassifier.Candidate] = []
        }
    }
    
    /**
     recognizeText
     */
    static func recognizeText(req: Request) async throws -> String{
        
        guard let input = req.query("input") else {
            throw ExecutionError("Parameter `input` not found.")
        }
        guard let language = req.query("language") else {
            throw ExecutionError("Parameter `language` not found.")
        }
        try OCRLanguage.validateLanguage(language: language)
        
        let textRecognizer = TextRecognizer(input: input, language: language)
        let result = try await textRecognizer.recognizeText()
        
        let jsonString = try result.toJsonString()
        return jsonString
    }
    
    /**
     classifyImage
     */
    static func classifyImage(req: Request) async throws -> String {
      
        guard let input = req.query("input") else {
            throw ExecutionError("Parameter `input` not found.")
        }
        guard let mlmodel = req.query("mlmodel") else {
            throw ExecutionError("Parameter `mlmodel` not found.")
        }
        
        let imageClassifier = try ImageClassifier(input: input, mlmodel: mlmodel)
        let result = try imageClassifier.classifyImage()
        
        let jsonString = try result.toJsonString()
        return jsonString
    }
    
    /**
     detectRectangles
     */
    static func detectRectangles(req: Request) async throws -> String {
        
        guard let input = req.query("input") else {
            throw ExecutionError("Parameter `input` not found.")
        }
        
        let rectangleDetector = RectangleDetector(input: input)
        let result = try await rectangleDetector.detectRectangles()
        
        let jsonString = try result.toJsonString()
        return jsonString
    }
    
    /**
     detectRectanglesIncludingText
     */
    static func detectRectanglesIncludingRect(req: Request) async throws -> String {
        
        guard let input = req.query("input") else {
            throw ExecutionError("Parameter `input` not found.")
        }
        guard let rect = req.query("rect") else {
            throw ExecutionError("Parameter `rect` not found.")
        }
        
        let rectangleDetector = RectangleDetector(input: input)
        let result = try await rectangleDetector.detectRectanglesIncludingRect(rectString: rect)
        
        let jsonString = try result.toJsonString()
        return jsonString
    }
    
    /**
     detectRectanglesIncludingText
     */
    static func detectRectanglesIncludingText(req: Request) async throws -> String {

        guard let input = req.query("input") else {
            throw ExecutionError("Parameter `input` not found.")
        }
        guard let text = req.query("text") else {
            throw ExecutionError("Parameter `text` not found.")
        }
        guard let language = req.query("language") else {
            throw ExecutionError("Parameter `language` not found.")
        }
        try! OCRLanguage.validateLanguage(language: language)

        let rectangleDetector = RectangleDetector(input: input)
        let result = try await rectangleDetector.detectRectanglesIncludingText(text: text, language: language)
        
        let jsonString = try result.toJsonString()
        return jsonString
    }

    /**
     matchWithTemplate
     */
    static func matchWithTemplate(req: Request) async throws -> String {
        
        guard let template = req.query("template") else {
            throw ExecutionError("Parameter `template` not found.")
        }
        guard let inputDirectory = req.query("inputDirectory") else {
            throw ExecutionError("Parameter `inputDirectory` not found.")
        }
        
        let imageFeaturePrintMatcher = try ImageFeaturePrintMatcher(template: template, inputDirectory: inputDirectory)
        let result = try await imageFeaturePrintMatcher.matchWithTemplate()
        
        let jsonString = try result.toJsonString()
        
        return jsonString
    }

    /**
     getDistance
     */
    static func getDistance(req: Request) async throws -> String {

        guard let imageFile1 = req.query("imageFile1") else {
            throw ExecutionError("Parameter `imageFile1` not found.")
        }
        guard let imageFile2 = req.query("imageFile2") else {
            throw ExecutionError("Parameter `imageFile2` not found.")
        }

        let result = try await ImageFeaturePrintComparator()
            .getDistance(imageFile1: imageFile1, imageFile2: imageFile2)
        
        let jsonString = try result.toJsonString()
        
        return jsonString
    }
}
