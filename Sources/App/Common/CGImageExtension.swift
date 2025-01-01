//

import Foundation
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

extension CGImage {
    
    func saveToFile(_ filePath: String) throws {

        let url = URL(fileURLWithPath: filePath)
        
        return try saveToUrl(url)
    }
    
    func saveToUrl(_ url: URL) throws {
    
        let cgImage = self
        let type = UTType.png.identifier as CFString
        
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
            throw ExecutionError("Could not create CGImageDestination")
        }
        CGImageDestinationAddImage(dest, cgImage, nil)
        CGImageDestinationFinalize(dest)
    }
    
}
