import SwiftBlend2D
import Rendering

extension ExtendMode {
    var asBLExtendMode: BLExtendMode {
        switch self {
        case .pad:
            return .pad
        
        case .repeat:
            return .repeat
        
        case .reflect:
            return .reflect
        
        case .padXRepeatY:
            return .padXRepeatY
        
        case .padXReflectY:
            return .padXReflectY
        
        case .repeatXPadY:
            return .repeatXPadY
        
        case .repeatXReflectY:
            return .repeatXReflectY
        
        case .reflectXPadY:
            return .reflectXPadY
        
        case .reflectXRepeatY:
            return .reflectXRepeatY
        }
    }
}
