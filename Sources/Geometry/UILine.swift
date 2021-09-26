public struct UILine: Hashable, Codable {
    public typealias Scalar = UIPoint.Scalar

    public static let zero: Self = .init()

    public var start: UIPoint
    public var end: UIPoint

    public init() {
        self.start = .zero
        self.end = .zero
    }

    public init(start: UIPoint, end: UIPoint) {
        self.start = start
        self.end = end
    }

    @_transparent
    public init(x1: Scalar, y1: Scalar, x2: Scalar, y2: Scalar) {
        start = .init(x: x1, y: y1)
        end = .init(x: x2, y: y2)
    }

    @_transparent
    public func length() -> Scalar {
        start.distance(to: end)
    }
}