public class ViewTraveler<Visitor: ViewVisitor> {
    var state: Visitor.State
    let visitor: Visitor

    public init(state: Visitor.State, visitor: Visitor) {
        self.state = state
        self.visitor = visitor
    }

    public convenience init(visitor: Visitor) where Visitor.State == Void {
        self.init(state: (), visitor: visitor)
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
