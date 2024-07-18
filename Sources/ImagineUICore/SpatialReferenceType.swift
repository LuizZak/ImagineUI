import Geometry

/// A protocol that describes a type that has its own local spatial transformation
/// information
public protocol SpatialReferenceType {
    @ImagineActor
    func absoluteTransform() -> UIMatrix

    @ImagineActor
    func convert(point: UIPoint, to other: SpatialReferenceType?) -> UIPoint
    @ImagineActor
    func convert(point: UIPoint, from other: SpatialReferenceType?) -> UIPoint
    @ImagineActor
    func convert(bounds: UIRectangle, to other: SpatialReferenceType?) -> UIRectangle
    @ImagineActor
    func convert(bounds: UIRectangle, from other: SpatialReferenceType?) -> UIRectangle
}

public extension SpatialReferenceType {
    @ImagineActor
    func convert(point: UIPoint, to other: SpatialReferenceType?) -> UIPoint {
        var point = point
        point *= absoluteTransform()
        if let other = other {
            point *= other.absoluteTransform().inverted()
        }
        return point
    }

    @ImagineActor
    func convert(point: UIPoint, from other: SpatialReferenceType?) -> UIPoint {
        var point = point
        if let other = other {
            point *= other.absoluteTransform()
        }
        point *= absoluteTransform().inverted()

        return point
    }

    @ImagineActor
    func convert(bounds: UIRectangle, to other: SpatialReferenceType?) -> UIRectangle {
        var bounds = bounds
        bounds = absoluteTransform().transform(bounds)
        if let other = other {
            bounds = other.absoluteTransform().inverted().transform(bounds)
        }
        return bounds
    }

    @ImagineActor
    func convert(bounds: UIRectangle, from other: SpatialReferenceType?) -> UIRectangle {
        var bounds = bounds
        if let other = other {
            bounds = other.absoluteTransform().transform(bounds)
        }
        bounds = absoluteTransform().inverted().transform(bounds)
        return bounds
    }
}
