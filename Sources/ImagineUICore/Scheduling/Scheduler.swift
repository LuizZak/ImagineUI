import Foundation

/// A scheduler for `onFixedFrame` events.
public final class Scheduler {
    /// Gets the singleton global instance of `Scheduler`.
    public static let instance = Scheduler()

    /// Event invoked every time `onFixedFrame` is invoked; usually aligned to
    /// the display's refresh rate.
    ///
    /// The `TimeInterval` provided to the function is the time interval elapsed
    /// since the last fixed frame event was issued.
    @Event<TimeInterval>
    public var fixedFrameEvent

    private init() {

    }

    /// Raises the `fixedFrameEvent` event.
    /// Should be invoked at an interval that is equal to the refresh rate of the
    /// monitor.
    public func onFixedFrame(_ intervalInSeconds: TimeInterval) async {
        await _fixedFrameEvent(intervalInSeconds)
    }

    /// Schedules a timer to fire at a specified interval.
    ///
    /// The timer will fire in the main `RunLoop`, with `RunLoop.Mode.default`
    /// mode.
    ///
    /// The timer is scheduled to fire `interval` seconds after the current date
    /// at the time of calling this method, and if `repeats` is passed as `true`,
    /// every `interval` seconds afterwards until `SchedulerTimerType.invalidate()`
    /// is called on the returned timer object.
    ///
    /// Precision of the timer is undefined, but it is guaranteed to not fire
    /// before its scheduled time.
    public func scheduleTimer(interval: TimeInterval, repeats: Bool = false, _ block: @escaping () -> Void) -> SchedulerTimerType {
        let date = Date().addingTimeInterval(interval)
        let timer = Timer(fire: date, interval: interval, repeats: repeats) { _ in
            block()
        }

        RunLoop.main.add(timer, forMode: .default)

        return InternalSchedulerTimer(timer: timer)
    }

    private class InternalSchedulerTimer: SchedulerTimerType {
        let timer: Timer

        init(timer: Timer) {
            self.timer = timer
        }

        func invalidate() {
            timer.invalidate()
        }

        func fire() {
            timer.fire()
        }
    }
}

public protocol SchedulerTimerType {
    /// Invalidates, or stops, this timer from firing.
    func invalidate()

    /// Immediately invokes the trigger associated with this timer, invalidating
    /// the timer.
    func fire()
}
