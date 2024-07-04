/// A pair of angle + angle range values that can be used to test inclusivity of
/// `UIAngle` values.
public struct UIAngleSweep {
    public typealias Scalar = Double

    public var start: UIAngle
    public var sweep: Scalar

    /// Returns `start + sweep`.
    public var stop: UIAngle {
        start + .init(radians: sweep)
    }

    public init(start startInRadians: Scalar, sweep: Scalar) {
        self.start = .init(radians: startInRadians)
        self.sweep = sweep
    }

    public init(start: UIAngle, sweep: Scalar) {
        self.start = start
        self.sweep = sweep
    }

    public func contains(_ angleInRadians: Scalar) -> Bool {
        contains(UIAngle(radians: angleInRadians))
    }

    public func contains(_ angle: UIAngle) -> Bool {
        if start < stop {
            if sweep > 0 {
                return angle >= start && angle <= stop
            } else {
                return angle <= start || angle >= stop
            }
        } else if start > stop {
            // Angle wraps around; check for inclusion in the upper range and
            // lower range of the space
            if sweep > 0 {
                return angle >= start || angle <= stop
            } else {
                return angle <= start && angle >= stop
            }
        } else {
            return angle == start
        }
    }

    /// Returns the shortest relative sweep between `start` and `angle`.
    public func relativeToStart(_ angle: UIAngle) -> Scalar {
        var relative = angle.radians - start.radians

        while relative < -.pi {
            relative += .pi * 2
        }
        while relative > .pi {
            relative -= .pi * 2
        }

        return relative
    }

    /// Returns the result of clamping a given angle so it is contained within
    /// this angle sweep.
    public func clamped(_ angle: UIAngle) -> UIAngle {
        var start = self.start
        var stop = self.stop

        if sweep < 0 {
            swap(&start, &stop)
        }

        let n_min = normalize180(start.radians - angle.radians)
        let n_max = normalize180(stop.radians - angle.radians)

        if n_min <= 0 && n_max >= 0 {
            return angle
        }
        if abs(n_min) < abs(n_max) {
            return start
        }

        return stop
    }
}

fileprivate func normalize180(_ angle: Double) -> Double {
    var angle = angle
    while angle < -.pi {
        angle += .pi * 2
    }
    while angle >= .pi {
        angle -= .pi * 2
    }
    return angle
}
