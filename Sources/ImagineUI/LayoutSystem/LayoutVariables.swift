import Cassowary

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
    }

    func deriveConstraints(_ constraintList: ViewConstraintList) {
        if let view = container as? View {
            deriveViewConstraints(view, constraintList)
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
    
    func deriveViewConstraints(_ view: View, _ constraintList: ViewConstraintList) {
        if view.areaIntoConstraintsMask.contains(.location) {
            let location = view.convert(point: .zero, to: nil)
            
            constraintList.suggestValue(variable: left,
                                        value: location.x,
                                        strength: Strength.STRONG)
            
            constraintList.suggestValue(variable: top,
                                        value: location.y,
                                        strength: Strength.STRONG)
        }
        if view.areaIntoConstraintsMask.contains(.size) {
            constraintList.suggestValue(variable: width,
                                        value: view.bounds.width,
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
    }

    func applyVariables() {
        let location: Vector2
        if let parent = container.parent {
            location = parent.convert(point: Vector2(x: left.value, y: top.value), from: nil)
        } else {
            location = Vector2(x: left.value, y: top.value)
        }
        
        container.area = Rectangle(location: location, size: Size(x: width.value, y: height.value))
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
