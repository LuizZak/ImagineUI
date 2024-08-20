/// Specifies a raster composition mode.
public enum CompositionMode {
    /// Source-over (default).
    case sourceOver

    /// Source-copy.
    case sourceCopy

    /// Source-in.
    case sourceIn

    /// Source-out.
    case sourceOut

    /// Source-atop.
    case sourceAtop

    /// Destination-over.
    case destinationOver

    /// Destination-copy (produces no change in output).
    case destinationCopy

    /// Destination-in.
    case destinationIn

    /// Destination-out.
    case destinationOut

    /// Destination-atop.
    case destinationAtop

    /// Xor.
    case xor

    /// Clear.
    case clear

    /// Plus.
    case plus

    /// Minus.
    case minus

    /// Modulate.
    case modulate

    /// Multiply.
    case multiply

    /// Screen.
    case screen

    /// Overlay.
    case overlay

    /// Darken.
    case darken

    /// Lighten.
    case lighten

    /// Color dodge.
    case colorDodge

    /// Color burn.
    case colorBurn

    /// Linear burn.
    case linearBurn

    /// Linear light.
    case linearLight

    /// Pin light.
    case pinLight

    /// Hard-light.
    case hardLight

    /// Soft-light.
    case softLight

    /// Difference.
    case difference

    /// Exclusion.
    case exclusion
}
