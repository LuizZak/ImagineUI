import Foundation
import CassowarySwift

public class LayoutConstraintSolverCache {
    private var cacheState: CacheType

    public init() {
        cacheState = .split(horizontal: _LayoutConstraintSolverCache(), vertical: _LayoutConstraintSolverCache())
    }

    func update(fromView view: View) throws -> ConstraintCollection {
        let visitor = ConstraintViewVisitor(rootView: view)
        let traveler = ViewTraveler(state: ConstraintCollection(), visitor: visitor)
        traveler.travelThrough(view: view)

        try update(result: traveler.state, rootSpatialReference: view)

        return traveler.state
    }

    private func update(result: ConstraintCollection, rootSpatialReference: View?) throws {
        saveState()
        register(result: result, rootSpatialReference: rootSpatialReference)

        try compareAndApplyStates()

        updateVariables()
    }

    private func updateVariables() {
        withCaches {
            $0.updateVariables()
        }
    }

    private func saveState() {
        withCaches {
            $0.saveState()
        }
    }

    private func register(result: ConstraintCollection, rootSpatialReference: View?) {
        if _hasMixedConstraints(result) {
            let mixed: _LayoutConstraintSolverCache

            switch cacheState {
            case .mixed(let cache):
                mixed = cache

            case .split:
                // TODO: Do a cache merge instead of creating one from scratch.
                mixed = _LayoutConstraintSolverCache()
                mixed.saveState()
            }

            mixed.register(result: result, orientations: [.horizontal, .vertical, .mixed], rootSpatialReference: rootSpatialReference)
            cacheState = .mixed(mixed)
        } else {
            let horizontal: _LayoutConstraintSolverCache
            let vertical: _LayoutConstraintSolverCache

            switch cacheState {
            case .mixed:
                horizontal = _LayoutConstraintSolverCache()
                vertical = _LayoutConstraintSolverCache()

                horizontal.saveState()
                vertical.saveState()

            case .split(let h, let v):
                horizontal = h
                vertical = v
            }

            horizontal.register(result: result, orientations: [.horizontal], rootSpatialReference: rootSpatialReference)
            vertical.register(result: result, orientations: [.vertical], rootSpatialReference: rootSpatialReference)

            cacheState = .split(horizontal: horizontal, vertical: vertical)
        }
    }

    private func compareAndApplyStates() throws {
        switch cacheState {
        case .mixed(let cache):
            try cache.compareAndApplyStates(orientations: [.horizontal, .vertical, .mixed])

        case .split(let horizontal, let vertical):

            #if DUMP_CONSTRAINTS_TO_DESKTOP // For debugging purposes; .compareAndApplyStates() must be run sequentially on the same thread due to potential dump file contention.

            try horizontal.compareAndApplyStates(orientations: [.horizontal])
            try vertical.compareAndApplyStates(orientations: [.vertical])

            #else // DUMP_CONSTRAINTS_TO_DESKTOP

            var horizontalResult: Result<Void, Error> = .success(())
            var verticalResult: Result<Void, Error> = .success(())

            let queue = OperationQueue()
            queue.addOperation {
                horizontalResult = Result<Void, Error>.init {
                    try horizontal.compareAndApplyStates(orientations: [.horizontal])
                }
            }
            queue.addOperation {
                verticalResult = Result<Void, Error>.init {
                    try vertical.compareAndApplyStates(orientations: [.vertical])
                }
            }

            queue.waitUntilAllOperationsAreFinished()

            try horizontalResult.get()
            try verticalResult.get()

            #endif // DUMP_CONSTRAINTS_TO_DESKTOP
        }
    }

    private func _hasMixedConstraints(_ collection: ConstraintCollection) -> Bool {
        return collection.constraints.contains { $0.constraintOrientation == .mixed }
    }

    /// Applies the same closure to all caches currently registered.
    private func withCaches(_ block: (_LayoutConstraintSolverCache) throws -> Void) rethrows {
        switch cacheState {
        case .mixed(let cache):
            try block(cache)

        case .split(let horizontal, let vertical):
            try block(horizontal)
            try block(vertical)
        }
    }

    private enum CacheType {
        // Cache for horizontal and vertical constraints.
        case mixed(_LayoutConstraintSolverCache)

        // Separate caches for horizontal/vertical constraints.
        case split(horizontal: _LayoutConstraintSolverCache, vertical: _LayoutConstraintSolverCache)
    }

    private struct ConstraintViewVisitor: ViewVisitor {
        var rootView: View

        init(rootView: View) {
            self.rootView = rootView
        }

        func shouldVisitView(_ view: View, _ state: State) -> Bool {
            if view === rootView {
                return true
            }

            // Stop short at the boundaries to independent layout systems.
            return !view.hasIndependentInternalLayout()
        }

        func visitView(_ view: View, _ collection: inout ConstraintCollection) -> ViewVisitorResult {
            // Ignore fully static views that do not participate in the overall
            // layout system
            if !(view.areaIntoConstraintsMask == Set(BoundsConstraintMask.allCases) && view.constraints.isEmpty) {
                collection.affectedLayoutVariables.append(view.layoutVariables)
            } else {
                collection.fixedLayoutVariables.append(view.layoutVariables)
            }

            for guide in view.layoutGuides {
                collection.affectedLayoutVariables.append(guide.layoutVariables)
            }

            for constraint in view.containedConstraints where constraint.isEnabled {
                collection.constraints.append(constraint)
            }

            return .visitChildren
        }
    }
}

fileprivate class _LayoutConstraintSolverCache {
    private var _constraintSet: [LayoutConstraint: ConstraintState] = [:]
    private var _previousConstraintSet: [LayoutConstraint: ConstraintState] = [:]

    private var _viewConstraintList: [LayoutVariables: ViewConstraintList] = [:]
    private var _previousViewConstraintList: [LayoutVariables: ViewConstraintList] = [:]

    private let solver: Solver

    public init() {
        solver = Solver()
    }

    internal func updateVariables() {
        solver.updateVariables()
    }

    internal func saveState() {
        _previousConstraintSet = _constraintSet
        _previousViewConstraintList = _viewConstraintList.mapValues { $0.clone() }

        _constraintSet.removeAll(keepingCapacity: true)
        _viewConstraintList.removeAll(keepingCapacity: true)
    }

    internal func register(result: ConstraintCollection, orientations: Set<LayoutConstraintOrientation>, rootSpatialReference: View?) {
        for affectedView in result.affectedLayoutVariables {
            let viewConstraintList = constraintList(for: affectedView.container, orientations: orientations)
            affectedView.deriveConstraints(viewConstraintList, rootSpatialReference: rootSpatialReference)
        }

        _registerConstraints(result.constraints, orientations: orientations)
    }

    internal func compareAndApplyStates(orientations: Set<LayoutConstraintOrientation>) throws {
        let diff = compareState()

        try updateSolver(diff)

        // TODO: Refactor view constraint state to work around a quirk where the
        // TODO: new state must not replace the old state as it would end up losing
        // TODO: reference to Constraint instance identity.
        for (id, viewList) in _viewConstraintList where _previousViewConstraintList[id] == nil {
            _previousViewConstraintList[id] = viewList.clone()
        }

        for (id, viewDiff) in diff.viewStateDiffs {
            _previousViewConstraintList[id]?.apply(diff: viewDiff)
        }

        _viewConstraintList = _previousViewConstraintList.mapValues { $0.clone() }
        _previousViewConstraintList.removeAll(keepingCapacity: true)
    }

    /* TODO: Implement cache merging to speedup merging of mixed constraint sets.

    /// Returns a new _LayoutConstraintSolverCache which represents the merging
    /// of this and another solver cache.
    internal func merge(with other: _LayoutConstraintSolverCache) -> _LayoutConstraintSolverCache {
        var result = _LayoutConstraintSolverCache()
        result._previousConstraintSet =
            self._previousConstraintSet.merging(other._previousConstraintSet) { (_, second) in
                return second
            }

        result._constraintSet =
            self._constraintSet.merging(other._constraintSet) { (_, second) in
                return second
            }

        result._previousViewConstraintList =
            self._previousViewConstraintList.merging(other._previousViewConstraintList) { (_, second) in
                return second
            }

        result._viewConstraintList =
            self._viewConstraintList.merging(other._viewConstraintList) { (_, second) in
                return second
            }

        return result
    }
    */

    private func compareState() -> CacheStateDiff {
        return _compareState()
    }

    private func constraintList(for container: LayoutVariablesContainer, orientations: Set<LayoutConstraintOrientation>) -> ViewConstraintList {
        let identifier: LayoutVariables = container.layoutVariables

        if let list = _viewConstraintList[identifier], list.orientations == orientations {
            return list
        }

        let list = ViewConstraintList(orientations: orientations)
        _viewConstraintList[identifier] = list
        return list
    }

    private func updateSolver(_ diff: CacheStateDiff) throws {
        let transaction = solver.startTransaction()

        // Process removals first
        for constDiff in diff.constraintDiffs {
            switch constDiff {
            case .removed(_, let constraint):
                transaction.removeConstraint(constraint.constraint)

            case .updated(_, let old, _):
                transaction.removeConstraint(old.constraint)

            case .added:
                break
            }
        }

        for (_, viewDiff) in diff.viewStateDiffs {
            for constDiff in viewDiff.constraints {
                switch constDiff {
                case .removed(_, let const):
                    transaction.removeConstraint(const)

                case let .updated(_, old, _):
                    transaction.removeConstraint(old)

                case .added:
                    break
                }
            }

            for varDiff in viewDiff.suggestedValues {
                switch varDiff {
                case let .updated(variable, old, new):
                    if old.strength != new.strength {
                        transaction.removeEditVariable(variable)
                    }

                case .removed(let variable, _):
                    transaction.removeEditVariable(variable)

                case .added:
                    break
                }
            }
        }

        // Process rest of constraints
        for constDiff in diff.constraintDiffs {
            switch constDiff {
            case .added(_, let constraint):
                transaction.addConstraint(constraint.constraint)

            case .removed:
                break // Already handled above

            case .updated(_, _, let new):
                transaction.addConstraint(new.constraint)
            }
        }

        for (_, viewDiff) in diff.viewStateDiffs {
            for constDiff in viewDiff.constraints {
                switch constDiff {
                case let .added(_, const):
                    transaction.addConstraint(const)

                case .removed(_, _):
                    break // Already handled above

                case let .updated(_, _, new):
                    transaction.addConstraint(new)
                }
            }

            for varDiff in viewDiff.suggestedValues {
                switch varDiff {
                case let .added(variable, (value, strength)):
                    transaction.addEditVariable(variable, strength: strength)
                    transaction.suggestValue(variable, value: value)

                case let .updated(variable, old, new):
                    if old.strength != new.strength {
                        transaction.addEditVariable(variable, strength: new.strength)
                    }

                    transaction.suggestValue(variable, value: new.value)

                case .removed:
                    break // Already handled above
                }
            }
        }

        #if DUMP_CONSTRAINTS_TO_DESKTOP // For debugging purposes

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

        try transaction.apply()

        do {
            var variables: [Variable] = []
            for viewConstraint in _viewConstraintList.values {
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

        #else // DUMP_CONSTRAINTS_TO_DESKTOP

        try transaction.apply()

        #endif // DUMP_CONSTRAINTS_TO_DESKTOP
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

        constDiff += removedList.map(KeyedDifference.removed) + updatedList.map(KeyedDifference.updated)

        return constDiff
    }

    private func _compareViewState() -> [(LayoutVariables, ViewConstraintList.StateDiff)] {
        var viewDiff: [(LayoutVariables, ViewConstraintList.StateDiff)] = []

        for (key, value) in _viewConstraintList {
            let diff: ViewConstraintList.StateDiff
            if let oldValue = _previousViewConstraintList[key] {
                diff = value.state.makeDiff(previous: oldValue.state)
            } else {
                diff = value.state.makeDiffFromEmpty()
            }

            if !diff.isEmpty {
                viewDiff.append((key, diff))
            }
        }
        for (key, value) in _previousViewConstraintList where _viewConstraintList[key] == nil {
            let diff = value.state.makeDiffToEmpty()

            if !diff.isEmpty {
                viewDiff.append((key, diff))
            }
        }

        return viewDiff
    }

    private func _registerConstraints(_ constraints: [LayoutConstraint], orientations: Set<LayoutConstraintOrientation>) {
        for constraint in constraints {
            if orientations.contains(constraint.constraintOrientation) {
                _registerConstraint(constraint)
            }
        }
    }

    private func _registerConstraint(_ layoutConstraint: LayoutConstraint) {
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

    private struct ConstraintState {
        var constraint: Constraint
        var definition: LayoutConstraint.Definition
    }

    private struct CacheStateDiff {
        var constraintDiffs: [KeyedDifference<LayoutConstraint, ConstraintState>]
        var viewStateDiffs: [(LayoutVariables, ViewConstraintList.StateDiff)]
    }
}
