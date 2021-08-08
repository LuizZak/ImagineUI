import SwiftBlend2D
import Rendering

extension Color {
    var asBLRgba32: BLRgba32 {
        return BLRgba32(r: UInt32(red), g: UInt32(green), b: UInt32(blue), a: UInt32(alpha))
    }
}
