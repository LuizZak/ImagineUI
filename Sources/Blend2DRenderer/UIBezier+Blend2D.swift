import Geometry
import SwiftBlend2D

extension Collection where Element == UIBezier.Operation {
    func toBLPath() -> BLPath {
        let path = BLPath()
        var lastVertex: BLPoint?

        for op in self {
            switch op {
            case .moveTo(let point):
                path.moveTo(point.asBLPoint)
                lastVertex = point.asBLPoint

            case .lineTo(let point):
                path.lineTo(point.asBLPoint)
                lastVertex = point.asBLPoint

            case .arc(let end, let sweepAngle):
                guard let start = lastVertex else {
                    lastVertex = end.asBLPoint
                    continue
                }

                let arc = UICircleArc(
                    startPoint: start.asUIVector,
                    endPoint: end,
                    sweepAngle: sweepAngle
                )

                path.arcTo(
                    center: arc.center.asBLPoint,
                    radius: BLPoint(x: arc.radius, y: arc.radius),
                    start: arc.startAngle,
                    sweep: arc.sweepAngle,
                    forceMoveTo: false
                )

                lastVertex = end.asBLPoint

            case .quadTo(let end, let cp1):
                path.quadTo(end.asBLPoint, cp1.asBLPoint)
                lastVertex = end.asBLPoint

            case .cubicTo(let end, let cp1, let cp2):
                path.cubicTo(cp1.asBLPoint, cp2.asBLPoint, end.asBLPoint)
                lastVertex = end.asBLPoint
            }
        }

        return path
    }
}
