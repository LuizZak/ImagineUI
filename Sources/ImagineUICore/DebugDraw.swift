import Geometry
import Rendering

public enum DebugDraw {
    public static func debugDrawRecursive(
        _ view: View,
        flags: Set<DebugDrawFlags>,
        in renderer: Renderer
    ) {

        if flags.isEmpty {
            return
        }
        
        let state = State()
        
        internalDebugDrawRecursive(
            view,
            flags: flags.intersection([.viewBounds, .layoutGuideBounds]),
            to: renderer,
            state: state)
        
        internalDebugDrawRecursive(
            view,
            flags: flags.intersection([.constraints]),
            to: renderer,
            state: state)
    }
}

extension DebugDraw {
    private static func internalDebugDrawRecursive(
        _ view: View,
        flags: Set<DebugDrawFlags>,
        to renderer: Renderer,
        state: State
    ) {
        
        if flags.isEmpty {
            return
        }
        
        let visitor = ClosureViewVisitor<Void> { (_, view) in
            debugDraw(view, flags: flags, to: renderer, state: state)
        }
        let traveler = ViewTraveler(visitor: visitor)
        traveler.travelThrough(view: view)
    }
    
    private static func debugDraw(
        _ view: View,
        flags: Set<DebugDrawFlags>,
        to renderer: Renderer,
        state: State
    ) {
        
        if flags.contains(.viewBounds) {
            drawBounds(view, to: renderer)
        }
        if flags.contains(.layoutGuideBounds) {
            drawLayoutGuideBounds(view, to: renderer)
        }
        if flags.contains(.constraints) {
            drawConstraints(view, to: renderer, state: state)
        }
    }
    
    private static func drawBounds(_ view: View, to renderer: Renderer) {
        let screenBounds = view.convert(bounds: view.bounds, to: nil)
        
        renderer.setStroke(Color.red)
        renderer.setStrokeWidth(1)
        renderer.stroke(screenBounds)
        renderer.setFill(Color.red)
        renderer.fill(UICircle(x: 0, y: 0, radius: 2))
    }
    
    private static func drawLayoutGuideBounds(_ view: View, to renderer: Renderer) {
        for layoutGuide in view.layoutGuides {
            let screenBounds = view.convert(bounds: layoutGuide.area, to: nil)
            
            renderer.setStroke(Color.orange)
            renderer.setStrokeWidth(1)
            renderer.stroke(screenBounds)
            renderer.setFill(Color.red)
        }
    }
    
    private static func drawConstraints(_ view: View, to renderer: Renderer, state: State) {
        let cookie = renderer.saveState()
        renderer.restoreClipping()
        
        for constraint in view.containedConstraints {
            drawConstraint(constraint, to: renderer, state: state)
        }
        
        renderer.restoreState(cookie)
    }
    
    private static func drawConstraint(
        _ constraint: LayoutConstraint,
        to renderer: Renderer,
        state: State
    ) {
        
        if let second = constraint.secondCast {
            drawDualAnchorConstraint(
                constraint,
                first: constraint.firstCast,
                second: second,
                to: renderer,
                state: state
            )
        } else {
            drawSingleAnchorConstraint(constraint, to: renderer, state: state)
        }
    }
    
    private static func drawSingleAnchorConstraint(
        _ constraint: LayoutConstraint,
        to renderer: Renderer,
        state: State
    ) {
        
        guard let view = constraint.firstCast._owner else { return }
        let bounds = state.boundsForRedrawOnScreen(for: view)
        
        switch constraint.first.kind {
        case .width:
            let left = bounds.bottomLeft + UIVector(x: 0, y: 2)
            let right = bounds.bottomRight + UIVector(x: 0, y: 2)
            
            drawLine(start: left, end: right, tangentLength: 3, to: renderer)
            drawRelationship(
                relationship: constraint.relationship,
                at: (left + right) / 2, to: renderer
            )
            
        case .height:
            let top = bounds.topRight + UIVector(x: 2, y: 0)
            let bottom = bounds.bottomRight + UIVector(x: 2, y: 0)
            
            drawLine(start: top, end: bottom, tangentLength: 3, to: renderer)
            drawRelationship(
                relationship: constraint.relationship,
                at: (top + bottom) / 2, to: renderer
            )
            
        default:
            break
        }
    }
    
    private static func drawDualAnchorConstraint(
        _ constraint: LayoutConstraint,
        first: AnyLayoutAnchor,
        second: AnyLayoutAnchor,
        to renderer: Renderer,
        state: State
    ) {
        
        guard let firstOwner = first._owner else { return }
        guard let secondOwner = second._owner else { return }
        
        let firstBounds = state.boundsForRedrawOnScreen(for: firstOwner)
        let secondBounds = state.boundsForRedrawOnScreen(for: secondOwner)
        
        switch (first.kind, second.kind) {
        // Horizontal constraints
        case (.left, .left), (.left, .right), (.right, .left), (.right, .right):
            let firstEdge = extractEdge(firstBounds, edge: first.kind)
            let secondEdge = extractEdge(secondBounds, edge: second.kind)
            
            if firstEdge.topLeft.x < secondEdge.topLeft.x {
                connectHorizontalEdges(
                    edge1: (topLeft: firstEdge.topLeft, height: firstEdge.length),
                    edge2: (topLeft: secondEdge.topLeft, height: secondEdge.length),
                    relationship: constraint.relationship,
                    renderer: renderer
                )
            } else {
                connectHorizontalEdges(
                    edge1: (topLeft: secondEdge.topLeft, height: secondEdge.length),
                    edge2: (topLeft: firstEdge.topLeft, height: firstEdge.length),
                    relationship: constraint.relationship,
                    renderer: renderer
                )
            }
            
        // Vertical constraints
        case (.top, .top), (.top, .bottom), (.bottom, .top), (.bottom, .bottom):
            let firstEdge = extractEdge(firstBounds, edge: first.kind)
            let secondEdge = extractEdge(secondBounds, edge: second.kind)
            
            if firstEdge.topLeft.y < secondEdge.topLeft.y {
                connectVerticalEdges(
                    edge1: (topLeft: firstEdge.topLeft, width: firstEdge.length),
                    edge2: (topLeft: secondEdge.topLeft, width: secondEdge.length),
                    relationship: constraint.relationship,
                    renderer: renderer
                )
            } else {
                connectVerticalEdges(
                    edge1: (topLeft: secondEdge.topLeft, width: secondEdge.length),
                    edge2: (topLeft: firstEdge.topLeft, width: firstEdge.length),
                    relationship: constraint.relationship,
                    renderer: renderer
                )
            }
            
        case (.centerX, .centerX):
            connectCenterX(firstBounds, secondBounds, renderer: renderer)
            
        case (.centerY, .centerY):
            connectCenterY(firstBounds, secondBounds, renderer: renderer)
            
        default:
            break
        }
    }
    
    private static func connectHorizontalEdges(
        edge1: (topLeft: UIVector, height: Double),
        edge2: (topLeft: UIVector, height: Double),
        relationship: Relationship,
        renderer: Renderer
    ) {
        
        let center2 = edge2.topLeft.y + edge2.height / 2
        
        let edge1BottomLeft = UIVector(x: edge1.topLeft.x, y: edge1.topLeft.y + edge1.height)
        
        let edge1Top = min(edge1.topLeft.y, center2)
        let edge1Bottom = max(edge1BottomLeft.y, center2)
        
        // Only draw first edge if the horizontal line to be drawn is outside the
        // range of the boundary
        if center2 < edge1.topLeft.y || center2 > edge1.topLeft.y + edge1.height {
            drawLine(
                start: UIVector(x: edge1.topLeft.x, y: edge1Top),
                end: UIVector(x: edge1.topLeft.x, y: edge1Bottom),
                tangentLength: 0,
                to: renderer
            )
        }
        
        let start = UIVector(x: edge1.topLeft.x, y: center2)
        let end = UIVector(x: edge2.topLeft.x, y: center2)
        
        drawLine(
            start: start,
            end: end,
            tangentLength: 3,
            to: renderer
        )
        
        drawRelationship(
            relationship: relationship,
            at: (start + end) / 2,
            to: renderer
        )
    }
    
    private static func connectVerticalEdges(
        edge1: (topLeft: UIVector, width: Double),
        edge2: (topLeft: UIVector, width: Double),
        relationship: Relationship,
        renderer: Renderer
    ) {
        
        let center2 = edge2.topLeft.x + edge2.width / 2
        
        let edge1TopRight = UIVector(x: edge1.topLeft.x + edge1.width, y: edge1.topLeft.y)
        
        let edge1Left = min(edge1.topLeft.x, center2)
        let edge1Right = max(edge1TopRight.x, center2)
        
        // Only draw first edge if the vertical line to be drawn is outside the
        // range of the boundary
        if center2 < edge1.topLeft.x || center2 > edge1.topLeft.x + edge1.width {
            drawLine(
                start: UIVector(x: edge1Left, y: edge1.topLeft.y),
                end: UIVector(x: edge1Right, y: edge1.topLeft.y),
                tangentLength: 0,
                to: renderer
            )
        }
        
        let start = UIVector(x: center2, y: edge1.topLeft.y)
        let end = UIVector(x: center2, y: edge2.topLeft.y)
        
        drawLine(
            start: start,
            end: end,
            tangentLength: 3,
            to: renderer
        )
        
        drawRelationship(
            relationship: relationship,
            at: (start + end) / 2,
            to: renderer
        )
    }
    
    private static func connectCenterX(
        _ rect1: UIRectangle,
        _ rect2: UIRectangle,
        renderer: Renderer
    ) {
        
        prepareStroke(in: renderer)
        
        let union = rect1.union(rect2)
        
        let rect1Top: UIPoint
        let rect1Bottom: UIPoint
        let rect2Top: UIPoint
        let rect2Bottom: UIPoint
        let lineStart: UIPoint
        let lineEnd: UIPoint
        
        // Draw a horizontal line that centers on the largest of the rectangles,
        // with the vertical bounds matching the total vertical space occupied
        // by both rectangles
        
        if rect1.height > rect2.height {
            rect1Top = UIPoint(x: rect1.center.x, y: union.top)
            rect1Bottom = UIPoint(x: rect1.center.x, y: union.bottom)
            rect2Top = UIPoint(x: rect2.center.x, y: rect2.top)
            rect2Bottom = UIPoint(x: rect2.center.x, y: rect2.bottom)
            
            lineStart = UIPoint(x: rect1.center.x, y: rect2.center.y)
            lineEnd = UIPoint(x: rect2.center.x, y: rect2.center.y)
        } else {
            rect1Top = UIPoint(x: rect1.center.x, y: rect1.top)
            rect1Bottom = UIPoint(x: rect1.center.x, y: rect1.bottom)
            rect2Top = UIPoint(x: rect2.center.x, y: union.top)
            rect2Bottom = UIPoint(x: rect2.center.x, y: union.bottom)
            
            lineStart = UIPoint(x: rect2.center.x, y: rect1.center.y)
            lineEnd = UIPoint(x: rect1.center.x, y: rect1.center.y)
        }
        
        renderer.strokeLine(start: rect1Top, end: rect1Bottom)
        renderer.strokeLine(start: rect2Top, end: rect2Bottom)
        renderer.strokeLine(start: lineStart, end: lineEnd)
    }
    
    private static func connectCenterY(
        _ rect1: UIRectangle,
        _ rect2: UIRectangle,
        renderer: Renderer
    ) {
        
        prepareStroke(in: renderer)
        
        let union = rect1.union(rect2)
        
        let rect1Left: UIPoint
        let rect1Right: UIPoint
        let rect2Left: UIPoint
        let rect2Right: UIPoint
        let lineStart: UIPoint
        let lineEnd: UIPoint
        
        // Draw a horizontal line that centers on the largest of the rectangles,
        // with the vertical bounds matching the total vertical space occupied
        // by both rectangles
        
        if rect1.width > rect2.width {
            rect1Left = UIPoint(x: union.left, y: rect1.center.y)
            rect1Right = UIPoint(x: union.right, y: rect1.center.y)
            rect2Left = UIPoint(x: rect1.left, y: rect2.center.y)
            rect2Right = UIPoint(x: rect2.right, y: rect2.center.y)
            
            lineStart = UIPoint(x: rect2.center.x, y: rect1.center.y)
            lineEnd = UIPoint(x: rect2.center.x, y: rect2.center.y)
        } else {
            rect1Left = UIPoint(x: rect1.left, y: rect1.center.y)
            rect1Right = UIPoint(x: rect1.right, y: rect1.center.y)
            rect2Left = UIPoint(x: union.left, y: rect2.center.y)
            rect2Right = UIPoint(x: union.right, y: rect2.center.y)
            
            lineStart = UIPoint(x: rect1.center.x, y: rect2.center.y)
            lineEnd = UIPoint(x: rect1.center.x, y: rect1.center.y)
        }
        
        renderer.strokeLine(start: rect1Left, end: rect1Right)
        renderer.strokeLine(start: rect2Left, end: rect2Right)
        renderer.strokeLine(start: lineStart, end: lineEnd)
    }
    
    private static func extractEdge(
        _ rectangle: UIRectangle,
        edge: AnchorKind
    ) -> (topLeft: UIVector, length: Double) {
        
        switch edge {
        case .left:
            return (topLeft: rectangle.topLeft, length: rectangle.height)
        case .top:
            return (topLeft: rectangle.topLeft, length: rectangle.width)
        case .right:
            return (topLeft: rectangle.topRight, length: rectangle.height)
        case .bottom:
            return (topLeft: rectangle.bottomLeft, length: rectangle.width)
        default:
            fatalError("Expected a top, left, right, or bottom anchor kind")
        }
    }
    
    private static func drawLine(
        start: UIVector,
        end: UIVector,
        tangentLength: Double,
        to renderer: Renderer
    ) {

        prepareStroke(in: renderer)
        
        renderer.strokeLine(start: start, end: end)
        
        if tangentLength > 0 {
            let normal = (end - start).normalized()
            
            let tangentLeft = normal.leftRotated() * tangentLength
            let tangentRight = normal.rightRotated() * tangentLength
            
            renderer.strokeLine(start: start + tangentLeft, end: start + tangentRight)
            renderer.strokeLine(start: end + tangentLeft, end: end + tangentRight)
        }
    }
    
    private static func drawRelationship(
        relationship: Relationship,
        at point: UIVector,
        to renderer: Renderer
    ) {
        
        guard relationship != .equal else { return }
        
        let circle = UICircle(center: point, radius: 5)
        prepareDarkStroke(in: renderer)
        prepareFill(in: renderer)
        renderer.fill(circle)
        renderer.stroke(circle)
        
        // Draw '<' or '>'
        var triangle = UITriangle
            .unitEquilateral
            .offsetBy(point - UIPoint(x: 0, y: 1))
            .scaledBy(x: 3, y: 4)
        
        switch relationship {
        case .equal:
            break
            
        case .lessThanOrEqual:
            triangle = triangle.rotated(by: -.pi / 2)
            
        case .greaterThanOrEqual:
            triangle = triangle.rotated(by: .pi / 2)
        }
        
        renderer.strokeLine(start: triangle.p2, end: triangle.p0)
        renderer.strokeLine(start: triangle.p0, end: triangle.p1)
        
        // Draw second line under triangle to form greater-than or less-than
        // symbol
        triangle = triangle.offsetBy(x: 0, y: 2)
        
        switch relationship {
        case .equal:
            break
            
        case .lessThanOrEqual:
            renderer.strokeLine(start: triangle.p2, end: triangle.p0)
            
        case .greaterThanOrEqual:
            renderer.strokeLine(start: triangle.p0, end: triangle.p1)
        }
    }
    
    private static func prepareStroke(in renderer: Renderer) {
        renderer.setStrokeWidth(1)
        renderer.setStroke(Color.lightBlue)
    }
    
    private static func prepareDarkStroke(in renderer: Renderer) {
        renderer.setStrokeWidth(1)
        renderer.setStroke(Color.blue)
    }
    
    private static func prepareFill(in renderer: Renderer) {
        renderer.setFill(Color.lightBlue.faded(towards: .white, factor: 0.5))
    }
    
    public enum DebugDrawFlags {
        /// Render view bounds as a red rectangle
        case viewBounds
        
        /// Render layout guide bounds as an orange rectangle
        case layoutGuideBounds
        
        /// Render constraints
        case constraints
    }
    
    /// A small stateful container that is passed around the inner debug draw
    /// methods to cache useful calculations.
    private class State {
        var boundsCache: [ObjectIdentifier: UIRectangle] = [:]
        
        func boundsForRedrawOnScreen(for layoutContainer: LayoutVariablesContainer) -> UIRectangle {
            if let bounds = boundsCache[ObjectIdentifier(layoutContainer)] {
                return bounds
            }
            
            let bounds = layoutContainer.boundsForRedrawOnScreen()
            boundsCache[ObjectIdentifier(layoutContainer)] = bounds
            
            return bounds
        }
    }
}
