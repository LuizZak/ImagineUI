import Geometry
import SwiftBlend2D

extension Vector2 {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
}

extension Line {
    var asBLLine: BLLine {
        return BLLine(x0: start.x, y0: start.y, x1: end.x, y1: end.y)
    }
}

extension BLLine {
    var asLine: Line {
        return Line(x1: x0, y1: y0, x2: x1, y2: y1)
    }
}

extension BLPoint {
    var asVector2: Vector2 {
        return Vector2(x: x, y: y)
    }
}

extension Matrix2D {
    var asBLMatrix2D: BLMatrix2D {
        return BLMatrix2D(m00: m11, m01: m12, m10: m21, m11: m22, m20: m31, m21: m32)
    }
}

extension Rectangle {
    var asBLRect: BLRect {
        return BLRect(x: x, y: y, w: width, h: height)
    }
}

extension BLRect {
    var asRectangle: Rectangle {
        return Rectangle(x: x, y: y, width: w, height: h)
    }
}

extension BLRoundRect {
    var asRoundRectangle: RoundRectangle {
        return RoundRectangle(bounds: Rectangle(x: x, y: y, width: w, height: h), radiusX: rx, radiusY: ry)
    }
}

extension RoundRectangle {
    var asBLRoundRect: BLRoundRect {
        return BLRoundRect(rect: bounds.asBLRect, radius: BLPoint(x: radiusX, y: radiusX))
    }
}

extension BLCircle {
    var asCircle: Circle {
        return Circle(center: center.asVector2, radius: r)
    }
}

extension Circle {
    var asBLCircle: BLCircle {
        return BLCircle(center: center.asBLPoint, radius: radius)
    }
}

extension BLEllipse {
    var asEllipse: Ellipse {
        return Ellipse(center: Vector2(x: cx, y: cy), radiusX: rx, radiusY: ry)
    }
}

extension Ellipse {
    var asBLEllipse: BLEllipse {
        return BLEllipse(center: center.asBLPoint, radius: BLPoint(x: radiusX, y: radiusY))
    }
}

extension EdgeInsets {
    func inset(rectangle: BLRect) -> BLRect {
        return BLRect(x: rectangle.x + left,
                      y: rectangle.y + top,
                      w: rectangle.w - left - right,
                      h: rectangle.h - top - bottom)
    }
}
