import Foundation
import CassowarySwift

public class LayoutConstraintSolverCache {
    internal let solver: Solver

    private var _constraintSet: [LayoutConstraint: ConstraintState] = [:]
    private var _previousConstraintSet: [LayoutConstraint: ConstraintState] = [:]

    private var viewConstraintList: [ObjectIdentifier: ViewConstraintList] = [:]
    private var previousViewConstraintList: [ObjectIdentifier: ViewConstraintList] = [:]

    public init() {
        solver = Solver()
    }

    internal func saveState() {
        _previousConstraintSet = _constraintSet
        previousViewConstraintList = viewConstraintList.mapValues { $0.clone() }

        _constraintSet.removeAll(keepingCapacity: true)
        viewConstraintList.removeAll(keepingCapacity: true)
    }

    internal func compareState() -> CacheStateDiff {
        return _compareState()
    }

    private func _compareState() -> CacheStateDiff {
        let constDiff = _compareConstraints()
        let viewStateDiff = _compareViewState()

        return CacheStateDiff(constraintDiffs: constDiff, viewStateDiffs: viewStateDiff)
    }

    private func _compareConstraints() -> [KeyedDifference<LayoutConstraint, ConstraintState>] {
        var addedList: [(LayoutConstraint, ConstraintState)] = []
        var updatedList: [(LayoutConstraint, old: ConstraintState, new: ConstraintState)] = []
        var removedList: [(LayoutConstraint, ConstraintState)] = []

        _constraintSet
            .makeDifference(
                withPrevious: _previousConstraintSet,
                addedList: &addedList,
                updatedList: &updatedList,
                removedList: &removedList
            ) { (_, old, new) in
                return old.definition == new.definition && old.constraint.hasSameEffects(as: new.constraint)
            }

        var constDiff: [KeyedDifference<LayoutConstraint, ConstraintState>] = []

        // Cross-check newly-added constraints can be interpreted as one of the
        // constraints that where removed
        for (added, addedState) in addedList {
            var found = false
            for (i, (removed, removedState)) in removedList.enumerated() where addedState.definition == removedState.definition {
                removedList.remove(at: i)
                _constraintSet[removed] = removedState
                found = true
                break
            }

            if !found {
                constDiff.append(.added(added, addedState))
            }
        }

        // Prepend removals as they need to occur before additions in the solver
        // change function
        constDiff = removedList.map(KeyedDifference.removed) + constDiff + updatedList.map(KeyedDifference.updated)

        return constDiff
    }

    private func _compareViewState() -> [ViewConstraintList.StateDiff] {
        var viewDiff: [ViewConstraintList.StateDiff] = []

        for (key, value) in viewConstraintList {
            let diff: ViewConstraintList.StateDiff
            if let oldValue = previousViewConstraintList[key] {
                diff = value.state.makeDiff(previous: oldValue.state)
            } else {
                diff = value.state.makeDiffFromEmpty()
            }

            if !diff.isEmpty {
                viewDiff.append(diff)
            }
        }
        for (key, value) in previousViewConstraintList where viewConstraintList[key] == nil {
            let diff = value.state.makeDiffToEmpty()

            if !diff.isEmpty {
                viewDiff.append(diff)
            }
        }

        return viewDiff
    }

    internal func constraintList(for container: LayoutVariablesContainer) -> ViewConstraintList {
        let identifier = ObjectIdentifier(container)

        // Check previous list to copy over old state first
        if let previous = previousViewConstraintList[identifier] {
            let list = previous.clone()

            viewConstraintList[identifier] = list

            return list
        }

        if let list = viewConstraintList[identifier] {
            return list
        }

        let list = ViewConstraintList(container: container)
        viewConstraintList[identifier] = list
        return list
    }

    internal func updateSolver(_ diff: CacheStateDiff) throws {
        let transaction = solver.startTransaction()

        for constDiff in diff.constraintDiffs {
            switch constDiff {
            case .added(_, let constraint):
                transaction.addConstraint(constraint.constraint)

            case .removed(_, let constraint):
                transaction.removeConstraint(constraint.constraint)

            case .updated(_, let old, let new):
                transaction.removeConstraint(old.constraint)
                transaction.addConstraint(new.constraint)
            }
        }

        for viewDiff in diff.viewStateDiffs {
            for constDiff in viewDiff.constraints {
                switch constDiff {
                case let .added(_, (const, priority)):
                    transaction.addConstraint(const.setStrength(priority))

                case .removed(_, (let const, _)):
                    transaction.removeConstraint(const)

                case let .updated(_, old, new):
                    transaction.removeConstraint(old.0)
                    transaction.addConstraint(new.0.setStrength(new.1))
                }
            }

            for varDiff in viewDiff.suggestedValues {
                switch varDiff {
                case let .added(variable, (value, strength)):
                    transaction.addEditVariable(variable, strength: strength)
                    transaction.suggestValue(variable, value: value)

                case let .updated(variable, old, new):
                    if old.strength != new.strength {
                        transaction.removeEditVariable(variable)
                        transaction.addEditVariable(variable, strength: new.strength)
                    }

                    transaction.suggestValue(variable, value: new.value)

                case .removed(let variable, _):
                    transaction.removeEditVariable(variable)
                }
            }
        }

        // For debugging purposes
        #if !DUMP_CONSTRAINTS_TO_DESKTOP

        do {
            let data = try SolverSerializer.serialize(transaction: transaction)
            let pathTransactions = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Desktop")
                .appendingPathComponent("ImagineUI_constraint_transactions")
                .appendingPathExtension("json")

            if let existing = FileManager.default.contents(atPath: pathTransactions.path) {
                let newFile = existing + ",".data(using: .utf8)! + data
                try FileManager.default.removeItem(at: pathTransactions)
                FileManager.default.createFile(atPath: pathTransactions.path, contents: newFile)
            } else {
                let newFile = "[".data(using: .utf8)! + data
                FileManager.default.createFile(atPath: pathTransactions.path, contents: newFile)
            }
        }

        #endif // DUMP_CONSTRAINTS_TO_DESKTOP

        try transaction.apply()

        #if !DUMP_CONSTRAINTS_TO_DESKTOP

        do {
            var variables: [Variable] = []
            for viewConstraint in viewConstraintList.values {
                variables.append(contentsOf: viewConstraint.container.layoutVariables.allVariables)
            }

            let dataVariables = try JSONEncoder().encode(variables)
            let pathVariables = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Desktop")
                .appendingPathComponent("ImagineUI_constraint_variables")
                .appendingPathExtension("json")

            if let existing = FileManager.default.contents(atPath: pathVariables.path) {
                let newFile = existing + ",".data(using: .utf8)! + dataVariables
                try FileManager.default.removeItem(at: pathVariables)
                FileManager.default.createFile(atPath: pathVariables.path, contents: newFile)
            } else {
                let newFile = "[".data(using: .utf8)! + dataVariables
                FileManager.default.createFile(atPath: pathVariables.path, contents: newFile)
            }
        }

        #endif // DUMP_CONSTRAINTS_TO_DESKTOP
    }

    internal func inspectConstraints(_ constraints: [LayoutConstraint]) {
        for constraint in constraints {
            _inspectConstraint(constraint)
        }
    }

    private func _inspectConstraint(_ layoutConstraint: LayoutConstraint) {
        if !layoutConstraint.isEnabled {
            return
        }

        guard let constraint = layoutConstraint.createConstraint() else {
            return
        }

        if let previous = _previousConstraintSet[layoutConstraint], previous.definition == layoutConstraint.definition {
            _constraintSet[layoutConstraint] = previous
        } else {
            _constraintSet[layoutConstraint] = ConstraintState(
                constraint: constraint,
                definition: layoutConstraint.definition
            )
        }
    }

    struct ConstraintState {
        var constraint: Constraint
        var definition: LayoutConstraint.Definition
    }
}

extension LayoutConstraintSolverCache {
    internal struct CacheStateDiff {
        var constraintDiffs: [KeyedDifference<LayoutConstraint, ConstraintState>]
        var viewStateDiffs: [ViewConstraintList.StateDiff]
    }
}
