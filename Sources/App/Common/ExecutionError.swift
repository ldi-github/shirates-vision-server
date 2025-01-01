import Foundation

struct ExecutionError: Error, CustomStringConvertible {
    var description: String
    var error: Error?
    
    init(_ description: String, error : Error? = nil) {
        self.description = description
        self.error = error
    }
}
