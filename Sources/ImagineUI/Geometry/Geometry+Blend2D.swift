import SwiftBlend2D

public extension Vector2 {
    var asBLPoint: BLPoint {
        return BLPoint(x: x, y: y)
    }
}

public extension Line {
    var asBLLine: BLLine {
        return BLLine(x0: start.x, y0: start.y, x1: end.x, y1: end.y)
    }
}

public extension BLLine {
    var asLine: Line {
        return Line(x1: x0, y1: y0, x2: x1, y2: y1)
    }
}

public extension BLPoint {
    var asVector2: Vector2 {
        return Vector2(x: x, y: y)
    }
}

public extension Matrix2D {
    var asBLMatrix2D: BLMatrix2D {
        return BLMatrix2D(m00: m11, m01: m12, m10: m21, m11: m22, m20: m31, m21: m32)
    }
}

public extension Rectangle {
    var asBLRect: BLRect {
        return BLRect(x: x, y: y, w: width, h: height)
    }
}

public extension BLRect {
    var asRectangle: Rectangle {
        return Rectangle(x: x, y: y, width: w, height: h)
    }
}
