import Rendering

public extension TreeView {
    struct VisualStyle {
        var backgroundColor: Color
        var itemStyle: (normal: ItemStyle, highlighted: ItemStyle, selected: ItemStyle)

        public static func defaultDarkStyle() -> Self {
            return Self(
                backgroundColor: Color(red: 37, green: 37, blue: 38),
                itemStyle: (
                    normal: .init(
                        backgroundColor: .transparentBlack,
                        textColor: .lightGray,
                        chevronColor: .gray
                    ),
                    highlighted: .init(
                        backgroundColor: Color(red: 42, green: 45, blue: 46),
                        textColor: .white,
                        chevronColor: .gray
                    ),
                    selected: .init(
                        backgroundColor: Color(red: 9, green: 71, blue: 113),
                        textColor: .white,
                        chevronColor: .white
                    )
                )
            )
        }

        public static func defaultLightStyle() -> Self {
            return Self(
                backgroundColor: .white,
                itemStyle: (
                    normal: .init(
                        backgroundColor: .transparentBlack,
                        textColor: .black,
                        chevronColor: .gray
                    ),
                    highlighted: .init(
                        backgroundColor: .lightGray.faded(towards: .white, factor: 0.5),
                        textColor: .black,
                        chevronColor: .gray
                    ),
                    selected: .init(
                        backgroundColor: .cornflowerBlue,
                        textColor: .white,
                        chevronColor: .white
                    )
                )
            )
        }

        public struct ItemStyle {
            var backgroundColor: Color
            var textColor: Color
            var chevronColor: Color
        }
    }
}
