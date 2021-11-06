public struct LayoutConstraintDefinition {
    var firstCast: AnyLayoutAnchor
    var secondCast: AnyLayoutAnchor?

    var relationship: Relationship
    var offset: Double
    var multiplier: Double
    var priority: LayoutPriority?

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

    @discardableResult
    public func update() -> LayoutConstraint {
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

    public static func create<T>(first: LayoutAnchor<T>,
                                 second: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        return .create(
            first: first.toInternalLayoutAnchor(),
            second: second.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    internal static func create(first: AnyLayoutAnchor,
                                second: AnyLayoutAnchor,
                                relationship: Relationship = .equal,
                                offset: Double = 0,
                                multiplier: Double = 1,
                                priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        return .init(
            firstCast: first,
            secondCast: second,
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public static func create<T>(first: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        return .create(
            first: first.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            priority: priority
        )
    }

    internal static func create(first: AnyLayoutAnchor,
                                relationship: Relationship = .equal,
                                offset: Double = 0,
                                priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
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
