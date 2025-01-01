import Foundation
import AppKit

public extension CIImage {
    
    /**
     toCGImage
     */
    func toCGImage() -> CGImage? {
        let context = { CIContext(options: nil)}()
        return context.createCGImage(self, from: self.extent)
    }
    
}
