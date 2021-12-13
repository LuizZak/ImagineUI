public struct EventSource<T> {
    private let publisher: EventPublisher<T>

    init(publisher: EventPublisher<T>) {
        self.publisher = publisher
    }

    /// Adds a new event listener to this event source.
    ///
    /// The `weakOwner` object is held weakly, and the event listener is
    /// automatically removed when the `owner` turns `nil`.
    @discardableResult
    public func addListener(weakOwner: AnyObject, _ listener: @escaping (T) -> Void) -> EventListenerKey {
        return publisher.addListener(weakOwner: weakOwner, listener)
    }

    /// Adds a new event listener to this event source.
    ///
    /// The `weakOwner` object is held weakly, and the event listener is
    /// automatically removed when the `weakOwner` turns `nil`.
    @discardableResult
    public func addListener(weakOwner: AnyObject, _ listener: @escaping () -> Void) -> EventListenerKey where T == Void {
        return publisher.addListener(weakOwner: weakOwner) { listener() }
    }

    public func removeListener(forKey key: EventListenerKey) {
        publisher.removeListener(forKey: key)
    }

    public func removeAll(fromOwner owner: AnyObject) {
        publisher.removeAll(fromOwner: owner)
    }
}
