import Geometry
import CassowarySwift

/// A view that lays out a set of its arranged subviews horizontally or
/// vertically automatically.
open class StackView: View {
    private var _stackViewConstraints: [LayoutConstraint] = []
    private var customSpacing: [WeakReference<View>: Double] = [:]

    /// List of views contained within this stack view that are being arranged
    /// as part of the stack view's layout behaviour.
    private(set) public var arrangedSubviews: [View] = []

    /// Intrinsic size of a `StackView` is always `UISize.zero`, as the default
    /// behaviour of a stack view is to always shrink to the smallest size
    /// possible.
    public override var intrinsicSize: UISize? {
        return .zero
    }

    /// A spacing applied between every view added to this stack view.
    /// This value is override by custom per-view spacings specified with
    /// `self.setCustomSpacing(after:_:)`.
    open var spacing: Double = 0 {
        didSet {
            recreateConstraints()
        }
    }

    /// The orientation the arranged views within this stack view will be laid.
    open var orientation: Orientation {
        didSet {
            recreateConstraints()
        }
    }

    /// The alignment of the arranged views within this stack view perpendicular
    /// to the current orientation.
    ///
    /// By default, stack views shrink to occupy the smallest space that can
    /// fit all arranged views, and that can lead to empty slack space along the
    /// opposite axis the views are aligned on, and this property can be used to
    /// specify how each view is placed along that empty space.
    ///
    /// Defaults to `Alignment.leading`.
    ///
    /// - seealso: `Alignment`.
    open var alignment: Alignment = .leading {
        didSet {
            recreateConstraints()
        }
    }

    /// Inset space between the edges of the stack view and its arranged subviews.
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            recreateConstraints()
        }
    }

    /// Initializes a new empty stack view with a given starting orientation.
    public init(orientation: Orientation) {
        self.orientation = orientation

        super.init()
    }

    private func recreateConstraints() {
        withSuspendedLayout(setNeedsLayout: true) {
            for constraint in _stackViewConstraints {
                constraint.removeConstraint()
            }
            _stackViewConstraints.removeAll(keepingCapacity: true)

            let constraints = Self.makeStackViewConstraints(
                views: arrangedSubviews,
                parent: self,
                orientation: orientation,
                alignment: alignment,
                spacing: spacing,
                inset: contentInset,
                customSpacing: customSpacing.mapToStrong()
            ).create()

            _stackViewConstraints = constraints
        }
    }

    /// Inserts a view to the list of arranged views at a specified index.
    ///
    /// Arranged views are added as subviews as well, and are further subject to
    /// the stack view's layout behaviour.
    ///
    /// - precondition: `index >= 0 && index < arrangedSubviews.count`.
    open func insertArrangedSubview(_ view: View, at index: Int) {
        if arrangedSubviews.contains(view) {
            return
        }

        arrangedSubviews.insert(view, at: index)

        withSuspendedLayout(setNeedsLayout: true) {
            addSubview(view)
            recreateConstraints()
        }
    }

    /// Adds a view to the end of the arranged view list on this stack view.
    ///
    /// Arranged views are added as subviews as well, and are further subject to
    /// the stack view's layout behaviour.
    open func addArrangedSubview(_ view: View) {
        if arrangedSubviews.contains(view) {
            return
        }

        arrangedSubviews.append(view)

        withSuspendedLayout(setNeedsLayout: true) {
            addSubview(view)
            recreateConstraints()
        }
    }

    /// Adds a list of views to the end of the arranged view list on this stack
    /// view.
    ///
    /// Arranged views are added as subviews as well, and are further subject to
    /// the stack view's layout behaviour.
    open func addArrangedSubviews(_ views: [View]) {
        withSuspendedLayout(setNeedsLayout: true) {
            for view in views where !arrangedSubviews.contains(view) {
                arrangedSubviews.append(view)
                addSubview(view)
            }

            recreateConstraints()
        }
    }

    /// Removes an arranged view at a specified index from this stack view.
    ///
    /// Removing an arranged view also removes it from the view hierarchy.
    open func removeArrangedSubview(atIndex index: Int) {
        assert(index < arrangedSubviews.count)

        customSpacing.removeValue(forKey: arrangedSubviews[index])
        arrangedSubviews[index].removeFromSuperview()
    }

    /// Removes all arranged views from this stack view.
    ///
    /// Removing arranged views also remove them from the view hierarchy.
    open func removeArrangedSubviews() {
        withSuspendedLayout(setNeedsLayout: true) {
            let views = arrangedSubviews
            arrangedSubviews.removeAll()

            for view in views {
                customSpacing.removeValue(forKey: view)
                view.removeFromSuperview()
            }

            recreateConstraints()
        }
    }

    open override func willRemoveSubview(_ view: View) {
        super.willRemoveSubview(view)

        customSpacing.removeValue(forKey: view)
        arrangedSubviews.removeAll(where: { $0 === view })

        recreateConstraints()
    }

    /// Sets a custom spacing after a specified view when it is being arranged
    /// in this stack view.
    ///
    /// Custom spacings override the default `StackView.spacing` that is applied
    /// uniformly across all views.
    ///
    /// Passing `nil` as a spacing removes any custom spacing configured for the
    /// view in this stack view.
    ///
    /// Spacings can be added before or after a view is added to the arranged
    /// views list on a stack view.
    open func setCustomSpacing(after view: View, _ spacing: Double?) {
        customSpacing[view] = spacing

        recreateConstraints()
    }

    /// Creates stack view constraints with the specified parameters into a parent
    /// layout container.
    @LayoutResultBuilder
    internal static func makeStackViewConstraints<T: LayoutAnchorsContainer>(
        views: [View],
        parent: T,
        orientation: Orientation,
        alignment: Alignment,
        spacing: Double,
        inset: UIEdgeInsets,
        customSpacing: [View: Double]
    ) -> LayoutConstraintDefinitions {

        let widthInset = inset.left + inset.right
        let heightInset = inset.top + inset.bottom

        for (index, view) in views.enumerated() {
            let previous: View? = index > 0 ? views[index - 1] : nil
            let viewSpacing = previous.flatMap { customSpacing[$0] } ?? spacing
            let isLastView = index == views.count - 1

            let make = view.layout
            view.areaIntoConstraintsMask = []

            // Connection to previous view
            switch orientation {
            case .horizontal:
                if let previous = previous {
                    make.right(of: previous, offset: viewSpacing)
                } else {
                    make.left == parent + inset.left
                }
                if isLastView {
                    make.right == parent - inset.right
                }
            default:
                if let previous = previous {
                    make.under(previous, offset: viewSpacing)
                } else {
                    make.top == parent + inset.top
                }
                if isLastView {
                    make.bottom == parent - inset.bottom
                }
            }

            // Connect to parent guide
            switch alignment {
            case .leading:
                switch orientation {
                case .horizontal:
                    make.top == parent + inset.top
                    make.bottom <= parent - inset.bottom

                case .vertical:
                    make.left == parent + inset.left
                    make.right <= parent - inset.right
                }

            case .trailing:
                switch orientation {
                case .horizontal:
                    make.top >= parent + inset.top
                    make.bottom == parent - inset.bottom
                case .vertical:
                    make.left >= parent + inset.left
                    make.right == parent - inset.right
                }

            case .fill:
                switch orientation {
                case .horizontal:
                    make.top == parent + inset.top
                    make.bottom == parent - inset.bottom

                case .vertical:
                    make.left == parent + inset.left
                    make.right == parent - inset.right
                }

            case .centered:
                switch orientation {
                case .horizontal:
                    make.centerY == parent + heightInset
                    make.height <= parent - heightInset

                case .vertical:
                    make.centerX == parent + widthInset
                    make.width <= parent - widthInset
                }
            }
        }
    }

    /// Specifies the orientation that views from a stack view are laid out.
    public enum Orientation {
        /// Views are arranged from top to bottom
        case vertical

        /// Views are arranged from left to right
        case horizontal
    }

    /// Specifies the alignment behaviour of arranged subviews of a stack view
    /// along the perpendicular axis of the stack view's orientation, i.e. the
    /// horizontal alignment of a vertical stack of views, and vice-versa for a
    /// vertical alignment of a horizontal stack of views.
    public enum Alignment {
        /// Views are aligned to the leading edge of the view (either left, in
        /// horizontal orientations, or top, in vertical orientations). Views
        /// with an increased width or height requirements push the stack view's
        /// bounds larger.
        case leading

        /// Views are aligned to the trailing edge of the view (either right, in
        /// horizontal orientations, or bottom, in vertical orientations). Views
        /// with an increased width or height requirements push the stack view's
        /// bounds larger.
        case trailing

        /// Views are forced to match the span of the view with the highest
        /// content compression resistance or content hugging priority.
        case fill

        /// Views increase the boundaries of the stack view, and views that are
        /// smaller than the minimal width or height are centered horizontally
        /// or vertically along the available space, perpendicular to the stack
        /// view's orientation
        case centered
    }

    fileprivate struct WeakReference<T: AnyObject & Hashable>: Hashable {
        weak var reference: T?
        var cachedHash: Int

        init(reference: T) {
            self.reference = reference
            cachedHash = reference.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(cachedHash)
        }
    }
}

fileprivate extension Dictionary {
    subscript<T>(key: T) -> Value? where Key == StackView.WeakReference<T> {
        get {
            return self[.init(reference: key)]
        }
        set {
            self[.init(reference: key)] = newValue
        }
    }

    @discardableResult
    mutating func removeValue<T>(forKey key: T) -> Value? where Key == StackView.WeakReference<T> {
        removeValue(forKey: .init(reference: key))
    }

    mutating func mapToStrong<T>() -> [T: Value] where Key == StackView.WeakReference<T> {
        var result: [T: Value] = [:]

        for (key, value) in self {
            if let reference = key.reference {
                result[reference] = value
            } else {
                removeValue(forKey: key)
            }
        }

        return result
    }
}
