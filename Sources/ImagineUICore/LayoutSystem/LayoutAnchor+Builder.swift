import Geometry

extension LayoutAnchor {
    public func equalTo(_ value: Double,
                        priority: LayoutPriority = .required) -> LayoutConstraintDefinition {

        .create(first: self, offset: value, priority: priority)
    }

    public func equalTo(_ other: LayoutAnchor<T>,
                        offset: Double = 0,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        .create(
            first: self,
            second: other,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public func equalTo(_ other: LayoutAnchorsContainer,
                        offset: Double = 0,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        ._create(
            first: self.toInternalLayoutAnchor(),
            second: anchorOnOtherContainer(self.kind, other),
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public func lessThanOrEqualTo(_ value: Double,
                                  priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        .create(
            first: self,
            relationship: .lessThanOrEqual,
            offset: value,
            priority: priority
        )
    }

    public func lessThanOrEqualTo(_ other: LayoutAnchor<T>,
                                  offset: Double = 0,
                                  multiplier: Double = 1,
                                  priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        .create(
            first: self,
            second: other,
            relationship: .lessThanOrEqual,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public func lessThanOrEqualTo(_ other: LayoutAnchorsContainer,
                                  offset: Double = 0,
                                  multiplier: Double = 1,
                                  priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        ._create(
            first: self.toInternalLayoutAnchor(),
            second: anchorOnOtherContainer(self.kind, other),
            relationship: .lessThanOrEqual,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public func greaterThanOrEqualTo(_ value: Double,
                                     priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        .create(
            first: self,
            relationship: .greaterThanOrEqual,
            offset: value,
            priority: priority
        )
    }

    public func greaterThanOrEqualTo(_ other: LayoutAnchor<T>,
                                     offset: Double = 0,
                                     multiplier: Double = 1,
                                     priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        .create(
            first: self,
            second: other,
            relationship: .greaterThanOrEqual,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }

    public func greaterThanOrEqualTo(_ other: LayoutAnchorsContainer,
                                     offset: Double = 0,
                                     multiplier: Double = 1,
                                     priority: LayoutPriority = .required) -> LayoutConstraintDefinition {
        ._create(
            first: self.toInternalLayoutAnchor(),
            second: anchorOnOtherContainer(self.kind, other),
            relationship: .greaterThanOrEqual,
            offset: offset,
            multiplier: multiplier,
            priority: priority
        )
    }
}

public extension LayoutAnchorSize {
    @LayoutResultBuilder
    func greaterThanOrEqualTo(_ size: UISize, priority: LayoutPriority = .required) -> LayoutConstraintDefinitions {
        .create(
            first: layout.width,
            relationship: .greaterThanOrEqual,
            offset: size.width,
            priority: priority
        );
        .create(
            first: layout.height,
            relationship: .greaterThanOrEqual,
            offset: size.height,
            priority: priority
        )
    }

    @LayoutResultBuilder
    func lessThanOrEqualTo(_ size: UISize, priority: LayoutPriority = .required) -> LayoutConstraintDefinitions {
        .create(
            first: layout.width,
            relationship: .lessThanOrEqual,
            offset: size.width,
            priority: priority
        );
        .create(
            first: layout.height,
            relationship: .lessThanOrEqual,
            offset: size.height,
            priority: priority
        )
    }
}

private func anchorOnOtherContainer(_ kind: AnchorKind, _ container: LayoutAnchorsContainer) -> AnyLayoutAnchor {
    switch kind {
    case .width:
        return container.layout.width.toInternalLayoutAnchor()
    case .height:
        return container.layout.height.toInternalLayoutAnchor()
    case .left:
        return container.layout.left.toInternalLayoutAnchor()
    case .top:
        return container.layout.top.toInternalLayoutAnchor()
    case .right:
        return container.layout.right.toInternalLayoutAnchor()
    case .bottom:
        return container.layout.bottom.toInternalLayoutAnchor()
    case .centerX:
        return container.layout.centerX.toInternalLayoutAnchor()
    case .centerY:
        return container.layout.centerY.toInternalLayoutAnchor()
    case .firstBaseline:
        return container.layout.firstBaseline.toInternalLayoutAnchor()
    }
}
