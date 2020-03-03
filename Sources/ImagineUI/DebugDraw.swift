import SwiftBlend2D

public enum DebugDraw {
    public static func debugDrawRecursive(_ view: View, flags: Set<DebugDrawFlags>, to context: BLContext) {
        if flags.isEmpty {
            return
        }
        
        let visitor = ClosureViewVisitor<Void> { (_, view) in
            debugDraw(view, flags: flags, to: context)
        }
        let traveler = ViewTraveler(visitor: visitor)
        traveler.visit(view: view)
    }
    
    static func debugDraw(_ view: View, flags: Set<DebugDrawFlags>, to context: BLContext) {
        if flags.contains(.viewBounds) {
            drawBounds(view, to: context)
        }
        if flags.contains(.constraints) {
            drawConstraints(view, to: context)
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
    
    private static func drawConstraints(_ view: View, to context: BLContext) {
        let cookie = context.saveWithCookie()
        context.restoreClipping()
        context.resetMatrix()
        context.scale(by: UISettings.scale.asBLPoint)
        
        for constraint in view.containedConstraints {
            drawConstraint(constraint, to: context)
        }
        
        context.restore(from: cookie)
    }
    
    private static func drawConstraint(_ constraint: LayoutConstraint, to context: BLContext) {
        if let second = constraint.secondCast {
            drawDualAnchorConstraint(constraint,
                                     first: constraint.firstCast,
                                     second: second,
                                     to: context)
        } else {
            drawSingleAnchorConstraint(constraint, to: context)
        }
    }
    
    private static func drawSingleAnchorConstraint(_ constraint: LayoutConstraint, to context: BLContext) {
        let view = constraint.firstCast.owner
        let bounds = view.boundsForRedrawOnScreen()
        
        switch constraint.first.kind {
        case .width:
            let left = bounds.bottomLeft + Vector2(x: 0, y: 2)
            let right = bounds.bottomRight + Vector2(x: 0, y: 2)
            
            drawLine(start: left, end: right, tangentLength: 3, to: context)
            
        case .height:
            let top = bounds.topRight + Vector2(x: 2, y: 0)
            let bottom = bounds.bottomRight + Vector2(x: 2, y: 0)
            
            drawLine(start: top, end: bottom, tangentLength: 3, to: context)
            
        default:
            break
        }
    }
    
    private static func drawDualAnchorConstraint(_ constraint: LayoutConstraint,
                                                 first: InternalLayoutAnchor,
                                                 second: InternalLayoutAnchor,
                                                 to context: BLContext) {
        
        let firstBounds = first.owner.boundsForRedrawOnScreen()
        let secondBounds = second.owner.boundsForRedrawOnScreen()
        
        switch (first.kind, second.kind) {
        case (.left, .left) where constraint.offset == 0:
            let top = min(firstBounds.topLeft, secondBounds.topLeft)
            let bottom = max(firstBounds.bottomLeft, secondBounds.bottomLeft)
            
            drawLine(start: top, end: bottom, tangentLength: 0, to: context)
            
        case (.left, .left):
            if firstBounds.topLeft.x < secondBounds.topLeft.x {
                connectHorizontalEdges(
                    edge1: (topLeft: firstBounds.topLeft, height: firstBounds.height),
                    edge2: (topLeft: secondBounds.topLeft, height: secondBounds.height),
                    to: context)
            } else {
                connectHorizontalEdges(
                    edge1: (topLeft: secondBounds.topLeft, height: secondBounds.height),
                    edge2: (topLeft: firstBounds.topLeft, height: firstBounds.height),
                    to: context)
            }
            
        case (.left, .right):
            if firstBounds.topLeft.x < secondBounds.topRight.x {
                connectHorizontalEdges(
                    edge1: (topLeft: firstBounds.topLeft, height: firstBounds.height),
                    edge2: (topLeft: secondBounds.topRight, height: secondBounds.height),
                    to: context)
            } else {
                connectHorizontalEdges(
                    edge1: (topLeft: secondBounds.topRight, height: secondBounds.height),
                    edge2: (topLeft: firstBounds.topLeft, height: firstBounds.height),
                    to: context)
            }
            
        case (.right, .left):
            if firstBounds.topRight.x < secondBounds.topLeft.x {
                connectHorizontalEdges(
                    edge1: (topLeft: firstBounds.topRight, height: firstBounds.height),
                    edge2: (topLeft: secondBounds.topLeft, height: secondBounds.height),
                    to: context)
            } else {
                connectHorizontalEdges(
                    edge1: (topLeft: secondBounds.topLeft, height: secondBounds.height),
                    edge2: (topLeft: firstBounds.topRight, height: firstBounds.height),
                    to: context)
            }
            
        case (.right, .right):
            if firstBounds.topRight.x < secondBounds.topRight.x {
                connectHorizontalEdges(
                    edge1: (topLeft: firstBounds.topRight, height: firstBounds.height),
                    edge2: (topLeft: secondBounds.topRight, height: secondBounds.height),
                    to: context)
            } else {
                connectHorizontalEdges(
                    edge1: (topLeft: secondBounds.topRight, height: secondBounds.height),
                    edge2: (topLeft: firstBounds.topRight, height: firstBounds.height),
                    to: context)
            }
        default:
            break
        }
    }
    
    private static func connectHorizontalEdges(edge1: (topLeft: Vector2, height: Double),
                                               edge2: (topLeft: Vector2, height: Double),
                                               to context: BLContext) {
        
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
        
        drawLine(start: Vector2(x: edge1.topLeft.x, y: center2),
                 end: Vector2(x: edge2.topLeft.x, y: center2),
                 tangentLength: 3,
                 to: context)
    }
    
    private static func drawLine(start: Vector2, end: Vector2, tangentLength: Double, to context: BLContext) {
        context.setStrokeWidth(1)
        context.setStrokeStyle(BLRgba32.lightBlue)
        
        context.strokeLine(p0: start.asBLPoint, p1: end.asBLPoint)
        
        if tangentLength > 0 {
            let tangentLeft = (end - start).normalized().leftRotated() * tangentLength
            let tangentRight = (end - start).normalized().rightRotated() * tangentLength
            
            context.strokeLine(p0: (start + tangentLeft).asBLPoint, p1: (start + tangentRight).asBLPoint)
            context.strokeLine(p0: (end + tangentLeft).asBLPoint, p1: (end + tangentRight).asBLPoint)
        }
    }
    
    public enum DebugDrawFlags {
        /// Render view bounds as a red rectangle
        case viewBounds
        
        /// Render constraints
        case constraints
    }
}
