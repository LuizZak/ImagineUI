public extension LayoutAnchors {
    func makeConstraints(_ builder: (LayoutAnchorUpdateCreator) -> Void) {
        if let view = container as? View {
            view.areaIntoConstraintsMask = []
        }
        
        builder(LayoutAnchorUpdateCreator(layout: self))
    }
    
    func remakeConstraints(_ builder: (LayoutAnchorUpdateCreator) -> Void) {
        for constraint in container.constraints {
            constraint.removeConstraint()
        }
        
        makeConstraints(builder)
    }

    func updateConstraints(_ builder: (LayoutAnchorUpdateBuilder) -> Void) {
        builder(LayoutAnchorUpdateBuilder(layout: self))
    }
}

public struct LayoutAnchorUpdateCreator {
    let layout: LayoutAnchors

    public var width: LayoutAnchorCreator<DimensionLayoutAnchor> { .init(anchor: layout.width) }
    public var height: LayoutAnchorCreator<DimensionLayoutAnchor> { .init(anchor: layout.height) }
    public var left: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.left) }
    public var right: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.right) }
    public var top: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.top) }
    public var bottom: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.bottom) }
    public var centerX: LayoutAnchorCreator<XLayoutAnchor> { .init(anchor: layout.centerX) }
    public var centerY: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.centerY) }
    public var firstBaseline: LayoutAnchorCreator<YLayoutAnchor> { .init(anchor: layout.firstBaseline) }
    public var edges: LayoutAnchorEdgesCreator { .init(layout: layout) }
    public var size: LayoutAnchorSizeCreator { .init(layout: layout) }
    
    @discardableResult
    public func left(of other: LayoutAnchorsContainer,
                     offset: Double = 0,
                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        return right.equalTo(other.layout.left, offset: offset, priority: priority)
    }
    
    @discardableResult
    public func right(of other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraint {
        
        return left.equalTo(other.layout.right, offset: offset, priority: priority)
    }
    
    @discardableResult
    public func under(_ other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraint {
        
        return top.equalTo(other.layout.bottom, offset: offset, priority: priority)
    }
}

public struct LayoutAnchorUpdateBuilder {
    let layout: LayoutAnchors

    public var width: LayoutAnchorUpdater<DimensionLayoutAnchor> { .init(anchor: layout.width) }
    public var height: LayoutAnchorUpdater<DimensionLayoutAnchor> { .init(anchor: layout.height) }
    public var left: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.left) }
    public var right: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.right) }
    public var top: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.top) }
    public var bottom: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.bottom) }
    public var centerX: LayoutAnchorUpdater<XLayoutAnchor> { .init(anchor: layout.centerX) }
    public var centerY: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.centerY) }
    public var firstBaseline: LayoutAnchorUpdater<YLayoutAnchor> { .init(anchor: layout.firstBaseline) }
    public var edges: LayoutAnchorEdgesUpdater { .init(layout: layout) }
    public var size: LayoutAnchorSizeUpdater { .init(layout: layout) }
    
    @discardableResult
    public func left(of other: LayoutAnchorsContainer,
                     offset: Double = 0,
                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        return right.equalTo(other.layout.left, offset: offset, priority: priority)
    }
    
    @discardableResult
    public func right(of other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraint {
        
        return left.equalTo(other.layout.right, offset: offset, priority: priority)
    }
    
    @discardableResult
    public func under(_ other: LayoutAnchorsContainer,
                      offset: Double = 0,
                      priority: LayoutPriority = .required) -> LayoutConstraint {
        
        return top.equalTo(other.layout.bottom, offset: offset, priority: priority)
    }
}

public struct LayoutAnchorEdgesCreator {
    let layout: LayoutAnchors

    init(layout: LayoutAnchors) {
        self.layout = layout
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchorsContainer,
                        inset: EdgeInsets = .zero,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> [LayoutConstraint] {
        
        return [
            LayoutConstraint.create(first: layout.top,
                                    second: other.layout.top,
                                    offset: inset.top,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.create(first: layout.left,
                                    second: other.layout.left,
                                    offset: inset.left,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.create(first: layout.right,
                                    second: other.layout.right,
                                    offset: -inset.right,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.create(first: layout.bottom,
                                    second: other.layout.bottom,
                                    offset: -inset.bottom,
                                    multiplier: multiplier,
                                    priority: priority),
        ]
    }
}

public struct LayoutAnchorSizeCreator {
    let layout: LayoutAnchors

    init(layout: LayoutAnchors) {
        self.layout = layout
    }
    
    @discardableResult
    public func equalTo(_ other: LayoutAnchorsContainer,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> [LayoutConstraint] {
        
        return  [
            LayoutConstraint.create(first: layout.width,
                                    second: other.layout.width,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.create(first: layout.height,
                                    second: other.layout.height,
                                    multiplier: multiplier,
                                    priority: priority)
        ]
    }
    
    @discardableResult
    public func equalTo(_ size: Size, priority: LayoutPriority = .required) -> [LayoutConstraint] {
        
        return  [
            LayoutConstraint.create(first: layout.width,
                                    offset: size.x,
                                    priority: priority),
            
            LayoutConstraint.create(first: layout.height,
                                    offset: size.y,
                                    priority: priority)
        ]
    }
}

public struct LayoutAnchorEdgesUpdater {
    let layout: LayoutAnchors

    init(layout: LayoutAnchors) {
        self.layout = layout
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchorsContainer,
                        inset: EdgeInsets = .zero,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> [LayoutConstraint] {
        
        return [
            LayoutConstraint.update(first: layout.top,
                                    second: other.layout.top,
                                    offset: inset.top,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.update(first: layout.left,
                                    second: other.layout.left,
                                    offset: inset.left,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.update(first: layout.right,
                                    second: other.layout.right,
                                    offset: -inset.right,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.update(first: layout.bottom,
                                    second: other.layout.bottom,
                                    offset: -inset.bottom,
                                    multiplier: multiplier,
                                    priority: priority),
        ]
    }
}

public struct LayoutAnchorSizeUpdater {
    let layout: LayoutAnchors

    init(layout: LayoutAnchors) {
        self.layout = layout
    }
    
    @discardableResult
    public func equalTo(_ other: LayoutAnchorsContainer,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> [LayoutConstraint] {
        
        return  [
            LayoutConstraint.update(first: layout.width,
                                    second: other.layout.width,
                                    multiplier: multiplier,
                                    priority: priority),
            
            LayoutConstraint.update(first: layout.height,
                                    second: other.layout.height,
                                    multiplier: multiplier,
                                    priority: priority)
        ]
    }
    
    @discardableResult
    public func equalTo(_ size: Size, priority: LayoutPriority = .required) -> [LayoutConstraint] {
        return  [
            LayoutConstraint.update(first: layout.width,
                                    offset: size.x,
                                    priority: priority),
            
            LayoutConstraint.update(first: layout.height,
                                    offset: size.y,
                                    priority: priority)
        ]
    }
}

public struct LayoutAnchorCreator<T> {
    let anchor: LayoutAnchor<T>

    init(anchor: LayoutAnchor<T>) {
        self.anchor = anchor
    }

    @discardableResult
    public func equalTo(_ value: Double,
                        priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.create(first: anchor, offset: value, priority: priority)
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchor<T>,
                        offset: Double = 0,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.create(first: anchor,
                                second: other,
                                offset: offset,
                                multiplier: multiplier,
                                priority: priority)
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchorsContainer,
                        offset: Double = 0,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint._create(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherContainer(anchor.kind, other),
                                 offset: offset,
                                 multiplier: multiplier,
                                 priority: priority)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ value: Double,
                                  priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.create(first: anchor, relationship: .lessThanOrEqual,
                                offset: value, priority: priority)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: LayoutAnchor<T>,
                                  offset: Double = 0,
                                  multiplier: Double = 1,
                                  priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.create(first: anchor,
                                second: other,
                                relationship: .lessThanOrEqual,
                                offset: offset,
                                multiplier: multiplier,
                                priority: priority)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: LayoutAnchorsContainer,
                                  offset: Double = 0,
                                  multiplier: Double = 1,
                                  priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint._create(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherContainer(anchor.kind, other),
                                 relationship: .lessThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier,
                                 priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ value: Double,
                                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.create(first: anchor,
                                relationship: .greaterThanOrEqual,
                                offset: value,
                                priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: LayoutAnchor<T>,
                                     offset: Double = 0,
                                     multiplier: Double = 1,
                                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.create(first: anchor,
                                second: other,
                                relationship: .greaterThanOrEqual,
                                offset: offset,
                                multiplier: multiplier,
                                priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: LayoutAnchorsContainer,
                                     offset: Double = 0,
                                     multiplier: Double = 1,
                                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint._create(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherContainer(anchor.kind, other),
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier,
                                 priority: priority)
    }
}

public struct LayoutAnchorUpdater<T> {
    let anchor: LayoutAnchor<T>

    init(anchor: LayoutAnchor<T>) {
        self.anchor = anchor
    }

    @discardableResult
    public func equalTo(_ value: Double,
                        priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.update(first: anchor, offset: value, priority: priority)
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchor<T>,
                        offset: Double = 0,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.update(first: anchor,
                                second: other,
                                offset: offset,
                                multiplier: multiplier,
                                priority: priority)
    }

    @discardableResult
    public func equalTo(_ other: LayoutAnchorsContainer,
                        offset: Double = 0,
                        multiplier: Double = 1,
                        priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint._update(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherContainer(anchor.kind, other),
                                 offset: offset,
                                 multiplier: multiplier,
                                 priority: priority)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ value: Double,
                                  priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.update(first: anchor,
                                relationship: .lessThanOrEqual,
                                offset: value,
                                priority: priority)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: LayoutAnchor<T>,
                                  offset: Double = 0,
                                  multiplier: Double = 1,
                                  priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.update(first: anchor,
                                second: other,
                                relationship: .lessThanOrEqual,
                                offset: offset,
                                multiplier: multiplier,
                                priority: priority)
    }

    @discardableResult
    public func lessThanOrEqualTo(_ other: LayoutAnchorsContainer,
                                  offset: Double = 0,
                                  multiplier: Double = 1,
                                  priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint._update(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherContainer(anchor.kind, other),
                                 relationship: .lessThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier,
                                 priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ value: Double,
                                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.update(first: anchor,
                                relationship: .greaterThanOrEqual,
                                offset: value,
                                priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: LayoutAnchor<T>,
                                     offset: Double = 0,
                                     multiplier: Double = 1,
                                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint.update(first: anchor,
                                second: other,
                                relationship: .greaterThanOrEqual,
                                offset: offset,
                                multiplier: multiplier,
                                priority: priority)
    }

    @discardableResult
    public func greaterThanOrEqualTo(_ other: LayoutAnchorsContainer,
                                     offset: Double = 0,
                                     multiplier: Double = 1,
                                     priority: LayoutPriority = .required) -> LayoutConstraint {
        
        LayoutConstraint._update(first: anchor.toInternalLayoutAnchor(),
                                 second: anchorOnOtherContainer(anchor.kind, other),
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier,
                                 priority: priority)
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
