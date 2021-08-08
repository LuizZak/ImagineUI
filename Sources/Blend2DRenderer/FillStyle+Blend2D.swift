import SwiftBlend2D
import Rendering

extension FillStyle {
    func setStyle(in context: BLContext) {
        switch brush {
        case .solid(let color):
            context.setFillStyle(color.asBLRgba32)
            
        case .gradient(let gradient):
            context.setFillStyle(gradient.toBLGradient())
        }
    }
}
