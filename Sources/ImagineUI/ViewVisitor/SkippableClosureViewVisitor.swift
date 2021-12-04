/// A closure-based view visitor that skips all remaining view visits after the
/// provided closure returns `.skipChildren` for the first time.
public class SkippableClosureViewVisitor<T>: ViewVisitor {
    public typealias State = T
    var shouldSkipAll: Bool = false
    let visitor: (inout T, View) -> ViewVisitorResult

    public init(visitor: @escaping (inout T, View) -> ViewVisitorResult) {
        self.visitor = visitor
    }

    public convenience init(visitor: @escaping (View) -> ViewVisitorResult) where T == Void {
        self.init(visitor: { (_, view) in visitor(view) })
    }

    public func onVisitorEnter(_ view: View, _ state: inout T) {

    }

    public func visitView(_ view: View, _ state: inout T) -> ViewVisitorResult {
        guard !shouldSkipAll else {
            return .skipChildren
        }

        let result = visitor(&state, view)
        if result == .skipChildren {
            shouldSkipAll = true
        }

        return result
    }

    public func shouldVisitView(_ view: View, _ state: T) -> Bool {
        return !shouldSkipAll
    }

    public func onVisitorExit(_ view: View, _ state: inout T) {

    }
}
