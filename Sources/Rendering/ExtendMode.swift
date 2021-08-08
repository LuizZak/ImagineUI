/// Specifies an extension mode for pattern and gradient brushes
public enum ExtendMode {
    /// Pad extend
    case pad
    /// Repeat extend
    case `repeat`
    /// Reflect extend
    case reflect
    
    /// Pad X and repeat Y
    case padXRepeatY
    /// Pad X and reflect Y
    case padXReflectY
    /// Repeat X and pad Y
    case repeatXPadY
    /// Repeat X and reflect Y
    case repeatXReflectY
    /// Reflect X and pad Y
    case reflectXPadY
    /// Reflect X and repeat Y
    case reflectXRepeatY
}
