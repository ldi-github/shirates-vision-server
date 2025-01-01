//

import Foundation

class Stopwatch {
    private var title: String
    private var startTime: DispatchTime?
    private var endTime: DispatchTime?
    
    init(_ title: String) {
        self.title = title
        
        start()
    }
    
    func start() {
        startTime = DispatchTime.now()
    }
    
    func stop() {
        endTime = DispatchTime.now()
    }
    
    func elapsedTime() -> Double? {
        guard let start = startTime, let end = endTime else {
            return nil
        }
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        return Double(nanoTime) / 1_000_000_000
    }
    
    func printInfo(_ message: String? = nil) {
        stop()
        let elapsedTime = elapsedTime()
        print("[\(title)] in \(elapsedTime ?? 0) sec \(message ?? "")")
    }
}
