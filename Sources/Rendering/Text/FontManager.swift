import Text

/// Provides font management functionality
public protocol FontManager {
    /// Attempts to load a font face from a given file path.
    func loadFontFace(fromPath path: String) throws -> FontFace
}
