/// Vertical text alignment used during text layout
public enum VerticalTextAlignment {
    /// Text is aligned with the top of the available region
    case near
    /// Text is aligned centrally with respect to available region's height
    case center
    /// Text is aligned with the bottom of the available region
    case far
}

/// Horizontal text alignment used during text layout
public enum HorizontalTextAlignment {
    /// Text is aligned to leading of available region
    case leading
    /// Text is aligned centrally with respect to available region's width
    case center
    /// Text is aligned to trailing of available region
    case trailing
}
