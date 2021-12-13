import Geometry
import CassowarySwift

/// A view that lays out a set of its arranged subviews horizontally or
/// vertically automatically
open class StackView: View {
    private var _stackViewConstraints: [LayoutConstraint] = []
    private var customSpacing: [View: Double] = [:]

    private(set) public var arrangedSubviews: [View] = []

    public override var intrinsicSize: UISize? {
        return arrangedSubviews.isEmpty ? .zero : nil
    }

    open var spacing: Double = 0 {
        didSet {
            recreateConstraints()
        }
    }

    open var orientation: Orientation {
        didSet {
            recreateConstraints()
        }
    }

    open var alignment: Alignment = .leading {
        didSet {
            recreateConstraints()
        }
    }

    /// Insets between the edges of the stack view and its contents
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            recreateConstraints()
        }
    }

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
                customSpacing: customSpacing
            ).create()

            _stackViewConstraints = constraints
        }
    }

    open func insertArrangedSubview(_ view: View, at index: Int) {
        if arrangedSubviews.contains(view) {
            return
        }

        arrangedSubviews.insert(view, at: index)
        addSubview(view)

        recreateConstraints()
    }

    open func addArrangedSubview(_ view: View) {
        if arrangedSubviews.contains(view) {
            return
        }

        arrangedSubviews.append(view)
        addSubview(view)

        recreateConstraints()
    }

    open func addArrangedSubviews(_ views: [View]) {
        withSuspendedLayout(setNeedsLayout: true) {
            for view in views where !arrangedSubviews.contains(view) {
                arrangedSubviews.append(view)
                addSubview(view)
            }

            recreateConstraints()
        }
    }

    open func removeArrangedSubview(atIndex index: Int) {
        assert(index < arrangedSubviews.count)

        customSpacing.removeValue(forKey: arrangedSubviews[index])
        arrangedSubviews[index].removeFromSuperview()
    }

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

    public enum Orientation {
        /// Views are arranged from top to bottom
        case vertical

        /// Views are arranged from left to right
        case horizontal
    }

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
}
