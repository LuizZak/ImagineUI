public extension View.Layout {
    func makeConstraints(_ builder: (LayoutAnchorUpdateCreator) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        builder(LayoutAnchorUpdateCreator(layout: self))
    }
    
    func remakeConstraints(_ builder: (LayoutAnchorUpdateCreator) -> Void) {
        for constraint in view.constraints {
            constraint.removeConstraint()
        }
        
        makeConstraints(builder)
    }

    func updateConstraints(_ builder: (LayoutAnchorUpdateBuilder) -> Void) {
        builder(LayoutAnchorUpdateBuilder(layout: self))
    }
}

public struct LayoutAnchorUpdateCreator {
    let layout: View.Layout

    public var width: LayoutAnchorCreator<DimensionLayoutAnchor> { .init(anchor: layout.width) }
    public var height: LayoutAnchorCreator<DimensionLayoutAnchor> { .init(anchor: layout.height) }
    public var left: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.left) }
    public var right: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.right) }
    public var top: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.top) }
    public var bottom: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.bottom) }
    public var centerX: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.centerX) }
    public var centerY: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.centerY) }
    public var firstBaseline: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.firstBaseline) }
    public var edges: LayoutAnchorEdgesCreator { .init(layout: layout) }
    public var size: LayoutAnchorSizeCreator { .init(layout: layout) }
    
    @discardableResult
    public func left(of other: View, offset: Double = 0) -> LayoutConstraint {
        return right == other.layout.left + offset
    }
    
    @discardableResult
    public func right(of other: View, offset: Double = 0) -> LayoutConstraint {
        return left == other.layout.right + offset
    }
    
    @discardableResult
    public func under(_ other: View, offset: Double = 0) -> LayoutConstraint {
        return top == other.layout.bottom + offset
    }
}

public struct LayoutAnchorUpdateBuilder {
    let layout: View.Layout

    public var width: LayoutAnchorUpdater<DimensionLayoutAnchor> { .init(anchor: layout.width) }
    public var height: LayoutAnchorUpdater<DimensionLayoutAnchor> { .init(anchor: layout.height) }
    public var left: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.left) }
    public var right: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.right) }
    public var top: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.top) }
    public var bottom: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.bottom) }
    public var centerX: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.centerX) }
    public var centerY: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.centerY) }
    public var firstBaseline: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.firstBaseline) }
    public var edges: LayoutAnchorEdgesUpdater { .init(layout: layout) }
    public var size: LayoutAnchorSizeUpdater { .init(layout: layout) }
    
    @discardableResult
    public func left(of other: View, offset: Double = 0) -> LayoutConstraint {
        return right == other.layout.left + offset
    }
    
    @discardableResult
    public func right(of other: View, offset: Double = 0) -> LayoutConstraint {
        return left == other.layout.right + offset
    }
    
    @discardableResult
    public func under(_ other: View, offset: Double = 0) -> LayoutConstraint {
        return top == other.layout.bottom + offset
    }
}

public struct LayoutAnchorEdgesCreator {
    let layout: View.Layout

    init(layout: View.Layout) {
        self.layout = layout
    }

    @discardableResult
    public func equalTo(_ other: View, inset: EdgeInsets = .zero, multiplier: Double = 1) -> [LayoutConstraint] {
        return [
            LayoutConstraint.create(first: layout.top, second: other.layout.top,
                                    offset: inset.top, multiplier: multiplier),
            
            LayoutConstraint.create(first: layout.left, second: other.layout.left,
                                    offset: inset.left, multiplier: multiplier),
            
            LayoutConstraint.create(first: layout.right, second: other.layout.right,
                                    offset: -inset.right, multiplier: multiplier),
            
            LayoutConstraint.create(first: layout.bottom, second: other.layout.bottom,
                                    offset: -inset.bottom, multiplier: multiplier),
        ]
    }
}

public struct LayoutAnchorSizeCreator {
    let layout: View.Layout

    init(layout: View.Layout) {
        self.layout = layout
    }
    
    @discardableResult
    public func equalTo(_ other: View, multiplier: Double = 1) -> [LayoutConstraint] {
        return  [
            LayoutConstraint.create(first: layout.width,
                                    second: other.layout.width,
                                    multiplier: multiplier),
            LayoutConstraint.create(first: layout.height,
                                    second: other.layout.height,
                                    multiplier: multiplier)
        ]
    }
}

public struct LayoutAnchorEdgesUpdater {
    let layout: View.Layout

    init(layout: View.Layout) {
        self.layout = layout
    }

    @discardableResult
    public func equalTo(_ other: View, inset: EdgeInsets = .zero, multiplier: Double = 1) -> [LayoutConstraint] {
        return [
            LayoutConstraint.update(first: layout.top, second: other.layout.top,
                                    offset: inset.top, multiplier: multiplier),
            
            LayoutConstraint.update(first: layout.left, second: other.layout.left,
                                    offset: inset.left, multiplier: multiplier),
            
            LayoutConstraint.update(first: layout.right, second: other.layout.right,
                                    offset: -inset.right, multiplier: multiplier),
            
            LayoutConstraint.update(first: layout.bottom, second: other.layout.bottom,
                                    offset: -inset.bottom, multiplier: multiplier),
        ]
    }
}

public struct LayoutAnchorSizeUpdater {
    let layout: View.Layout

    init(layout: View.Layout) {
        self.layout = layout
    }
    
    @discardableResult
    public func equalTo(_ other: View, multiplier: Double = 1) -> [LayoutConstraint] {
        return  [
            LayoutConstraint.update(first: layout.width,
                                    second: other.layout.width,
                                    multiplier: multiplier),
            LayoutConstraint.update(first: layout.height,
                                    second: other.layout.height,
                                    multiplier: multiplier)
        ]
    }
}

public struct LayoutAnchorCreator<T> {
    let anchor: LayoutAnchor<T>

    init(anchor: LayoutAnchor<T>) {
        self.anchor = anchor
    }

    @discardableResult
    public func equalTo(_ value: Double) -> LayoutConstraint {
        LayoutConstraint.create(first: anchor, offset: value)
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchor<T>, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint.create(first: anchor,
                                second: other,
                                offset: offset,
                                multiplier: multiplier)
    }

    @discardableResult
    public func equalTo(_ other: View, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint._create(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherView(anchor.kind, other),
                                 offset: offset,
                                 multiplier: multiplier)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ value: Double) -> LayoutConstraint {
        LayoutConstraint.create(first: anchor, relationship: .lessThanOrEqual, offset: value)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: LayoutAnchor<T>, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint.create(first: anchor,
                                second: other,
                                relationship: .lessThanOrEqual,
                                offset: offset,
                                multiplier: multiplier)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: View, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint._create(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherView(anchor.kind, other),
                                 relationship: .lessThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ value: Double) -> LayoutConstraint {
        LayoutConstraint.create(first: anchor, relationship: .greaterThanOrEqual, offset: value)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: LayoutAnchor<T>, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint.create(first: anchor,
                                 second: other,
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: View, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint._create(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherView(anchor.kind, other),
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }
}

public struct LayoutAnchorUpdater<T> {
    let anchor: LayoutAnchor<T>

    init(anchor: LayoutAnchor<T>) {
        self.anchor = anchor
    }

    @discardableResult
    public func equalTo(_ value: Double) -> LayoutConstraint {
        LayoutConstraint.update(first: anchor, offset: value)
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchor<T>, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint.update(first: anchor,
                                second: other,
                                offset: offset,
                                multiplier: multiplier)
    }

    @discardableResult
    public func equalTo(_ other: View, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint._update(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherView(anchor.kind, other),
                                 offset: offset,
                                 multiplier: multiplier)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ value: Double) -> LayoutConstraint {
        LayoutConstraint.update(first: anchor, relationship: .lessThanOrEqual, offset: value)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: LayoutAnchor<T>, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint.update(first: anchor,
                                second: other,
                                relationship: .lessThanOrEqual,
                                offset: offset,
                                multiplier: multiplier)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: View, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint._update(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherView(anchor.kind, other),
                                 relationship: .lessThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ value: Double) -> LayoutConstraint {
        LayoutConstraint.update(first: anchor, relationship: .greaterThanOrEqual, offset: value)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: LayoutAnchor<T>, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint.update(first: anchor,
                                second: other,
                                relationship: .greaterThanOrEqual,
                                offset: offset,
                                multiplier: multiplier)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: View, offset: Double = 0, multiplier: Double = 1) -> LayoutConstraint {
        LayoutConstraint._update(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherView(anchor.kind, other),
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }
}

private func anchorOnOtherView(_ kind: AnchorKind, _ view: View) -> InternalLayoutAnchor {
    switch kind {
    case .width:
        return view.layout.width.toInternalLayoutAnchor()
    case .height:
        return view.layout.height.toInternalLayoutAnchor()
    case .left:
        return view.layout.left.toInternalLayoutAnchor()
    case .top:
        return view.layout.top.toInternalLayoutAnchor()
    case .right:
        return view.layout.right.toInternalLayoutAnchor()
    case .bottom:
        return view.layout.bottom.toInternalLayoutAnchor()
    case .centerX:
        return view.layout.centerX.toInternalLayoutAnchor()
    case .centerY:
        return view.layout.centerY.toInternalLayoutAnchor()
    case .firstBaseline:
        return view.layout.firstBaseline.toInternalLayoutAnchor()
    }
}
