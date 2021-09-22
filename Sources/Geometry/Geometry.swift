@_exported import Geometria

#if canImport(simd)
import simd

public typealias UIVector = SIMD2<Double>
#else
public typealias UIVector = Vector2D
#endif

public typealias UIMatrix = Matrix3x2D
public typealias UISize = UIVector
public typealias UIIntPoint = Vector2i
public typealias UIRectangle = Rectangle2<UIVector>
public typealias UIEdgeInsets = EdgeInsets2<UIVector>
public typealias UIRoundRectangle = RoundRectangle2<UIVector>
public typealias UICircle = Circle2<UIVector>
public typealias UIEllipse = Ellipse2<UIVector>
public typealias UILine = LineSegment2<UIVector>
public typealias UIPolygon = LinePolygon2<UIVector>
