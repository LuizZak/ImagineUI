@_exported import Geometria
import simd

public typealias Vector = SIMD2<Double>
public typealias Size = Vector
public typealias IntPoint = Vector2i
public typealias Rectangle = Geometria.NRectangle<Vector>
public typealias EdgeInsets = EdgeInsets2<Vector>
public typealias RoundRectangle = RoundRectangle2<Vector>
public typealias Circle = Geometria.NSphere<Vector>
public typealias Ellipse = Ellipsoid<Vector>
public typealias Line = Geometria.Line<Vector>
public typealias Polygon = Geometria.LinePolygon<Vector>
