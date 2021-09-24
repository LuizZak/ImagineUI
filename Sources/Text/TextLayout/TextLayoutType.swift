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
    var size: UISize { get }
    
    func locationOfCharacter(index: Int) -> UIPoint
    func boundsForCharacters(startIndex: Int, length: Int) -> [UIRectangle]
    func boundsForCharacters(in range: TextRange) -> [UIRectangle]
    func hitTestPoint(_ point: UIPoint) -> TextLayoutHitTestResult
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
