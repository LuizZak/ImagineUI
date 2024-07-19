/// An event publisher that handles registration and dispatching of events
/// synchronously.
///
/// Warning: Not thread-safe.
public class SynchronousEventPublisher<T>: EventPublisherType {
    private var _listenerKey = 0
    var listeners: [(key: EventListenerKey, listener: (T) -> Void)] = []

    /// Publishes a given value to all event listeners currently subscribed to
    /// this event publisher.
    public func publish(value: T) {
        guard !listeners.isEmpty else { return }

        var removed = 0
        for (i, listener) in listeners.enumerated() {
            if listener.key.owner != nil {
                listener.listener(value)
            } else {
                listeners.remove(at: i - removed)
                removed += 1
            }
        }
    }

    /// Adds a new event listener, tied to a given weakly-held owner object
    /// reference, with a listener closure that will be invoked when future events
    /// are published on this event publisher.
    ///
    /// `weakOwner` is used to create a weak ownership link that is verified
    /// internally during event processing, and if `weakOwner` is released from
    /// memory, the underlying event listener that is registered is removed, as
    /// if by calling `EventListenerKey.removeListener()`.
    public func addListener(weakOwner: AnyObject, _ listener: @escaping (T) -> Void) -> EventListenerKey {
        let key = EventListenerKey(owner: weakOwner, publisher: self, key: _listenerKey)
        _listenerKey &+= 1

        listeners.append((key, listener))

        return key
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
        return addListener(weakOwner: weakOwner) { [weak weakOwner] value in
            guard let owner = weakOwner else { return }

            listener(owner, value)
        }
    }

    /// Requesta that an event listener associated with a given key be
    /// unsubscribed from this event publisher.
    public func removeListener(forKey key: EventListenerKey) {
        guard key.publisher === self else {
            return
        }

        for (i, listener) in listeners.enumerated() {
            if listener.key.key == key.key {
                listeners.remove(at: i)
                return
            }
        }
    }

    /// Removes all event subscriptions associated with a given owner object,
    /// by verifying the original `weakOwner` argument that was passed to
    /// `addListener(weakOwner:_:)`. Matching is done by object identity, i.e.
    /// via `===`.
    public func removeAll(fromOwner owner: AnyObject) {
        listeners.removeAll(where: { $0.key.owner === owner })
    }

    /// Creates a wrapping event source on top of this event publisher that can
    /// be used to expose an API for event listeners to subscribe to without
    /// exposing the event publishing API as well.
    public func makeEventSource() -> SynchronousEventSource<T> {
        return SynchronousEventSource(publisher: self)
    }
}
