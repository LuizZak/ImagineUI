@ImagineActor
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
