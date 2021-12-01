/// Specifies the alignment of a UI element relative to another.
public enum UIAlignment: Hashable {
    /// Alignment happens at the leading edge of the elements (left or top,
    /// depending on orientation).
    case leading

    /// Alignment happens at the center edge of the elements (center.x or center.y,
    /// depending on orientation).
    case center

    /// Alignment happens at the trailing edge of the elements (right or bottom,
    /// depending on orientation).
    case trailing
}
