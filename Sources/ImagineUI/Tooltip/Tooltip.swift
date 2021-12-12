/// Display configuration for a tooltip view.
public struct Tooltip {
    public var text: AttributedText
    public var backColor: Color?
    public var borderColor: Color?

    public init(text: AttributedText, backColor: Color? = nil, borderColor: Color? = nil) {
        self.text = text
        self.backColor = backColor
        self.borderColor = borderColor
    }

    public init<T: AttributedTextConvertible>(text: T, backColor: Color? = nil, borderColor: Color? = nil) {
        self.init(text: text.attributedText(), backColor: backColor, borderColor: borderColor)
    }
}

extension Tooltip: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(text: value)
    }
}
