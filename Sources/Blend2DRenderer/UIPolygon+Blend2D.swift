import Geometry
import SwiftBlend2D
import Rendering

extension UIPolygon {
    func asBLPath() -> BLPath {
        let path = BLPath()
        
        path.addPolygon(vertices.map(\.asBLPoint))
        
        return path
    }
}
