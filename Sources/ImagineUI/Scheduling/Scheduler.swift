import Foundation

/// A scheduler for `onFixedFrame` events.
public final class Scheduler {
    /// Gets the singleton global instance of `Scheduler`.
    public static let instance = Scheduler()

    /// Event invoked every time `onFixedFrame` is invoked; usually aligned to
    /// the display's refresh rate.
    @Event public var fixedFrameEvent: EventSource<TimeInterval>

    private init() {

    }

    /// Raises the `fixedFrameEvent` event.
    /// Should be invoked at an interval that is equal to the refresh rate of the
    /// monitor.
    public func onFixedFrame(_ intervalInSeconds: TimeInterval) {
        _fixedFrameEvent(intervalInSeconds)
    }

    /// Schedules a timer to fire at a specified interval.
    ///
    /// The timer will fire in the main `RunLoop`, with `RunLoop.Mode.default`
    /// mode.
    public func scheduleTimer(interval: TimeInterval, repeats: Bool = false, _ block: @escaping () -> Void) -> SchedulerTimerType {
        let timer = Timer(timeInterval: interval, repeats: repeats) { _ in
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
    }
}

public protocol SchedulerTimerType {
    /// Invalidates, or stops, this timer from firing.
    func invalidate()
}
