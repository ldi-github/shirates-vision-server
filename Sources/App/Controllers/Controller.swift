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
     classifyScreenWithShard
     */
    static func classifyScreenWithShard(req: Request) async throws -> String {
        
        guard let inputFile = req.query("inputFile") else {
            throw ExecutionError("Parameter `inputFile` not found.")
        }
        guard let classifierDirectory = req.query("classifierDirectory") else {
            throw ExecutionError("Parameter `classifierDirectory` not found.")
        }
        guard let shardCount = req.query("shardCount") else {
            throw ExecutionError("Parameter `shardCount` not found.")
        }
        guard let shardCountInt = Int(shardCount) else {
            throw ExecutionError("Parameter `shardCount` must be an integer.")
        }
        
        let contents = try FileManager.default.contentsOfDirectory(atPath: classifierDirectory)

        let result = Result()

        for shardID in 1...shardCountInt {
            let mlmodel = classifierDirectory + "/\(shardID)/\(shardID).mlmodel"
            if(FileManager.default.fileExists(atPath: mlmodel) == false){
                continue
            }

            let screenClassifier = try ScreenClassifier(input: inputFile, mlmodel: mlmodel)
            
            let classifyResult = try screenClassifier.classifyScreen()
            
            var resultItem = ResultItem()
            result.items.append(resultItem)

            resultItem.baseImageFile = screenClassifier.input

            if classifyResult.candidates.isEmpty {
                resultItem.errorInfo = try! result.toJsonString()
            }

            for r in classifyResult.candidates {
                resultItem.candidates.append(r)
            }
            resultItem.candidates.sort { $0.confidence > $1.confidence }
        }
        
        let jsonString = try result.toJsonString()
        return jsonString

        class Result: Encodable {
            var items: [ResultItem] = []
        }
        
        class ResultItem: Encodable {
            var baseImageFile: String = ""
            var candidates: [ScreenClassifier.Candidate] = []
            var errorInfo: String = ""
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
     classifyImageWithShard
     */
    static func classifyImageWithShard(req: Request) async throws -> String {
        
        guard let input = req.query("input") else {
            throw ExecutionError("Parameter `input` not found.")
        }
        guard let classifierDirectory = req.query("classifierDirectory") else {
            throw ExecutionError("Parameter `classifierDirectory` not found.")
        }
        guard let shardCount = req.query("shardCount") else {
            throw ExecutionError("Parameter `shardCount` not found.")
        }
        guard let shardCountInt = Int(shardCount) else {
            throw ExecutionError("Parameter `shardCount` must be an integer.")
        }

        let contents = try FileManager.default.contentsOfDirectory(atPath: classifierDirectory)
        
        let result = Result()
        
        for shardID in 1...shardCountInt {
            let mlmodel = classifierDirectory + "/\(shardID)/\(shardID).mlmodel"
            
            let imageClassifier = try ImageClassifier(input: input, mlmodel: mlmodel)
            let resultItem = try imageClassifier.classifyImage()
            result.items.append(resultItem)
        }
        
        let jsonString = try result.toJsonString()
        return jsonString

        class Result: Encodable {
            var items: [ImageClassifier.Result] = []
        }
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
