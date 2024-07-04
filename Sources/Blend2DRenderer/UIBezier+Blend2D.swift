import Geometry
import SwiftBlend2D

extension UIBezier.DrawOperation {
    func apply(to path: BLPath) {
        switch self {
        case .line(let start, let end):
            path.addLine(.init(start: start.asBLPoint, end: end.asBLPoint))

        case .arc(let arc):
            path.addArc(arc.asBLArc)

        case .quadBezier(let bezier):
            let points = bezier.points

            path.moveTo(points[0].asBLPoint)
            path.quadTo(points[1].asBLPoint, points[2].asBLPoint)

        case .cubicBezier(let bezier):
            let points = bezier.points

            path.moveTo(points[0].asBLPoint)
            path.cubicTo(points[1].asBLPoint, points[2].asBLPoint, points[3].asBLPoint)
        }
    }
}

extension Collection where Element == UIBezier.DrawOperation {
    func toBLPath() -> BLPath {
        let path = BLPath()
        var lastVertex: UIPoint?

        for op in self {
            switch op {
            case .line(let start, let end):
                path.addLine(.init(start: start.asBLPoint, end: end.asBLPoint))

                lastVertex = end

            case .arc(let arc):
                path.addArc(arc.asBLArc)

                lastVertex = arc.endPoint

            case .quadBezier(let bezier):
                let points = bezier.points

                if points[0] != lastVertex {
                    path.moveTo(points[0].asBLPoint)
                }
                path.quadTo(points[1].asBLPoint, points[2].asBLPoint)

                lastVertex = bezier.lastPoint

            case .cubicBezier(let bezier):
                let points = bezier.points

                if points[0] != lastVertex {
                    path.moveTo(points[0].asBLPoint)
                }
                path.cubicTo(points[1].asBLPoint, points[2].asBLPoint, points[3].asBLPoint)

                lastVertex = bezier.lastPoint
            }
        }

        return path
    }
}
