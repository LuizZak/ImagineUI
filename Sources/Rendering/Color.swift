/// Represents a 4-component ARGB color
public struct Color: Equatable {
    @Clamped(min: 0, max: 255) public var alpha: Int = 0
    @Clamped(min: 0, max: 255) public var red: Int = 0
    @Clamped(min: 0, max: 255) public var green: Int = 0
    @Clamped(min: 0, max: 255) public var blue: Int = 0
    
    public init(alpha: Int = 255, red: Int, green: Int, blue: Int) {
        self.alpha = alpha
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    public func withTransparency(_ alpha: Int) -> Color {
        return Color(alpha: alpha, red: red, green: green, blue: blue)
    }
    
    public func withTransparency(factor: Float) -> Color {
        return Color(
            alpha: Int(255 * factor),
            red: red,
            green: green,
            blue: blue
        )
    }
    
    public func faded(towards otherColor: Color, factor: Float, blendAlpha: Bool = false) -> Color {
        let from = 1 - factor

        let a = blendAlpha ? Float(self.alpha) * from + Float(otherColor.alpha) * factor : Float(self.alpha)
        let r = Float(self.red) * from + Float(otherColor.red) * factor
        let g = Float(self.green) * from + Float(otherColor.green) * factor
        let b = Float(self.blue) * from + Float(otherColor.blue) * factor

        return Color(alpha: Int(a), red: Int(r), green: Int(g), blue: Int(b))
    }
}

public extension Color {
    /// Returns whether this color instance is fully transparent (alpha = 0)
    var isTransparent: Bool {
        return alpha == 0
    }
}
