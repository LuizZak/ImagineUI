public protocol ViewVisitor {
    associatedtype State

    func onVisitorEnter(_ state: State, _ view: View)
    func visitView(_ state: State, _ view: View) -> ViewVisitorResult
    func shouldVisitView(_ state: State, _ view: View) -> Bool
    func onVisitorExit(_ state: State, _ view: View)
}

public enum ViewVisitorResult {
    case visitChildren
    case skipChildren
}

public class ClosureViewVisitor<T>: ViewVisitor {
    public typealias State = T
    let visitor: (T, View) -> Void

    public init(visitor: @escaping (T, View) -> Void) {
        self.visitor = visitor
    }

    public func onVisitorEnter(_ state: T, _ view: View) {

    }

    public func visitView(_ state: T, _ view: View) -> ViewVisitorResult {
        visitor(state, view)
        return .visitChildren
    }

    public func shouldVisitView(_ state: T, _ view: View) -> Bool {
        return true
    }

    public func onVisitorExit(_ state: T, _ view: View) {

    }
}

public class ViewTraveler<Visitor: ViewVisitor> {
    let state: Visitor.State
    let visitor: Visitor

    public init(state: Visitor.State, visitor: Visitor) {
        self.state = state
        self.visitor = visitor
    }

    public func travelThrough(view: View) {
        if !visitor.shouldVisitView(state, view) {
            return
        }

        visitor.onVisitorEnter(state, view)

        if visitor.visitView(state, view) == .visitChildren {
            for subview in view.subviews {
                travelThrough(view: subview)
            }
        }

        visitor.onVisitorExit(state, view)
    }
}

public extension ViewTraveler where Visitor.State == Void {
    convenience init(visitor: Visitor) {
        self.init(state: (), visitor: visitor)
    }
}
