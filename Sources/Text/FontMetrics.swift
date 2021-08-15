import Geometry

/// Scaled design metrics based on font size and other properties.
public struct FontMetrics {
    /// Font size
    public var size: Float
    
    /// Font ascent (horizontal orientation).
    public var ascent: Float
    
    /// Font ascent (vertical orientation).
    public var vAscent: Float
    
    /// Font descent (horizontal orientation).
    public var descent: Float
    
    /// Font descent (vertical orientation).
    public var vDescent: Float
    
    /// Line gap.
    public var lineGap: Float
    
    /// Distance between the baseline and the mean line of lower-case letters.
    public var xHeight: Float
    
    /// Maximum height of a capital letter above the baseline.
    public var capHeight: Float
    
    /// Text underline position.
    public var underlinePosition: Float
    
    /// Text underline thickness.
    public var underlineThickness: Float
    
    /// Text strikethrough position.
    public var strikethroughPosition: Float
    
    /// Text strikethrough thickness.
    public var strikethroughThickness: Float
    
    public init(size: Float,
                ascent: Float,
                vAscent: Float,
                descent: Float,
                vDescent: Float,
                lineGap: Float,
                xHeight: Float,
                capHeight: Float,
                underlinePosition: Float,
                underlineThickness: Float,
                strikethroughPosition: Float,
                strikethroughThickness: Float) {
        
        self.size = size
        self.ascent = ascent
        self.vAscent = vAscent
        self.descent = descent
        self.vDescent = vDescent
        self.lineGap = lineGap
        self.xHeight = xHeight
        self.capHeight = capHeight
        self.underlinePosition = underlinePosition
        self.underlineThickness = underlineThickness
        self.strikethroughPosition = strikethroughPosition
        self.strikethroughThickness = strikethroughThickness
    }
}
