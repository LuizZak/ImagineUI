import CassowarySwift

public class LayoutConstraint: Hashable {
    var isRemoved: Bool = false

    var definition: Definition {
        didSet {
            if definition == oldValue { return }

            container?.setNeedsLayout()
        }
    }

    /// The container that effectively contains this constraint
    var container: LayoutVariablesContainer? {
        definition.container
    }

    var firstCast: AnyLayoutAnchor {
        definition.firstCast
    }
    var secondCast: AnyLayoutAnchor? {
        definition.secondCast
    }

    var constraintOrientation: LayoutConstraintOrientation {
        guard let secondCast = secondCast else {
            return firstCast.orientation.asLayoutConstraintOrientation
        }

        switch (firstCast.orientation, secondCast.orientation) {
        case (.horizontal, .horizontal):
            return .horizontal

        case (.vertical, .vertical):
            return .vertical

        default:
            return .mixed
        }
    }

    public var first: LayoutAnchorType {
        return firstCast
    }
    public var second: LayoutAnchorType? {
        return secondCast
    }

    public var relationship: Relationship {
        definition.relationship
    }

    public var offset: Double {
        get { definition.offset }
        set { definition.offset = newValue }
    }

    public var multiplier: Double {
        get { definition.multiplier }
        set { definition.multiplier = newValue }
    }

    public var priority: LayoutPriority {
        get { definition.priority }
        set {
            if priority == .required && newValue != .required {
                assertionFailure("Cannot change priority of required constraints to be non-required.")
            }
            if priority != .required && newValue == .required {
                assertionFailure("Cannot change priority of non-required constraints to be required.")
            }

            definition.priority = newValue
        }
    }

    public var isEnabled: Bool = true {
        didSet {
            if isEnabled == oldValue { return }

            container?.setNeedsLayout()
        }
    }

    private init(
        container: LayoutVariablesContainer,
        first: AnyLayoutAnchor,
        second: AnyLayoutAnchor,
        relationship: Relationship,
        offset: Double,
        multiplier: Double,
        priority: LayoutPriority
    ) {

        definition = Definition(
            container: container,
            firstCast: first,
            secondCast: second,
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    private init(
        container: LayoutVariablesContainer,
        first: AnyLayoutAnchor,
        relationship: Relationship,
        offset: Double,
        priority: LayoutPriority
    ) {

        definition = Definition(
            container: container,
            firstCast: first,
            secondCast: nil,
            relationship: relationship,
            offset: offset,
            multiplier: 1,
            priority: priority
        )
    }

    func createConstraint() -> Constraint? {
        return definition.createConstraint()
    }

    func removeConstraint() {
        guard !isRemoved else {
            return
        }

        isRemoved = true

        container?.setNeedsLayout()
        firstCast._owner?.setNeedsLayout()
        secondCast?._owner?.setNeedsLayout()

        container?.viewInHierarchy?.containedConstraints.removeAll { $0 === self }
        firstCast._owner?.constraints.removeAll { $0 === self }
        secondCast?._owner?.constraints.removeAll { $0 === self }
        firstCast._owner?.didRemoveConstraint(self)
        secondCast?._owner?.didRemoveConstraint(self)
    }

    @discardableResult
    public static func create<T>(
        first: LayoutAnchor<T>,
        second: LayoutAnchor<T>,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority = .required
    ) -> LayoutConstraint {

        return _create(
            first: first.toInternalLayoutAnchor(),
            second: second.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    @discardableResult
    public static func create<T>(
        first: LayoutAnchor<T>,
        relationship: Relationship = .equal,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraint {

        return _create(
            first: first.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            priority: priority
        )
    }

    @discardableResult
    internal static func _create(
        first: AnyLayoutAnchor,
        second: AnyLayoutAnchor,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority = .required
    ) -> LayoutConstraint {

        guard let view1 = first._owner?.viewInHierarchy else {
            if first.owner is LayoutGuide {
                fatalError("Attempting to add constraint to layout guide that is not contained in a view")
            } else {
                fatalError("No view in hierarchy found for input type \(type(of: first))")
            }
        }
        guard let view2 = second._owner?.viewInHierarchy else {
            if second.owner is LayoutGuide {
                fatalError("Attempting to add constraint to layout guide that is not contained in a view")
            } else {
                fatalError("No view in hierarchy found for input type \(type(of: second))")
            }
        }

        guard let ancestor = View.firstCommonAncestor(between: view1, view2) else {
            fatalError("Cannot add constraint between two views in two different hierarchies")
        }

        let constraint = LayoutConstraint(
            container: ancestor,
            first: first,
            second: second,
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )

        ancestor.containedConstraints.append(constraint)

        first._owner?.constraints.append(constraint)
        second._owner?.constraints.append(constraint)

        ancestor.setNeedsLayout()
        first._owner?.setNeedsLayout()
        second._owner?.setNeedsLayout()

        first._owner?.didAddConstraint(constraint)
        second._owner?.didAddConstraint(constraint)

        return constraint
    }

    @discardableResult
    internal static func _create(
        first: AnyLayoutAnchor,
        relationship: Relationship = .equal,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraint {

        guard let container = first._owner else {
            fatalError("Attempting to create constraint with reference to an anchor of a view or layout guide that was already deallocated")
        }

        let constraint = LayoutConstraint(
            container: container,
            first: first,
            relationship: relationship,
            offset: offset,
            priority: priority
        )

        container.viewInHierarchy?.containedConstraints.append(constraint)
        container.constraints.append(constraint)

        container.setNeedsLayout()

        container.didAddConstraint(constraint)

        return constraint
    }

    @discardableResult
    public static func update<T>(
        first: LayoutAnchor<T>,
        second: LayoutAnchor<T>,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority? = nil
    ) -> LayoutConstraint {

        return _update(
            first: first.toInternalLayoutAnchor(),
            second: second.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    @discardableResult
    public static func update<T>(
        first: LayoutAnchor<T>,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority? = nil
    ) -> LayoutConstraint {

        return _update(
            first: first.toInternalLayoutAnchor(),
            relationship: relationship,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    @discardableResult
    internal static func _update(
        first: AnyLayoutAnchor,
        second: AnyLayoutAnchor,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority? = nil
    ) -> LayoutConstraint {

        let constraint = first._owner?.constraints.first {
            $0.firstCast == first
                && $0.secondCast == second
                && $0.relationship == relationship
        }

        if let constraint = constraint {
            constraint.offset = offset
            constraint.multiplier = multiplier

            if let priority = priority {
                constraint.priority = priority
            }

            return constraint
        } else {
            fatalError("Could not find constraint anchoring \(first) to \(second) to update")
        }
    }

    @discardableResult
    internal static func _update(
        first: AnyLayoutAnchor,
        relationship: Relationship = .equal,
        offset: Double = 0,
        multiplier: Double = 1,
        priority: LayoutPriority? = nil
    ) -> LayoutConstraint {

        let constraint = first._owner?.constraints.first {
            $0.firstCast == first
                && $0.second == nil
                && $0.relationship == relationship
        }

        if let constraint = constraint {
            constraint.offset = offset
            constraint.multiplier = multiplier

            if let priority = priority {
                constraint.priority = priority
            }

            return constraint
        } else {
            fatalError("Could not find constraint anchoring \(first) to update")
        }
    }

    public static func == (lhs: LayoutConstraint, rhs: LayoutConstraint) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    struct Definition: Hashable {
        private var _hashValue: Int = 0

        /// The container that effectively contains a constraint
        weak var container: LayoutVariablesContainer?

        let firstCast: AnyLayoutAnchor
        let secondCast: AnyLayoutAnchor?
        let relationship: Relationship

        var offset: Double {
            didSet {
                _rehash()
            }
        }
        var multiplier: Double {
            didSet {
                _rehash()
            }
        }
        var priority: LayoutPriority {
            didSet {
                _rehash()
            }
        }

        init(
            container: LayoutVariablesContainer,
            firstCast: AnyLayoutAnchor,
            secondCast: AnyLayoutAnchor?,
            relationship: Relationship,
            offset: Double,
            multiplier: Double,
            priority: LayoutPriority
        ) {

            self.container = container
            self.firstCast = firstCast
            self.secondCast = secondCast
            self.relationship = relationship
            self.offset = offset
            self.multiplier = multiplier
            self.priority = priority

            _rehash()
        }

        func createConstraint() -> Constraint? {
            guard let firstVariable = firstCast.getVariable() else {
                return nil
            }

            let strength = priority.cassowaryStrength

            // Next section only applies to constraints with two anchors.
            guard
                let secondCast = secondCast,
                let secondVariable = secondCast.getVariable(),
                let container = container
            else {
                return relationship
                    .makeConstraint(left: firstVariable, offset: offset)
                    .setStrength(strength)
            }

            // For constraints with multiplier != 1, create an expression of
            // the form:
            //
            // first [ == | <= | >= ] (second - containerLocation) * multiplier + containerLocation + offset
            //
            // The container is a reference to the direct parent of the second
            // anchor's view, or the second anchor's view itself in case it has
            // no parents, and is used to apply proper multiplication of the
            // constraints.
            // For width/height constraints, containerLocation is zero, for
            // left/right containerLocation is containerView.layout.left, and
            // for top/bottom containerLocation is containerView.layout.top.
            //
            // Without this relative container offset, multiplicative constraints
            // would multiply the absolute view locations, resulting in views
            // that potentially break their parent view's bounds.
            //
            //
            // For non multiplicative constraints (where multiplier == 1),
            // a simpler solution is used:
            //
            // first [ == | <= | >= ] second + offset
            //

            if multiplier == 1 {
                return relationship
                    .makeConstraint(
                        left: firstVariable,
                        right: secondVariable,
                        offset: offset
                    )
                    .setStrength(strength)
            } else {
                let secondExpr = secondCast.makeExpression(
                    variable: secondVariable,
                    relative: container
                )

                let adjustedOffset = secondCast.makeRelativeExpression(
                    relative: container
                ) + offset

                return relationship
                    .makeConstraint(
                        left: firstVariable,
                        right: secondExpr,
                        offset: adjustedOffset,
                        multiplier: multiplier
                    )
                    .setStrength(strength)
            }
        }

        private mutating func _rehash() {
            var hasher = Hasher()

            _internalHash(into: &hasher)

            _hashValue = hasher.finalize()
        }

        private func _internalHash(into hasher: inout Hasher) {
            hasher.combine(firstCast)
            hasher.combine(secondCast)
            hasher.combine(relationship)
            hasher.combine(offset)
            hasher.combine(multiplier)
            hasher.combine(priority)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(_hashValue)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs._hashValue == rhs._hashValue
                && lhs.relationship == rhs.relationship
                && lhs.offset == rhs.offset
                && lhs.multiplier == rhs.multiplier
                && lhs.priority == rhs.priority
                && lhs.firstCast == rhs.firstCast
                && lhs.secondCast == rhs.secondCast
        }
    }
}

extension LayoutConstraint: CustomStringConvertible {
    public var description: String {
        var trailing = ""
        if multiplier != 1 && second != nil {
            trailing += " * \(multiplier)"
        }
        if offset != 0 || second == nil {
            if second == nil {
                trailing += " \(offset.description)"
            } else {
                trailing += " + \(offset)"
            }
        }
        if priority != .required {
            trailing += " @ \(priority)"
        }

        if let second = second {
            return "<\(first) \(relationship) \(second)\(trailing)>"
        }

        return "<\(first) \(relationship)\(trailing)>"
    }
}

public extension Sequence where Element == LayoutConstraint {
    func setPriority(_ priority: LayoutPriority) {
        for constraint in self {
            constraint.priority = priority
        }
    }
}
