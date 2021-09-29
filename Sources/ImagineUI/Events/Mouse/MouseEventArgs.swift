import Geometry

public struct MouseEventArgs {
    public var location: UIVector
    public var buttons: MouseButton
    public var delta: UIVector
    public var clicks: Int
    
    public init(location: UIVector,
                buttons: MouseButton,
                delta: UIVector,
                clicks: Int) {
        
        self.location = location
        self.buttons = buttons
        self.delta = delta
        self.clicks = clicks
    }
}
