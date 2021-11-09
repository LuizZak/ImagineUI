import Geometry

public extension LayoutAnchor {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs)
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
    static func <= (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs)
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
    static func >= (lhs: Self, rhs: Double) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs)
    }
}

public extension LayoutAnchorEdges {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorSize {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }

    @discardableResult
    static func == (lhs: Self, rhs: UISize) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs)
    }

    @discardableResult
    static func == (lhs: Self, rhs: UIVector) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs.asUISize)
    }
}

// MARK: Double offset

public extension LayoutAnchor {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.equalTo(rhs.anchor, offset: rhs.offset)
    }

    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.lessThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }

    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraintDefinition {
        lhs.greaterThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
}

public extension LayoutAnchorEdges {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraintDefinitions {
        return lhs.equalTo(rhs.container, inset: -UIEdgeInsets(rhs.offset))
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

public extension LayoutAnchorsContainer {
    static func + (lhs: Self, rhs: Double) -> LayoutAnchorsContainerWithOffset {
        return LayoutAnchorsContainerWithOffset(container: lhs, offset: rhs)
    }

    static func - (lhs: Self, rhs: Double) -> LayoutAnchorsContainerWithOffset {
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
