import SwiftBlend2D

public enum Fonts {
    public static var fontFilePath: String = "Resources/NotoSans-Regular.ttf"

    private static var _fontCache: [Float: BLFont] = [:]
    static let defaultFontFace = try! BLFontFace(fromFile: fontFilePath)

    public static func defaultFont(size: Float) -> BLFont {
        if let cached = _fontCache[size] {
            return cached
        }

        let font = BLFont(fromFace: defaultFontFace, size: size)
        _fontCache[size] = font

        return font
    }
}
