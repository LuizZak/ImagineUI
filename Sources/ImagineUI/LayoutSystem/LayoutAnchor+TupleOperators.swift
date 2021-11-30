// MARK: Container

@LayoutResultBuilder
public func == <T0, T1>(lhs: (LayoutAnchor<T0>, LayoutAnchor<T1>), rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
    lhs.0 == rhs
    lhs.1 == rhs
}

@LayoutResultBuilder
public func == <T0, T1, T2>(lhs: (LayoutAnchor<T0>, LayoutAnchor<T1>, LayoutAnchor<T2>), rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
    lhs.0 == rhs
    lhs.1 == rhs
    lhs.2 == rhs
}

@LayoutResultBuilder
public func == <T0, T1, T2, T3>(lhs: (LayoutAnchor<T0>, LayoutAnchor<T1>, LayoutAnchor<T2>, LayoutAnchor<T3>), rhs: LayoutAnchorsContainer) -> LayoutConstraintDefinitions {
    lhs.0 == rhs
    lhs.1 == rhs
    lhs.2 == rhs
    lhs.3 == rhs
}

// MARK: Constant

@LayoutResultBuilder
public func == <T0, T1>(lhs: (LayoutAnchor<T0>, LayoutAnchor<T1>), rhs: Double) -> LayoutConstraintDefinitions {
    lhs.0 == rhs
    lhs.1 == rhs
}

@LayoutResultBuilder
public func == <T0, T1, T2>(lhs: (LayoutAnchor<T0>, LayoutAnchor<T1>, LayoutAnchor<T2>), rhs: Double) -> LayoutConstraintDefinitions {
    lhs.0 == rhs
    lhs.1 == rhs
    lhs.2 == rhs
}

@LayoutResultBuilder
public func == <T0, T1, T2, T3>(lhs: (LayoutAnchor<T0>, LayoutAnchor<T1>, LayoutAnchor<T2>, LayoutAnchor<T3>), rhs: Double) -> LayoutConstraintDefinitions {
    lhs.0 == rhs
    lhs.1 == rhs
    lhs.2 == rhs
    lhs.3 == rhs
}
