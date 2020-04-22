import SwiftBlend2D

public enum DebugDraw {
    public static func debugDrawRecursive(_ view: View,
                                          flags: Set<DebugDrawFlags>,
                                          to context: BLContext) {
        if flags.isEmpty {
            return
        }
        
        let state = State()
        
        internalDebugDrawRecursive(
            view,
            flags: flags.intersection([.viewBounds, .layoutGuideBounds]),
            to: context,
            state: state)
        
        internalDebugDrawRecursive(
            view,
            flags: flags.intersection([.constraints]),
            to: context,
            state: state)
    }
    
    private static func internalDebugDrawRecursive(_ view: View,
                                                   flags: Set<DebugDrawFlags>,
                                                   to context: BLContext,
                                                   state: State) {
        
        if flags.isEmpty {
            return
        }
        
        let visitor = ClosureViewVisitor<Void> { (_, view) in
            debugDraw(view, flags: flags, to: context, state: state)
        }
        let traveler = ViewTraveler(visitor: visitor)
        traveler.travelThrough(view: view)
    }
    
    private static func debugDraw(_ view: View,
                                  flags: Set<DebugDrawFlags>,
                                  to context: BLContext,
                                  state: State) {
        
        if flags.contains(.viewBounds) {
            drawBounds(view, to: context)
        }
        if flags.contains(.layoutGuideBounds) {
            drawLayoutGuideBounds(view, to: context)
        }
        if flags.contains(.constraints) {
            drawConstraints(view, to: context, state: state)
        }
    }
    
    private static func drawBounds(_ view: View, to context: BLContext) {
        let screenBounds = view.convert(bounds: view.bounds, to: nil)
        
        context.setStrokeStyle(BLRgba32.red)
        context.setStrokeWidth(1)
        context.strokeRect(screenBounds.asBLRect)
        context.setFillStyle(BLRgba32.red)
        context.fillCircle(x: 0, y: 0, radius: 2)
    }
    
    private static func drawLayoutGuideBounds(_ view: View, to context: BLContext) {
        for layoutGuide in view.layoutGuides {
            let screenBounds = view.convert(bounds: layoutGuide.area, to: nil)
            
            context.setStrokeStyle(BLRgba32.orange)
            context.setStrokeWidth(1)
            context.strokeRect(screenBounds.asBLRect)
            context.setFillStyle(BLRgba32.red)
        }
    }
    
    private static func drawConstraints(_ view: View, to context: BLContext, state: State) {
        let cookie = context.saveWithCookie()
        context.restoreClipping()
        context.resetMatrix()
        context.scale(by: UISettings.scale.asBLPoint)
        
        for constraint in view.containedConstraints {
            drawConstraint(constraint, to: context, state: state)
        }
        
        context.restore(from: cookie)
    }
    
    private static func drawConstraint(_ constraint: LayoutConstraint,
                                       to context: BLContext,
                                       state: State) {
        
        if let second = constraint.secondCast {
            drawDualAnchorConstraint(constraint,
                                     first: constraint.firstCast,
                                     second: second,
                                     to: context,
                                     state: state)
        } else {
            drawSingleAnchorConstraint(constraint, to: context, state: state)
        }
    }
    
    private static func drawSingleAnchorConstraint(_ constraint: LayoutConstraint,
                                                   to context: BLContext,
                                                   state: State) {
        
        guard let view = constraint.firstCast._owner else { return }
        let bounds = state.boundsForRedrawOnScreen(for: view)
        
        switch constraint.first.kind {
        case .width:
            let left = bounds.bottomLeft + Vector2(x: 0, y: 2)
            let right = bounds.bottomRight + Vector2(x: 0, y: 2)
            
            drawLine(start: left, end: right, tangentLength: 3, to: context)
            drawRelationship(relationship: constraint.relationship, at: (left + right) / 2, to: context)
            
        case .height:
            let top = bounds.topRight + Vector2(x: 2, y: 0)
            let bottom = bounds.bottomRight + Vector2(x: 2, y: 0)
            
            drawLine(start: top, end: bottom, tangentLength: 3, to: context)
            drawRelationship(relationship: constraint.relationship, at: (top + bottom) / 2, to: context)
            
        default:
            break
        }
    }
    
    private static func drawDualAnchorConstraint(_ constraint: LayoutConstraint,
                                                 first: AnyLayoutAnchor,
                                                 second: AnyLayoutAnchor,
                                                 to context: BLContext,
                                                 state: State) {
        
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
                connectHorizontalEdges(edge1: (topLeft: firstEdge.topLeft, height: firstEdge.length),
                                       edge2: (topLeft: secondEdge.topLeft, height: secondEdge.length),
                                       relationship: constraint.relationship,
                                       context: context)
            } else {
                connectHorizontalEdges(edge1: (topLeft: secondEdge.topLeft, height: secondEdge.length),
                                       edge2: (topLeft: firstEdge.topLeft, height: firstEdge.length),
                                       relationship: constraint.relationship,
                                       context: context)
            }
            
        // Vertical constraints
        case (.top, .top), (.top, .bottom), (.bottom, .top), (.bottom, .bottom):
            let firstEdge = extractEdge(firstBounds, edge: first.kind)
            let secondEdge = extractEdge(secondBounds, edge: second.kind)
            
            if firstEdge.topLeft.y < secondEdge.topLeft.y {
                connectVerticalEdges(edge1: (topLeft: firstEdge.topLeft, width: firstEdge.length),
                                     edge2: (topLeft: secondEdge.topLeft, width: secondEdge.length),
                                     relationship: constraint.relationship,
                                     context: context)
            } else {
                connectVerticalEdges(edge1: (topLeft: secondEdge.topLeft, width: secondEdge.length),
                                     edge2: (topLeft: firstEdge.topLeft, width: firstEdge.length),
                                     relationship: constraint.relationship,
                                     context: context)
            }
            
        case (.centerX, .centerX):
            connectCenterX(firstBounds, secondBounds, context: context)
            
        case (.centerY, .centerY):
            connectCenterY(firstBounds, secondBounds, context: context)
            
        default:
            break
        }
    }
    
    private static func connectHorizontalEdges(edge1: (topLeft: Vector2, height: Double),
                                               edge2: (topLeft: Vector2, height: Double),
                                               relationship: Relationship,
                                               context: BLContext) {
        
        let center2 = edge2.topLeft.y + edge2.height / 2
        
        let edge1BottomLeft = Vector2(x: edge1.topLeft.x, y: edge1.topLeft.y + edge1.height)
        
        let edge1Top = min(edge1.topLeft.y, center2)
        let edge1Bottom = max(edge1BottomLeft.y, center2)
        
        // Only draw first edge if the horizontal line to be drawn is outside the
        // range of the boundary
        if center2 < edge1.topLeft.y || center2 > edge1.topLeft.y + edge1.height {
            drawLine(start: Vector2(x: edge1.topLeft.x, y: edge1Top),
                     end: Vector2(x: edge1.topLeft.x, y: edge1Bottom),
                     tangentLength: 0,
                     to: context)
        }
        
        let start = Vector2(x: edge1.topLeft.x, y: center2)
        let end = Vector2(x: edge2.topLeft.x, y: center2)
        
        drawLine(start: start,
                 end: end,
                 tangentLength: 3,
                 to: context)
        
        drawRelationship(relationship: relationship,
                         at: (start + end) / 2,
                         to: context)
    }
    
    private static func connectVerticalEdges(edge1: (topLeft: Vector2, width: Double),
                                             edge2: (topLeft: Vector2, width: Double),
                                             relationship: Relationship,
                                             context: BLContext) {
        
        let center2 = edge2.topLeft.x + edge2.width / 2
        
        let edge1TopRight = Vector2(x: edge1.topLeft.x + edge1.width, y: edge1.topLeft.y)
        
        let edge1Left = min(edge1.topLeft.x, center2)
        let edge1Right = max(edge1TopRight.x, center2)
        
        // Only draw first edge if the vertical line to be drawn is outside the
        // range of the boundary
        if center2 < edge1.topLeft.x || center2 > edge1.topLeft.x + edge1.width {
            drawLine(start: Vector2(x: edge1Left, y: edge1.topLeft.y),
                     end: Vector2(x: edge1Right, y: edge1.topLeft.y),
                     tangentLength: 0,
                     to: context)
        }
        
        let start = Vector2(x: center2, y: edge1.topLeft.y)
        let end = Vector2(x: center2, y: edge2.topLeft.y)
        
        drawLine(start: start,
                 end: end,
                 tangentLength: 3,
                 to: context)
        
        drawRelationship(relationship: relationship,
                         at: (start + end) / 2,
                         to: context)
    }
    
    private static func connectCenterX(_ rect1: Rectangle,
                                       _ rect2: Rectangle,
                                       context: BLContext) {
        
        prepareStroke(in: context)
        
        let union = rect1.formUnion(rect2)
        
        let rect1Top: BLPoint
        let rect1Bottom: BLPoint
        let rect2Top: BLPoint
        let rect2Bottom: BLPoint
        let lineStart: BLPoint
        let lineEnd: BLPoint
        
        // Draw a horizontal line that centers on the largest of the rectangles,
        // with the vertical bounds matching the total vertical space occupied
        // by both rectangles
        
        if rect1.height > rect2.height {
            rect1Top = BLPoint(x: rect1.center.x, y: union.top)
            rect1Bottom = BLPoint(x: rect1.center.x, y: union.bottom)
            rect2Top = BLPoint(x: rect2.center.x, y: rect2.top)
            rect2Bottom = BLPoint(x: rect2.center.x, y: rect2.bottom)
            
            lineStart = BLPoint(x: rect1.center.x, y: rect2.center.y)
            lineEnd = BLPoint(x: rect2.center.x, y: rect2.center.y)
        } else {
            rect1Top = BLPoint(x: rect1.center.x, y: rect1.top)
            rect1Bottom = BLPoint(x: rect1.center.x, y: rect1.bottom)
            rect2Top = BLPoint(x: rect2.center.x, y: union.top)
            rect2Bottom = BLPoint(x: rect2.center.x, y: union.bottom)
            
            lineStart = BLPoint(x: rect2.center.x, y: rect1.center.y)
            lineEnd = BLPoint(x: rect1.center.x, y: rect1.center.y)
        }
        
        context.strokeLine(p0: rect1Top, p1: rect1Bottom)
        context.strokeLine(p0: rect2Top, p1: rect2Bottom)
        context.strokeLine(p0: lineStart, p1: lineEnd)
    }
    
    private static func connectCenterY(_ rect1: Rectangle,
                                       _ rect2: Rectangle,
                                       context: BLContext) {
        
        prepareStroke(in: context)
        
        let union = rect1.formUnion(rect2)
        
        let rect1Left: BLPoint
        let rect1Right: BLPoint
        let rect2Left: BLPoint
        let rect2Right: BLPoint
        let lineStart: BLPoint
        let lineEnd: BLPoint
        
        // Draw a horizontal line that centers on the largest of the rectangles,
        // with the vertical bounds matching the total vertical space occupied
        // by both rectangles
        
        if rect1.width > rect2.width {
            rect1Left = BLPoint(x: union.left, y: rect1.center.y)
            rect1Right = BLPoint(x: union.right, y: rect1.center.y)
            rect2Left = BLPoint(x: rect1.left, y: rect2.center.y)
            rect2Right = BLPoint(x: rect2.right, y: rect2.center.y)
            
            lineStart = BLPoint(x: rect2.center.x, y: rect1.center.y)
            lineEnd = BLPoint(x: rect2.center.x, y: rect2.center.y)
        } else {
            rect1Left = BLPoint(x: rect1.left, y: rect1.center.y)
            rect1Right = BLPoint(x: rect1.right, y: rect1.center.y)
            rect2Left = BLPoint(x: union.left, y: rect2.center.y)
            rect2Right = BLPoint(x: union.right, y: rect2.center.y)
            
            lineStart = BLPoint(x: rect1.center.x, y: rect2.center.y)
            lineEnd = BLPoint(x: rect1.center.x, y: rect1.center.y)
        }
        
        context.strokeLine(p0: rect1Left, p1: rect1Right)
        context.strokeLine(p0: rect2Left, p1: rect2Right)
        context.strokeLine(p0: lineStart, p1: lineEnd)
    }
    
    private static func extractEdge(_ rectangle: Rectangle, edge: AnchorKind) -> (topLeft: Vector2, length: Double) {
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
    
    private static func drawLine(start: Vector2, end: Vector2, tangentLength: Double, to context: BLContext) {
        prepareStroke(in: context)
        
        context.strokeLine(p0: start.asBLPoint, p1: end.asBLPoint)
        
        if tangentLength > 0 {
            let normal = (end - start).normalized()
            
            let tangentLeft = normal.leftRotated() * tangentLength
            let tangentRight = normal.rightRotated() * tangentLength
            
            context.strokeLine(p0: (start + tangentLeft).asBLPoint, p1: (start + tangentRight).asBLPoint)
            context.strokeLine(p0: (end + tangentLeft).asBLPoint, p1: (end + tangentRight).asBLPoint)
        }
    }
    
    private static func drawRelationship(relationship: Relationship,
                                         at point: Vector2,
                                         to context: BLContext) {
        
        guard relationship != .equal else { return }
        
        let circle = BLCircle(center: point.asBLPoint, radius: 5)
        prepareDarkStroke(in: context)
        prepareFill(in: context)
        context.fillCircle(circle)
        context.strokeCircle(circle)
        
        // Draw '<' or '>'
        var triangle = BLTriangle.unitEquilateral.offsetBy(point.asBLPoint - BLPoint(x: 0, y: 1)).scaledBy(x: 3, y: 4)
        
        switch relationship {
        case .equal:
            break
            
        case .lessThanOrEqual:
            triangle = triangle.rotated(by: -.pi / 2)
            
        case .greaterThanOrEqual:
            triangle = triangle.rotated(by: .pi / 2)
        }
        
        context.strokeLine(p0: triangle.p2, p1: triangle.p0)
        context.strokeLine(p0: triangle.p0, p1: triangle.p1)
        
        // Draw second line under triangle to form greater-than or less-than
        // symbol
        triangle = triangle.offsetBy(x: 0, y: 2)
        
        switch relationship {
        case .equal:
            break
            
        case .lessThanOrEqual:
            context.strokeLine(p0: triangle.p2, p1: triangle.p0)
            
        case .greaterThanOrEqual:
            context.strokeLine(p0: triangle.p0, p1: triangle.p1)
        }
    }
    
    private static func prepareStroke(in context: BLContext) {
        context.setStrokeWidth(1)
        context.setStrokeStyle(BLRgba32.lightBlue)
    }
    
    private static func prepareDarkStroke(in context: BLContext) {
        context.setStrokeWidth(1)
        context.setStrokeStyle(BLRgba32.blue)
    }
    
    private static func prepareFill(in context: BLContext) {
        context.setFillStyle(BLRgba32.lightBlue.faded(towards: .white, factor: 0.5))
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
        var boundsCache: [ObjectIdentifier: Rectangle] = [:]
        
        func boundsForRedrawOnScreen(for layoutContainer: LayoutVariablesContainer) -> Rectangle {
            if let bounds = boundsCache[ObjectIdentifier(layoutContainer)] {
                return bounds
            }
            
            let bounds = layoutContainer.boundsForRedrawOnScreen()
            boundsCache[ObjectIdentifier(layoutContainer)] = bounds
            
            return bounds
        }
    }
}
