public struct LayoutConstraintDefinition {
    var firstCast: AnyLayoutAnchor
    var secondCast: AnyLayoutAnchor?

    var relationship: Relationship
    var offset: Double
    var multiplier: Double
    var priority: LayoutPriority?

    var affectedContainers: [LayoutVariablesContainer] {
        var result: [LayoutVariablesContainer] = []
        if let first = firstCast._owner {
            result.append(first)
        }
        if let second = secondCast?._owner {
            result.append(second)
        }
        return result
    }

    /// Creates the layout constraint defined within this `LayoutConstraintDefinition`
    /// object.
    @discardableResult
    public func create() -> LayoutConstraint {
        if let secondCast = secondCast {
            return LayoutConstraint._create(
                first: firstCast,
                second: secondCast,
                relationship: relationship,
                offset: offset,
                multiplier: multiplier,
                priority: priority ?? .required
            )
        }

        return LayoutConstraint._create(
            first: firstCast,
            relationship: relationship,
            offset: offset,
            priority: priority ?? .required
        )
    }

    /// Updates the layout constraint defined within this `LayoutConstraintDefinition`
    /// object.
    ///
    /// Note: This method assumes the referenced constraint already exist. If
    /// a matching constraint does not exist, the method traps with a `fatalError`.
    @discardableResult
    public func update(updateAreaIntoConstraintsMask: Bool = true) -> LayoutConstraint {
        if let secondCast = secondCast {
            return LayoutConstraint._update(
                first: firstCast,
                second: secondCast,
                relationship: relationship,
                offset: offset,
                multiplier: multiplier,
                priority: priority
            )
        }

        return LayoutConstraint._update(
            first: firstCast,
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    /// Attempts to remove a constraint whose anchors and relationships
    /// match the current constraint definition.
    ///
    /// If the operation succeeds, the layout constraint that was just removed
    /// is returned.
    ///
    /// If more than one constraint with the current relationship and anchors
    /// is present, only the first instance found is removed.
    @discardableResult
    public func remove() -> LayoutConstraint? {
        guard let constraints = firstCast._owner?.constraintsOnAnchorKind(firstCast.kind) else {
            return nil
        }

        for constraint in constraints {
            if constraint.secondCast == self.secondCast && constraint.relationship == relationship {
                constraint.removeConstraint()
                return constraint
            }
        }

        return nil
    }

    public static func create<T>(
        first: LayoutAnchor<T>,
        second: LayoutAnchor<T>,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return ._create(
            first: first.toInternalLayoutAnchor(),
            second: second.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public static func create<T>(
        first: LayoutAnchor<T>,
        relationship: Relationship = .equal,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return ._create(
            first: first.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            priority: priority
        )
    }

    internal static func _create(
        first: AnyLayoutAnchor,
        second: AnyLayoutAnchor,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return .init(
            firstCast: first,
            secondCast: second,
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    internal static func _create(
        first: AnyLayoutAnchor,
        relationship: Relationship = .equal,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return .init(
            firstCast: first,
            secondCast: nil,
            relationship: relationship,
            offset: offset,
            multiplier: 1,
            priority: priority
        )
    }
}

public extension LayoutConstraintDefinition {
    static func | (
        lhs: LayoutConstraintDefinition,
        rhs: LayoutPriority
    ) -> LayoutConstraintDefinition {

        var copy = lhs
        copy.priority = rhs
        return copy
    }
}
