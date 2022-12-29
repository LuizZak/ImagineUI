/// A key that is issued when subscribing to an event publisher that can be used
/// to revoke the subscription to that publisher, halting further events from
/// invoking the event listener closure associated with this event listener key.
public struct EventListenerKey {
    private let _removedBox: RemovedBox
    internal weak var owner: AnyObject?
    internal weak var publisher: EventPublisherType?
    internal let key: Int

    init(owner: AnyObject, publisher: EventPublisherType, key: Int) {
        _removedBox = RemovedBox()
        self.owner = owner
        self.publisher = publisher
        self.key = key
    }

    /// Removes the event listener associated with this event listener key. Even
    /// though `EventListenerKey` is a struct type, copies of the same original
    /// event listener key returned by an event publisher all cancel the same
    /// underlying event listener entry.
    ///
    /// Calling this method multiple times has no effect.
    public func removeListener() {
        guard !_removedBox.removed else {
            return
        }

        publisher?.removeListener(forKey: self)
        _removedBox.removed = true
    }

    private class RemovedBox {
        var removed: Bool = false
    }
}
