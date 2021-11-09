import Geometry
import CassowarySwift

/// A view that lays out a set of its arranged subviews horizontally or
/// vertically automatically
open class StackView: View {
    private let parentGuide = LayoutGuide()
    private var customSpacing: [View: Double] = [:]

    private(set) public var arrangedSubviews: [View] = []

    public override var intrinsicSize: UISize? {
        return .zero
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
            parentGuide.layout.updateConstraints { make in
                make.edges.equalTo(self, inset: contentInset)
            }
        }
    }

    public init(orientation: Orientation) {
        self.orientation = orientation

        super.init()

        addLayoutGuide(parentGuide)
        parentGuide.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }
    }

    private func recreateConstraints() {
        withSuspendedLayout(setNeedsLayout: true) {
            // Re-add the views back to allow constraints between views and the
            // parent layout guide to reset
            let views = arrangedSubviews
            for view in arrangedSubviews {
                view.removeFromSuperview()
                addSubview(view)
            }

            arrangedSubviews = views

            for (i, view) in arrangedSubviews.enumerated() {
                _makeConstraints(view: view, index: i)
            }
        }
    }

    private func _makeConstraints(view: View, index: Int) {
        let previous: View? = index > 0 ? arrangedSubviews[index - 1] : nil
        let viewSpacing = previous.flatMap { customSpacing[$0] } ?? spacing
        let isLastView = index == arrangedSubviews.count - 1

        view.layout.makeConstraints { make in
            // Connection to previous view
            switch orientation {
            case .horizontal:
                if let previous = previous {
                    make.right(of: previous, offset: viewSpacing)
                } else {
                    make.left == parentGuide
                }
                if isLastView {
                    make.right == parentGuide
                }
            default:
                if let previous = previous {
                    make.under(previous, offset: viewSpacing)
                } else {
                    make.top == parentGuide
                }
                if isLastView {
                    make.bottom == parentGuide
                }
            }

            // Connect to parent guide
            switch alignment {
            case .leading:
                switch orientation {
                case .horizontal:
                    make.top == parentGuide
                    make.bottom <= parentGuide

                case .vertical:
                    make.left == parentGuide
                    make.right <= parentGuide
                }

            case .trailing:
                switch orientation {
                case .horizontal:
                    make.top >= parentGuide
                    make.bottom == parentGuide
                case .vertical:
                    make.left >= parentGuide
                    make.right == parentGuide
                }

            case .fill:
                switch orientation {
                case .horizontal:
                    make.top == parentGuide
                    make.bottom == parentGuide

                case .vertical:
                    make.left == parentGuide
                    make.right == parentGuide
                }

            case .centered:
                switch orientation {
                case .horizontal:
                    make.centerY == parentGuide
                    make.height <= parentGuide

                case .vertical:
                    make.centerX == parentGuide
                    make.width <= parentGuide
                }
            }
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

        arrangedSubviews[index].removeFromSuperview()
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
