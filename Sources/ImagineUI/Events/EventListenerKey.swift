public struct EventListenerKey {
    internal weak var owner: AnyObject?
    internal weak var publisher: EventPublisherType?
    internal let key: Int

    init(owner: AnyObject, publisher: EventPublisherType, key: Int) {
        self.owner = owner
        self.publisher = publisher
        self.key = key
    }
}
