import Foundation
import Geometry

extension NSRect {
    var asUIRectangle: UIRectangle {
        return UIRectangle(x: Double(origin.x), y: Double(origin.y), width: Double(width), height: Double(height))
    }
}
