public protocol LayoutAnchorsContainer {
    var layout: LayoutAnchors { get }
}

public struct LayoutAnchors {
    var container: LayoutVariablesContainer

    public var width: LayoutAnchor<DimensionLayoutAnchor> { make(.width) }
    public var height: LayoutAnchor<DimensionLayoutAnchor> { make(.height) }
    public var left: LayoutAnchor<XLayoutAnchor> { make(.left) }
    public var right: LayoutAnchor<XLayoutAnchor> { make(.right) }
    public var top: LayoutAnchor<YLayoutAnchor> { make(.top) }
    public var bottom: LayoutAnchor<YLayoutAnchor> { make(.bottom) }
    public var centerX: LayoutAnchor<XLayoutAnchor> { make(.centerX) }
    public var centerY: LayoutAnchor<YLayoutAnchor> { make(.centerY) }
    public var firstBaseline: LayoutAnchor<YLayoutAnchor> { make(.firstBaseline) }

    public var edges: LayoutAnchorEdges { LayoutAnchorEdges(layout: self) }
    public var size: LayoutAnchorSize { LayoutAnchorSize(layout: self) }

    init(container: LayoutVariablesContainer) {
        self.container = container
    }

    /// Removes all constraints that are connecting this layout anchor list to
    /// another layout anchor list.
    public func removeConstraintsConnecting(to other: LayoutAnchors) {
        for constraint in container.constraints {
            if (constraint.firstCast.owner === container && constraint.secondCast?.owner === other.container) ||
                (constraint.firstCast.owner === other.container && constraint.secondCast?.owner === container) {
                constraint.removeConstraint()
            }
        }
    }

    private func make<T>(_ anchorKind: AnchorKind) -> LayoutAnchor<T> {
        return LayoutAnchor(_owner: container, kind: anchorKind)
    }
}

extension View: LayoutAnchorsContainer {
    public var layout: LayoutAnchors {
        return LayoutAnchors(container: self)
    }
}

extension LayoutGuide: LayoutAnchorsContainer {
    public var layout: LayoutAnchors {
        return LayoutAnchors(container: self)
    }
}

public struct XLayoutAnchor { }
public struct YLayoutAnchor { }
public struct DimensionLayoutAnchor { }

public struct LayoutAnchorEdges {
    let layout: LayoutAnchors

    init(layout: LayoutAnchors) {
        self.layout = layout
    }

    @LayoutResultBuilder
    public func equalTo(_ other: LayoutAnchorsContainer,
                        inset: UIEdgeInsets = .zero,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraintDefinitions {
        .create(
            first: layout.top,
            second: other.layout.top,
            offset: inset.top,
            multiplier: multiplier,
            priority: priority
        );
        .create(
            first: layout.left,
            second: other.layout.left,
            offset: inset.left,
            multiplier: multiplier,
            priority: priority
        );
        .create(
            first: layout.right,
            second: other.layout.right,
            offset: -inset.right,
            multiplier: multiplier,
            priority: priority
        );
        .create(
            first: layout.bottom,
            second: other.layout.bottom,
            offset: -inset.bottom,
            multiplier: multiplier,
            priority: priority
        )
    }
}

public struct LayoutAnchorSize {
    let layout: LayoutAnchors

    init(layout: LayoutAnchors) {
        self.layout = layout
    }

    @LayoutResultBuilder
    public func equalTo(_ other: LayoutAnchorsContainer,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraintDefinitions {
        .create(
            first: layout.width,
            second: other.layout.width,
            multiplier: multiplier,
            priority: priority
        );
        .create(
            first: layout.height,
            second: other.layout.height,
            multiplier: multiplier,
            priority: priority
        )
    }

    @LayoutResultBuilder
    public func equalTo(_ size: UISize, priority: LayoutPriority = .required) -> LayoutConstraintDefinitions {
        .create(
            first: layout.width,
            offset: size.width,
            priority: priority
        );
        .create(
            first: layout.height,
            offset: size.height,
            priority: priority
        )
    }
}
