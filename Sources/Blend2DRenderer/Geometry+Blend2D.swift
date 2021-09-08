import Geometry
import SwiftBlend2D

extension UILine {
    var asBLLine: BLLine {
        return BLLine(start: start.asBLPoint, end: end.asBLPoint)
    }
}

extension BLLine {
    var asLine: UILine {
        return UILine(x1: x0, y1: y0, x2: x1, y2: y1)
    }
}

extension BLPoint {
    var asVector2: UIVector {
        return UIVector(x: x, y: y)
    }
}

extension UIVector {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
}

extension BLPointI {
    var asIntPoint: UIIntPoint {
        return UIIntPoint(x: Int(x), y: Int(y))
    }
}

extension UIIntPoint {
    var asBLPointI: BLPointI {
        return BLPointI(x: Int32(x), y: Int32(y))
    }
}

extension UIMatrix {
    var asBLMatrix2D: BLMatrix2D {
        return BLMatrix2D(m00: m11, m01: m12, m10: m21, m11: m22, m20: m31, m21: m32)
    }
}

extension UIRectangle {
    var asBLRect: BLRect {
        return BLRect(x: x, y: y, w: width, h: height)
    }
}

extension BLRect {
    var asRectangle: UIRectangle {
        return UIRectangle(x: x, y: y, width: w, height: h)
    }
}

extension BLBox {
    var asRectangle: UIRectangle {
        return UIRectangle(x: x0, y: y0, width: w, height: h)
    }
}

extension BLRectI {
    var asRectangle: UIRectangle {
        return UIRectangle(x: Double(x), y: Double(y), width: Double(w), height: Double(h))
    }
}

extension BLBoxI {
    var asRectangle: UIRectangle {
        return UIRectangle(x: Double(x0), y: Double(y0), width: Double(w), height: Double(h))
    }
}

extension BLRoundRect {
    var asRoundRectangle: UIRoundRectangle {
        return UIRoundRectangle(rectangle: UIRectangle(x: x, y: y, width: w, height: h), radiusX: rx, radiusY: ry)
    }
}

extension UIRoundRectangle {
    var asBLRoundRect: BLRoundRect {
        return BLRoundRect(rect: rectangle.asBLRect, radius: BLPoint(x: radius.x, y: radius.y))
    }
}

extension BLCircle {
    var asCircle: UICircle {
        return UICircle(center: center.asVector2, radius: r)
    }
}

extension UICircle {
    var asBLCircle: BLCircle {
        return BLCircle(center: center.asBLPoint, radius: radius)
    }
}

extension BLEllipse {
    var asEllipse: UIEllipse {
        return UIEllipse(center: UIVector(x: cx, y: cy), radiusX: rx, radiusY: ry)
    }
}

extension UIEllipse {
    var asBLEllipse: BLEllipse {
        return BLEllipse(center: center.asBLPoint, radius: BLPoint(x: radiusX, y: radiusY))
    }
}

extension UIEdgeInsets {
    func inset(rectangle: BLRect) -> BLRect {
        return BLRect(x: rectangle.x + left,
                      y: rectangle.y + top,
                      w: rectangle.w - left - right,
                      h: rectangle.h - top - bottom)
    }
}
