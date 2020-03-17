import blend2d
import Cassowary

public enum Relationship: CustomStringConvertible {
    case equal
    case greaterThanOrEqual
    case lessThanOrEqual
    
    public var description: String {
        switch self {
        case .equal:
            return "=="
        case .greaterThanOrEqual:
            return ">="
        case .lessThanOrEqual:
            return "<="
        }
    }

    func makeConstraint(left: Variable, right: Variable, offset: Double, multiplier: Double) -> Constraint {
        switch self {
        case .equal:
            return left == (right * multiplier) + offset
        case .greaterThanOrEqual:
            return left >= (right * multiplier) + offset
        case .lessThanOrEqual:
            return left <= (right * multiplier) + offset
        }
    }

    func makeConstraint(left: Variable, right: Expression, offset: Expression, multiplier: Double) -> Constraint {
        switch self {
        case .equal:
            return left == (right * multiplier) + offset
        case .greaterThanOrEqual:
            return left >= (right * multiplier) + offset
        case .lessThanOrEqual:
            return left <= (right * multiplier) + offset
        }
    }

    func makeConstraint(left: Variable, right: Variable, offset: Double) -> Constraint {
        switch self {
        case .equal:
            return left == right + offset
        case .greaterThanOrEqual:
            return left >= right + offset
        case .lessThanOrEqual:
            return left <= right + offset
        }
    }
    
    func makeConstraint(left: Variable, offset: Double) -> Constraint {
        switch self {
        case .equal:
            return left == offset
        case .greaterThanOrEqual:
            return left >= offset
        case .lessThanOrEqual:
            return left <= offset
        }
    }
}

public enum AnchorKind {
    case width
    case height
    case left
    case top
    case right
    case bottom
    case centerX
    case centerY
    case firstBaseline
}

public protocol LayoutAnchorType: CustomStringConvertible {
    var kind: AnchorKind { get }
    var owner: AnyObject? { get }
}

internal struct AnyLayoutAnchor: LayoutAnchorType, Equatable {
    weak var _owner: LayoutVariablesContainer?
    var kind: AnchorKind
    
    var owner: AnyObject? { return _owner }
    
    public var description: String {
        return getVariable()?.name ?? "<unowned anchor>"
    }
    
    func getVariable() -> Variable? {
        switch kind {
        case .width:
            return _owner?.layoutVariables.width
        case .height:
            return _owner?.layoutVariables.height
        case .left:
            return _owner?.layoutVariables.left
        case .top:
            return _owner?.layoutVariables.top
        case .right:
            return _owner?.layoutVariables.right
        case .bottom:
            return _owner?.layoutVariables.bottom
        case .centerX:
            return _owner?.layoutVariables.centerX
        case .centerY:
            return _owner?.layoutVariables.centerY
        case .firstBaseline:
            return _owner?.layoutVariables.firstBaseline
        }
    }

    // Returns an expression that can be subtracted from this layout anchor's
    // `makeVariable` result to create an expression that is relative to another
    // view's location
    func makeRelativeExpression(relative: LayoutVariablesContainer) -> Expression {
        switch kind {
        case .width, .height:
            return Expression(constant: 0)
            
        case .left, .right, .centerX:
            return Expression(term: Term(variable: relative.layoutVariables.left))
            
        case .top, .bottom, .centerY, .firstBaseline:
            return Expression(term: Term(variable: relative.layoutVariables.top))
        }
    }

    func makeExpression(relative: LayoutVariablesContainer) -> Expression? {
        guard let variable = getVariable() else {
            return nil
        }
        return variable - makeRelativeExpression(relative: relative)
    }
    
    func isEqual(to other: AnyLayoutAnchor) -> Bool {
        return other._owner === _owner && other.kind == kind
    }
    
    public static func == (lhs: AnyLayoutAnchor, rhs: AnyLayoutAnchor) -> Bool {
        return lhs._owner === rhs._owner && lhs.kind == rhs.kind
    }
}

public class LayoutConstraint: Hashable {
    var cachedConstraint: Constraint?
    
    /// The container that effectively contains this constraint
    weak var container: LayoutVariablesContainer?

    internal let firstCast: AnyLayoutAnchor
    internal let secondCast: AnyLayoutAnchor?
    
    public var first: LayoutAnchorType {
        return firstCast
    }
    public var second: LayoutAnchorType? {
        return secondCast
    }
    
    public var relationship: Relationship {
        didSet {
            if relationship == oldValue { return }
            
            cachedConstraint = nil
            container?.setNeedsLayout()
        }
    }
    
    public var offset: Double {
        didSet {
            if offset == oldValue { return }
            
            cachedConstraint = nil
            container?.setNeedsLayout()
        }
    }
    
    public var multiplier: Double {
        didSet {
            if multiplier == oldValue { return }
            
            cachedConstraint = nil
            container?.setNeedsLayout()
        }
    }
    
    public var priority: Double {
        didSet {
            if priority == oldValue { return }
            
            cachedConstraint = nil
            container?.setNeedsLayout()
        }
    }
    
    public var isEnabled: Bool = true {
        didSet {
            if isEnabled == oldValue { return }
            
            cachedConstraint = nil
            container?.setNeedsLayout()
        }
    }

    private init(container: LayoutVariablesContainer,
                 first: AnyLayoutAnchor,
                 second: AnyLayoutAnchor,
                 relationship: Relationship,
                 offset: Double,
                 multiplier: Double,
                 priority: Double) {

        self.container = container
        self.firstCast = first
        self.secondCast = second
        self.relationship = relationship
        self.offset = offset
        self.multiplier = multiplier
        self.priority = priority
    }
    
    private init(container: LayoutVariablesContainer,
                 first: AnyLayoutAnchor,
                 relationship: Relationship,
                 offset: Double,
                 priority: Double) {

        self.container = container
        self.firstCast = first
        self.secondCast = nil
        self.relationship = relationship
        self.offset = offset
        self.multiplier = 1
        self.priority = priority
    }
    
    func getOrCreateCachedConstraint() -> Constraint? {
        if let cached = cachedConstraint {
            return cached
        }
        guard let firstVariable = firstCast.getVariable() else {
            return nil
        }
        
        var constraint: Constraint?
        if let secondCast = secondCast,
            let secondVariable = secondCast.getVariable(),
            let container = container {
            
            // Create an expression of the form:
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
                constraint =
                    relationship
                        .makeConstraint(left: firstVariable,
                                        right: secondVariable,
                                        offset: offset)
                        .setStrength(priority)
            } else if let secondExpr = secondCast.makeExpression(relative: container) {
                constraint =
                    relationship
                        .makeConstraint(left: firstVariable,
                                        right: secondExpr,
                                        offset: secondCast.makeRelativeExpression(relative: container) + offset,
                                        multiplier: multiplier)
                        .setStrength(priority)
            }
        } else {
            constraint =
                relationship
                    .makeConstraint(left: firstVariable, offset: offset)
                    .setStrength(priority)
        }
        
        cachedConstraint = constraint
        
        return constraint
    }

    func removeConstraint() {
        container?.setNeedsLayout()
        firstCast._owner?.setNeedsLayout()
        secondCast?._owner?.setNeedsLayout()

        container?.viewInHierarchy?.containedConstraints.removeAll { $0 === self }
        firstCast._owner?.constraints.removeAll { $0 === self }
        secondCast?._owner?.constraints.removeAll { $0 === self }
    }

    @discardableResult
    public static func create<T>(first: LayoutAnchor<T>,
                                 second: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.REQUIRED) -> LayoutConstraint {

        return _create(first: first.toInternalLayoutAnchor(),
                       second: second.toInternalLayoutAnchor(),
                       relationship: relationship,
                       offset: offset,
                       multiplier: multiplier,
                       priority: priority)
    }

    @discardableResult
    public static func create<T>(first: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 priority: Double = Strength.REQUIRED) -> LayoutConstraint {

        return _create(first: first.toInternalLayoutAnchor(),
                       relationship: relationship,
                       offset: offset,
                       priority: priority)
    }

    @discardableResult
    internal static func _create(first: AnyLayoutAnchor,
                                 second: AnyLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.REQUIRED) -> LayoutConstraint {

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

        let constraint =
            LayoutConstraint(container: ancestor,
                             first: first,
                             second: second,
                             relationship: relationship,
                             offset: offset,
                             multiplier: multiplier,
                             priority: priority)

        ancestor.containedConstraints.append(constraint)

        first._owner?.constraints.append(constraint)
        second._owner?.constraints.append(constraint)

        ancestor.setNeedsLayout()
        first._owner?.setNeedsLayout()
        second._owner?.setNeedsLayout()

        return constraint
    }

    @discardableResult
    internal static func _create(first: AnyLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 priority: Double = Strength.REQUIRED) -> LayoutConstraint {

        guard let container = first._owner else {
            fatalError("Attempting to create constraint with reference to an anchor of a view or layout guide that was already deallocated")
        }
        
        let constraint =
            LayoutConstraint(container: container,
                             first: first,
                             relationship: relationship,
                             offset: offset,
                             priority: priority)

        container.viewInHierarchy?.containedConstraints.append(constraint)
        container.constraints.append(constraint)

        container.setNeedsLayout()

        return constraint
    }

    @discardableResult
    public static func update<T>(first: LayoutAnchor<T>,
                                 second: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double? = nil) -> LayoutConstraint {

        return _update(first: first.toInternalLayoutAnchor(),
                       second: second.toInternalLayoutAnchor(),
                       relationship: relationship,
                       offset: offset,
                       multiplier: multiplier,
                       priority: priority)
    }

    @discardableResult
    public static func update<T>(first: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double? = nil) -> LayoutConstraint {

        return _update(first: first.toInternalLayoutAnchor(),
                       relationship: relationship,
                       offset: offset,
                       multiplier: multiplier,
                       priority: priority)
    }

    @discardableResult
    internal static func _update(first: AnyLayoutAnchor,
                                 second: AnyLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double? = nil) -> LayoutConstraint {

        let constraint = first._owner?.constraints.first {
            $0.firstCast.isEqual(to: first) == true
                && $0.secondCast?.isEqual(to: second) == true
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
    internal static func _update(first: AnyLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double? = nil) -> LayoutConstraint {

        let constraint = first._owner?.constraints.first {
            $0.firstCast.isEqual(to: first) == true
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
}

extension LayoutConstraint: CustomStringConvertible {
    public var description: String {
        var trailing = ""
        if multiplier != 1 {
            trailing += " * \(multiplier)"
        }
        if offset != 0 || second == nil {
            trailing += " + \(offset)"
        }
        if priority != Strength.REQUIRED {
            trailing += " @ \(priority)"
        }
        
        if let second = second {
            return "<\(first) \(relationship) \(second)\(trailing)>"
        }
        
        return "<\(first) \(relationship)\(trailing)>"
    }
}

public extension Sequence where Element == LayoutConstraint {
    func setPriority(_ priority: Double) {
        for constraint in self {
            constraint.priority = priority
        }
    }
}
