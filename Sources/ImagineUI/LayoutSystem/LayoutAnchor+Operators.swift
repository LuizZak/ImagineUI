import Geometry

public extension LayoutAnchorCreator {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraint {
        lhs.equalTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func == (lhs: Self, rhs: Double) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraint {
        lhs.equalTo(rhs.anchor, offset: rhs.offset)
    }
    
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: Double) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
    
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: Double) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
}

public extension LayoutAnchorUpdater {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraint {
        lhs.equalTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func == (lhs: Self, rhs: Double) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraint {
        lhs.equalTo(rhs.anchor, offset: rhs.offset)
    }
    
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: Double) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
    
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainer) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorsContainerWithOffset) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs.container, offset: rhs.offset)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: Double) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: LayoutAnchorWithOffset<T>) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs.anchor, offset: rhs.offset)
    }
}

public extension LayoutAnchorEdgesCreator {
    @discardableResult
    static func == (lhs: LayoutAnchorEdgesCreator, rhs: LayoutAnchorsContainer) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorSizeCreator {
    @discardableResult
    static func == (lhs: LayoutAnchorSizeCreator, rhs: LayoutAnchorsContainer) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
    
    @discardableResult
    static func == (lhs: LayoutAnchorSizeCreator, rhs: Size) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorEdgesUpdater {
    @discardableResult
    static func == (lhs: LayoutAnchorEdgesUpdater, rhs: LayoutAnchorsContainer) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorSizeUpdater {
    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: LayoutAnchorsContainer) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
    
    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: Vector) -> [LayoutConstraint] {
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
