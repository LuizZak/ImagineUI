public protocol EventPublisherType: AnyObject {
    /// Removes a listener associated with a given key.
    func removeListener(forKey key: EventListenerKey)
}

/// An event publisher that handles registration and dispatching of events.
///
/// Warning: Not thread-safe.
public class EventPublisher<T>: EventPublisherType {
    private var _listenerKey = 0
    var listeners: [(key: EventListenerKey, listener: (T) -> Void)] = []

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

    public func removeAll(fromOwner owner: AnyObject) {
        listeners.removeAll(where: { $0.key.owner === owner })
    }

    public func makeEventSource() -> EventSource<T> {
        return EventSource(publisher: self)
    }
}
