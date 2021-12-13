/// Specifies the orientation of a layout constraint.
enum LayoutConstraintOrientation {
    /// Specifies a constraint that connects two horizontal anchors.
    case horizontal

    /// Specifies a constraint that connects two vertical anchors.
    case vertical

    /// Specifies a constraint that connects a horizontal and vertical constraint.
    /// Used for layout constraints that connect width and height anchors.
    case mixed
}

extension LayoutAnchorOrientation {
    var asLayoutConstraintOrientation: LayoutConstraintOrientation {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}
