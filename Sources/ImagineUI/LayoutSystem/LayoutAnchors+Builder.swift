import Geometry

public extension LayoutAnchors {
    func makeConstraints(@LayoutResultBuilder _ builder: (LayoutAnchors) -> LayoutConstraintDefinitions) {
        if let view = container as? View {
            view.areaIntoConstraintsMask = []
        }

        let definitions = builder(self)
        definitions.create()
    }

    func remakeConstraints(@LayoutResultBuilder _ builder: (LayoutAnchors) -> LayoutConstraintDefinitions) {
        for constraint in container.constraints {
            constraint.removeConstraint()
        }

        makeConstraints(builder)
    }

    func updateConstraints(@LayoutResultBuilder _ builder: (LayoutAnchors) -> LayoutConstraintDefinitions) {
        let definitions = builder(self)
        definitions.update()
    }
}

extension LayoutAnchors {
    @discardableResult
    public func left(of other: LayoutAnchorsContainer,
                     offset: Double = 0,
                     priority: LayoutPriority = .required) -> LayoutConstraintDefinition {

        return right.equalTo(other.layout.left, offset: offset, priority: priority)
    }

    @discardableResult
    public func right(of other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraintDefinition {

        return left.equalTo(other.layout.right, offset: offset, priority: priority)
    }

    @discardableResult
    public func over(_ other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraintDefinition {

        return bottom.equalTo(other.layout.top, offset: offset, priority: priority)
    }

    @discardableResult
    public func under(_ other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraintDefinition {

        return top.equalTo(other.layout.bottom, offset: offset, priority: priority)
    }
}
