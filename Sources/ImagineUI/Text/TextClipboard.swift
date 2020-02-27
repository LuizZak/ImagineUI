import Cocoa

/// Basic text clipboard for a `TextEngine` to use during copy/cut/paste operations.
public protocol TextClipboard {
    /// Returns text from this clipboard, if present.
    func getText() -> String?

    /// Sets the textual content to this clipboard
    func setText(_ text: String)

    /// Returns whether this clipboard contains any text content in it
    func containsText() -> Bool
}

class MacOSTextClipboard: TextClipboard {
    func getText() -> String? {
        NSPasteboard.general.string(forType: .string)
    }

    func setText(_ text: String) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }

    func containsText() -> Bool {
        return getText() != nil
    }
}
