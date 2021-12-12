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

extension Tooltip: ExpressibleByStringInterpolation {
    public init(stringInterpolation: StringInterpolation) {
        self.init(text: stringInterpolation.output)
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        public typealias StringLiteralType = String

        var output: String = ""

        public init(literalCapacity: Int, interpolationCount: Int) {
            output.reserveCapacity(literalCapacity * 2)
        }

        public mutating func appendLiteral(_ literal: String) {
            output += literal
        }

        public mutating func appendInterpolation<T>(_ literal: T) {
            output += "\(literal)"
        }
    }
}
