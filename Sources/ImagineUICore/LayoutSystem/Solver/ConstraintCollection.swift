struct ConstraintCollection {
    var affectedLayoutVariables: [(LayoutVariablesContainer, LayoutVariables)] = []
    var fixedLayoutVariables: [(LayoutVariablesContainer, LayoutVariables)] = []
    var constraints: [LayoutConstraint] = []
}
