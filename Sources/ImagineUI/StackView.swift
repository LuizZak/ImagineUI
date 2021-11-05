import Geometry
import CassowarySwift

/// A view that lays out a set of its arranged subviews horizontally or
/// vertically automatically
open class StackView: View {
    private var arrangedSubviews: [View] = []
    private var customSpacing: [View: Double] = [:]

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
            recreateConstraints()
        }
    }

    public init(orientation: Orientation) {
        self.orientation = orientation
        super.init()

        setContentHuggingPriority(.vertical, 50)
        setContentHuggingPriority(.horizontal, 50)
    }

    private func recreateConstraints() {
        for layoutGuide in layoutGuides {
            removeLayoutGuide(layoutGuide)
        }

        let parentGuide = LayoutGuide()
        addLayoutGuide(parentGuide)
        parentGuide.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }

        var previousGuide: LayoutGuide?
        var previousAfterSpacing: Double?
        for (i, view) in arrangedSubviews.enumerated() {
            let guide = LayoutGuide()
            defer {
                previousGuide = guide
                previousAfterSpacing = customSpacing[view]
            }

            let isLastView = i == arrangedSubviews.count - 1

            let viewSpacing = previousAfterSpacing ?? spacing

            addLayoutGuide(guide)

            view.layout.makeConstraints { make in
                switch alignment {
                case .leading:
                    switch orientation {
                    case .horizontal:
                        make.left == guide
                        make.right == guide
                        make.top == guide
                        make.bottom <= guide
                    case .vertical:
                        make.top == guide
                        make.bottom == guide
                        make.left == guide
                        make.right <= guide
                    }

                case .trailing:
                    switch orientation {
                    case .horizontal:
                        make.left == guide
                        make.right == guide
                        make.top >= guide
                        make.bottom == guide
                    case .vertical:
                        make.top == guide
                        make.bottom == guide
                        make.width <= guide
                        make.right == guide
                    }

                case .fill:
                    make.edges == guide

                case .centered:
                    switch orientation {
                    case .horizontal:
                        make.left == guide
                        make.height <= guide
                        make.centerY == guide
                        make.right == guide

                    case .vertical:
                        make.top == guide
                        make.width <= guide
                        make.centerX == guide
                        make.bottom == guide
                    }
                }
            }

            guide.layout.makeConstraints { make in
                switch orientation {
                case .horizontal:
                    make.top == parentGuide
                    make.bottom == parentGuide

                    if let previous = previousGuide {
                        make.right(of: previous, offset: viewSpacing)
                    } else {
                        make.left == parentGuide
                    }
                    if isLastView {
                        make.right == parentGuide
                    }
                default:
                    make.left == parentGuide
                    make.right == parentGuide

                    if let previous = previousGuide {
                        make.under(previous, offset: viewSpacing)
                    } else {
                        make.top == parentGuide
                    }
                    if isLastView {
                        make.bottom == parentGuide
                    }
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
        for view in views {
            if arrangedSubviews.contains(view) {
                continue
            }

            arrangedSubviews.append(view)
            addSubview(view)
        }

        recreateConstraints()
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
