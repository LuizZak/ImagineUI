/// A protocol that describes a type that has its own local spatial transformation
/// information
public protocol SpatialReferenceType {
    func absoluteTransform() -> Matrix2D
    
    func convert(point: Vector2, to other: SpatialReferenceType?) -> Vector2
    func convert(point: Vector2, from other: SpatialReferenceType?) -> Vector2
    func convert(bounds: Rectangle, to other: SpatialReferenceType?) -> Rectangle
    func convert(bounds: Rectangle, from other: SpatialReferenceType?) -> Rectangle
}
