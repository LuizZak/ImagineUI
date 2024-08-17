import Foundation
import Dispatch

/// Main actor for ImagineUI components.
///
/// Exposes a public executor that can be invoked to dispatch all enqueued jobs.
@globalActor
public actor ImagineActor {
    public let executor = ImagineActorExecutor()
    public static let shared = ImagineActor()

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        .init(ordinary: executor)
    }
}

public final class ImagineActorExecutor: SerialExecutor {
    public static let queue: DispatchQueue = {
        let queue = DispatchQueue(
            label: "com.imagine-ui.imagine-actor.executor",
            attributes: []
        )
        queue.activate()

        return queue
    }()
    public static let jobsQueue: DispatchQueue = {
        let queue = DispatchQueue(
            label: "com.imagine-ui.imagine-actor.executor.jobs",
            attributes: []
        )
        queue.activate()

        return queue
    }()
    static var _jobs: [UnownedJob] = []

    public static var jobs: [UnownedJob] {
        get { jobsQueue.sync { _jobs } }
        set { jobsQueue.sync { _jobs = newValue } }
    }

    public static func initialize() {
        _ = queue
    }

    public func enqueue(_ job: consuming ExecutorJob) {
        let job = UnownedJob(job)
        Self.queue.async {
            job.runSynchronously(on: ImagineActor.sharedUnownedExecutor)
        }
        /*
        Self.jobs.append(job)
        */
    }

    public static func synchronousOperation(_ block: @ImagineActor () -> Void) {
        queue.sync(flags: .barrier) {
            ImagineActor.preconditionIsolated()
            ImagineActor.shared.assumeIsolated { @ImagineActor _ in
                block()
            }
        }
    }

    func checkIsolation() {
        dispatchPrecondition(condition: .onQueue(Self.queue))
    }

    public static func flushJobsSynchronously() {
        let jobs = Self.jobsQueue.sync {
            defer { Self._jobs.removeAll() }
            return Self._jobs
        }
        for job in jobs {
            job.runSynchronously(on: ImagineActor.sharedUnownedExecutor)
        }
    }
}
