//

import Foundation

struct Rect: Codable, CustomStringConvertible {
    
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    init () {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
    }
    
    init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(_ rectString: String) throws {
        
        let array = rectString
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "x:", with: "")
            .replacingOccurrences(of: "y:", with: "")
            .replacingOccurrences(of: "width:", with: "")
            .replacingOccurrences(of: "height:", with: "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        if array.count != 4 {
            throw ExecutionError("Invalid rect string. `(\(rectString)`)")
        }
        self.x = Int(array[0])!
        self.y = Int(array[1])!
        self.width = Int(array[2])!
        self.height = Int(array[3])!
    }
    
    init(_ cgRect: CGRect) {
        self.x = Int(cgRect.origin.x)
        self.y = Int(cgRect.origin.y)
        self.width = Int(cgRect.size.width)
        self.height = Int(cgRect.size.height)
    }

    var description: String {
        return "x:\(x), y:\(y), width:\(width), height:\(height)"
    }
    
    func toFileName() -> String {
        
        return "[\(x),\(y),\(width),\(height)]"
    }
    
    func toCGRect() -> CGRect {

        return CGRect(x: Double(x), y: Double(y), width: Double(width), height: Double(height))
    }

    func printInfo() {
        
        print(description)
    }

    var x2: Int {
        return x + width - 1
    }
    
    var y2: Int {
        return y + height - 1
    }
    
    var centerX: Int {
        return x + width / 2
    }
    
    var centerY: Int {
        return y + height / 2
    }
    
    var left: Int {
        return x
    }
    
    var top: Int {
        return y
    }
    
    var right: Int {
        return x + width - 1
    }
    
    var bottom: Int {
        return y + height - 1
    }
    
    var area : Int {
        return width * height
    }
    
    /**
     * isCenterXIncludedIn
     */
    func isCenterXIncludedIn(_ rect: Rect) -> Bool {
        
        if (self.centerX < rect.x) {
            return false
        }
        if (self.centerX > self.x) {
            return false
        }
        
        return true
    }
    
    /**
     * isCenterYIncludedIn
     */
    func isCenterYIncludedIn(_ rect: Rect) -> Bool {
        
        if (self.centerY < rect.y) {
            return false
        }
        if (self.centerY > rect.y) {
            return false
        }
        
        return true
    }
    
    /**
     * isCenterIncludedIn
     */
    func isCenterIncludedIn(_ rect: Rect) -> Bool {
        
        return isCenterXIncludedIn(rect) && isCenterYIncludedIn(rect)
    }
    
    /**
     * includesPoint
     */
    func includesPoint(x: Int, y: Int) -> Bool {
        
        return (self.x <= x && x <= self.x2 && self.y <= y && y <= self.y2)
    }
    
    /**
     * isLeftIncludedIn
     */
    func isLeftIncludedIn(_ rect: Rect) -> Bool {
        
        return (rect.left <= self.left && self.left <= rect.right)
    }
    
    /**
     * isRightIncludedIn
     */
    func isRightIncludedIn(_ rect: Rect) -> Bool {
        
        return (rect.left <= self.right && self.right <= rect.right)
    }
    
    /**
     * isTopIncludedIn
     */
    func isTopIncludedIn(_ rect: Rect) -> Bool {
        
        return (rect.top <= self.top && self.top <= rect.bottom)
    }
    
    /**
     * isBottomIncludedIn
     */
    func isBottomIncludedIn(_ rect: Rect) -> Bool {
        
        return (rect.top <= self.bottom && self.bottom <= rect.bottom)
    }
    
    /**
     * isIncludedIn
     */
    func isIncludedIn(_ rect: Rect) -> Bool {
        
        return isLeftIncludedIn(rect) &&
        isTopIncludedIn(rect) &&
        isRightIncludedIn(rect) &&
        isBottomIncludedIn(rect)
    }
    
    /**
     * isAlmostIncludedIn
     */
    func isAlmostIncludedIn(_ rect: Rect, margin: Int = 5) -> Bool {
        
        let relaxedRect = Rect(
            x : rect.left - margin,
            y : rect.top - margin,
            width : rect.width + margin * 2,
            height : rect.height + margin * 2
        )
        return isLeftIncludedIn(relaxedRect) &&
        isTopIncludedIn(relaxedRect) &&
        isRightIncludedIn(relaxedRect) &&
        isBottomIncludedIn(relaxedRect)
    }
    
    /**
     * isSeparatedFrom
     */
    func isSeparatedFrom(_ rect: Rect) -> Bool {
        
        if (rect.right < self.left) {
            return true
        }
        if (rect.bottom < self.top) {
            return true
        }
        if (self.right < rect.left) {
            return true
        }
        if (self.bottom < rect.top) {
            return true
        }
        return false
    }
    
    /**
     * isOverlapping
     */
    func isOverlapping(rect: Rect) -> Bool {
        
        return !isSeparatedFrom(rect)
    }
    
    /**
     * offsetRect
     */
    func offsetRect(offsetX: Int = 0, offsetY: Int = 0) -> Rect {
        
        let newRect = Rect(
            x : left + offsetX,
            y : top + offsetY,
            width : width,
            height : height
        )
        return newRect
    }

}
