import CassowarySwift

class ViewConstraintList {
    let container: LayoutVariablesContainer
    var state: State = State()

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
                       orientation: ConstraintOrientation,
                       _ constraint: @autoclosure () -> Constraint,
                       strength: Double) {

        let current = state.constraints[name]

        if current?.strength != strength {
            state.constraints[name] = (constraint(), strength)
        }
    }

    func suggestValue(variable: Variable,
                      orientation: ConstraintOrientation,
                      value: Double,
                      strength: Double) {

        state.suggestedValue[variable] = (value, strength)
    }
}

extension ViewConstraintList {
    struct State {
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
                                                       areEqual: { $1.1 == $2.1 })

            let suggestedDiff = suggestedValue.makeDifference(withPrevious: previous.suggestedValue,
                                                              areEqual: { $1 == $2 })

            return StateDiff(constraints: constDiff, suggestedValues: suggestedDiff)
        }
    }

    struct StateDiff {
        var constraints: [KeyedDifference<String, (Constraint, strength: Double)>]
        var suggestedValues: [KeyedDifference<Variable, (value: Double, strength: Double)>]

        var isEmpty: Bool {
            return constraints.isEmpty && suggestedValues.isEmpty
        }
    }
}

enum ConstraintOrientation {
    case horizontal
    case vertical
}
