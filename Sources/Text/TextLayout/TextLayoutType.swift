import Geometry


public protocol TextLayoutType {
    var lines: [TextLayoutLine] { get }
    var font: Font { get }
    var text: String { get }
    var attributedText: AttributedText { get }
    var horizontalAlignment: HorizontalTextAlignment { get }
    var verticalAlignment: VerticalTextAlignment { get }
    var numberOfLines: Int { get }
    
    /// Total size of text layout area
    var size: Size { get }
    
    func locationOfCharacter(index: Int) -> Vector2
    func boundsForCharacters(startIndex: Int, length: Int) -> [Rectangle]
    func boundsForCharacters(in range: TextRange) -> [Rectangle]
    func hitTestPoint(_ point: Vector2) -> TextLayoutHitTestResult
    func font(atLocation index: Int) -> Font
    func baselineHeightForLine(atIndex index: Int) -> Float
}

public struct TextLayoutHitTestResult {
    public var isInside: Bool
    public var textPosition: Int
    public var stringIndex: String.Index
    public var isTrailing: Bool
    public var width: Double
    public var height: Double
    
    public init(isInside: Bool,
                textPosition: Int,
                stringIndex: String.Index,
                isTrailing: Bool,
                width: Double,
                height: Double) {
        
        self.isInside = isInside
        self.textPosition = textPosition
        self.stringIndex = stringIndex
        self.isTrailing = isTrailing
        self.width = width
        self.height = height
    }
}
