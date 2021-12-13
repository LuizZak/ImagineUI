import Text

/// Caret position of a `TextEngine`.
public struct Caret: Hashable, CustomStringConvertible {
    /// Range of text this caret covers on a text engine
    public var textRange: Text.TextRange

    /// Position of this text caret.
    ///
    /// If `position` is `CaretPosition.start`, this value matches the value of
    /// `start`, otherwise this value matches `end`, instead.
    public var location: Int {
        switch position {
        case .start:
            return start
        case .end:
            return end
        }
    }

    /// Position of the caret within the text range.
    public var position: CaretPosition

    /// Start of text range this caret covers
    public var start: Int { textRange.start }

    /// End of text range this caret covers
    public var end: Int { textRange.end }

    /// Length of text this caret covers
    public var length: Int { textRange.length }
    
    public var description: String {
        return "Caret: \(textRange) : \(position)"
    }

    init(location: Int) {
        textRange = TextRange(start: location, length: 0)
        position = CaretPosition.start
    }

    init(range: TextRange, position: CaretPosition) {
        textRange = range
        self.position = position
    }
}

/// Specifies the position a `Caret` is located within its own range.
///
/// If start, `Caret.Location == Caret.Start`, if end, `Caret.Location == Caret.End`.
public enum CaretPosition {
   case start
   case end
}
