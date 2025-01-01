//

import Foundation
import Vision

@available(macOS 15.0, *)
class ImageFeaturePrintInfo {

    let name: String
    let imageFile: String
    let cgImage: CGImage
    let featurePrint: FeaturePrintObservation

    var lastMatchedImageFeaturePrintInfo: ImageFeaturePrintInfo? = nil
    var textObservations: [RecognizedTextObservation] = []
    var distance: Double = Double.infinity
    var matchedTexts: [String] = []
    var allTexts: [String] = []
    var textDistance: Double = 0.0
    
    var texts: [String] {
        return textObservations.map { $0.text }
    }
    
    var matchedTextsJoinedLength: Int {
        return matchedTexts.joined().count
    }
    
    var allTextsJoinedLength: Int {
        return allTexts.joined().count
    }
    
    init (
        name: String,
        imageFile: String,
        featurePrint: FeaturePrintObservation
    ){
        self.name = name
        self.imageFile = imageFile
        self.featurePrint = featurePrint
        self.cgImage = getCGImage(path: imageFile)
    }

    func getTextObservations(language: String? = nil) async throws {

        if(textObservations.isEmpty == false){
            return
        }

        var request = RecognizeTextRequest()
        if(language != nil){
            request.recognitionLanguages[0] = Locale.Language(identifier: language!)
        }
        textObservations = try await request.perform(on: cgImage)
        allTexts = textObservations.map{ $0.text }
    }

    func matchTexts(imageFeaturePrintInfo: ImageFeaturePrintInfo, language: String?) async throws {

        if(imageFeaturePrintInfo.imageFile == lastMatchedImageFeaturePrintInfo?.imageFile) {
            return
        }
        
        matchedTexts.removeAll()
        
        if textObservations.isEmpty || imageFeaturePrintInfo.textObservations.isEmpty {
            try await getTextObservations(language: language)
        }
        
        let thisTexts = texts
        for text in thisTexts {
            let targetTexts = imageFeaturePrintInfo.texts
            for t in targetTexts {
                if text == t {
                    matchedTexts.append(text)
                }
            }
        }
    }
    
    func updateDistance(targetFeaturePrintInfo: ImageFeaturePrintInfo) throws {
        distance = try featurePrint.distance(to: targetFeaturePrintInfo.featurePrint)
    }
    
    func refresh() {
        let length = allTextsJoinedLength
        if(length > 0) {
            textDistance = 1.0 - Double(matchedTextsJoinedLength) / Double(length)
        } else {
            textDistance = 1.0
        }
    }

}
