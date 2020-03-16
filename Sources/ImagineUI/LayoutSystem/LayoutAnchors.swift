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

    init(container: LayoutVariablesContainer) {
        self.container = container
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
