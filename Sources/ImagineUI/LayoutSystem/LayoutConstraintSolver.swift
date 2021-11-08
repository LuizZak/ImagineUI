import CassowarySwift
import Foundation

public class LayoutConstraintSolver {
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let visitor = ClosureViewVisitor<ConstraintCollection> { collection, view in
            collection.affectedLayoutVariables.append(view.layoutVariables)
            for guide in view.layoutGuides {
                collection.affectedLayoutVariables.append(guide.layoutVariables)
            }

            for constraint in view.containedConstraints where constraint.isEnabled {
                collection.constraints.append(constraint)
            }
        }
        let result = ConstraintCollection()
        let traveler = ViewTraveler(state: result, visitor: visitor)
        traveler.travelThrough(view: viewHierarchy)

        let locCache = cache ?? LayoutConstraintSolverCache()

        locCache.saveState()

        register(result: result, cache: locCache)

        let diff = locCache.compareState()

        do {
            try locCache.updateSolver(diff)

            locCache.solver.updateVariables()
        } catch {
            print("Error solving layout constraints: \(error)")
        }

        for view in result.affectedLayoutVariables {
            view.applyVariables()
        }
    }

    private func register(result: ConstraintCollection,
                          cache: LayoutConstraintSolverCache) {

        for affectedView in result.affectedLayoutVariables {
            affectedView.deriveConstraints(cache.constraintList(for: affectedView.container))
        }

        cache.addConstraints(result.constraints)
    }
}

private class ConstraintCollection {
    var affectedLayoutVariables: [LayoutVariables] = []
    var constraints: [LayoutConstraint] = []
}

class ViewConstraintList {
    let container: LayoutVariablesContainer
    fileprivate var state: State = State()

    init(container: LayoutVariablesContainer) {
        self.container = container
    }

    fileprivate init(container: LayoutVariablesContainer, state: State) {
        self.container = container
        self.state = state
    }

    func clone() -> ViewConstraintList {
        return ViewConstraintList(container: container, state: state)
    }

    /// Adds a constraint with a given name and strength.
    func addConstraint(name: String,
                       _ constraint: @autoclosure () -> Constraint,
                       strength: Double) {

        let current = state.constraints[name]

        if current?.strength != strength {
            state.constraints[name] = (constraint(), strength)
        }
    }

    func suggestValue(variable: Variable, value: Double, strength: Double) {
        state.suggestedValue[variable] = (value, strength)
    }

    fileprivate struct State {
        var constraints: [String: (Constraint, strength: Double)] = [:]
        var suggestedValue: [Variable: (value: Double, strength: Double)] = [:]

        func makeDiffFromEmpty() -> StateDiff {
            return makeDiff(previous: State())
        }

        func makeDiffToEmpty() -> StateDiff {
            return State().makeDiff(previous: self)
        }

        func makeDiff(previous: State) -> StateDiff {
            let constDiff = constraints.makeDifference(withPrevious: previous.constraints,
                                                       didUpdate: { $1.1 != $2.1 })

            let suggestedDiff = suggestedValue.makeDifference(withPrevious: previous.suggestedValue,
                                                              didUpdate: { $1 != $2 })

            return StateDiff(constraints: constDiff, suggestedValues: suggestedDiff)
        }
    }

    fileprivate struct StateDiff {
        var constraints: [Difference<String, (Constraint, strength: Double)>]
        var suggestedValues: [Difference<Variable, (value: Double, strength: Double)>]

        var isEmpty: Bool {
            return constraints.isEmpty && suggestedValues.isEmpty
        }
    }
}

public class LayoutConstraintSolverCache {
    let solver: Solver

    private var constraintDefinitionsMap: [LayoutConstraint: ConstraintDefinition] = [:]
    private var previousConstraintDefinitionsMap: [LayoutConstraint: ConstraintDefinition] = [:]

    private var viewConstraintList: [ObjectIdentifier: ViewConstraintList] = [:]
    private var previousViewConstraintList: [ObjectIdentifier: ViewConstraintList] = [:]

    public init() {
        solver = Solver()
    }

    fileprivate func saveState() {
        previousConstraintDefinitionsMap = constraintDefinitionsMap
        previousViewConstraintList = viewConstraintList.mapValues { $0.clone() }

        constraintDefinitionsMap = Dictionary(minimumCapacity: previousConstraintDefinitionsMap.count)
        viewConstraintList = Dictionary(minimumCapacity: previousViewConstraintList.count)
    }

    fileprivate func compareState() -> StateDiff {
        var constDiff: [Difference<LayoutConstraint, ConstraintDefinition>] = []
        var viewDiff: [ViewConstraintList.StateDiff] = []

        constDiff = constraintDefinitionsMap.makeDifference(withPrevious: previousConstraintDefinitionsMap)

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

        return StateDiff(constraintDiffs: constDiff, viewStateDiffs: viewDiff)
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

    fileprivate func updateSolver(_ diff: StateDiff) throws {
        let transaction = solver.startTransaction()

        for constDiff in diff.constraintDiffs {
            switch constDiff {
            case .added(_, let constraintDef):
                transaction.addConstraint(constraintDef.constraint)

            case .removed(_, let constraintDef):
                transaction.removeConstraint(constraintDef.constraint)

            case let .updated(_, old, new):
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
        #if DUMP_CONSTRAINTS_TO_DESKTOP

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

        #if DUMP_CONSTRAINTS_TO_DESKTOP

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

    fileprivate func addConstraints(_ constraints: [LayoutConstraint]) {
        for constraint in constraints {
            addConstraint(constraint)
        }
    }

    private func addConstraint(_ constraint: LayoutConstraint) {
        if !constraint.isEnabled {
            return
        }
        if let previous = previousConstraintDefinitionsMap[constraint] {
            if previous.matches(constraint) {
                constraintDefinitionsMap[constraint] = previous
                return
            }
        }

        let definition = toDefinition(constraint)
        constraintDefinitionsMap[constraint] = definition
    }

    private func toDefinition(_ layoutConstraint: LayoutConstraint) -> ConstraintDefinition? {
        guard let constraint = layoutConstraint.getOrCreateCachedConstraint() else {
            return nil
        }

        return
            ConstraintDefinition(constraint: constraint,
                                 container: layoutConstraint.container,
                                 relationship: layoutConstraint.relationship,
                                 offset: layoutConstraint.offset,
                                 multiplier: layoutConstraint.multiplier,
                                 priority: layoutConstraint.priority)
    }

    fileprivate class ConstraintDefinition: Equatable {
        internal init(constraint: Constraint, container: LayoutVariablesContainer?,
                      relationship: Relationship, offset: Double,
                      multiplier: Double, priority: LayoutPriority) {

            self.constraint = constraint
            self.container = container
            self.relationship = relationship
            self.offset = offset
            self.multiplier = multiplier
            self.priority = priority
        }

        var constraint: Constraint
        var container: LayoutVariablesContainer?
        var relationship: Relationship
        var offset: Double
        var multiplier: Double
        var priority: LayoutPriority

        func matches(_ constraint: LayoutConstraint) -> Bool {
            return container === constraint.container
                && relationship == constraint.relationship
                && offset == constraint.offset
                && multiplier == constraint.multiplier
                && priority == constraint.priority
        }

        static func == (lhs: LayoutConstraintSolverCache.ConstraintDefinition,
                        rhs: LayoutConstraintSolverCache.ConstraintDefinition) -> Bool {

            return lhs.container === rhs.container
                && lhs.relationship == rhs.relationship
                && lhs.offset == rhs.offset
                && lhs.multiplier == rhs.multiplier
                && lhs.priority == rhs.priority
        }
    }

    fileprivate struct StateDiff {
        var constraintDiffs: [Difference<LayoutConstraint, ConstraintDefinition>]
        var viewStateDiffs: [ViewConstraintList.StateDiff]
    }
}

private enum Difference<Key, Value> {
    case removed(Key, Value)
    case added(Key, Value)
    case updated(Key, old: Value, new: Value)
}

private extension Dictionary {
    func makeDifference(withPrevious previous: Dictionary,
                        didUpdate: (Key, _ old: Value, _ new: Value) -> Bool) -> [Difference<Key, Value>] {

        var result: [Difference<Key, Value>] = []
        for (key, value) in self {
            if let older = previous[key] {
                if didUpdate(key, older, value) {
                    result.append(.updated(key, old: older, new: value))
                }
            } else {
                result.append(.added(key, value))
            }
        }

        for (key, value) in previous where self[key] == nil {
            result.append(.removed(key, value))
        }

        return result
    }
}

private extension Dictionary where Value: Equatable {
    func makeDifference(withPrevious previous: Dictionary) -> [Difference<Key, Value>] {
        return makeDifference(withPrevious: previous, didUpdate: { $1 != $2 })
    }
}
