import CassowarySwift

struct ViewConstraintList: ViewConstraintCollectorType {
    var orientations: Set<LayoutConstraintOrientation>
    var state: State = State()

    #if DUMP_CONSTRAINTS_TO_DESKTOP // For debugging purposes
    
    var container: LayoutVariablesContainer

    init(orientations: Set<LayoutConstraintOrientation>, container: LayoutVariablesContainer) {
        self.orientations = orientations
        self.container = container
    }

    fileprivate init(state: State, orientations: Set<LayoutConstraintOrientation>, container: LayoutVariablesContainer) {
        self.state = state
        self.orientations = orientations
        self.container = container
    }

    #else

    init(orientations: Set<LayoutConstraintOrientation>) {
        self.orientations = orientations
    }

    fileprivate init(state: State, orientations: Set<LayoutConstraintOrientation>) {
        self.state = state
        self.orientations = orientations
    }

    #endif // DUMP_CONSTRAINTS_TO_DESKTOP

    mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&state) {
            state = state.copy()
        }
    }

    /// Adds a constraint with a given name and strength.
    mutating func addConstraint(
        _ constraint: Constraint,
        tag: String,
        orientation: LayoutConstraintOrientation
    ) {
        ensureUnique()

        if !orientations.contains(orientation) {
            return
        }

        state.constraints[tag] = constraint
    }

    mutating func suggestValue(
        _ variable: Variable,
        value: Double,
        strength: Double,
        orientation: LayoutConstraintOrientation
    ) {
        ensureUnique()

        if !orientations.contains(orientation) {
            return
        }

        state.suggestedValue[variable] = (value, strength)
    }

    mutating func apply(diff: StateDiff) {
        ensureUnique()

        for constraintDiff in diff.constraints {
            switch constraintDiff {
            case let .added(key, constraint):
                state.constraints[key] = constraint

            case let .updated(key, _, new):
                state.constraints[key] = new

            case let .removed(key, _):
                state.constraints[key] = nil
            }
        }

        for suggestedValueDiff in diff.suggestedValues {
            switch suggestedValueDiff {
            case let .added(key, value):
                state.suggestedValue[key] = value

            case let .updated(key, _, new):
                state.suggestedValue[key] = new

            case let .removed(key, _):
                state.suggestedValue[key] = nil
            }
        }
    }
    
    class State {
        var constraints: [String: Constraint]
        var suggestedValue: [Variable: (value: Double, strength: Double)]

        init(
            constraints: [String: Constraint] = [:],
            suggestedValue: [Variable: (value: Double, strength: Double)] = [:]
        ) {
            self.constraints = constraints
            self.suggestedValue = suggestedValue
        }

        func copy() -> State {
            State(constraints: constraints, suggestedValue: suggestedValue)
        }

        func makeDiffFromEmpty() -> StateDiff {
            return makeDiff(previous: State())
        }

        func makeDiffToEmpty() -> StateDiff {
            return State().makeDiff(previous: self)
        }

        func makeDiff(previous: State) -> StateDiff {
            let constDiff = constraints.makeDifference(
                withPrevious: previous.constraints,
                areEqual: {
                    $1.hasSameEffects(as: $2)
                }
            )

            let suggestedDiff = suggestedValue.makeDifference(
                withPrevious: previous.suggestedValue,
                areEqual: {
                    $1 == $2
                }
            )

            return StateDiff(constraints: constDiff, suggestedValues: suggestedDiff)
        }
    }

    struct StateDiff {
        var constraints: [KeyedDifference<String, Constraint>]
        var suggestedValues: [KeyedDifference<Variable, (value: Double, strength: Double)>]

        var isEmpty: Bool {
            return constraints.isEmpty && suggestedValues.isEmpty
        }
    }
}
