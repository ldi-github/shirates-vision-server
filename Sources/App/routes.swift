import Vapor

@available(macOS 15.0, *)
func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("ImageFeaturePrintConfigurator","setupImageFeaturePrintConfig") { req async throws -> String in

        let sw = Stopwatch("ImageFeaturePrintConfigurator/setupImageFeaturePrintConfig")
        let result = try await Controller.setupImageFeaturePrintConfig(req: req)
        sw.printInfo()
        return result
    }

    app.get("ImageFeaturePrintClassifier","classifyWithImageFeaturePrintOrText") { req async throws -> String in
        
        let sw = Stopwatch("ImageFeaturePrintClassifier/classifyWithImageFeaturePrintOrText")
        let result = try await Controller.classifyWithImageFeaturePrintOrText(req: req)
        sw.printInfo()
        return result
    }

    app.get("TextRecognizer","recognizeText") { req async throws -> String in
        
        let sw = Stopwatch("TextRecognizer/recognizeText")
        let result = try await Controller.recognizeText(req: req)
        sw.printInfo()
        return result
    }
    
    app.get("ImageClassifier","classifyImage") { req async throws -> String in

        let sw = Stopwatch("ImageClassifier/classifyImage")
        let result = try await Controller.classifyImage(req: req)
        sw.printInfo()
        return result
    }
    
    app.get("ImageFeaturePrintMatcher","matchWithTemplate") { req async throws -> String in

        let sw = Stopwatch("ImageFeaturePrintMatcher/matchWithTemplate")
        let result = try await Controller.matchWithTemplate(req: req)
        sw.printInfo()
        return result
    }

    app.get("RectangleDetector","detectRectangles") { req async throws -> String in
        
        let sw = Stopwatch("RectangleDetector/detectRectangles")
        let result = try await Controller.detectRectangles(req: req)
        sw.printInfo()
        return result
    }

    app.get("RectangleDetector","detectRectanglesIncludingRect") { req async throws -> String in
        
        let sw = Stopwatch("RectangleDetector/detectRectanglesIncludingRect")
        let result = try await Controller.detectRectanglesIncludingRect(req: req)
        sw.printInfo()
        return result
    }

    app.get("RectangleDetector","detectRectanglesIncludingText") { req async throws -> String in
        
        let sw = Stopwatch("RectangleDetector/detectRectanglesIncludingText")
        let result = try await Controller.detectRectanglesIncludingText(req: req)
        sw.printInfo()
        return result
    }

//    app.get("YOLO") { req async throws -> String in
//        
//        return try await Controller.yolo(req: req)
//    }
}
