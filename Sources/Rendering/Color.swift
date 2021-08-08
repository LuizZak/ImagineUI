/// Represents a 4-component ARGB color
public struct Color: Equatable {
    @Clamped(min: 0, max: 255) public var alpha: Int = 0
    @Clamped(min: 0, max: 255) public var red: Int = 0
    @Clamped(min: 0, max: 255) public var green: Int = 0
    @Clamped(min: 0, max: 255) public var blue: Int = 0
    
    internal init(alpha: Int = 255, red: Int, green: Int, blue: Int) {
        self.alpha = alpha
        self.red = red
        self.green = green
        self.blue = blue
    }
}
