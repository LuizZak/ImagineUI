public struct EventSource<T> {
    private let publisher: EventPublisher<T>

    init(publisher: EventPublisher<T>) {
        self.publisher = publisher
    }

    /// Adds a new event listener to this event source.
    /// The `owner` object is held weakly, and the event listener is automatically
    /// removed when the `owner` turns `nil`.
    @discardableResult
    public func addListener(owner: AnyObject, _ listener: @escaping (T) -> Void) -> EventListenerKey {
        return publisher.addListener(owner: owner, listener)
    }

    /// Adds a new event listener to this event source.
    /// The `owner` object is held weakly, and the event listener is automatically
    /// removed when the `owner` turns `nil`.
    @discardableResult
    public func addListener(owner: AnyObject, _ listener: @escaping () -> Void) -> EventListenerKey where T == Void {
        return publisher.addListener(owner: owner) { listener() }
    }

    public func removeListener(withKey key: EventListenerKey) {
        publisher.removeListener(withKey: key)
    }

    public func removeAll(fromOwner owner: AnyObject) {
        publisher.removeAll(fromOwner: owner)
    }
}
