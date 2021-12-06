/// A stroke style brush
public struct StrokeStyle {
    public var brush: BrushStyle
    public var width: Double
    public var dashOffset: Double
    public var dashArray: [Double]
    public var startCap: CapStyle
    public var endCap: CapStyle
    public var joinStyle: JoinStyle
    
    public init(color: Color,
                width: Double = 1,
                dashOffset: Double = 0,
                dashArray: [Double] = [],
                startCap: CapStyle = .butt,
                endCap: CapStyle = .butt,
                joinStyle: JoinStyle = .miterClip(limit: 4)) {
        
        self.init(brush: .solid(color),
                  width: width,
                  dashOffset: dashOffset,
                  dashArray: dashArray,
                  startCap: startCap,
                  endCap: endCap,
                  joinStyle: joinStyle)
    }
    
    public init(brush: BrushStyle,
                width: Double = 1,
                dashOffset: Double = 0,
                dashArray: [Double] = [],
                startCap: CapStyle = .butt,
                endCap: CapStyle = .butt,
                joinStyle: JoinStyle = .miterClip(limit: 4)) {
        
        self.brush = brush
        self.width = width
        self.dashOffset = dashOffset
        self.dashArray = dashArray
        self.startCap = startCap
        self.endCap = endCap
        self.joinStyle = joinStyle
    }
}

public extension StrokeStyle {
    enum CapStyle {
        /// Butt cap [default].
        case butt
        
        /// Square cap.
        case square
        
        /// Round cap.
        case round
    }
    
    /// Represents the join kind for a stroke
    enum JoinStyle {
        /// Miter-join possibly clipped at `miterLimit` [default].
        case miterClip(limit: Double)
        
        /// Miter-join or bevel-join depending on miterLimit condition.
        case miterBevel
        
        /// Miter-join or round-join depending on miterLimit condition.
        case miterRound
        
        /// Bevel-join.
        case bevel
        
        /// Round-join.
        case round
    }
}
