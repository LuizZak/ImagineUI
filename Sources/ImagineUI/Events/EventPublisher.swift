public protocol EventPublisherType: AnyObject {

}

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

    public func addListener(owner: AnyObject, _ listener: @escaping (T) -> Void) -> EventListenerKey {
        let key = EventListenerKey(owner: owner, publisher: self, key: _listenerKey)
        _listenerKey &+= 1

        listeners.append((key, listener))

        return key
    }

    public func removeListener(withKey key: EventListenerKey) {
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