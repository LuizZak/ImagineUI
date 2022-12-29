/// Exposes an event source point that can be subscribed into in order to receive
/// future events issued by the an event publisher associated with this event
/// source.
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

    /// Convenience for:
    /// 
    /// ```swift
    /// addListener(weakOwner: owner) { [weak owner] value in
    ///     guard let owner else { return }
    ///     ...
    /// }
    /// ```
    @discardableResult
    public func addWeakListener<U: AnyObject>(_ weakOwner: U, _ listener: @escaping (U, T) -> Void) -> EventListenerKey {
        return publisher.addWeakListener(weakOwner, listener)
    }

    /// Requesta that an event listener associated with a given key be
    /// unsubscribed and no longer receive any events.
    public func removeListener(forKey key: EventListenerKey) {
        publisher.removeListener(forKey: key)
    }

    /// Removes all event subscriptions associated with a given owner object,
    /// by verifying the original `weakOwner` argument that was passed to
    /// `addListener(weakOwner:_:)`. Matching is done by object identity, i.e.
    /// via `===`.
    public func removeAll(fromOwner owner: AnyObject) {
        publisher.removeAll(fromOwner: owner)
    }
}
