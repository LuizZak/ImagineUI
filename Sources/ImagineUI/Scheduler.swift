import Foundation

/// A scheduler for `onFixedFrame` events.
public final class Scheduler {
    /// Gets the singleton global instance of `Scheduler`.
    public static let instance = Scheduler()
    
    /// Event invoked every time `onFixedFrame` is invoked; usually aligned to
    /// the display's refresh rate.
    @Event public var fixedFrameEvent: EventSource<TimeInterval>
    
    private init() {
        
    }
    
    /// Raises the `fixedFrameEvent` event.
    public func onFixedFrame(_ intervalInSeconds: TimeInterval) {
        _fixedFrameEvent.publishEvent(intervalInSeconds)
    }
}
