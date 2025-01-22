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
     classifyWithImageFeaturePrintOrText
     */
    static func classifyWithImageFeaturePrintOrText(req: Request) async throws -> String {
        
        guard let project = req.query("project") else {
            throw ExecutionError("Parameter `project` not found.")
        }
        guard let inputFile = req.query("inputFile") else {
            throw ExecutionError("Parameter `inputFile` not found.")
        }
        guard let language = req.query("language") else {
            throw ExecutionError("Parameter `language` not found.")
        }
        try! OCRLanguage.validateLanguage(language: language)
        
        let withTextMatching = Bool(req.query("withTextMatching") ?? "") ?? false
        
        let imageFeaturePrintClassifier = ImageFeaturePrintClassifier()

        let classifyResult =
            try await imageFeaturePrintClassifier.classify(
                project: project,
                inputFile: inputFile,
                withTextMatching: withTextMatching,
                language: language)

        let result = Result()
        result.baseImageFile = classifyResult.baseFeaturePrintInfo.imageFile
        result.diffBetweenFirstAndSecond = classifyResult.diffBetweenFirstAndSecond
        result.textMatchingRequiredDiffThreshold = classifyResult.textMatchingRequiredDiffThreshold
        result.withTextMatching = classifyResult.withTextMatching

        if classifyResult.candidates.isEmpty {
            return try! result.toJsonString()
        }

        for r in classifyResult.candidates {
            let allTextsJoinedLength = r.allTextsJoinedLength
            if allTextsJoinedLength > 0 {
                r.textDistance = Double(r.matchedTextsJoinedLength) / Double(allTextsJoinedLength)
            }
            r.refresh()
        }
        classifyResult.sortCandidatesByDistance()
        
        class Candidate: Encodable {
            var distance: Double = Double.greatestFiniteMagnitude
            var matchedTexts: [String]? = nil
            var allTexts: [String]? = nil
            var name: String = ""
            var imageFile: String = ""
            var textDistance: Double? = nil
            var matchedTextJoinedLength: Int? = nil
            var allTextJoinedLength: Int? = nil
        }
        class Result: Encodable {
            var baseImageFile: String = ""
            var candidates: [Candidate] = []
            var firstDistance: Double = Double.greatestFiniteMagnitude
            var secondDistance: Double = Double.greatestFiniteMagnitude
            var diffBetweenFirstAndSecond: Double = Double.greatestFiniteMagnitude
            var textMatchingRequiredDiffThreshold:Double = Double.greatestFiniteMagnitude
            var withTextMatching: Bool = false
        }

        for r in classifyResult.candidates {
            let e = Candidate()
            e.distance = r.distance
            e.name = r.name
            e.imageFile = r.imageFile
            if(classifyResult.withTextMatching) {
                e.textDistance = r.textDistance
                e.matchedTexts = r.matchedTexts
                e.allTexts = r.allTexts
                e.matchedTextJoinedLength = r.matchedTextsJoinedLength
                e.allTextJoinedLength = r.allTextsJoinedLength
            }
            result.candidates.append(e)
        }
        if(result.candidates.count > 0) {
            result.firstDistance = result.candidates[0].distance
        }
        if(result.candidates.count > 1) {
            result.secondDistance = result.candidates[1].distance
        }
        result.diffBetweenFirstAndSecond = abs(result.firstDistance - result.secondDistance)

        let jsonString = try result.toJsonString()
        return jsonString
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

}
