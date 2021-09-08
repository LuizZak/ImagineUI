import Geometry

public protocol MouseEventHandler: EventHandler {
    func onMouseDown(_ event: MouseEventArgs)
    func onMouseMove(_ event: MouseEventArgs)
    func onMouseUp(_ event: MouseEventArgs)

    func onMouseLeave()
    func onMouseEnter()

    func onMouseClick(_ event: MouseEventArgs)
    func onMouseWheel(_ event: MouseEventArgs)
}

/// Event requests for mouse input
public protocol MouseEventRequest: EventRequest {
    var eventType: MouseEventType { get }
    var screenLocation: UIVector { get }
    var buttons: MouseButton { get }
    var delta: UIVector { get }
    var clicks: Int { get }
}

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

public struct MouseButton: OptionSet {
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = MouseButton([])
    public static let left = MouseButton(rawValue: 0b1)
    public static let right = MouseButton(rawValue: 0b01)
    public static let middle = MouseButton(rawValue: 0b001)
}

public enum MouseEventType {
    case mouseDown
    case mouseMove
    case mouseUp
    case mouseClick
    case mouseDoubleClick
    case mouseWheel
}
