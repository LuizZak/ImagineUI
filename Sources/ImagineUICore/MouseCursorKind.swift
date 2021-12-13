public enum MouseCursorKind {
    /// A standard arrow cursor.
    case arrow
    
    /// A standard I-beam cursor used in text controls.
    case iBeam
    
    /// Resize arrow pointing up and down.
    case resizeUpDown
    
    /// Resize arrow pointing left and right.
    case resizeLeftRight

    /// Resize arrow pointing from the top-left corner to the bottom-right corner.
    case resizeTopLeftBottomRight

    /// Resize arrow pointing from the top-right corner to the bottom-left corner.
    case resizeTopRightBottomLeft

    /// Resize arrow pointing left, top, right, and bottom.
    case resizeAll

    /// A custom cursor with a path to the cursor file.
    case custom(imagePath: String, hotspot: UIVector)
}
