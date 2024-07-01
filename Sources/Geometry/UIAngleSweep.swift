/// A pair of angle + angle range values that can be used to test inclusivity of
/// `UIAngle` values.
public struct UIAngleSweep {
    public var start: UIAngle
    public var sweep: Double

    /// Returns `start + sweep`.
    public var stop: UIAngle {
        start + .init(radians: sweep)
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
    public func relativeToStart(_ angle: UIAngle) -> Double {
        var relative = angle.radians - start.radians
        while relative < -.pi {
            relative += .pi * 2
        }
        while relative > .pi {
            relative -= .pi * 2
        }
        return relative
        /*
        let angle1 = start.radians
        let angle2 = angle.radians

        if angle1 > angle2 {
            if (angle1 - angle2) > .pi {
                return (.pi * 2 - angle1) + angle2
            } else {
                return angle1 - angle2
            }
        } else {
            if (angle2 - angle1) > .pi {
                return (.pi * 2 - angle2) + angle1
            } else {
                return angle2 - angle1
            }
        }
        */
        /*
        let relative: Double = .pi - abs(abs(start.radians - angle.radians) - .pi)
        if start.radians < angle.radians {
            return -relative
        }

        return relative
        */
    }
}
