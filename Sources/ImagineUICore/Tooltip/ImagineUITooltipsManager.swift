/// Manages exhibition of tooltips for a view hierarchy within an ImagineUI
/// control system.
public class ImagineUITooltipsManager: TooltipsManagerType {
    private var _previousConstraints: [LayoutConstraint] = []

    private var _mouseLocation: UIPoint = .zero {
        didSet {
            switch _position {
            case .followingMouse:
                _updateTooltipConstraints()

            default:
                break
            }
        }
    }

    /// The singular tooltip instance to display all tooltips with.
    private let _tooltip: TooltipView = TooltipView()

    /// The container view for the tooltips to be added to.
    private let _container: View

    public var isTooltipVisible: Bool {
        _tooltip.superview != nil
    }

    private var _position: DisplayPosition = .none

    public init(container: View) {
        self._container = container

        _setupTooltipView()
    }

    private func _setupTooltipView() {
        _tooltip.areaIntoConstraintsMask = []
    }

    public func isInTooltipView(_ view: View) -> Bool {
        view.isDescendant(of: view)
    }

    public func hideTooltip() {
        _tooltip.removeFromSuperview()
        _position = .none
    }

    public func showTooltip(_ tooltip: Tooltip, view: View, location: PreferredTooltipLocation) {
        _tooltip.update(tooltip)

        _container.addSubview(_tooltip)

        _computePosition(view: view, location: location)
    }

    public func updateTooltipCursorLocation(_ location: UIPoint) {
        _mouseLocation = location
    }

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
        case .inPlace:
            _position = .inPlace(view, _computeInPlacePosition(view))
        case .nextToMouse:
            _position = .nextToMouse
        case .followingMouse:
            _position = .followingMouse
        }

        _updateTooltipConstraints()
    }

    private func _computeInPlacePosition(_ view: View) -> UIPoint {
        // Align labels with the tooltip's internal label
        if view is Label {
            return -_tooltip.contentInset.topLeft
        }

        return .zero
    }

    private func _updateTooltipConstraints() {
        let mouseOffset: UIVector = .init(x: 12, y: 5)
        let mousePosition = _mouseLocation + mouseOffset
        let location: UIPoint

        switch _position {
        case .relative(let view, let point):
            location = _container.convert(point: point, from: view)

        case .rightOf(let view):
            location = _container.convert(point: UIPoint(x: view.size.width, y: 0), from: view)

        case .leftOf(let view):
            location = _container.convert(point: .zero, from: view) - _tooltip.size.width

        case .inPlace(let view, let point):
            location = _container.convert(point: point, from: view)

        case .nextToMouse:
            location = _container.convert(point: mousePosition, from: nil)

        case .followingMouse:
            location = _container.convert(point: mousePosition, from: nil)

        case .none:
            location = .zero
        }

        for constraint in _previousConstraints {
            constraint.removeConstraint()
        }

        _previousConstraints = _tooltip.layout.makeConstraints { make in
            (make.left >= _container) | .high
            (make.top >= _container) | .high
            (make.right <= _container) | .medium
            (make.bottom <= _container) | .medium

            (make.left == location.x) | .low
            (make.top == location.y) | .low
        }
    }

    private func _updateTooltipPosition() {
        
    }

    private enum DisplayPosition {
        case none
        case relative(View, UIPoint)
        case rightOf(View)
        case leftOf(View)
        case inPlace(View, UIPoint)
        case nextToMouse
        case followingMouse
    }
}
