import CassowarySwift

internal struct AnyLayoutAnchor: LayoutAnchorType, Hashable {
    weak var _owner: LayoutVariablesContainer?
    var kind: AnchorKind

    var owner: AnyObject? { return _owner }

    var orientation: LayoutAnchorOrientation {
        switch kind {
        case .left, .width, .right, .centerX:
            return .horizontal

        case .top, .height, .bottom, .centerY, .firstBaseline:
            return .vertical
        }
    }

    var description: String {
        return getVariable()?.name ?? "<unowned anchor>"
    }

    func getVariable() -> Variable? {
        switch kind {
        case .width:
            return _owner?.layoutVariables.width
        case .height:
            return _owner?.layoutVariables.height
        case .left:
            return _owner?.layoutVariables.left
        case .top:
            return _owner?.layoutVariables.top
        case .right:
            return _owner?.layoutVariables.right
        case .bottom:
            return _owner?.layoutVariables.bottom
        case .centerX:
            return _owner?.layoutVariables.centerX
        case .centerY:
            return _owner?.layoutVariables.centerY
        case .firstBaseline:
            return _owner?.layoutVariables.firstBaseline
        }
    }

    // Returns an expression that can be subtracted from this layout anchor's
    // `makeVariable` result to create an expression that is relative to another
    // view's location.
    func makeRelativeExpression(relative: LayoutVariablesContainer) -> Expression {
        switch kind {
        case .width, .height:
            return Expression(constant: 0)

        case .left, .right, .centerX:
            return Expression(term: Term(variable: relative.layoutVariables.left))

        case .top, .bottom, .centerY, .firstBaseline:
            return Expression(term: Term(variable: relative.layoutVariables.top))
        }
    }

    func makeExpression(variable: Variable, relative: LayoutVariablesContainer) -> Expression {
        return variable - makeRelativeExpression(relative: relative)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_owner.map(ObjectIdentifier.init))
        hasher.combine(kind)
    }

    static func == (lhs: AnyLayoutAnchor, rhs: AnyLayoutAnchor) -> Bool {
        return lhs.kind == rhs.kind && lhs._owner === rhs._owner
    }
}
