/// Object that lays out views in horizontal disposition like a stack view without
/// using a constraint system.
struct BoxLayout {
    /// Applies box layout to a series of views across an available length.
    ///
    /// - note: Views are assumed to be contained within the same parent view.
    static func layout(
        _ entries: [Entry],
        alignment: Alignment = .centered,
        orientation: Orientation = .horizontal,
        origin: UIPoint,
        availableLength: Double
    ) {
        // TODO: Improve handling of mixed flexible/extensible view layouts under
        // TODO: compression scenarios.

        // Find available length for flexible views
        let fixedLength = entries.reduce(0.0) {
            switch $1 {
            case .fixed(_, let length, let spacing):
                return $0 + length + spacing

            case .flexible(_, let spacing):
                return $0 + spacing

            case .extensible(let view, let length, let spacing):
                if let length = length {
                    return length + spacing
                }

                let minimal = view.layoutSizeFitting(size: .zero)
                return orientation[axisOf: minimal] + spacing
            }
        }

        let flexibleSpace = availableLength - fixedLength
        let flexibleViewCount = entries.reduce(0.0) {
            switch $1 {
            case .fixed:
                return $0
            case .flexible:
                return $0 + 1
            case .extensible(let view, let length, let spacing):
                let minimal: Double
                if let length = length {
                    minimal = length + spacing
                } else {
                    let size = view.layoutSizeFitting(size: .zero)
                    minimal = orientation[axisOf: size] + spacing
                }

                return flexibleSpace > minimal ? $0 + 1 : $0
            }
        }

        let flexibleSpacePerView = flexibleViewCount > 0 ? flexibleSpace / flexibleViewCount : 0

        var current = orientation[axisOf: origin]
        for entry in entries {
            switch entry {
            case .fixed(let view, let length, let spacing):
                orientation[location: view] = current
                orientation[size: view] = length

                current += length + spacing

            case .flexible(let view, let spacing):
                orientation[location: view] = current
                orientation[size: view] = flexibleSpacePerView

                current += flexibleSpacePerView + spacing

            case .extensible(let view, let length, let spacing):
                let minimal: Double
                if let length = length {
                    minimal = length + spacing
                } else {
                    let size = view.layoutSizeFitting(size: .zero)
                    minimal = orientation[axisOf: size] + spacing
                }

                orientation[location: view] = current

                if flexibleSpacePerView > minimal {
                    orientation[size: view] = flexibleSpacePerView
                } else {
                    orientation[size: view] = minimal
                }

                current += spacing
            }
        }

        // Align views on perpendicular axis
        let perpendicular = orientation.perpendicular
        let perpendicularSize = entries.reduce(0.0) {
            max($0, perpendicular[size: $1.view])
        }

        for entry in entries {
            switch alignment {
            case .leading:
                perpendicular[location: entry.view] = perpendicular[axisOf: origin]

            case .trailing:
                perpendicular[location: entry.view] =
                    perpendicular[axisOf: origin]
                    + perpendicularSize
                    - perpendicular[size: entry.view]

            case .centered:
                perpendicular[center: entry.view] =
                    perpendicular[axisOf: origin]
                    + perpendicularSize / 2
            }
        }
    }

    enum Entry {
        /// Represents a view that should have a fixed size in the layout.
        case fixed(View, length: Double, spacingAfter: Double)

        /// Represents a view that needs to fill the available space left by
        /// other fixed-sized views.
        case flexible(View, spacingAfter: Double)

        /// Represents a view that can be stretched beyond its minimal size, but
        /// cannot be compressed past it.
        ///
        /// If `length` is `nil`, minimal size is derived from
        /// `view.layoutSizeFitting(size: .zero)`
        case extensible(View, length: Double? = nil, spacingAfter: Double)

        var view: View {
            switch self {
            case .fixed(let view, _, _),
                .flexible(let view, _),
                .extensible(let view, _, _):
                return view
            }
        }
    }

    enum Orientation {
        /// Views are arranged from left to right
        case horizontal

        /// Views are arranged from top to bottom
        case vertical

        var perpendicular: Self {
            switch self {
            case .horizontal:
                return .vertical

            case .vertical:
                return .horizontal
            }
        }

        subscript(axisOf point: UIPoint) -> Double {
            get {
                switch self {
                case .horizontal:
                    return point.x
                case .vertical:
                    return point.y
                }
            }
        }

        subscript(axisOf size: UISize) -> Double {
            get {
                switch self {
                case .horizontal:
                    return size.width
                case .vertical:
                    return size.height
                }
            }
        }

        subscript(location view: View) -> Double {
            get {
                switch self {
                case .horizontal:
                    return view.location.x
                case .vertical:
                    return view.location.y
                }
            }
            nonmutating set {
                switch self {
                case .horizontal:
                    view.location.x = newValue
                case .vertical:
                    view.location.y = newValue
                }
            }
        }

        subscript(center view: View) -> Double {
            get {
                switch self {
                case .horizontal:
                    return view.area.center.x
                case .vertical:
                    return view.area.center.y
                }
            }
            nonmutating set {
                switch self {
                case .horizontal:
                    view.area.center.x = newValue
                case .vertical:
                    view.area.center.y = newValue
                }
            }
        }

        subscript(size view: View) -> Double {
            get {
                switch self {
                case .horizontal:
                    return view.size.width
                case .vertical:
                    return view.size.height
                }
            }
            nonmutating set {
                switch self {
                case .horizontal:
                    view.size.width = newValue
                case .vertical:
                    view.size.height = newValue
                }
            }
        }
    }

    public enum Alignment {
        /// Views are aligned to the leading edge of the view (either left, in
        /// horizontal orientations, or top, in vertical orientations). Views
        /// with an increased width or height requirements push the box layout's
        /// bounds larger.
        case leading

        /// Views are aligned to the trailing edge of the view (either right, in
        /// horizontal orientations, or bottom, in vertical orientations). Views
        /// with an increased width or height requirements push the box layout's
        /// bounds larger.
        case trailing

        /// Views increase the boundaries of the box layout, and views that are
        /// smaller than the minimal width or height are centered horizontally
        /// or vertically along the available space, perpendicular to the box
        /// layout's orientation.
        case centered
    }
}
