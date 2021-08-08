/// Defines the style of a fill or stroke style
public enum BrushStyle {
    /// A solid color brush
    case solid(Color)
    
    /// A gradient brush
    case gradient(Gradient)
}
