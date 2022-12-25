/// Property wrapper that can be used to define an event publisher/source pair
/// using a single property which can also hold state and notify sources when its
/// state has changed.
///
/// Events can be registered to with `someEvent.addListener()`, and published
/// with `_someEvent(<eventValue>)`.
///
/// Warning: Not thread-safe.
public class StatefulEvent<T>: Event<T> {
    internal var state: T

    public init(wrappedValue: T) {
        self.state = wrappedValue

        super.init()
    }

    public override func publishEvent(_ event: T) {
        state = event
        
        super.publishEvent(event)
    }

    public override func callAsFunction(_ event: T) {
        publishEvent(event)
    }
}
