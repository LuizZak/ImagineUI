/// Manages exhibition of tooltips for a view hierarchy within an ImagineUI
/// control system.
public class ImagineUITooltipsManager: TooltipsManagerType {
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

    public var isTooltipVisible: Bool {
        _tooltip.superview != nil
    }

    private var _position: DisplayPosition = .none {
        didSet {
            _updateTooltipPosition()
        }
    }

    public init(container: View) {
        self._container = container

        _tooltip.areaIntoConstraintsMask = [.location]
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
        _tooltip.location = .init(x: 50, y: 50)

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
            _position = .inPlace(view)
        case .nextToMouse:
            _position = .nextToMouse
        case .followingMouse:
            _position = .followingMouse
        }

        _updateTooltipPosition()
    }

    private func _updateTooltipPosition() {
        let mouseOffset: UIVector = .init(x: 12, y: 5)
        let mousePosition = _mouseLocation + mouseOffset

        switch _position {
        case .relative(let view, let point):
            _tooltip.location = _container.convert(point: point, from: view)

        case .rightOf(let view):
            _tooltip.location = _container.convert(point: UIPoint(x: view.size.width, y: 0), from: view)

        case .leftOf(let view):
            _tooltip.location = _container.convert(point: .zero, from: view) - _tooltip.size.width
        
        case .inPlace(let view):
            _tooltip.location = _container.convert(point: .zero, from: view)

        case .nextToMouse:
            _tooltip.location = _container.convert(point: mousePosition, from: nil)

        case .followingMouse:
            _tooltip.location = _container.convert(point: mousePosition, from: nil)

        case .none:
            break
        }
    }

    private enum DisplayPosition {
        case none
        case relative(View, UIPoint)
        case rightOf(View)
        case leftOf(View)
        case inPlace(View)
        case nextToMouse
        case followingMouse
    }
}
