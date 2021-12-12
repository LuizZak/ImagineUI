/// Manages exhibition of tooltips for a view hierarchy.
public class TooltipsManager {
    private var _mouseLocation: UIPoint = .zero {
        didSet {
            switch _position {
            case .followingMouse:
                _updateTooltipPosition()
            default:
                break
            }
        }
    }

    /// The singular tooltip instance to display all tooltips with.
    private let _tooltip: TooltipView = TooltipView()

    /// The container view for the tooltips to be added to.
    private let _container: View

    private var _position: DisplayPosition = .none {
        didSet {
            _updateTooltipPosition()
        }
    }

    public init(container: View) {
        self._container = container

        _tooltip.areaIntoConstraintsMask = [.location]
    }

    public func isVisible() -> Bool {
        _tooltip.superview != nil
    }

    public func hideTooltip() {
        _tooltip.removeFromSuperview()
        _position = .none
    }

    public func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation) {
        _tooltip.update(tooltip)
        _tooltip.location = .init(x: 50, y: 50)

        _container.addSubview(_tooltip)

        _computePosition(view: view, location: location)
    }

    /// Updates the mouse location so the tooltip stays besides it, in case it is
    /// currently being shown and is configured to follow the mouse.
    public func updateTooltipCursorLocation(_ location: UIPoint) {
        _mouseLocation = location
    }

    /// Updates the contents of the currently displayed tooltip.
    public func updateTooltip(_ tooltip: Tooltip) {
        _tooltip.update(tooltip)
    }

    func _computePosition(view: View, location: PreferredTooltipLocation) {
        switch location {
        case .systemDefined:
            _position = .nextToMouse
        case .right:
            _position = .rightOf(view)
        case .left:
            _position = .leftOf(view)
        case .top:
            _position = .rightOf(view)
        case .bottom:
            _position = .rightOf(view)
        case .nextToMouse:
            _position = .nextToMouse
        case .followingMouse:
            _position = .followingMouse
        }

        _updateTooltipPosition()
    }

    private func _show(text: String, position: DisplayPosition) {
        if isVisible() {
            hideTooltip()
        }

        _configure(text: text)
        _container.addSubview(_tooltip)

        _position = position
        _updateTooltipPosition()
    }

    private func _configure(text: String) {
        _tooltip.update(.init(text: text))
    }

    private func _updateTooltipPosition() {
        let mouseOffset: UIVector = .init(x: 12, y: 5)
        let mousePosition = _mouseLocation + mouseOffset

        switch _position {
        case .none:
            break
        case .relative(let view, let point):
            _tooltip.location = _container.convert(point: point, from: view)

        case .rightOf(let view):
            _tooltip.location = _container.convert(point: UIPoint(x: view.size.width, y: 0), from: view)

        case .leftOf(let view):
            _tooltip.location = _container.convert(point: .zero, from: view) - _tooltip.size.width

        case .nextToMouse:
            _tooltip.location = _container.convert(point: mousePosition, from: nil)

        case .followingMouse:
            _tooltip.location = _container.convert(point: mousePosition, from: nil)
        }
    }

    private enum DisplayPosition {
        case none
        case relative(View, UIPoint)
        case rightOf(View)
        case leftOf(View)
        case nextToMouse
        case followingMouse
    }
}
