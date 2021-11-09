public var globalTextClipboard: TextClipboard? {
    @_transparent
    willSet {
        precondition(!(newValue is GlobalTextClipboard),
                     "Cannot set a GlobalTextClipboard as the global text clipboard instance as that would lead into an infinite recursion")
    }
}

/// Basic text clipboard for a `TextEngine` to use during copy/cut/paste operations.
public protocol TextClipboard {
    /// Returns text from this clipboard, if present.
    func getText() -> String?

    /// Sets the textual content to this clipboard
    func setText(_ text: String)

    /// Returns whether this clipboard contains any text content in it
    func containsText() -> Bool
}

class GlobalTextClipboard: TextClipboard {
    func getText() -> String? {
        return globalTextClipboard?.getText()
    }

    func setText(_ text: String) {
        globalTextClipboard?.setText(text)
    }

    func containsText() -> Bool {
        return globalTextClipboard?.containsText() ?? false
    }
}
