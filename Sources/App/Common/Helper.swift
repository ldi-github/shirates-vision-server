//

import Foundation
import AppKit
import Vapor
import Vision

func getCGImage(path: String) -> CGImage {
    
    let imageUrl = URL(fileURLWithPath: path)
    let image = CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(imageUrl as CFURL, nil)!,0, nil)!
    return image
}

func getJson(list: [String]) -> String {
    
    let json = """
[
\(list.joined(separator: ",\n"))
]
"""
    return json
}

extension String {
    func name() -> String {
        return (self as NSString).deletingPathExtension.components(separatedBy: "/").last ?? ""
    }
}

extension Request {
    
    func query(_ name: String) -> String? {
        return self.query[String.self, at: name]
    }
}

@available(macOS 15.0, *)
extension NormalizedRect {
    
    func toRect(cgImage: CGImage) -> Rect {
        
        let cgRect = self.toCGRect(cgImage: cgImage)
        return Rect(cgRect)
    }
    
    func toRect(size: CGSize) -> Rect {
        
        let cgRect = self.toCGRect(size: size)
        return Rect(cgRect)
    }
    
    func toCGRect(cgImage: CGImage) -> CGRect {
        
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        return toCGRect(size: size)
    }
    
    func toCGRect(size: CGSize) -> CGRect {

        let bounds = self.toImageCoordinates(size, origin: .upperLeft)
        return bounds
    }
}

@available(macOS 15.0, *)
extension RecognizedTextObservation {

    var candidate: RecognizedText {
        
        return self.topCandidates(1).first!
    }
    
    var text: String {
        
        return candidate.string
    }
}

extension Encodable {
    
    func toJsonString() throws -> String {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let jsonData = try encoder.encode(self)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        return jsonString
    }
}
