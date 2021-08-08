import SwiftBlend2D
import Rendering

extension Gradient {
    func toBLGradient() -> BLGradient {
        var gradient = BLGradient()
        
        gradient.extendMode = extendMode.asBLExtendMode
        gradient.matrix = matrix.asBLMatrix2D
        gradient.stops = stops.map(\.asBLGradientStop)
        gradient.gradientValues = type.asGradientValues
        
        return gradient
    }
}

extension Gradient.Stop {
    var asBLGradientStop: BLGradientStop {
        return BLGradientStop(offset: offset, rgba: color.asBLRgba32)
    }
}

extension Gradient.GradientType {
    var asGradientValues: BLGradient.GradientValues {
        switch self {
        case .linear(let values):
            return .linear(values.asBLLinearGradientValues)
        case .radial(let values):
            return .radial(values.asBLRadialGradientParameters)
        case .conical(let values):
            return .conical(values.asBLConicalGradientParameters)
        }
    }
}

extension Gradient.LinearGradientParameters {
    var asBLLinearGradientValues: BLLinearGradientValues {
        return BLLinearGradientValues(x0: bounds.left,
                                      y0: bounds.right,
                                      x1: bounds.right,
                                      y1: bounds.bottom)
    }
}

extension Gradient.RadialGradientParameters {
    var asBLRadialGradientParameters: BLRadialGradientValues {
        return BLRadialGradientValues(x0: bounds.left,
                                      y0: bounds.right,
                                      x1: bounds.right,
                                      y1: bounds.bottom,
                                      r0: radius)
    }
}

extension Gradient.ConicalGradientParameters {
    var asBLConicalGradientParameters: BLConicalGradientValues {
        return BLConicalGradientValues(x0: center.x,
                                       y0: center.y,
                                       angle: angle)
    }
}
