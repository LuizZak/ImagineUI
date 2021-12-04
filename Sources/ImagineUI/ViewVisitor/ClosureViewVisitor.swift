public class ClosureViewVisitor<T>: ViewVisitor {
    public typealias State = T
    let visitor: (inout T, View) -> Void

    public init(visitor: @escaping (inout T, View) -> Void) {
        self.visitor = visitor
    }

    public convenience init(visitor: @escaping (View) -> Void) where T == Void {
        self.init(visitor: { (_, view) in visitor(view) })
    }

    public func onVisitorEnter(_ view: View, _ state: inout T) {

    }

    public func visitView(_ view: View, _ state: inout T) -> ViewVisitorResult {
        visitor(&state, view)
        return .visitChildren
    }

    public func shouldVisitView(_ view: View, _ state: T) -> Bool {
        return true
    }

    public func onVisitorExit(_ view: View, _ state: inout T) {

    }
}
