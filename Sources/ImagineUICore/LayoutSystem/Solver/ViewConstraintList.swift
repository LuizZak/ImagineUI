import CassowarySwift

class ViewConstraintList: ViewConstraintCollectorType {
    var orientations: Set<LayoutConstraintOrientation>
    var state: State = State()

    init(orientations: Set<LayoutConstraintOrientation>) {
        self.orientations = orientations
    }

    fileprivate init(state: State, orientations: Set<LayoutConstraintOrientation>) {
        self.state = state
        self.orientations = orientations
    }

    func clone() -> ViewConstraintList {
        return ViewConstraintList(state: state, orientations: orientations)
    }

    /// Adds a constraint with a given name and strength.
    func addConstraint(_ constraint: Constraint,
                       tag: String,
                       orientation: LayoutConstraintOrientation) {

        if !orientations.contains(orientation) {
            return
        }

        state.constraints[tag] = constraint
    }

    func suggestValue(_ variable: Variable,
                      value: Double,
                      strength: Double,
                      orientation: LayoutConstraintOrientation) {

        if !orientations.contains(orientation) {
            return
        }

        state.suggestedValue[variable] = (value, strength)
    }

    func apply(diff: StateDiff) {
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
}

extension ViewConstraintList {
    struct State {
        var constraints: [String: Constraint] = [:]
        var suggestedValue: [Variable: (value: Double, strength: Double)] = [:]

        func makeDiffFromEmpty() -> StateDiff {
            return makeDiff(previous: State())
        }

        func makeDiffToEmpty() -> StateDiff {
            return State().makeDiff(previous: self)
        }

        func makeDiff(previous: State) -> StateDiff {
            let constDiff =
                constraints.makeDifference(
                    withPrevious: previous.constraints,
                    areEqual: { $1.hasSameEffects(as: $2) }
                )

            let suggestedDiff =
                suggestedValue.makeDifference(
                    withPrevious: previous.suggestedValue,
                    areEqual: { $1 == $2 }
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
