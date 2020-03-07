public extension LayoutAnchorCreator {
    @discardableResult
    static func == (lhs: Self, rhs: LayoutAnchor<T>) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: View) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: ViewWithOffset) -> LayoutConstraint {
        lhs.equalTo(rhs.view, offset: rhs.offset)
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
    static func <= (lhs: Self, rhs: View) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: ViewWithOffset) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs.view, offset: rhs.offset)
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
    static func >= (lhs: Self, rhs: View) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: ViewWithOffset) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs.view, offset: rhs.offset)
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
    static func == (lhs: Self, rhs: View) -> LayoutConstraint {
        lhs.equalTo(rhs)
    }
    @discardableResult
    static func == (lhs: Self, rhs: ViewWithOffset) -> LayoutConstraint {
        lhs.equalTo(rhs.view, offset: rhs.offset)
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
    static func <= (lhs: Self, rhs: View) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs)
    }
    @discardableResult
    static func <= (lhs: Self, rhs: ViewWithOffset) -> LayoutConstraint {
        lhs.lessThanOrEqualTo(rhs.view, offset: rhs.offset)
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
    static func >= (lhs: Self, rhs: View) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs)
    }
    @discardableResult
    static func >= (lhs: Self, rhs: ViewWithOffset) -> LayoutConstraint {
        lhs.greaterThanOrEqualTo(rhs.view, offset: rhs.offset)
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
    static func == (lhs: LayoutAnchorEdgesCreator, rhs: View) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorSizeCreator {
    @discardableResult
    static func == (lhs: LayoutAnchorSizeCreator, rhs: View) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
    
    @discardableResult
    static func == (lhs: LayoutAnchorSizeCreator, rhs: Size) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorEdgesUpdater {
    @discardableResult
    static func == (lhs: LayoutAnchorEdgesUpdater, rhs: View) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
}

public extension LayoutAnchorSizeUpdater {
    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: View) -> [LayoutConstraint] {
        return lhs.equalTo(rhs)
    }
    
    @discardableResult
    static func == (lhs: LayoutAnchorSizeUpdater, rhs: Vector2) -> [LayoutConstraint] {
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
    static func + (lhs: View, rhs: Double) -> ViewWithOffset {
        return ViewWithOffset(view: lhs, offset: rhs)
    }
    
    static func - (lhs: View, rhs: Double) -> ViewWithOffset {
        return ViewWithOffset(view: lhs, offset: -rhs)
    }
}

public struct ViewWithOffset {
    var view: View
    var offset: Double
}

public struct LayoutAnchorWithOffset<T> {
    var anchor: LayoutAnchor<T>
    var offset: Double
}
