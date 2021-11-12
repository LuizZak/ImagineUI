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

    init(container: LayoutVariablesContainer) {
        let name = LayoutVariables.deriveName(container)

        self.container = container

        left = Variable("\(name)_left")
        right = Variable("\(name)_right")
        top = Variable("\(name)_top")
        bottom = Variable("\(name)_bottom")
        width = Variable("\(name)_width")
        height = Variable("\(name)_height")
        centerX = Variable("\(name)_centerX")
        centerY = Variable("\(name)_centerY")
        firstBaseline = Variable("\(name)_firstBaseline")
        intrinsicWidth = Variable("\(name)_intrinsicWidth")
        intrinsicHeight = Variable("\(name)_intrinsicHeight")
        baselineHeight = Variable("\(name)_baselineHeight")
    }

    func deriveConstraints(_ constraintCollector: ViewConstraintCollectorType) {
        if let view = container as? View {
            deriveViewConstraints(view, constraintCollector)
        }

        constraintCollector.addConstraint(
            width >= 0,
            tag: "width >= 0",
            orientation: .horizontal
        )

        constraintCollector.addConstraint(
            height >= 0,
            tag: "height >= 0",
            orientation: .horizontal
        )

        if container.hasConstraintsOnAnchorKind(.right) {
            constraintCollector.addConstraint(
                right == width + left,
                tag: "right == width + left",
                orientation: .horizontal
            )
        }

        if container.hasConstraintsOnAnchorKind(.bottom) {
            constraintCollector.addConstraint(
                bottom == top + height,
                tag: "bottom == top + height",
                orientation: .vertical
            )
        }

        if constraintsReferencesAnchorKind(.centerX) {
            constraintCollector.addConstraint(
                centerX == left + width / 2,
                tag: "centerX",
                orientation: .horizontal
            )
        }

        if constraintsReferencesAnchorKind(.centerY) {
            constraintCollector.addConstraint(
                centerY == top + height / 2,
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
                    firstBaseline == top + baselineHeight,
                    tag: "firstBaseline=baselineHeight",
                    orientation: .vertical
                )
            } else {
                constraintCollector.addConstraint(
                    firstBaseline == top + height,
                    tag: "firstBaseline=height",
                    orientation: .vertical
                )
            }
        }
    }

    private func deriveViewConstraints(_ view: View, _ constraintCollector: ViewConstraintCollectorType) {
        if view.areaIntoConstraintsMask.contains(.location) {
            let location = view.convert(point: .zero, to: nil)

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
            constraintCollector.suggestValue(
                right,
                value: view.bounds.right,
                strength: Strength.STRONG,
                orientation: .horizontal
            )

            constraintCollector.suggestValue(
                bottom,
                value: view.bounds.bottom,
                strength: Strength.STRONG,
                orientation: .vertical
            )
        }

        if let intrinsicSize = view._targetLayoutSize ?? view.intrinsicSize {
            constraintCollector.suggestValue(
                intrinsicWidth,
                value: intrinsicSize.width,
                strength: Strength.STRONG,
                orientation: .horizontal
            )
            constraintCollector.suggestValue(
                intrinsicHeight,
                value: intrinsicSize.height,
                strength: Strength.STRONG,
                orientation: .vertical
            )

            // Content compression/hugging priority
            constraintCollector.addConstraint(
                (width >= intrinsicWidth).setStrength(view.horizontalCompressResistance.cassowaryStrength),
                tag: "width >= intrinsicWidth",
                orientation: .horizontal
            )

            constraintCollector.addConstraint(
                (width <= intrinsicWidth).setStrength(view.horizontalHuggingPriority.cassowaryStrength),
                tag: "width <= intrinsicWidth",
                orientation: .horizontal
            )

            constraintCollector.addConstraint(
                (height >= intrinsicHeight).setStrength(view.verticalCompressResistance.cassowaryStrength),
                tag: "height >= intrinsicHeight",
                orientation: .vertical
            )

            constraintCollector.addConstraint(
                (height <= intrinsicHeight).setStrength(view.verticalHuggingPriority.cassowaryStrength),
                tag: "height <= intrinsicHeight",
                orientation: .vertical
            )
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

        container.area = UIRectangle(location: location, size: UISize(width: w, height: h))
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
