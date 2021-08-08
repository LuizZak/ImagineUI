import Geometry

/// Defines a gradient of colors
public struct Gradient {
    public var type: GradientType
    
    public internal(set) var stops: [Stop]
    
    public var extendMode: ExtendMode
    
    /// A transformation matrix for this gradient
    public var matrix: Matrix2D
    
    /// Initializes a gradient object of the specified gradient type
    public init(type: GradientType, stops: [Stop] = [], extendMode: ExtendMode = .pad, matrix: Matrix2D = .identity) {
        self.type = type
        self.stops = stops
        self.extendMode = extendMode
        self.matrix = matrix
    }
    
    public mutating func addStop(offset: Double, color: Color) {
        stops.append(Stop(offset: offset, color: color))
    }
    
    /// Removes all stops on this gradient
    public mutating func clearStops() {
        stops.removeAll()
    }
    
    /// Defines a stop for a gradient
    public struct Stop: Equatable {
        public var offset: Double
        public var color: Color
        
        public init(offset: Double, color: Color) {
            self.offset = offset
            self.color = color
        }
    }
    
    /// Specifies the type of a gradient style
    public enum GradientType {
        case linear(LinearGradientParameters)
        case radial(RadialGradientParameters)
        case conical(ConicalGradientParameters)
    }
}

public extension Gradient {
    /// Parameters for a linear gradient type
    struct LinearGradientParameters: Equatable {
        /// The bounds of the linear gradient
        public var bounds: Rectangle
        
        public init(left: Double, top: Double, right: Double, bottom: Double) {
            bounds = Rectangle(left: left, top: top, right: right, bottom: bottom)
        }
        
        public init(bounds: Rectangle) {
            self.bounds = bounds
        }
    }
    
    struct RadialGradientParameters: Equatable {
        /// The bounds of the radial gradient
        public var bounds: Rectangle
        
        /// The radius of the radial gradient
        public var radius: Double
        
        public init(left: Double, top: Double, right: Double, bottom: Double, radius: Double) {
            bounds = Rectangle(left: left, top: top, right: right, bottom: bottom)
            self.radius = radius
        }
        
        public init(bounds: Rectangle, radius: Double) {
            self.bounds = bounds
            self.radius = radius
        }
    }
    
    struct ConicalGradientParameters: Equatable {
        /// The center point of the conical gradient
        public var center: Vector2
        
        /// The angle for the conical gradient which separates the
        /// last and first stop colors
        public var angle: Double
    }
}

public extension Gradient {
    static func linear(bounds: Rectangle, stops: [Stop] = [], extendMode: ExtendMode = .pad, matrix: Matrix2D = .identity) -> Gradient {
        return Gradient(type: .linear(LinearGradientParameters(bounds: bounds)),
                        stops: stops,
                        extendMode: extendMode,
                        matrix: matrix)
    }
    
    static func radial(bounds: Rectangle, radius: Double, stops: [Stop] = [], extendMode: ExtendMode = .pad, matrix: Matrix2D = .identity) -> Gradient {
        return Gradient(type: .radial(RadialGradientParameters(bounds: bounds, radius: radius)),
                        stops: stops,
                        extendMode: extendMode,
                        matrix: matrix)
    }
    
    static func conical(center: Vector2, angle: Double, stops: [Stop] = [], extendMode: ExtendMode = .pad, matrix: Matrix2D = .identity) -> Gradient {
        return Gradient(type: .conical(ConicalGradientParameters(center: center, angle: angle)),
                        stops: stops,
                        extendMode: extendMode,
                        matrix: matrix)
    }
}
