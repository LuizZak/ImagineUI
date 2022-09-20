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

        /// Caches the minimal size of extensible entries by index.
        /// Entries that are not extensible have a size cache entry of zero.
        let extensibleMinimalSizeCache: [Double] = entries.map { entry in
            switch entry {
            case .fixed:
                return 0

            case .flexible:
                return 0

            case .extensible(let view, let minimumLength, let spacingAfter):
                if let minimumLength = minimumLength {
                    return minimumLength + spacingAfter
                }

                let minimal = view.layoutSizeFitting(size: .zero)
                return orientation[axisOf: minimal] + spacingAfter
            }
        }

        // Find available length for flexible views
        let fixedLength = entries.enumerated().reduce(0.0) {
            let accum = $0
            let index = $1.offset
            let entry = $1.element

            switch entry {
            case .fixed(_, let length, let spacingAfter):
                return accum + length + spacingAfter

            case .flexible(_, let spacingAfter):
                return accum + spacingAfter

            case .extensible:
                return accum + extensibleMinimalSizeCache[index]
            }
        }

        let flexibleSpace = availableLength - fixedLength
        let flexibleViewCount = entries.enumerated().reduce(0.0) {
            let accum = $0
            let index = $1.offset
            let entry = $1.element

            switch entry {
            case .fixed:
                return accum

            case .flexible:
                return accum + 1

            case .extensible:
                return flexibleSpace > extensibleMinimalSizeCache[index] ? accum + 1 : accum
            }
        }

        let flexibleSpacePerView = flexibleViewCount > 0 ? flexibleSpace / flexibleViewCount : 0

        var current = orientation[axisOf: origin]
        for (index, entry) in entries.enumerated() {
            switch entry {
            case .fixed(let view, let length, let spacingAfter):
                orientation[location: view] = current
                orientation[size: view] = length

                current += length + spacingAfter

            case .flexible(let view, let spacingAfter):
                orientation[location: view] = current
                orientation[size: view] = flexibleSpacePerView

                current += flexibleSpacePerView + spacingAfter

            case .extensible(let view, _, _):
                let minimal = extensibleMinimalSizeCache[index]

                orientation[location: view] = current

                if flexibleSpacePerView > minimal {
                    orientation[size: view] = flexibleSpacePerView
                    current += flexibleSpacePerView
                } else {
                    orientation[size: view] = minimal
                    current += minimal
                }
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

        /// Represents a view that can be stretched beyond a minimal size, but
        /// cannot be compressed further than it.
        ///
        /// If `minimumLength` is `nil`, minimal size is derived from
        /// `view.layoutSizeFitting(size: .zero)`
        case extensible(View, minimumLength: Double? = nil, spacingAfter: Double)

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
