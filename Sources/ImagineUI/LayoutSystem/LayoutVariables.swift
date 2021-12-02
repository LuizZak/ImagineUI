import Geometry
import CassowarySwift

class LayoutVariables {
    unowned let container: LayoutVariablesContainer
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

    @ParameterizedCachedConstraint private var firstBaseline_definition: (Bool) -> Constraint

    @ParameterizedCachedConstraint private var widthHuggingConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint private var heightHuggingConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint private var widthCompressionConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint private var heightCompressionConstraint: (Double) -> Constraint

    @ParameterizedCachedConstraint private var widthAsIntrinsicSizeConstraint: (Double) -> Constraint
    @ParameterizedCachedConstraint private var heightAsIntrinsicSizeConstraint: (Double) -> Constraint

    init(container: LayoutVariablesContainer) {
        let name = LayoutVariables.deriveName(container)

        self.container = container

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

        widthConstraint = width >= 0
        heightConstraint = height >= 0
        right_definition = right == left + width
        bottom_definition = bottom == top + height
        centerX_definition = centerX == left + width / 2
        centerY_definition = centerY == top + height / 2

        firstBaseline_definition = { hasLabel in
            if hasLabel {
                return firstBaseline == top + baselineHeight
            } else {
                return firstBaseline == top + height
            }
        }

        widthHuggingConstraint = { strength in
            (width <= intrinsicWidth).setStrength(strength)
        }
        heightHuggingConstraint = { strength in
            (height <= intrinsicHeight).setStrength(strength)
        }
        widthCompressionConstraint = { strength in
            (width >= intrinsicWidth).setStrength(strength)
        }
        heightCompressionConstraint = { strength in
            (height >= intrinsicHeight).setStrength(strength)
        }

        widthAsIntrinsicSizeConstraint = { strength in
            (width == intrinsicWidth).setStrength(strength)
        }
        heightAsIntrinsicSizeConstraint = { strength in
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

    func deriveConstraints(_ constraintCollector: ViewConstraintCollectorType) {
        if let view = container as? View {
            deriveViewConstraints(view, constraintCollector)
        }

        constraintCollector.addConstraint(
            widthConstraint,
            tag: "width >= 0",
            orientation: .horizontal
        )

        constraintCollector.addConstraint(
            heightConstraint,
            tag: "height >= 0",
            orientation: .horizontal
        )

        if container.hasConstraintsOnAnchorKind(.right) {
            constraintCollector.addConstraint(
                right_definition,
                tag: "right == left + width",
                orientation: .horizontal
            )
        }

        if container.hasConstraintsOnAnchorKind(.bottom) {
            constraintCollector.addConstraint(
                bottom_definition,
                tag: "bottom == top + height",
                orientation: .vertical
            )
        }

        if constraintsReferencesAnchorKind(.centerX) {
            constraintCollector.addConstraint(
                centerX_definition,
                tag: "centerX",
                orientation: .horizontal
            )
        }

        if constraintsReferencesAnchorKind(.centerY) {
            constraintCollector.addConstraint(
                centerY_definition,
                tag: "centerY",
                orientation: .vertical
            )
        }

        if constraintsReferencesAnchorKind(.firstBaseline) {
            if let label = viewForFirstBaseline() as? Label {
                constraintCollector.suggestValue(
                    baselineHeight,
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

    private func deriveViewConstraints(_ view: View, _ constraintCollector: ViewConstraintCollectorType) {
        if view.areaIntoConstraintsMask.contains(.location) {
            let location = view.convert(point: .zero, to: nil)
            
            left.value = location.x
            top.value = location.y

            constraintCollector.suggestValue(
                left,
                value: location.x,
                strength: Strength.STRONG,
                orientation: .horizontal
            )

            constraintCollector.suggestValue(
                top,
                value: location.y,
                strength: Strength.STRONG,
                orientation: .vertical
            )
        }
        if view.areaIntoConstraintsMask.contains(.size) {
            width.value = view.size.width
            height.value = view.size.height
            
            constraintCollector.suggestValue(
                width,
                value: view.size.width,
                strength: Strength.STRONG,
                orientation: .horizontal
            )

            constraintCollector.suggestValue(
                height,
                value: view.size.height,
                strength: Strength.STRONG,
                orientation: .vertical
            )
        }

        if let intrinsicSize = view._targetLayoutSize ?? view.intrinsicSize {
            deriveIntrinsicSizeConstraints(view, intrinsicSize: intrinsicSize, constraintCollector)
        }
    }

    private func deriveIntrinsicSizeConstraints(_ view: View, intrinsicSize: UISize, _ constraintCollector: ViewConstraintCollectorType) {
        // Horizontal
        horizontal:
        if view.horizontalCompressResistance != nil || view.horizontalHuggingPriority != nil {
            constraintCollector.suggestValue(
                intrinsicWidth,
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
                        orientation: .vertical
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
                intrinsicHeight,
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

    func applyVariables() {
        let location: UIVector
        if let parent = container.parent {
            location = parent.convert(point: UIVector(x: left.value, y: top.value), from: nil)
        } else {
            location = UIVector(x: left.value, y: top.value)
        }

        let w = width.value
        let h = height.value

        container.setAreaSkippingLayout(UIRectangle(location: location, size: UISize(width: w, height: h)))
    }

    func viewForFirstBaseline() -> View? {
        if let view = container as? View {
            if let viewForBaseline = container.viewForFirstBaseline() {
                return viewForBaseline
            }

            return view
        }

        return nil
    }

    private func constraintsReferencesAnchorKind(_ kind: AnchorKind) -> Bool {
        // Center X/Y constraints reference width/height, so we must take them
        // into account as well.
        // Intrinsic size also references width/height constraints.

        switch kind {
        case .left, .top, .right, .bottom, .firstBaseline, .centerX, .centerY:
            return container.hasConstraintsOnAnchorKind(kind)

        case .width:
            if let view = container as? View, view._targetLayoutSize != nil || view.intrinsicSize != nil {
                return true
            }

            return container.hasConstraintsOnAnchorKind(.width) || container.hasConstraintsOnAnchorKind(.centerX)

        case .height:
            if let view = container as? View, view._targetLayoutSize != nil || view.intrinsicSize != nil {
                return true
            }

            return container.hasConstraintsOnAnchorKind(.height) || container.hasConstraintsOnAnchorKind(.centerY)
        }
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
}

extension LayoutVariables: Equatable {
    static func == (lhs: LayoutVariables, rhs: LayoutVariables) -> Bool {
        return lhs === rhs
    }
}

extension LayoutVariables: Hashable {
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
