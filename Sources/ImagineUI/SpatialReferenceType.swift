import Geometry

/// A protocol that describes a type that has its own local spatial transformation
/// information
public protocol SpatialReferenceType {
    func absoluteTransform() -> Matrix2D
    
    func convert(point: Vector, to other: SpatialReferenceType?) -> Vector
    func convert(point: Vector, from other: SpatialReferenceType?) -> Vector
    func convert(bounds: Rectangle, to other: SpatialReferenceType?) -> Rectangle
    func convert(bounds: Rectangle, from other: SpatialReferenceType?) -> Rectangle
}

public extension SpatialReferenceType {
    func convert(point: Vector, to other: SpatialReferenceType?) -> Vector {
        var point = point
        point *= absoluteTransform()
        if let other = other {
            point *= other.absoluteTransform().inverted()
        }
        return point
    }

    func convert(point: Vector, from other: SpatialReferenceType?) -> Vector {
        var point = point
        if let other = other {
            point *= other.absoluteTransform()
        }
        point *= absoluteTransform().inverted()

        return point
    }

    func convert(bounds: Rectangle, to other: SpatialReferenceType?) -> Rectangle {
        var bounds = bounds
        bounds = absoluteTransform().transform(bounds)
        if let other = other {
            bounds = other.absoluteTransform().inverted().transform(bounds)
        }
        return bounds
    }

    func convert(bounds: Rectangle, from other: SpatialReferenceType?) -> Rectangle {
        var bounds = bounds
        if let other = other {
            bounds = other.absoluteTransform().transform(bounds)
        }
        bounds = absoluteTransform().inverted().transform(bounds)
        return bounds
    }
}
