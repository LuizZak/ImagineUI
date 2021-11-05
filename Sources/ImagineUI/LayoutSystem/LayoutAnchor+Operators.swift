import Geometry

public extension LayoutAnchorCreator {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func == (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs.anchor, offset: rhs.offset)
    }

    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }

    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
}

public extension LayoutAnchorUpdater {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func == (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs.anchor, offset: rhs.offset)
    }

    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }

    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
}

public extension LayoutAnchorEdgesCreator {
    @discardableResult
    static func == (lhs: LayoutAnchorEdgesCreator, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }

    @discardableResult
    static func == (lhs: LayoutAnchorEdgesCreator, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs.container, inset: -UIEdgeInsets(rhs.offset))
    }
}

public extension LayoutAnchorSizeCreator {
    @discardableResult
    static func == (lhs: LayoutAnchorSizeCreator, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }

    @discardableResult
    static func == (lhs: LayoutAnchorSizeCreator, rhs: UISize) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorEdgesUpdater {
    @discardableResult
    static func == (lhs: LayoutAnchorEdgesUpdater, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }

    @discardableResult
    static func == (lhs: LayoutAnchorEdgesUpdater, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs.container, inset: -UIEdgeInsets(rhs.offset))
    }
}

public extension LayoutAnchorSizeUpdater {
    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }

    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: UIVector) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs.asUISize)
    }

    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: UISize) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchor {
    static func + (lhs: LayoutAnchor, rhs: Double) -> LayoutAnchorWithOffset<T> {
        return LayoutAnchorWithOffset(anchor: lhs, offset: rhs)
    }

    static func - (lhs: LayoutAnchor, rhs: Double) -> LayoutAnchorWithOffset<T> {
        return LayoutAnchorWithOffset(anchor: lhs, offset: -rhs)
    }
}

public extension View {
    static func + (lhs: View, rhs: Double) -> LayoutAnchorsContainerWithOffset {
        return LayoutAnchorsContainerWithOffset(container: lhs, offset: rhs)
    }

    static func - (lhs: View, rhs: Double) -> LayoutAnchorsContainerWithOffset {
        return LayoutAnchorsContainerWithOffset(container: lhs, offset: -rhs)
    }
}

public extension LayoutGuide {
    static func + (lhs: LayoutGuide, rhs: Double) -> LayoutAnchorsContainerWithOffset {
        return LayoutAnchorsContainerWithOffset(container: lhs, offset: rhs)
    }

    static func - (lhs: LayoutGuide, rhs: Double) -> LayoutAnchorsContainerWithOffset {
        return LayoutAnchorsContainerWithOffset(container: lhs, offset: -rhs)
    }
}

public struct LayoutAnchorsContainerWithOffset {
    var container: LayoutAnchorsContainer
    var offset: Double
}

public struct LayoutAnchorWithOffset<T> {
    var anchor: LayoutAnchor<T>
    var offset: Double
}
