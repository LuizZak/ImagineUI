import SwiftBlend2D
import Rendering

extension StrokeStyle {
    func setStyle(in context: BLContext) {
        setStrokeOptions(to: context)
        
        switch brush {
        case .solid(let color):
            context.setStrokeStyle(color.asBLRgba32)
            
        case .gradient(let gradient):
            context.setStrokeStyle(gradient.toBLGradient())
        }
    }
}

extension StrokeStyle {
    func setStrokeOptions(to context: BLContext) {
        context.setStrokeWidth(width)
        context.setStrokeCap(.start, strokeCap: startCap.toBLStrokeCap())
        context.setStrokeCap(.end, strokeCap: endCap.toBLStrokeCap())
        context.setStrokeDashOffset(dashOffset)
        context.setStrokeDashArray(dashArray)
        joinStyle.setStrokeJoin(to: context)
    }
}

extension StrokeStyle.JoinStyle {
    func setStrokeJoin(to context: BLContext) {
        switch self {
        case .miterClip(let limit):
            context.setStrokeJoin(.miterClip)
            context.setStrokeMiterLimit(limit)
            
        case .miterBevel:
            context.setStrokeJoin(.miterBevel)
            
        case .miterRound:
            context.setStrokeJoin(.miterRound)
            
        case .bevel:
            context.setStrokeJoin(.bevel)
            
        case .round:
            context.setStrokeJoin(.round)
        }
    }
}

extension StrokeStyle.CapStyle {
    func toBLStrokeCap() -> BLStrokeCap {
        switch self {
        case .butt:
            return .butt
        case .round:
            return .round
        case .square:
            return .square
        }
    }
}
