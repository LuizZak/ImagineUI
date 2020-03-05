import SwiftBlend2D

// MARK: - Event typealiases

/// A typealias for an event that has a sender
public typealias SenderEventArgs<Sender, EventArgs> = (sender: Sender, args: EventArgs)

/// A typealias for an event source for an event with a sender
public typealias EventSourceWithSender<T, U> = EventSource<SenderEventArgs<T, U>>

/// A typealias for an event that tracks changes to a property's value
public typealias ValueChangeEvent<Sender, Value> = EventSourceWithSender<Sender, ValueChangedEventArgs<Value>>

/// A typealias for an event that tracks changes to a property's value, while
/// enabling the opportunity to cancel the value change
public typealias CancelablleValueChangeEvent<Sender, Value> = EventSourceWithSender<Sender, CancellableValueChangedEventArgs<Value>>

// MARK: - Event argument typealiases

/// A typealias for arguments for a `ControlView.painted` event
public typealias PaintEventArgs = BLContext

// MARK: - Event argument structures

/// An event argument set for an event that tracks changes to a property
public struct ValueChangedEventArgs<T> {
    public var old: T
    public var new: T
    
    public init(old: T, new: T) {
        self.old = old
        self.new = new
    }
}

/// An event argument set for an event that tracks changes to a property, while
/// exposing a `cancel` that can be changed by clients to cancel the state change
public class CancellableValueChangedEventArgs<T> {
    public var old: T
    public var new: T
    public var cancel: Bool
    
    public init(old: T, new: T) {
        self.old = old
        self.new = new
        
        cancel = false
    }
}

// MARK: - Event extension
public extension Event {
    func publishEvent<Sender>(sender: Sender) where T == SenderEventArgs<Sender, Void> {
        self.publishEvent((sender, ()))
    }
    
    func publishEvent<Sender, Args>(sender: Sender, _ args: Args) where T == SenderEventArgs<Sender, Args> {
        self.publishEvent((sender, args))
    }
    
    func publishChangeEvent<Sender, Value>(sender: Sender, old: Value, new: Value) where T == SenderEventArgs<Sender, ValueChangedEventArgs<Value>> {
        self.publishEvent((sender, ValueChangedEventArgs(old: old, new: new)))
    }
    
    func publishCancellableChangeEvent<Sender, Value>(sender: Sender, old: Value, new: Value) -> Bool where T == SenderEventArgs<Sender, CancellableValueChangedEventArgs<Value>> {
        
        let event = CancellableValueChangedEventArgs(old: old, new: new)
        
        self.publishEvent((sender, event))
        
        return event.cancel
    }
}
