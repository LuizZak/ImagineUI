import CassowarySwift

protocol ViewConstraintCollectorType {
    func addConstraint(_ constraint: Constraint, tag: String, orientation: LayoutConstraintOrientation)
    func suggestValue(_ variable: Variable, value: Double, strength: Double, orientation: LayoutConstraintOrientation)
}
