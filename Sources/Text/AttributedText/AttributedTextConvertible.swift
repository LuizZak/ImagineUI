/// Protocol for objects that can be converted into an `AttributedText` instance.
public protocol AttributedTextConvertible {
    /// Returns a representation `AttributedText` instance for this object.
    func attributedText() -> AttributedText
}

extension String: AttributedTextConvertible {
    /// Converts this string into a plain, attribute-less `AttributedText`.
    ///
    /// Same as calling `AttributedText(self)`.
    public func attributedText() -> AttributedText {
        AttributedText(self)
    }
}
