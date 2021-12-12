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

    /// Removes the event listener associated with this event listener key.
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
