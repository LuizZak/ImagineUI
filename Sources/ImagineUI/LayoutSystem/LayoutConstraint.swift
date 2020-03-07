import blend2d
import Cassowary

public enum Relationship {
    case equal
    case greaterThanOrEqual
    case lessThanOrEqual

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

class ViewLayoutVariables {
    unowned let view: View
    let left: Variable
    let right: Variable
    let top: Variable
    let bottom: Variable
    let width: Variable
    let height: Variable
    let centerX: Variable
    let centerY: Variable
    let firstBaseline: Variable

    init(view: View) {
        let name = ViewLayoutVariables.deriveName(view)

        self.view = view

        left = Variable("\(name)_left")
        right = Variable("\(name)_right")
        top = Variable("\(name)_top")
        bottom = Variable("\(name)_bottom")
        width = Variable("\(name)_width")
        height = Variable("\(name)_height")
        centerX = Variable("\(name)_centerX")
        centerY = Variable("\(name)_centerY")
        firstBaseline = Variable("\(name)_firstBaseline")
    }

    func deriveConstraints(_ constraintList: ViewConstraintList) {
        if view.translatesAutoresizingMaskIntoConstraints {
            let location = view.convert(point: .zero, to: nil)
            
            constraintList.suggestValue(variable: left,
                                        value: location.x,
                                        strength: Strength.STRONG)
            
            constraintList.suggestValue(variable: width,
                                        value: view.bounds.width,
                                        strength: Strength.STRONG)
            
            constraintList.suggestValue(variable: top,
                                        value: location.y,
                                        strength: Strength.STRONG)
            
            constraintList.suggestValue(variable: height,
                                        value: view.bounds.height,
                                        strength: Strength.STRONG)
        }
        if let intrinsicSize = view.intrinsicSize {
            // Content compression/hugging priority
            constraintList.addConstraint(
                name: "width >= intrinsicSize.x",
                width >= intrinsicSize.x,
                strength: LayoutConstraintHelpers.strengthFromPriority(view.horizontalCompressResistance))
            
            constraintList.addConstraint(
                name: "width <= intrinsicSize.x",
                width <= intrinsicSize.x,
                strength: LayoutConstraintHelpers.strengthFromPriority(view.horizontalHuggingPriority))
            
            constraintList.addConstraint(
                name: "height >= intrinsicSize.y",
                height >= intrinsicSize.y,
                strength: LayoutConstraintHelpers.strengthFromPriority(view.verticalCompressResistance))
            
            constraintList.addConstraint(
                name: "height <= intrinsicSize.y",
                height <= intrinsicSize.y,
                strength: LayoutConstraintHelpers.strengthFromPriority(view.verticalHuggingPriority))
        }
        
        constraintList.addConstraint(name: "width >= 0",
                                     width >= 0,
                                     strength: Strength.REQUIRED)
        
        constraintList.addConstraint(name: "right == width + left",
                                     right == width + left,
                                     strength: Strength.REQUIRED)
        
        constraintList.addConstraint(name: "height >= 0",
                                     height >= 0,
                                     strength: Strength.REQUIRED)
        
        constraintList.addConstraint(name: "bottom == top + height",
                                     bottom == top + height,
                                     strength: Strength.REQUIRED)
        
        constraintList.addConstraint(name: "centerX",
                                     centerX == left + width / 2,
                                     strength: Strength.REQUIRED)
        
        constraintList.addConstraint(name: "centerY",
                                     centerY == top + height / 2,
                                     strength: Strength.REQUIRED)
        
        if let label = viewForFirstBaseline() as? Label {
            constraintList.addConstraint(name: "firstBaseline",
                                         firstBaseline == label.layoutVariables.top + label.baselineHeight,
                                         strength: Strength.REQUIRED,
                                         tag: label.baselineHeight.hashValue)
        } else {
            constraintList.addConstraint(name: "firstBaseline",
                                         firstBaseline == height,
                                         strength: Strength.REQUIRED)
        }
    }

    func applyVariables() {
        let location: Vector2
        if let parent = view.superview {
            location = parent.convert(point: Vector2(x: left.value, y: top.value), from: nil)
        } else {
            location = Vector2(x: left.value, y: top.value)
        }
        
        view.location = location
        view.bounds = view.bounds.withSize(width: width.value, height: height.value)
    }
    
    func viewForFirstBaseline() -> View {
        if let view = view.viewForFirstBaseline() {
            return view
        }
        
        return view
    }

    private static func deriveName(_ view: View) -> String {
        let pointer = Unmanaged.passUnretained(view).toOpaque()

        return "\(type(of: view))_\(pointer)"
    }
}

public protocol LayoutAnchorType {
    var kind: AnchorKind { get }
    var owner: View { get }
}

internal struct InternalLayoutAnchor: LayoutAnchorType, Equatable {
    var kind: AnchorKind
    var owner: View
    
    func getVariable() -> Variable {
        switch kind {
        case .width:
            return owner.layoutVariables.width
        case .height:
            return owner.layoutVariables.height
        case .left:
            return owner.layoutVariables.left
        case .top:
            return owner.layoutVariables.top
        case .right:
            return owner.layoutVariables.right
        case .bottom:
            return owner.layoutVariables.bottom
        case .centerX:
            return owner.layoutVariables.centerX
        case .centerY:
            return owner.layoutVariables.centerY
        case .firstBaseline:
            return owner.layoutVariables.firstBaseline
        }
    }

    // Returns an expression that can be subtracted from this layout anchor's
    // `makeVariable` result to create an expression that is relative to another
    // view's location
    func makeRelativeExpression(relative: View) -> Expression {
        switch kind {
        case .width, .height:
            return Expression(constant: 0)
            
        case .left, .right, .centerX:
            return Expression(term: Term(variable: relative.layoutVariables.left))
            
        case .top, .bottom, .centerY, .firstBaseline:
            return Expression(term: Term(variable: relative.layoutVariables.top))
        }
    }

    func makeExpression(relative: View) -> Expression {
        return getVariable() - makeRelativeExpression(relative: relative)
    }
    
    func isEqual(to other: InternalLayoutAnchor) -> Bool {
        return other.owner === owner && other.kind == kind
    }
    
    public static func == (lhs: InternalLayoutAnchor, rhs: InternalLayoutAnchor) -> Bool {
        return lhs.owner === rhs.owner && lhs.kind == rhs.kind
    }
}

public struct LayoutAnchor<T>: LayoutAnchorType, Equatable, CustomStringConvertible {
    public var owner: View
    public var kind: AnchorKind

    public var orientation: LayoutConstraintOrientation {
        switch kind {
        case .left, .width, .right, .centerX:
            return .horizontal
            
        case .top, .height, .bottom, .centerY, .firstBaseline:
            return .vertical
        }
    }

    public var description: String {
        return toInternalLayoutAnchor().getVariable().name
    }

    public static func == (lhs: LayoutAnchor, rhs: LayoutAnchor) -> Bool {
        return lhs.owner === rhs.owner && lhs.kind == rhs.kind
    }
}

extension LayoutAnchor {
    func toInternalLayoutAnchor() -> InternalLayoutAnchor {
        return InternalLayoutAnchor(kind: kind, owner: owner)
    }
}

public class LayoutConstraint: Hashable {
    var cachedConstraint: Constraint?
    
    /// The view that effectively contains this constraint
    var containerView: View

    internal let firstCast: InternalLayoutAnchor
    internal let secondCast: InternalLayoutAnchor?
    
    public let first: LayoutAnchorType
    public let second: LayoutAnchorType?
    public var relationship: Relationship {
        didSet {
            if relationship == oldValue { return }
            
            cachedConstraint = nil
            containerView.setNeedsLayout()
        }
    }
    public var offset: Double {
        didSet {
            if offset == oldValue { return }
            
            cachedConstraint = nil
            containerView.setNeedsLayout()
        }
    }
    public var multiplier: Double {
        didSet {
            if multiplier == oldValue { return }
            
            cachedConstraint = nil
            containerView.setNeedsLayout()
        }
    }
    public var priority: Double {
        didSet {
            if priority == oldValue { return }
            
            cachedConstraint = nil
            containerView.setNeedsLayout()
        }
    }
    public var isEnabled: Bool = true {
        didSet {
            if isEnabled == oldValue { return }
            
            cachedConstraint = nil
            containerView.setNeedsLayout()
        }
    }

    private init(containerView: View,
                 first: InternalLayoutAnchor,
                 second: InternalLayoutAnchor,
                 relationship: Relationship,
                 offset: Double,
                 multiplier: Double,
                 priority: Double) {

        self.containerView = containerView
        self.firstCast = first
        self.secondCast = second
        self.first = first
        self.second = second
        self.relationship = relationship
        self.offset = offset
        self.multiplier = multiplier
        self.priority = priority
    }
    
    private init(containerView: View,
                 first: InternalLayoutAnchor,
                 relationship: Relationship,
                 offset: Double,
                 priority: Double) {

        self.containerView = containerView
        self.firstCast = first
        self.secondCast = nil
        self.first = first
        self.second = nil
        self.relationship = relationship
        self.offset = offset
        self.multiplier = 1
        self.priority = priority
    }
    
    func getOrCreateCachedConstraint() -> Constraint {
        if let cached = cachedConstraint {
            return cached
        }
        
        let constraint: Constraint
        if let secondCast = secondCast {
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
                        .makeConstraint(left: firstCast.getVariable(),
                                        right: secondCast.getVariable(),
                                        offset: offset)
                        .setStrength(priority)
            } else {
                constraint =
                    relationship
                        .makeConstraint(left: firstCast.getVariable(),
                                        right: secondCast.makeExpression(relative: containerView),
                                        offset: secondCast.makeRelativeExpression(relative: containerView) + offset,
                                        multiplier: multiplier)
                        .setStrength(priority)
            }
        } else {
            constraint =
                relationship
                    .makeConstraint(left: firstCast.getVariable(), offset: offset)
                    .setStrength(priority)
        }
        
        cachedConstraint = constraint
        
        return constraint
    }

    func removeConstraint() {
        containerView.setNeedsLayout()
        firstCast.owner.setNeedsLayout()
        secondCast?.owner.setNeedsLayout()

        containerView.containedConstraints.removeAll { $0 === self }
        firstCast.owner.constraints.removeAll { $0 === self }
        secondCast?.owner.constraints.removeAll { $0 === self }
    }

    @discardableResult
    public static func create<T>(first: LayoutAnchor<T>,
                                 second: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

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
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

        return _create(first: first.toInternalLayoutAnchor(),
                       relationship: relationship,
                       offset: offset,
                       priority: priority)
    }

    @discardableResult
    internal static func _create(first: InternalLayoutAnchor,
                                 second: InternalLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

        guard let ancestor = View.firstCommonAncestor(between: first.owner, second.owner) else {
            fatalError("Cannot add constraint between two views in two different hierarchies")
        }

        let constraint =
            LayoutConstraint(containerView: ancestor,
                             first: first,
                             second: second,
                             relationship: relationship,
                             offset: offset,
                             multiplier: multiplier,
                             priority: priority)

        ancestor.containedConstraints.append(constraint)

        first.owner.constraints.append(constraint)
        second.owner.constraints.append(constraint)

        ancestor.setNeedsLayout()
        first.owner.setNeedsLayout()
        second.owner.setNeedsLayout()

        return constraint
    }

    @discardableResult
    internal static func _create(first: InternalLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

        let constraint =
            LayoutConstraint(containerView: first.owner,
                             first: first,
                             relationship: relationship,
                             offset: offset,
                             priority: priority)

        first.owner.containedConstraints.append(constraint)
        first.owner.constraints.append(constraint)

        first.owner.setNeedsLayout()

        return constraint
    }

    @discardableResult
    public static func update<T>(first: LayoutAnchor<T>,
                                 second: LayoutAnchor<T>,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

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
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

        return _update(first: first.toInternalLayoutAnchor(),
                       relationship: relationship,
                       offset: offset,
                       multiplier: multiplier,
                       priority: priority)
    }

    @discardableResult
    internal static func _update(first: InternalLayoutAnchor,
                                 second: InternalLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

        let constraint = first.owner.constraints.first {
            $0.firstCast.isEqual(to: first) == true && $0.secondCast?.isEqual(to: second) == true
        }

        if let constraint = constraint {
            constraint.relationship = relationship
            constraint.offset = offset
            constraint.multiplier = multiplier
            constraint.priority = priority

            return constraint
        } else {
            fatalError("Could not find constraint anchoring \(first) to \(second) to update")
        }
    }

    @discardableResult
    internal static func _update(first: InternalLayoutAnchor,
                                 relationship: Relationship = .equal,
                                 offset: Double = 0,
                                 multiplier: Double = 1,
                                 priority: Double = Strength.STRONG) -> LayoutConstraint {

        let constraint = first.owner.constraints.first {
            $0.firstCast.isEqual(to: first) == true && $0.second == nil
        }

        if let constraint = constraint {
            constraint.relationship = relationship
            constraint.offset = offset
            constraint.multiplier = multiplier
            constraint.priority = priority

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

public enum LayoutConstraintOrientation {
    case horizontal
    case vertical
}

public extension View {
    var layout: Layout {
        return Layout(view: self)
    }

    struct Layout {
        var view: View

        public var width: LayoutAnchor<DimensionLayoutAnchor> { make(.width) }
        public var height: LayoutAnchor<DimensionLayoutAnchor> { make(.height) }
        public var left: LayoutAnchor<XLayoutAnchor> { make(.left) }
        public var right: LayoutAnchor<XLayoutAnchor> { make(.right) }
        public var top: LayoutAnchor<YLayoutAnchor> { make(.top) }
        public var bottom: LayoutAnchor<YLayoutAnchor> { make(.bottom) }
        public var centerX: LayoutAnchor<XLayoutAnchor> { make(.centerX) }
        public var centerY: LayoutAnchor<XLayoutAnchor> { make(.centerY) }
        public var firstBaseline: LayoutAnchor<YLayoutAnchor> { make(.firstBaseline) }

        init(view: View) {
            self.view = view
        }

        private func make<T>(_ anchorKind: AnchorKind) -> LayoutAnchor<T> {
            return LayoutAnchor(owner: view, kind: anchorKind)
        }
    }
}

public struct XLayoutAnchor { }
public struct YLayoutAnchor { }
public struct DimensionLayoutAnchor { }
