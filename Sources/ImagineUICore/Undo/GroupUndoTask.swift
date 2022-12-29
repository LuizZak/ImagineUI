/// An undo task that encloses multiple `UndoTask`s in it
public class GroupUndoTask: UndoTask {
    /// The description for this `GroupUndoTask` instance
    private var _description: String

    /// Gets or sets a value specifying whether to discard the undo group if
    /// it's opened on an `UndoSystem` while it receives an undo/redo call
    public var discardOnOperation: Bool

    /// Gets or sets whether to reverse the order of the operations on undo
    public var reverseOnUndo: Bool

    /// The list of undo tasks enclosed in this `GroupUndoTask`
    private(set) public var undoList: [UndoTask]

    /// Initializes a new instance of the `GroupUndoTask` class with a description
    ///
    /// - Parameter description: The description for this `GroupUndoTask`
    public init(description: String) {
        undoList = []
        _description = description
        discardOnOperation = false
        reverseOnUndo = true
    }

    /// Initializes a new instance of the `GroupUndoTask` class with a list of
    /// tasks to perform and a description
    ///
    /// - Parameters:
    ///   - tasks: The tasks to perform
    ///   - description: The description for this `GroupUndoTask`
    ///   - discardOnOperation: Whether to discard the undo group if it's opened
    ///   on an UndoSystem while it receives an undo/redo call
    ///   - reverseOnUndo: Whether to perform the undo operations in the reverse
    ///   order the tasks where added
    public init(tasks: [UndoTask], description: String, discardOnOperation: Bool = false, reverseOnUndo: Bool = true) {
        undoList = tasks
        _description = description
        self.discardOnOperation = discardOnOperation
        self.reverseOnUndo = reverseOnUndo
    }

    /// Adds a new task on this `GroupUndoTask`
    ///
    /// - Parameter task: The task to add to this `GroupUndoTask`
    public func addTask(_ task: UndoTask) {
        assert(task as AnyObject !== self, "task as AnyObject !== self")

        undoList.append(task)
    }

    /// Adds a list of tasks on this `GroupUndoTask`
    ///
    /// - Parameter tasks: The tasks to add to this `GroupUndoTask`
    public func addTasks(_ tasks: [UndoTask]) {
        for task in tasks {
            addTask(task)
        }
    }

    /// Clears this UndoTask object
    public func clear() {
        for task in undoList {
            task.clear()
        }

        undoList.removeAll()
    }

    /// Undoes this task
    public func undo() {
        if reverseOnUndo {
            // Undo in reverse order (last to first)
            for task in undoList.reversed() {
                task.undo()
            }
        } else {
            for task in undoList {
                task.undo()
            }
        }
    }

    /// Redoes this task
    public func redo() {
        for task in undoList {
            task.redo()
        }
    }

    /// Returns a short string description of this UndoTask
    public func getDescription() -> String {
        return _description
    }
}
