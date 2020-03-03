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
                                                 first: InternalLayoutAnchorType,
                                                 second: InternalLayoutAnchorType,
                                                 to context: BLContext) {
        
        let firstBounds = first.owner.boundsForRedrawOnScreen()
        let secondBounds = second.owner.boundsForRedrawOnScreen()
        
        switch (first.kind, second.kind) {
        case (.left, .left) where constraint.offset == 0:
            let top = min(firstBounds.topLeft, secondBounds.topLeft)
            let bottom = max(firstBounds.bottomLeft, secondBounds.bottomLeft)
            
            drawLine(start: top, end: bottom, tangentLength: 0, to: context)
        default:
            break
        }
    }
    
    private static func drawLine(start: Vector2, end: Vector2, tangentLength: Double, to context: BLContext) {
        let tangentLeft = (end - start).normalized().leftRotated() * tangentLength
        let tangentRight = (end - start).normalized().rightRotated() * tangentLength
        
        context.setStrokeWidth(1)
        context.setStrokeStyle(BLRgba32.lightBlue)
        
        context.strokeLine(p0: start.asBLPoint, p1: end.asBLPoint)
        context.strokeLine(p0: (start + tangentLeft).asBLPoint, p1: (start + tangentRight).asBLPoint)
        context.strokeLine(p0: (end + tangentLeft).asBLPoint, p1: (end + tangentRight).asBLPoint)
    }
    
    public enum DebugDrawFlags {
        /// Render view bounds as a red rectangle
        case viewBounds
        
        /// Render constraints
        case constraints
    }
}
