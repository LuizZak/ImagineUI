import Geometry
import Geometria

/// A protocol that describes a type that has its own local spatial transformation
/// information
public protocol SpatialReferenceType {
    func absoluteTransform() -> UIMatrix
    
    func convert(point: UIVector, to other: SpatialReferenceType?) -> UIVector
    func convert(point: UIVector, from other: SpatialReferenceType?) -> UIVector
    func convert(bounds: UIRectangle, to other: SpatialReferenceType?) -> UIRectangle
    func convert(bounds: UIRectangle, from other: SpatialReferenceType?) -> UIRectangle
}

public extension SpatialReferenceType {
    func convert(point: UIVector, to other: SpatialReferenceType?) -> UIVector {
        var point = point
        point *= absoluteTransform()
        if let other = other {
            point *= other.absoluteTransform().inverted()
        }
        return point
    }

    func convert(point: UIVector, from other: SpatialReferenceType?) -> UIVector {
        var point = point
        if let other = other {
            point *= other.absoluteTransform()
        }
        point *= absoluteTransform().inverted()

        return point
    }

    func convert(bounds: UIRectangle, to other: SpatialReferenceType?) -> UIRectangle {
        var bounds = bounds
        bounds = absoluteTransform().transform(bounds)
        if let other = other {
            bounds = other.absoluteTransform().inverted().transform(bounds)
        }
        return bounds
    }

    func convert(bounds: UIRectangle, from other: SpatialReferenceType?) -> UIRectangle {
        var bounds = bounds
        if let other = other {
            bounds = other.absoluteTransform().transform(bounds)
        }
        bounds = absoluteTransform().inverted().transform(bounds)
        return bounds
    }
}
