import Geometry
import SwiftBlend2D

public extension UILine {
    var asBLLine: BLLine {
        return BLLine(start: start.asBLPoint, end: end.asBLPoint)
    }
}

public extension BLLine {
    var asLine: UILine {
        return UILine(x1: x0, y1: y0, x2: x1, y2: y1)
    }
}

public extension BLPoint {
    var asUIVector: UIVector {
        return UIVector(x: x, y: y)
    }
}

public extension UIVector {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
}

public extension BLPointI {
    var asIntPoint: UIIntPoint {
        return UIIntPoint(x: Int(x), y: Int(y))
    }
}

public extension UIIntPoint {
    var asBLPointI: BLPointI {
        return BLPointI(x: Int32(x), y: Int32(y))
    }
}

public extension UIMatrix {
    var asBLMatrix2D: BLMatrix2D {
        return BLMatrix2D(m00: m11, m01: m12, m10: m21, m11: m22, m20: m31, m21: m32)
    }
}

public extension UIRectangle {
    var asBLRect: BLRect {
        return BLRect(x: x, y: y, w: width, h: height)
    }
}

public extension BLRect {
    var asRectangle: UIRectangle {
        return UIRectangle(x: x, y: y, width: w, height: h)
    }
}

public extension BLBox {
    var asRectangle: UIRectangle {
        return UIRectangle(x: x0, y: y0, width: w, height: h)
    }
}

public extension BLRectI {
    var asRectangle: UIRectangle {
        return UIRectangle(x: Double(x), y: Double(y), width: Double(w), height: Double(h))
    }
}

public extension BLBoxI {
    var asRectangle: UIRectangle {
        return UIRectangle(x: Double(x0), y: Double(y0), width: Double(w), height: Double(h))
    }
}

public extension BLRoundRect {
    var asRoundRectangle: UIRoundRectangle {
        return UIRoundRectangle(rectangle: UIRectangle(x: x, y: y, width: w, height: h), radiusX: rx, radiusY: ry)
    }
}

public extension UIRoundRectangle {
    var asBLRoundRect: BLRoundRect {
        return BLRoundRect(rect: rectangle.asBLRect, radius: BLPoint(x: radius.x, y: radius.y))
    }
}

public extension BLCircle {
    var asCircle: UICircle {
        return UICircle(center: center.asUIVector, radius: r)
    }
}

public extension UICircle {
    var asBLCircle: BLCircle {
        return BLCircle(center: center.asBLPoint, radius: radius)
    }
}

public extension BLEllipse {
    var asEllipse: UIEllipse {
        return UIEllipse(center: UIVector(x: cx, y: cy), radiusX: rx, radiusY: ry)
    }
}

public extension UIEllipse {
    var asBLEllipse: BLEllipse {
        return BLEllipse(center: center.asBLPoint, radius: BLPoint(x: radiusX, y: radiusY))
    }
}

public extension UITriangle {
    var asBLTriangle: BLTriangle {
        .init(p0: p0.asBLPoint, p1: p1.asBLPoint, p2: p2.asBLPoint)
    }
}

public extension UICircleArc {
    var asBLArc: BLArc {
        ellipseArc.asBLArc
    }
}

public extension UIEllipseArc {
    var asBLArc: BLArc {
        .init(
            center: center.asBLPoint,
            radius: radius.asBLPoint,
            start: startAngle,
            sweep: sweepAngle
        )
    }
}

public extension UIEdgeInsets {
    func inset(rectangle: BLRect) -> BLRect {
        return BLRect(x: rectangle.x + left,
                      y: rectangle.y + top,
                      w: rectangle.w - left - right,
                      h: rectangle.h - top - bottom)
    }
}
