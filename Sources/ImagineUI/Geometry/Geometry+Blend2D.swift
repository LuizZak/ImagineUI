#if false

import Geometry

public extension UIVector {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
}

public extension UILine {
    var asBLLine: BLLine {
        return BLLine(x0: start.x, y0: start.y, x1: end.x, y1: end.y)
    }
}

public extension BLLine {
    var asLine: UILine {
        return UILine(x1: x0, y1: y0, x2: x1, y2: y1)
    }
}

public extension BLPoint {
    var asVector2: UIVector {
        return UIVector(x: x, y: y)
    }
}

public extension BLPointI {
    var asVector2: UIVector {
        return UIVector(x: Double(x), y: Double(y))
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

public extension UIEdgeInsets {
    func inset(rectangle: BLRect) -> BLRect {
        return BLRect(x: rectangle.x + left,
                      y: rectangle.y + top,
                      w: rectangle.w - left - right,
                      h: rectangle.h - top - bottom)
    }
}

#endif
