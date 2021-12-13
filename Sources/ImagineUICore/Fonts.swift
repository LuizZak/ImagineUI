import Rendering
import Text

public enum Fonts {
    private static var _fontCache: [Float: Font] = [:]
    
    static var defaultFontFace: FontFace?
    
    public static var fontFilePath: String = "Resources/NotoSans-Regular.ttf"
    
    public static func defaultFont(size: Float) -> Font {
        guard let fontFace = defaultFontFace else {
            fatalError("Called Fonts.defaultFont(size:) before calling UISettings.initialize with a valid FontManager and default font path")
        }
        
        if let cached = _fontCache[size] {
            return cached
        }
        
        let font = fontFace.font(withSize: size)
        _fontCache[size] = font
        
        return font
    }
    
    internal static func configure(fontManager: FontManager, defaultFontPath: String) throws {
        fontFilePath = defaultFontPath
        _fontCache.removeAll()
        
        defaultFontFace = try fontManager.loadFontFace(fromPath: defaultFontPath)
    }
}
