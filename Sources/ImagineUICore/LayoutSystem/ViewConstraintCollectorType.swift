import CassowarySwift

protocol ViewConstraintCollectorType {
    mutating func addConstraint(
        _ constraint: Constraint,
        tag: String,
        orientation: LayoutConstraintOrientation
    )

    mutating func suggestValue(
        _ variable: Variable,
        value: Double,
        strength: Double,
        orientation: LayoutConstraintOrientation
    )
}
