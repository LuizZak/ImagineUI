import CassowarySwift

public enum Relationship: CustomStringConvertible {
    case equal
    case greaterThanOrEqual
    case lessThanOrEqual

    public var description: String {
        switch self {
        case .equal:
            return "=="
        case .greaterThanOrEqual:
            return ">="
        case .lessThanOrEqual:
            return "<="
        }
    }

    func makeConstraint(left: Variable, right: Variable, offset: Double, multiplier: Double) -> Constraint {
        if multiplier == 1 {
            return makeConstraint(left: left, right: right, offset: offset)
        }

        switch self {
        case .equal:
            return left == (right * multiplier) + offset
        case .greaterThanOrEqual:
            return left >= (right * multiplier) + offset
        case .lessThanOrEqual:
            return left <= (right * multiplier) + offset
        }
    }

    func makeConstraint(left: Variable, right: Expression, offset: Expression, multiplier: Double) -> Constraint {
        if multiplier == 1 {
            return makeConstraint(left: left, right: right, offset: offset)
        }

        switch self {
        case .equal:
            return left == (right * multiplier) + offset
        case .greaterThanOrEqual:
            return left >= (right * multiplier) + offset
        case .lessThanOrEqual:
            return left <= (right * multiplier) + offset
        }
    }

    func makeConstraint(left: Variable, right: Variable, offset: Double) -> Constraint {
        if offset == 0 {
            return makeConstraint(left: left, right: right)
        }

        switch self {
        case .equal:
            return left == right + offset
        case .greaterThanOrEqual:
            return left >= right + offset
        case .lessThanOrEqual:
            return left <= right + offset
        }
    }

    func makeConstraint(left: Variable, right: Expression, offset: Expression) -> Constraint {
        switch self {
        case .equal:
            return left == right + offset
        case .greaterThanOrEqual:
            return left >= right + offset
        case .lessThanOrEqual:
            return left <= right + offset
        }
    }

    func makeConstraint(left: Variable, right: Expression) -> Constraint {
        switch self {
        case .equal:
            return left == right
        case .greaterThanOrEqual:
            return left >= right
        case .lessThanOrEqual:
            return left <= right
        }
    }

    func makeConstraint(left: Variable, right: Variable) -> Constraint {
        switch self {
        case .equal:
            return left == right
        case .greaterThanOrEqual:
            return left >= right
        case .lessThanOrEqual:
            return left <= right
        }
    }

    func makeConstraint(left: Variable, offset: Double) -> Constraint {
        switch self {
        case .equal:
            return left == offset
        case .greaterThanOrEqual:
            return left >= offset
        case .lessThanOrEqual:
            return left <= offset
        }
    }
}
