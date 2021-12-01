/// A typealias for an event source for an event with a sender
public typealias EventSourceWithSender<T, U> = EventSource<SenderEventArgs<T, U>>

public typealias EventWithSender<T, U> = Event<SenderEventArgs<T, U>>
