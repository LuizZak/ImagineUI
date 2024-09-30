import Geometry
import CassowarySwift

@ImagineActor
class LayoutVariables {
    let left: Variable
    let right: Variable
    let top: Variable
    let bottom: Variable
    let width: Variable
    let height: Variable
    let centerX: Variable
    let centerY: Variable
    let firstBaseline: Variable
    let intrinsicWidth: Variable
    let intrinsicHeight: Variable
    let baselineHeight: Variable

    var allVariables: [Variable] {
        [
            left,
            right,
            top,
            bottom,
            width,
            height,
            centerX,
            centerY,
            firstBaseline,
            intrinsicWidth,
            intrinsicHeight,
            baselineHeight,
        ]
    }

    private var widthConstraint: Constraint
    private var heightConstraint: Constraint
    private var right_definition: Constraint
    private var bottom_definition: Constraint
    private var centerX_definition: Constraint
    private var centerY_definition: Constraint

    @ParameterizedCachedConstraint
    private var firstBaseline_definition: (Bool) -> Constraint

    @ParameterizedCachedConstraint
    private var widthHuggingConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint
    private var heightHuggingConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint
    private var widthCompressionConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint
    private var heightCompressionConstraint: (Double) -> Constraint

    @ParameterizedCachedConstraint
    private var widthAsIntrinsicSizeConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint
    private var heightAsIntrinsicSizeConstraint: (Double) -> Constraint

    init(name: String) {
        let left = Variable("\(name)_left")
        let right = Variable("\(name)_right")
        let top = Variable("\(name)_top")
        let bottom = Variable("\(name)_bottom")
        let width = Variable("\(name)_width")
        let height = Variable("\(name)_height")
        let centerX = Variable("\(name)_centerX")
        let centerY = Variable("\(name)_centerY")
        let firstBaseline = Variable("\(name)_firstBaseline")
        let intrinsicWidth = Variable("\(name)_intrinsicWidth")
        let intrinsicHeight = Variable("\(name)_intrinsicHeight")
        let baselineHeight = Variable("\(name)_baselineHeight")

        self.widthConstraint = width >= 0
        self.heightConstraint = height >= 0
        self.right_definition = right == left + width
        self.bottom_definition = bottom == top + height
        self.centerX_definition = centerX == left + width / 2
        self.centerY_definition = centerY == top + height / 2

        self.firstBaseline_definition = { hasLabel in
            if hasLabel {
                return firstBaseline == top + baselineHeight
            } else {
                return firstBaseline == top + height
            }
        }

        self.widthHuggingConstraint = { strength in
            (width <= intrinsicWidth).setStrength(strength)
        }
        self.heightHuggingConstraint = { strength in
            (height <= intrinsicHeight).setStrength(strength)
        }
        self.widthCompressionConstraint = { strength in
            (width >= intrinsicWidth).setStrength(strength)
        }
        self.heightCompressionConstraint = { strength in
            (height >= intrinsicHeight).setStrength(strength)
        }

        self.widthAsIntrinsicSizeConstraint = { strength in
            (width == intrinsicWidth).setStrength(strength)
        }
        self.heightAsIntrinsicSizeConstraint = { strength in
            (height == intrinsicHeight).setStrength(strength)
        }

        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
        self.width = width
        self.height = height
        self.centerX = centerX
        self.centerY = centerY
        self.firstBaseline = firstBaseline
        self.intrinsicWidth = intrinsicWidth
        self.intrinsicHeight = intrinsicHeight
        self.baselineHeight = baselineHeight
    }

    func deriveConstraints<T: ViewConstraintCollectorType>(
        _ constraintCollector: inout T,
        container: LayoutVariablesContainer,
        rootSpatialReference: View?
    ) {
        let variables = VariablesBroker(
            container: container,
            layoutVariables: self
        )

        if let view = container as? View {
            deriveViewConstraints(
                view,
                &constraintCollector,
                variables,
                relativeTo: rootSpatialReference
            )
        }

        variables.markReferenced(.width)
        constraintCollector.addConstraint(
            widthConstraint,
            tag: "width >= 0",
            orientation: .horizontal
        )

        variables.markReferenced(.height)
        constraintCollector.addConstraint(
            heightConstraint,
            tag: "height >= 0",
            orientation: .vertical
        )

        if variables.isReferenced(.right) {
            constraintCollector.addConstraint(
                right_definition,
                tag: "right == left + width",
                orientation: .horizontal
            )
        }

        if variables.isReferenced(.bottom) {
            constraintCollector.addConstraint(
                bottom_definition,
                tag: "bottom == top + height",
                orientation: .vertical
            )
        }

        if variables.isReferenced(.centerX) {
            constraintCollector.addConstraint(
                centerX_definition,
                tag: "centerX",
                orientation: .horizontal
            )
        }

        if variables.isReferenced(.centerY) {
            constraintCollector.addConstraint(
                centerY_definition,
                tag: "centerY",
                orientation: .vertical
            )
        }

        if variables.isReferenced(.firstBaseline) {
            if let label = viewForFirstBaseline(container: container) as? Label {
                constraintCollector.suggestValue(
                    variables.baselineHeight,
                    value: label.baselineHeight,
                    strength: Strength.STRONG,
                    orientation: .vertical
                )

                constraintCollector.addConstraint(
                    $firstBaseline_definition(true),
                    tag: "firstBaseline == top + baselineHeight",
                    orientation: .vertical
                )
            } else {
                constraintCollector.addConstraint(
                    $firstBaseline_definition(false),
                    tag: "firstBaseline == top + height",
                    orientation: .vertical
                )
            }
        }
    }

    private func deriveViewConstraints<T: ViewConstraintCollectorType>(
        _ view: View,
        _ constraintCollector: inout T,
        _ variables: VariablesBroker,
        relativeTo spatialReference: View?
    ) {

        let bounds = view.convert(bounds: view.bounds, to: spatialReference)
        let mask = view.areaIntoConstraintsMask

        if mask.contains(.location) {
            variables.left.value = bounds.x
            variables.top.value = bounds.y

            constraintCollector.suggestValue(
                variables.left,
                value: bounds.x,
                strength: Strength.STRONG,
                orientation: .horizontal
            )

            constraintCollector.suggestValue(
                variables.top,
                value: bounds.y,
                strength: Strength.STRONG,
                orientation: .vertical
            )
        }

        if mask.contains(.size) {
            variables.width.value = bounds.width
            variables.height.value = bounds.height

            constraintCollector.suggestValue(
                variables.width,
                value: bounds.width,
                strength: Strength.STRONG,
                orientation: .horizontal
            )

            constraintCollector.suggestValue(
                variables.height,
                value: bounds.height,
                strength: Strength.STRONG,
                orientation: .vertical
            )
        }

        if let intrinsicSize = view._targetLayoutSize ?? view.intrinsicSize {
            deriveIntrinsicSizeConstraints(
                view,
                intrinsicSize: intrinsicSize,
                &constraintCollector,
                variables
            )
        }
    }

    private func deriveIntrinsicSizeConstraints<T: ViewConstraintCollectorType>(
        _ view: View,
        intrinsicSize: UISize,
        _ constraintCollector: inout T,
        _ variables: VariablesBroker
    ) {

        // Horizontal
        horizontal:
        if view.horizontalCompressResistance != nil || view.horizontalHuggingPriority != nil {
            constraintCollector.suggestValue(
                variables.intrinsicWidth,
                value: intrinsicSize.width,
                strength: Strength.STRONG,
                orientation: .horizontal
            )

            if let horizontalCompressResistance = view.horizontalCompressResistance {
                // When hugging == compression, we can simplify into an equality constraint.
                if horizontalCompressResistance == view.horizontalHuggingPriority {
                    constraintCollector.addConstraint(
                        $widthAsIntrinsicSizeConstraint(horizontalCompressResistance.cassowaryStrength),
                        tag: "width == intrinsicWidth",
                        orientation: .horizontal
                    )
                    break horizontal
                }

                constraintCollector.addConstraint(
                    $widthCompressionConstraint(horizontalCompressResistance.cassowaryStrength),
                    tag: "width >= intrinsicWidth",
                    orientation: .horizontal
                )
            }

            if let horizontalHuggingPriority = view.horizontalHuggingPriority {
                constraintCollector.addConstraint(
                    $widthHuggingConstraint(horizontalHuggingPriority.cassowaryStrength),
                    tag: "width <= intrinsicWidth",
                    orientation: .horizontal
                )
            }
        }

        // Vertical
        vertical:
        if view.verticalCompressResistance != nil || view.verticalHuggingPriority != nil {
            constraintCollector.suggestValue(
                variables.intrinsicHeight,
                value: intrinsicSize.height,
                strength: Strength.STRONG,
                orientation: .vertical
            )

            if let verticalCompressResistance = view.verticalCompressResistance {
                // When hugging == compression, we can simplify into an equality constraint.
                if verticalCompressResistance == view.verticalHuggingPriority {
                    constraintCollector.addConstraint(
                        $heightAsIntrinsicSizeConstraint(verticalCompressResistance.cassowaryStrength),
                        tag: "height == intrinsicHeight",
                        orientation: .vertical
                    )
                    break vertical
                }

                constraintCollector.addConstraint(
                    $heightCompressionConstraint(verticalCompressResistance.cassowaryStrength),
                    tag: "height >= intrinsicHeight",
                    orientation: .vertical
                )
            }

            if let verticalHuggingPriority = view.verticalHuggingPriority {
                constraintCollector.addConstraint(
                    $heightHuggingConstraint(verticalHuggingPriority.cassowaryStrength),
                    tag: "height <= intrinsicHeight",
                    orientation: .vertical
                )
            }
        }
    }

    func applyVariables(
        container: LayoutVariablesContainer,
        relativeTo spatialReference: View?
    ) {
        var area = UIRectangle(
            x: left.value,
            y: top.value,
            width: width.value,
            height: height.value
        )
        if let parent = container.parent {
            area = parent.convert(bounds: area, from: spatialReference)
            area.size = container.convert(bounds: area, from: parent).size

            // Make sure we respect a view's desired fixed location/size, even
            // if it participated in constraint resolution
            if let view = container as? View {
                if view.areaIntoConstraintsMask.contains(.location) {
                    area.location = view.location
                }
                if view.areaIntoConstraintsMask.contains(.size) {
                    area.size = view.size
                }
            }
        }

        container.setAreaSkippingLayout(area)
    }

    func viewForFirstBaseline(
        container: LayoutVariablesContainer
    ) -> View? {
        if let view = container as? View {
            if let viewForBaseline = container.viewForFirstBaseline() {
                return viewForBaseline
            }

            return view
        }

        return nil
    }

    private static func deriveName(_ container: LayoutVariablesContainer) -> String {
        if let view = container as? View {
            return deriveName(view)
        }
        if let guide = container as? LayoutGuide {
            return deriveName(guide)
        }

        return "\(type(of: container))"
    }

    private static func deriveName(_ view: View) -> String {
        let pointer = Unmanaged.passUnretained(view).toOpaque()

        return "\(type(of: view))_\(pointer)"
    }

    private static func deriveName(_ guide: LayoutGuide) -> String {
        let pointer = Unmanaged.passUnretained(guide).toOpaque()

        return "\(type(of: guide))_\(pointer)"
    }

    /// Used to help ensure variable references are taken into account while
    /// deciding which constraints to report to a `ViewConstraintCollectorType`.
    @ImagineActor
    private class VariablesBroker {
        let layoutVariables: LayoutVariables
        var referencedVariables: Set<LayoutVariable> = []

        var left: Variable { fetchVariable(.left) }
        var right: Variable { fetchVariable(.right) }
        var top: Variable { fetchVariable(.top) }
        var bottom: Variable { fetchVariable(.bottom) }
        var width: Variable { fetchVariable(.width) }
        var height: Variable { fetchVariable(.height) }
        var centerX: Variable { fetchVariable(.centerX) }
        var centerY: Variable { fetchVariable(.centerY) }
        var firstBaseline: Variable { fetchVariable(.firstBaseline) }
        var intrinsicWidth: Variable { fetchVariable(.intrinsicWidth) }
        var intrinsicHeight: Variable { fetchVariable(.intrinsicHeight) }
        var baselineHeight: Variable { fetchVariable(.baselineHeight) }

        init(
            container: LayoutVariablesContainer,
            layoutVariables: LayoutVariables
        ) {
            self.layoutVariables = layoutVariables

            // Pre-fill based on constraints
            if container.hasConstraintsOnAnchorKind(.left) {
                markReferenced(.left)
            }
            if container.hasConstraintsOnAnchorKind(.right) {
                markReferenced(.right)
            }
            if container.hasConstraintsOnAnchorKind(.top) {
                markReferenced(.top)
            }
            if container.hasConstraintsOnAnchorKind(.bottom) {
                markReferenced(.bottom)
            }
            if container.hasConstraintsOnAnchorKind(.width) {
                markReferenced(.width)
            }
            if container.hasConstraintsOnAnchorKind(.height) {
                markReferenced(.height)
            }
            if container.hasConstraintsOnAnchorKind(.centerX) {
                markReferenced(.centerX)
            }
            if container.hasConstraintsOnAnchorKind(.centerY) {
                markReferenced(.centerY)
            }
            if container.hasConstraintsOnAnchorKind(.firstBaseline) {
                markReferenced(.firstBaseline)
            }

            if let view = container as? View {
                let mask = view.areaIntoConstraintsMask
                if mask != [] || view._targetLayoutSize != nil || view.intrinsicSize != nil {
                    markReferenced(.left)
                    markReferenced(.right)
                    markReferenced(.top)
                    markReferenced(.bottom)
                    markReferenced(.width)
                    markReferenced(.height)
                }
            }
        }

        func isReferenced(_ variable: LayoutVariable) -> Bool {
            referencedVariables.contains(variable)
        }

        func markReferenced(_ variable: LayoutVariable) {
            referencedVariables.insert(variable)
        }

        func fetchVariable(_ variable: LayoutVariable) -> Variable {
            markReferenced(variable)

            switch variable {
            case .left:
                return layoutVariables.left
            case .right:
                return layoutVariables.right
            case .top:
                return layoutVariables.top
            case .bottom:
                return layoutVariables.bottom
            case .width:
                return layoutVariables.width
            case .height:
                return layoutVariables.height
            case .centerX:
                return layoutVariables.centerX
            case .centerY:
                return layoutVariables.centerY
            case .firstBaseline:
                return layoutVariables.firstBaseline
            case .intrinsicWidth:
                return layoutVariables.intrinsicWidth
            case .intrinsicHeight:
                return layoutVariables.intrinsicHeight
            case .baselineHeight:
                return layoutVariables.baselineHeight
            }
        }
    }

    private enum LayoutVariable: Hashable {
        case left
        case right
        case top
        case bottom
        case width
        case height
        case centerX
        case centerY
        case firstBaseline
        case intrinsicWidth
        case intrinsicHeight
        case baselineHeight
    }
}

extension LayoutVariables: @preconcurrency Equatable {
    static func == (lhs: LayoutVariables, rhs: LayoutVariables) -> Bool {
        return lhs === rhs
    }
}

extension LayoutVariables: @preconcurrency Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// A parameterized cache that returns the same Constraint instance on repeated
/// fetches with the same parameter, but refreshes the cache every time a
/// different parameter value is provided.
///
/// Past parameters are not remembered, and attempting to fetch a constraint for
/// a previous parameter returns a new Constraint instance.
@propertyWrapper
private class ParameterizedCachedConstraint<Parameter: Equatable> {
    var cached: Constraint?
    var currentParameter: Parameter?
    var wrappedValue: (Parameter) -> Constraint
    var projectedValue: (Parameter) -> Constraint {
        return { parameter in
            if self.currentParameter != parameter {
                self.currentParameter = parameter
                self.cached = nil
            }

            if let cached = self.cached {
                return cached
            }

            let newConstraint = self.wrappedValue(parameter)
            self.cached = newConstraint
            return newConstraint
        }
    }

    init(wrappedValue: @escaping (Parameter) -> Constraint) {
        self.wrappedValue = wrappedValue
    }
}
