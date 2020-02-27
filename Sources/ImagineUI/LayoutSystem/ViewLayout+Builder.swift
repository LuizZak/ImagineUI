public extension View.Layout {
    func makeConstraints(_ builder: (LayoutAnchorUpdateCreator) -> Void) {
        builder(LayoutAnchorUpdateCreator(layout: self))
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
}

public class LayoutAnchorEdgesCreator {
    let layout: View.Layout

    init(layout: View.Layout) {
        self.layout = layout
    }

    public func equalTo(_ other: View, inset: EdgeInsets = .empty, multiplier: Double = 1) {
        LayoutConstraint.create(first: layout.top, second: other.layout.top,
                                offset: inset.top, multiplier: multiplier)

        LayoutConstraint.create(first: layout.left, second: other.layout.left,
                                offset: inset.left, multiplier: multiplier)

        LayoutConstraint.create(first: layout.right, second: other.layout.right,
                                offset: -inset.right, multiplier: multiplier)

        LayoutConstraint.create(first: layout.bottom, second: other.layout.bottom,
                                offset: -inset.bottom, multiplier: multiplier)
    }
}

public class LayoutAnchorEdgesUpdater {
    let layout: View.Layout

    init(layout: View.Layout) {
        self.layout = layout
    }

    public func equalTo(_ other: View, inset: EdgeInsets = .empty, multiplier: Double = 1) {
        LayoutConstraint.update(first: layout.top, second: other.layout.top,
                                offset: inset.top, multiplier: multiplier)

        LayoutConstraint.update(first: layout.left, second: other.layout.left,
                                offset: inset.left, multiplier: multiplier)

        LayoutConstraint.update(first: layout.right, second: other.layout.right,
                                offset: -inset.right, multiplier: multiplier)

        LayoutConstraint.update(first: layout.bottom, second: other.layout.bottom,
                                offset: -inset.bottom, multiplier: multiplier)
    }
}

public class LayoutAnchorCreator<T> {
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
        LayoutConstraint._create(first: anchor,
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
        LayoutConstraint._create(first: anchor,
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
        LayoutConstraint._create(first: anchor,
                                 second: anchorOnOtherView(anchor.kind, other),
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }
}

public class LayoutAnchorUpdater<T> {
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
        LayoutConstraint._update(first: anchor,
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
        LayoutConstraint._update(first: anchor,
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
        LayoutConstraint._update(first: anchor,
                                 second: anchorOnOtherView(anchor.kind, other),
                                 relationship: .greaterThanOrEqual,
                                 offset: offset,
                                 multiplier: multiplier)
    }
}

private func anchorOnOtherView(_ kind: AnchorKind, _ view: View) -> InternalLayoutAnchorType {
    switch kind {
    case .width:
        return view.layout.width
    case .height:
        return view.layout.height
    case .left:
        return view.layout.left
    case .top:
        return view.layout.top
    case .right:
        return view.layout.right
    case .bottom:
        return view.layout.bottom
    case .centerX:
        return view.layout.centerX
    case .centerY:
        return view.layout.centerY
    case .firstBaseline:
        return view.layout.firstBaseline
    }
}
