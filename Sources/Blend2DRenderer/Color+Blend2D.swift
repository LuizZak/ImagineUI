import SwiftBlend2D
import Rendering

extension Color {
    public var asBLRgba32: BLRgba32 {
        return BLRgba32(r: UInt32(red), g: UInt32(green), b: UInt32(blue), a: UInt32(alpha))
    }
}

extension BLRgba32 {
    public var asColor: Color {
        return Color(alpha: Int(a), red: Int(r), green: Int(g), blue: Int(b))
    }
}
