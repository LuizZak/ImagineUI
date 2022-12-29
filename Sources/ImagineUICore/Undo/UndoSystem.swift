/// Base interface for performing undo/redo in undo systems.
///
/// See `UndoSystem` class.
/// - seealso: UndoSystem
protocol UndoSystemType {
    /// Gets whether this UndoSystem can currently undo a task
    var canUndo: Bool { get }

    /// Gets whether this UndoSystem can currently redo a task
    var canRedo: Bool { get }

    /// Undoes one task on this UndoSystem
    func undo()

    /// Redoes one task on this UndoSystem
    func redo()
}

/// A task that is capable of being undone/redone
public protocol UndoTask {
   /// Clears this `UndoTask` object
   func clear()

   /// Undoes this task
   func undo()

   /// Redoes this task
   func redo()

   /// Returns a short string description of this `UndoTask`
   func getDescription() -> String
}

/// Enables recording and performing of series of undo/redo tasks.
class UndoSystem: UndoSystemType {
    /// Set to true before any undo/redo task, and subsequently set to false
    /// before returning.
    ///
    /// Used to detect incorrect reentry calls to this undo system
    private var _isDoingWork: Bool = false

    /// The list of tasks that can be undone/redone
    private var _undoTasks: [UndoTask]

    /// The index of the current redo task.
    /// From this index onwards, all UndoTasks registered on the undo task list
    /// are considered Redo tasks
    private var _currentTask: Int

    /// The current group undo task
    private var _currentGroupUndoTask: GroupUndoTask?

    /// Occurs whenever a new Undo task is registered
    @EventWithSender<UndoSystem, UndoEventArgs>
    public var undoRegistered

    /// Occurs whenever a task will be undone
    @EventWithSender<UndoSystem, UndoEventArgs>
    public var willPerformUndo

    /// Occurs whenever a task was undone
    @EventWithSender<UndoSystem, UndoEventArgs>
    public var undoPerformed

    /// Occurs whenever a task will be redone
    @EventWithSender<UndoSystem, UndoEventArgs>
    public var willPerformRedo

    /// Occurs whenever a task was redone
    @EventWithSender<UndoSystem, UndoEventArgs>
    public var redoPerformed

    /// Occurs whenever the undo system was cleared
    @EventWithSender<UndoSystem, Void>
    public var cleared

    /// Gets the amount of tasks currently held by this `UndoSystem`
    public var count: Int { _undoTasks.count }

    /// Gets or sets the maximum amount of tasks this UndoSystem can store
    public var maximumTaskCount: Int

    /// Gets whether this UndoSystem can currently undo a task
    public var canUndo: Bool { _currentTask > 0 }

    /// Gets whether this UndoSystem can currently redo a task
    public var canRedo: Bool { _currentTask < count }

    /// Gets whether this UndoSystem is currently in group undo mode, recording
    /// all current undos into a group that will be stored as a single undo task
    /// later
    public var inGroupUndo: Bool { _currentGroupUndoTask != nil }

    /// Returns the next undo operation on the undo stack. If there's no undo
    /// operation available, nil is returned instead
    public var nextUndo: UndoTask? {
        canUndo ? _undoTasks[_currentTask - 1] : nil
    }

    /// Returns the next redo operation on the undo stack. If there's no redo
    /// operation available, nil is returned instead
    public var nextRedo: UndoTask? {
        canRedo ? _undoTasks[_currentTask] : nil
    }

    /// Initializes a new instance of the `UndoSystem` class
    public init() {
        _undoTasks = []
        _currentTask = 0
        maximumTaskCount = 15
    }

    /// Registers the given UndoTask on this `UndoSystem`
    ///
    /// - Parameter task: The task to undo
    public func registerUndo(_ task: UndoTask) {
        checkReentry()

        // Grouped undos: record them inside the group undo
        if inGroupUndo {
            _currentGroupUndoTask?.addTask(task)
            return
        }

        // Redo task clearing
        clearRedos()

        // Task capping
        if _undoTasks.count >= maximumTaskCount {
            while _undoTasks.count >= maximumTaskCount {
                _undoTasks[0].clear()

                _undoTasks.remove(at: 0)
            }
        } else {
            _currentTask += 1
        }

        _undoTasks.append(task)

        _undoRegistered(sender: self, UndoEventArgs(task: task))
    }

    /// Undoes one task on this `UndoSystem`
    public func undo() {
        checkReentry()

        // Finish any currently opened group undos
        if inGroupUndo, let undoGroup = _currentGroupUndoTask {
            finishGroupUndo(cancel: undoGroup.discardOnOperation)
        }

        if _currentTask == 0 {
            return
        }

        _isDoingWork = true

        // Get the task to undo
        let task = _undoTasks[_currentTask - 1]

        _willPerformUndo(sender: self, UndoEventArgs(task: task))

        _currentTask -= 1
        task.undo()

        _isDoingWork = false

        _undoPerformed(sender: self, UndoEventArgs(task: task))
    }

    /// Redoes one task on this `UndoSystem`
    public func redo() {
        checkReentry()

        // Finish any currently opened group undos
        if inGroupUndo, let groupUndo = _currentGroupUndoTask {
            finishGroupUndo(cancel: groupUndo.discardOnOperation)
        }

        if _currentTask == _undoTasks.count {
            return
        }

        _isDoingWork = true

        // Get the task to undo
        let task = _undoTasks[_currentTask]

        _willPerformRedo(sender: self, UndoEventArgs(task: task))

        _currentTask += 1
        task.redo()

        _isDoingWork = false

        _redoPerformed(sender: self, UndoEventArgs(task: task))
    }

    /// Starts a group undo task
    ///
    /// - Parameter description: A description for the task
    /// - Parameter discardOnOperation: Whether to discard the undo group if it's
    /// opened on this UndoSystem while it receives an undo/redo call
    public func startGroupUndo(description: String, discardOnOperation: Bool = false) {
        checkReentry()

        if inGroupUndo {
            return
        }

        _currentGroupUndoTask = GroupUndoTask(description: description)
        _currentGroupUndoTask?.discardOnOperation = discardOnOperation
    }

    /// Finishes and records the current grouped undo tasks
    ///
    /// - Parameter cancel: Whether to cancel the undo operations currently grouped
    public func finishGroupUndo(cancel: Bool = false) {
        checkReentry()

        if !inGroupUndo {
            return
        }
        guard let task = _currentGroupUndoTask else {
            return
        }

        _currentGroupUndoTask = nil

        if task.undoList.count > 0 && !cancel {
            registerUndo(task)
        } else {
            task.clear()
        }
    }

    /// Removes and returns the next undo task from this UndoSystem's undo list
    /// without performing it.
    /// If no undo task is available, null is returned
    ///
    /// - Returns: The next available undo operation if available, null otherwise
    public func popUndo() -> UndoTask? {
        if !canUndo {
            return nil
        }

        defer {
            _undoTasks.remove(at: _currentTask - 1)
            _currentTask -= 1
        }

        return nextUndo
    }

    /// Removes and returns the next redo task from this UndoSystem's undo list
    /// without performing it.
    /// If no redo task is available, null is returned
    ///
    /// - Returns: The next available redo operation if available, null otherwise
    public func popRedo() -> UndoTask? {
        if !canRedo {
            return nil
        }

        defer { _undoTasks.remove(at: _currentTask) }

        return nextRedo
    }

    /// Clears all operations on this `UndoSystem`
    public func clear() {
        if inGroupUndo, let groupUndo = _currentGroupUndoTask {
            finishGroupUndo(cancel: groupUndo.discardOnOperation)
        }

        for task in _undoTasks {
            task.clear()
        }

        _undoTasks.removeAll()

        _currentTask = 0

        _cleared(sender: self)
    }

    /// Clear all redo tasks currently stored on this `UndoSystem`
    private func clearRedos() {
        if _currentTask == _undoTasks.count {
            return
        }

        for i in _currentTask..<count {
            _undoTasks[i].clear()
        }

        _undoTasks.removeSubrange(_currentTask..<count)
    }

    private func checkReentry() {
        if _isDoingWork {
            fatalError("Re-entry in undo system")
        }
    }
}

/// Arguments for the UndoRegistered event
public struct UndoEventArgs {
    /// Gets or sets the task associated with this event
    public var task: UndoTask
}
