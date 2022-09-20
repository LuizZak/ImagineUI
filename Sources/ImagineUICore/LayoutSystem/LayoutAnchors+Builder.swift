import Geometry

public extension LayoutAnchors {
    /// Registers new constraints along the existing constraints of this anchors'
    /// container based on the results of a given closure.
    ///
    /// Passing `updateAreaIntoConstraintsMask` as `true` updates the value of
    /// `areaIntoConstraintsMask` of this layout anchor's view to allow constraints
    /// to affect the view correctly.
    @discardableResult
    func makeConstraints(
        updateAreaIntoConstraintsMask: Bool = true,
        @LayoutResultBuilder _ builder: (LayoutAnchors) -> LayoutConstraintDefinitions
    ) -> [LayoutConstraint] {

        if updateAreaIntoConstraintsMask, let view = container as? View {
            view.areaIntoConstraintsMask = []
        }

        let definitions = builder(self)
        return definitions.create()
    }

    /// Removes all constraints of this anchors' container and creates new
    /// constraints based on the results of a given closure.
    ///
    /// Passing `updateAreaIntoConstraintsMask` as `true` updates the value of
    /// `areaIntoConstraintsMask` of this layout anchor's view to allow constraints
    /// to affect the view correctly.
    @discardableResult
    func remakeConstraints(
        updateAreaIntoConstraintsMask: Bool = true,
        @LayoutResultBuilder _ builder: (LayoutAnchors) -> LayoutConstraintDefinitions
    ) -> [LayoutConstraint] {

        for constraint in container.constraints {
            constraint.removeConstraint()
        }

        return makeConstraints(updateAreaIntoConstraintsMask: updateAreaIntoConstraintsMask, builder)
    }

    /// Updates the constraints of this anchors' container based on the results
    /// of a given closure.
    /// Constraints are chosen to be updated based on the layout anchors referenced,
    /// and the comparison operator.
    ///
    /// Note: This method assumes the referenced constraints already exist. If
    /// one or more of the constraints does not exist, the method traps with a
    /// `fatalError`.
    ///
    /// Passing `updateAreaIntoConstraintsMask` as `true` updates the value of
    /// `areaIntoConstraintsMask` of this layout anchor's view to allow constraints
    /// to affect the view correctly.
    @discardableResult
    func updateConstraints(
        @LayoutResultBuilder _ builder: (LayoutAnchors) -> LayoutConstraintDefinitions
    ) -> [LayoutConstraint] {

        let definitions = builder(self)

        return definitions.update()
    }
}

extension LayoutAnchors {
    @discardableResult
    public func left(
        of other: LayoutAnchorsContainer,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return right.equalTo(other.layout.left, offset: offset, priority: priority)
    }

    @discardableResult
    public func right(
        of other: LayoutAnchorsContainer,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return left.equalTo(other.layout.right, offset: offset, priority: priority)
    }

    @discardableResult
    public func over(
        _ other: LayoutAnchorsContainer,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return bottom.equalTo(other.layout.top, offset: offset, priority: priority)
    }

    @discardableResult
    public func under(
        _ other: LayoutAnchorsContainer,
        offset: Double = 0,
        priority: LayoutPriority = .required
    ) -> LayoutConstraintDefinition {

        return top.equalTo(other.layout.bottom, offset: offset, priority: priority)
    }
}
