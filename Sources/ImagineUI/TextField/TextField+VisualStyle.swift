import Rendering

public extension TextField {
    /// Specifies the presentation style for a text field.
    ///
    /// Used to specify separate visual styles depending on the first-responding
    /// state of the text field.
    struct VisualStyle {
        public var textColor: Color = .black
        public var placeholderTextColor: Color = .black
        public var backgroundColor: Color = .white
        public var strokeColor: Color = .black
        public var strokeWidth: Double = 0
        public var caretColor: Color = .black
        public var selectionColor: Color = .black

        public init(textColor: Color = .black,
                    placeholderTextColor: Color = .black,
                    backgroundColor: Color = .white,
                    strokeColor: Color = .black,
                    strokeWidth: Double = 0,
                    caretColor: Color = .black,
                    selectionColor: Color = .black) {

            self.textColor = textColor
            self.placeholderTextColor = placeholderTextColor
            self.backgroundColor = backgroundColor
            self.strokeColor = strokeColor
            self.strokeWidth = strokeWidth
            self.caretColor = caretColor
            self.selectionColor = selectionColor
        }

        public static func defaultDarkStyle() -> [ControlViewState: Self] {
            return [
                .disabled:
                    Self(
                        textColor: .gray,
                        placeholderTextColor: .dimGray,
                        backgroundColor: Color(red: 40, green: 40, blue: 40),
                        strokeColor: .transparentBlack,
                        strokeWidth: 0,
                        caretColor: .white,
                        selectionColor: .slateGray
                    ),

                .normal:
                    Self(
                        textColor: .white,
                        placeholderTextColor: .dimGray,
                        backgroundColor: .black,
                        strokeColor: Color(alpha: 255, red: 50, green: 50, blue: 50),
                        strokeWidth: 1,
                        caretColor: .white,
                        selectionColor: .slateGray
                    ),

                .focused:
                    Self(
                        textColor: .white,
                        placeholderTextColor: .dimGray,
                        backgroundColor: .black,
                        strokeColor: .cornflowerBlue,
                        strokeWidth: 1,
                        caretColor: .white,
                        selectionColor: .steelBlue
                    )
            ]
        }

        public static func defaultLightStyle() -> [ControlViewState: Self] {
            return [
                .normal:
                    Self(
                        textColor: .black,
                        placeholderTextColor: .gray,
                        backgroundColor: .white /* TODO: Should be KnownColor.Control */,
                        strokeColor: .black,
                        strokeWidth: 1,
                        caretColor: .black,
                        selectionColor: .lightBlue
                    )
            ]
        }
    }
}
