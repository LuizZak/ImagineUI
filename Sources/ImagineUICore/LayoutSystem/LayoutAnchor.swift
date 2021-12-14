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

    /// Removes all constraints attached to this layout anchor.
    public func removeConstraints() {
        _owner?.constraintsOnAnchorKind(self.kind).forEach {
            $0.removeConstraint()
        }
    }

    /// Removes all constraints that tie this anchor to an absolute value,
    /// e.g. `layout.left >= 10` or `layout.width == 200`.
    public func removeAbsoluteConstraints() {
        _owner?.constraintsOnAnchorKind(self.kind).forEach {
            if $0.second == nil {
                $0.removeConstraint()
            }
        }
    }

    public static func == (lhs: LayoutAnchor, rhs: LayoutAnchor) -> Bool {
        return lhs._owner === rhs._owner && lhs.kind == rhs.kind
    }
}

extension LayoutAnchor {
    func toInternalLayoutAnchor() -> AnyLayoutAnchor {
        return AnyLayoutAnchor(_owner: _owner, kind: kind)
    }
}
