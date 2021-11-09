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

    func deriveConstraints(_ constraintList: ViewConstraintList) {
        if let view = container as? View {
            deriveViewConstraints(view, constraintList)
        }

        constraintList.addConstraint(name: "width >= 0",
                                     orientation: .horizontal,
                                     width >= 0,
                                     strength: Strength.REQUIRED)


        constraintList.addConstraint(name: "height >= 0",
                                     orientation: .vertical,
                                     height >= 0,
                                     strength: Strength.REQUIRED)


        if container.hasConstraintsOnAnchorKind(.right) {
            constraintList.addConstraint(name: "right == width + left",
                                         orientation: .horizontal,
                                         right == width + left,
                                         strength: Strength.REQUIRED)
        }

        if container.hasConstraintsOnAnchorKind(.bottom) {
            constraintList.addConstraint(name: "bottom == top + height",
                                         orientation: .vertical,
                                         bottom == top + height,
                                         strength: Strength.REQUIRED)
        }

        if constraintsReferencesAnchorKind(.centerX) {
            constraintList.addConstraint(name: "centerX",
                                         orientation: .horizontal,
                                         centerX == left + width / 2,
                                         strength: Strength.REQUIRED)
        }

        if constraintsReferencesAnchorKind(.centerY) {
            constraintList.addConstraint(name: "centerY",
                                         orientation: .vertical,
                                         centerY == top + height / 2,
                                         strength: Strength.REQUIRED)
        }

        if constraintsReferencesAnchorKind(.firstBaseline) {
            if let label = viewForFirstBaseline() as? Label {
                constraintList.suggestValue(variable: baselineHeight,
                                            orientation: .vertical,
                                            value: label.baselineHeight,
                                            strength: Strength.STRONG)

                constraintList.addConstraint(name: "firstBaseline=baselineHeight",
                                            orientation: .vertical,
                                            firstBaseline == top + baselineHeight,
                                            strength: Strength.REQUIRED)
            } else {
                constraintList.addConstraint(name: "firstBaseline=height",
                                            orientation: .vertical,
                                            firstBaseline == top + height,
                                            strength: Strength.REQUIRED)
            }
        }
    }

    func deriveViewConstraints(_ view: View, _ constraintList: ViewConstraintList) {
        if view.areaIntoConstraintsMask.contains(.location) {
            let location = view.convert(point: .zero, to: nil)

            constraintList.suggestValue(variable: left,
                                        orientation: .horizontal,
                                        value: location.x,
                                        strength: Strength.STRONG)

            constraintList.suggestValue(variable: top,
                                        orientation: .vertical,
                                        value: location.y,
                                        strength: Strength.STRONG)
        }
        if view.areaIntoConstraintsMask.contains(.size) {
            constraintList.suggestValue(variable: right,
                                        orientation: .horizontal,
                                        value: view.bounds.right,
                                        strength: Strength.STRONG)

            constraintList.suggestValue(variable: bottom,
                                        orientation: .vertical,
                                        value: view.bounds.bottom,
                                        strength: Strength.STRONG)
        }

        if let intrinsicSize = view._targetLayoutSize ?? view.intrinsicSize {
            constraintList.suggestValue(variable: intrinsicWidth,
                                        orientation: .horizontal,
                                        value: intrinsicSize.width,
                                        strength: Strength.STRONG)
            constraintList.suggestValue(variable: intrinsicHeight,
                                        orientation: .vertical,
                                        value: intrinsicSize.height,
                                        strength: Strength.STRONG)

            // Content compression/hugging priority
            constraintList.addConstraint(
                name: "width >= intrinsicWidth",
                orientation: .horizontal,
                width >= intrinsicWidth,
                strength: view.horizontalCompressResistance.cassowaryStrength)

            constraintList.addConstraint(
                name: "width <= intrinsicWidth",
                orientation: .horizontal,
                width <= intrinsicWidth,
                strength: view.horizontalHuggingPriority.cassowaryStrength)

            constraintList.addConstraint(
                name: "height >= intrinsicHeight",
                orientation: .vertical,
                height >= intrinsicHeight,
                strength: view.verticalCompressResistance.cassowaryStrength)

            constraintList.addConstraint(
                name: "height <= intrinsicHeight",
                orientation: .vertical,
                height <= intrinsicHeight,
                strength: view.verticalHuggingPriority.cassowaryStrength)
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
            if let view = container as? View, view.intrinsicSize != nil {
                return true
            }

            return container.hasConstraintsOnAnchorKind(.width) || container.hasConstraintsOnAnchorKind(.centerX)

        case .height:
            if let view = container as? View, view.intrinsicSize != nil {
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
