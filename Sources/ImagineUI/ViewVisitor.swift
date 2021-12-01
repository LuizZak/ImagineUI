public protocol ViewVisitor {
    associatedtype State

    func onVisitorEnter(_ view: View, _ state: inout State)
    func visitView(_ view: View, _ state: inout State) -> ViewVisitorResult
    func shouldVisitView(_ view: View, _ state: State) -> Bool
    func onVisitorExit(_ view: View, _ state: inout State)
}

public extension ViewVisitor {
    func onVisitorEnter(_ view: View, _ state: inout State) {

    }

    func shouldVisitView(_ view: View, _ state: State) -> Bool {
        return true
    }

    func onVisitorExit(_ view: View, _ state: inout State) {

    }
}

public enum ViewVisitorResult {
    case visitChildren
    case skipChildren
}

public class ClosureViewVisitor<T>: ViewVisitor {
    public typealias State = T
    let visitor: (inout T, View) -> Void

    public init(visitor: @escaping (inout T, View) -> Void) {
        self.visitor = visitor
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

public class ViewTraveler<Visitor: ViewVisitor> {
    var state: Visitor.State
    let visitor: Visitor

    public init(state: Visitor.State, visitor: Visitor) {
        self.state = state
        self.visitor = visitor
    }

    public func travelThrough(view: View) {
        if !visitor.shouldVisitView(view, state) {
            return
        }

        visitor.onVisitorEnter(view, &state)

        if visitor.visitView(view, &state) == .visitChildren {
            for subview in view.subviews {
                travelThrough(view: subview)
            }
        }

        visitor.onVisitorExit(view, &state)
    }
}

public extension ViewTraveler where Visitor.State == Void {
    convenience init(visitor: Visitor) {
        self.init(state: (), visitor: visitor)
    }
}
