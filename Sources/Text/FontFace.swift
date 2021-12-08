/// Protocol for font faces
public protocol FontFace {
    /// Creates a new font with a given size
    func font(withSize size: Float) -> Font
}
