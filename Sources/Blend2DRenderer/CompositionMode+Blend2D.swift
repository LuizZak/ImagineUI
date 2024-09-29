import SwiftBlend2D
import RenderingCommon

extension CompositionMode {
    var asBLCompOp: BLCompOp {
        switch self {
        case .clear:
            return .clear

        case .colorBurn:
            return .colorBurn

        case .colorDodge:
            return .colorDodge

        case .darken:
            return .darken

        case .destinationAtop:
            return .dstAtop

        case .destinationCopy:
            return .dstCopy

        case .destinationIn:
            return .dstIn

        case .destinationOut:
            return .dstOut

        case .destinationOver:
            return .dstOver

        case .difference:
            return .difference

        case .exclusion:
            return .exclusion

        case .hardLight:
            return .hardLight

        case .lighten:
            return .lighten

        case .linearBurn:
            return .linearBurn

        case .linearLight:
            return .linearLight

        case .minus:
            return .minus

        case .modulate:
            return .modulate

        case .multiply:
            return .multiply

        case .overlay:
            return .overlay

        case .pinLight:
            return .pinLight

        case .plus:
            return .plus

        case .screen:
            return .screen

        case .softLight:
            return .softLight

        case .sourceAtop:
            return .srcAtop

        case .sourceCopy:
            return .srcCopy

        case .sourceIn:
            return .srcIn

        case .sourceOut:
            return .srcOut

        case .sourceOver:
            return .srcOver

        case .xor:
            return .xor
        }
    }

    init?(compOp: BLCompOp) {
        switch compOp {
        case .clear:
            self = .clear

        case .colorBurn:
            self = .colorBurn

        case .colorDodge:
            self = .colorDodge

        case .darken:
            self = .darken

        case .dstAtop:
            self = .destinationAtop

        case .dstCopy:
            self = .destinationCopy

        case .dstIn:
            self = .destinationIn

        case .dstOut:
            self = .destinationOut

        case .dstOver:
            self = .destinationOver

        case .difference:
            self = .difference

        case .exclusion:
            self = .exclusion

        case .hardLight:
            self = .hardLight

        case .lighten:
            self = .lighten

        case .linearBurn:
            self = .linearBurn

        case .linearLight:
            self = .linearLight

        case .minus:
            self = .minus

        case .modulate:
            self = .modulate

        case .multiply:
            self = .multiply

        case .overlay:
            self = .overlay

        case .pinLight:
            self = .pinLight

        case .plus:
            self = .plus

        case .screen:
            self = .screen

        case .softLight:
            self = .softLight

        case .srcAtop:
            self = .sourceAtop

        case .srcCopy:
            self = .sourceCopy

        case .srcIn:
            self = .sourceIn

        case .srcOut:
            self = .sourceOut

        case .srcOver:
            self = .sourceOver

        case .xor:
            self = .xor

        default:
            return nil
        }
    }
}
