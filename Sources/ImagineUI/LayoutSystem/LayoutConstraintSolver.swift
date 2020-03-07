import Cassowary

public class LayoutConstraintSolver {
    public func solve(viewHierarchy: View, cache: LayoutConstraintSolverCache? = nil) {
        let visitor = ClosureViewVisitor<ConstraintCollection> { collection, view in
            collection.affectedLayoutVariables.append(view.layoutVariables)

            collection.constraints.append(contentsOf:
                view.containedConstraints.lazy.filter { $0.isEnabled }
            )
        }

        let result = ConstraintCollection()
        let traveler = ViewTraveler(state: result, visitor: visitor)

        traveler.visit(view: viewHierarchy)
        
        let locCache = cache ?? LayoutConstraintSolverCache()
        
        locCache.saveState()
        
        register(constraints: result.constraints,
                 affectedViews: result.affectedLayoutVariables,
                 cache: locCache)

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

    private func register(constraints: [LayoutConstraint],
                          affectedViews: [ViewLayoutVariables],
                          cache: LayoutConstraintSolverCache) {

        for affectedView in affectedViews {
            affectedView.deriveConstraints(cache.constraintList(for: affectedView.view))
        }
        
        cache.addConstraints(constraints)
    }
}

private class ConstraintCollection {
    var affectedLayoutVariables: [ViewLayoutVariables] = []
    var constraints: [LayoutConstraint] = []
}

class ViewConstraintList {
    let view: View
    fileprivate var state: State = State()
    
    init(view: View) {
        self.view = view
    }
    
    func clone() -> ViewConstraintList {
        let new = ViewConstraintList(view: view)
        new.state = state
        return new
    }
    
    /// Adds a constraint with a given name and strength, and optionally a tag
    /// to diferentiate constraints with the same name that must be refreshed to
    /// a new constraint.
    ///
    /// Tags should be the same across constraints with the same terms to mantain
    /// consistency and allow different terms to be correctly detected and updated
    /// accordingly.
    func addConstraint(name: String,
                       _ constraint: @autoclosure () -> Constraint,
                       strength: Double,
                       tag: Int = 0) {
        
        let current = state.constraints[name]
        
        if current?.strength != strength || current?.tag != tag {
            state.constraints[name] = (constraint(), strength, tag)
        }
    }
    
    func suggestValue(variable: Variable, value: Double, strength: Double) {
        state.suggestedValue[variable] = (value, strength)
    }
    
    fileprivate struct State {
        var constraints: [String: (Constraint, strength: Double, tag: Int)] = [:]
        var suggestedValue: [Variable: (value: Double, strength: Double)] = [:]
        
        func makeDiffFromEmpty() -> StateDiff {
            return makeDiff(previous: State())
        }
        
        func makeDiffToEmpty() -> StateDiff {
            return State().makeDiff(previous: self)
        }
        
        func makeDiff(previous: State) -> StateDiff {
            let constDiff = constraints.makeDifference(withPrevious: previous.constraints,
                                                       didUpdate: { $1.1 != $2.1 || $1.2 != $2.2 })
            
            let suggestedDiff = suggestedValue.makeDifference(withPrevious: previous.suggestedValue,
                                                              didUpdate: { $1 != $2 })
            
            return StateDiff(constraints: constDiff, suggestedValues: suggestedDiff)
        }
    }
    
    fileprivate struct StateDiff {
        var constraints: [Difference<String, (Constraint, strength: Double, tag: Int)>]
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
    
    internal func constraintList(for view: View) -> ViewConstraintList {
        let identifier = ObjectIdentifier(view)
        
        // Check previous list to copy over old state first
        if let previous = previousViewConstraintList[identifier] {
            let list = previous.clone()
            
            viewConstraintList[identifier] = list
            
            return list
        }
        
        if let list = viewConstraintList[identifier] {
            return list
        }
        
        let list = ViewConstraintList(view: view)
        viewConstraintList[identifier] = list
        return list
    }
    
    fileprivate func updateSolver(_ diff: StateDiff) throws {
        for constDiff in diff.constraintDiffs {
            switch constDiff {
            case .added(_, let constraintDef):
                try solver.addConstraint(constraintDef.constraint)
                
            case .removed(_, let constraintDef):
                try solver.removeConstraint(constraintDef.constraint)
                
            case let .updated(_, old, new):
                try solver.removeConstraint(old.constraint)
                try solver.addConstraint(new.constraint)
            }
        }
        
        for viewDiff in diff.viewStateDiffs {
            for constDiff in viewDiff.constraints {
                switch constDiff {
                case let .added(_, (const, priority, _)):
                    try solver.addConstraint(const.setStrength(priority))
                    
                case .removed(_, (let const, _, _)):
                    try solver.removeConstraint(const)
                    
                case let .updated(_, old, new):
                    try solver.removeConstraint(old.0)
                    try solver.addConstraint(new.0.setStrength(new.1))
                }
            }
            
            for varDiff in viewDiff.suggestedValues {
                switch varDiff {
                case let .added(variable, (value, strength)):
                    try solver.addEditVariable(variable: variable, strength: strength)
                    try solver.suggestValue(variable: variable, value: value)
                    
                case let .updated(variable, old, new):
                    if old.strength != new.strength {
                        try solver.removeEditVariable(variable)
                        try solver.addEditVariable(variable: variable, strength: new.strength)
                    }
                    
                    try solver.suggestValue(variable: variable, value: new.value)
                    
                case .removed(let variable, _):
                    try solver.removeEditVariable(variable)
                }
            }
        }
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
        
        let definition = toDefinition(constraint)
        constraintDefinitionsMap[constraint] = definition
    }
    
    private func toDefinition(_ layoutConstraint: LayoutConstraint) -> ConstraintDefinition {
        ConstraintDefinition(constraint: layoutConstraint.getOrCreateCachedConstraint(),
                             containerView: layoutConstraint.containerView,
                             first: layoutConstraint.firstCast,
                             second: layoutConstraint.secondCast,
                             relationship: layoutConstraint.relationship,
                             offset: layoutConstraint.offset,
                             multiplier: layoutConstraint.multiplier,
                             priority: layoutConstraint.priority,
                             isEnabled: layoutConstraint.isEnabled)
    }
    
    fileprivate struct ConstraintDefinition: Equatable {
        var constraint: Constraint
        var containerView: View
        var first: InternalLayoutAnchor
        var second: InternalLayoutAnchor?
        var relationship: Relationship
        var offset: Double
        var multiplier: Double 
        var priority: Double
        var isEnabled: Bool
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
