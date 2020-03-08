public struct LayoutAnchor<T>: LayoutAnchorType, Equatable, CustomStringConvertible {
    internal weak var _owner: LayoutVariablesContainer?
    public var owner: AnyObject? { return _owner }
    public var kind: AnchorKind

    public var orientation: LayoutAnchorOrientation {
        switch kind {
        case .left, .width, .right, .centerX:
            return .horizontal
            
        case .top, .height, .bottom, .centerY, .firstBaseline:
            return .vertical
        }
    }

    public var description: String {
        return toInternalLayoutAnchor().getVariable()?.name ?? "<unowned anchor>"
    }
    
    public static func == (lhs: LayoutAnchor, rhs: LayoutAnchor) -> Bool {
        return lhs._owner === rhs._owner && lhs.kind == rhs.kind
    }
}

extension LayoutAnchor {
    func toInternalLayoutAnchor() -> InternalLayoutAnchor {
        return InternalLayoutAnchor(_owner: _owner, kind: kind)
    }
}

public enum LayoutAnchorOrientation {
    case horizontal
    case vertical
}
