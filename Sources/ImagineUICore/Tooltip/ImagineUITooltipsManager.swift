/// Manages exhibition of tooltips for a view hierarchy within an ImagineUI
/// control system.
@ImagineActor
public class ImagineUITooltipsManager: TooltipsManagerType {
    private var _customTooltipState: CustomTooltipState?

    private var _previousConstraints: [LayoutConstraint] = []

    private var _mouseLocation: UIPoint = .zero {
        didSet {
            switch _position {
            case .followingMouse:
                _updateTooltipPosition(.followingMouse)

            default:
                break
            }
        }
    }

    /// The singular tooltip instance to display all tooltips with.
    private let _tooltip: TooltipView = TooltipView()

    /// The container view for the tooltips to be added to.
    private let _container: View
    /// A view used as a target for the tooltip to attempt to reach if there's
    /// enough space on screen to do so.
    private let _tooltipTargetPosition: View
    private var _position: DisplayPosition = .none

    public var isTooltipVisible: Bool {
        _tooltip.isVisible && _tooltip.superview != nil
    }

    public var hasCustomTooltipActive: Bool {
        _cullCustomTooltipState()

        return _customTooltipState?.isActive ?? false
    }

    public init(container: View) {
        self._container = container
        self._tooltipTargetPosition = View()

        _setupTooltipView()
    }

    private func _setupTooltipView() {
        _tooltip.isVisible = false

        _container.addSubview(_tooltip)
        _container.addSubview(_tooltipTargetPosition)

        // Add default constraints
        _tooltip.layout.makeConstraints { make in
            (make.left >= _container) | .high
            (make.top >= _container) | .high
            (make.right <= _container) | .medium
            (make.bottom <= _container) | .medium

            (make.top == _tooltipTargetPosition) | .low
            (make.left == _tooltipTargetPosition) | .low
        }
    }

    public func isInTooltipView(_ view: View) -> Bool {
        view.isDescendant(of: _tooltip)
    }

    public func hideTooltip() {
        guard !hasCustomTooltipActive else { return }

        internalHideTooltip()
    }

    public func showTooltip(
        _ tooltip: Tooltip,
        view: View,
        location: PreferredTooltipLocation
    ) {
        guard !hasCustomTooltipActive else { return }

        internalShowTooltip(tooltip, view: view, location: location)
    }

    public func updateTooltip(_ tooltip: Tooltip) {
        guard !hasCustomTooltipActive else { return }

        internalUpdateTooltip(tooltip)
    }

    public func updateTooltipCursorLocation(_ location: UIPoint) {
        internalUpdateTooltipCursorLocation(location)
    }

    public func beginCustomTooltipLifetime() -> CustomTooltipHandlerType? {
        guard !hasCustomTooltipActive else { return nil }

        let lifetime = CustomTooltipState.LifetimeObject()

        let handler = CustomTooltipHandler(lifetimeToken: lifetime, manager: self)

        _customTooltipState = CustomTooltipState(
            handler: handler,
            lifetimeObject: lifetime
        )

        return handler
    }

    // MARK: - Internals

    fileprivate func internalHideTooltip() {
        _tooltip.isVisible = false

        _updateTooltipPosition(.none)
    }

    fileprivate func internalShowTooltip(
        _ tooltip: Tooltip,
        view: View,
        location: PreferredTooltipLocation
    ) {

        _tooltip.update(tooltip)

        _tooltip.isVisible = true

        _computePosition(view: view, location: location)
    }

    fileprivate func internalUpdateTooltip(_ tooltip: Tooltip) {
        _tooltip.update(tooltip)
    }

    fileprivate func internalUpdateTooltipCursorLocation(_ location: UIPoint) {
        _mouseLocation = location
    }

    fileprivate func endCustomTooltipLifetime(_ handler: CustomTooltipHandler) {
        guard hasCustomTooltipActive, _customTooltipState?.handler === handler else {
            return
        }

        _customTooltipState = nil

        hideTooltip()
    }

    private func _computePosition(view: View, location: PreferredTooltipLocation) {
        let position: DisplayPosition

        switch location {
        case .systemDefined:
            position = .nextToMouse
        case .right:
            position = .rightOf(view)
        case .left:
            position = .leftOf(view)
        case .top:
            position = .above(view)
        case .bottom:
            position = .under(view)
        case .inPlace:
            position = .inPlace(view, _computeInPlacePosition(view))
        case .nextToMouse:
            position = .nextToMouse
        case .followingMouse:
            position = .followingMouse
        }

        _updateTooltipPosition(position)
    }

    private func _computeInPlacePosition(_ view: View) -> UIPoint {
        // Align labels with the tooltip's internal label
        if view is Label {
            return -_tooltip.contentInset.topLeft
        }

        return .zero
    }

    private func _updateTooltipPosition(_ newPosition: DisplayPosition) {
        defer { _position = newPosition }

        let location: UIPoint

        // Figure out if we need to remove auxiliary constraints
        var shouldRemakeConstraints = false
        if _position != newPosition {
            shouldRemakeConstraints = true

            _previousConstraints.forEach {
                $0.removeConstraint()
            }
            _previousConstraints = []
        }

        switch newPosition {
        case .relative(let view, let point):
            location = _container.convert(point: point, from: view)

        case .rightOf(let view):
            location = _container.convert(point: UIPoint(x: view.size.width, y: 0), from: view)

        case .leftOf(let view):
            location = _container.convert(point: .zero, from: view)

            if shouldRemakeConstraints {
                _previousConstraints = _tooltip.layout.makeConstraints { make in
                    (make.right == _tooltipTargetPosition.layout.left) | .medium
                }
            }

        case .under(let view):
            location = _container.convert(
                point: UIPoint(x: 0, y: view.size.height),
                from: view
            )

        case .above(let view):
            location = _container.convert(point: .zero, from: view)

            if shouldRemakeConstraints {
                _previousConstraints = _tooltip.layout.makeConstraints { make in
                    (make.bottom == _tooltipTargetPosition.layout.top) | .medium
                }
            }

        case .inPlace(let view, let point):
            location = _container.convert(point: point, from: view)

        case .nextToMouse, .followingMouse:
            location = _container.convert(
                point: _locationForMouseTracking(_mouseLocation),
                from: nil
            )

        case .none:
            location = .zero
        }

        _tooltipTargetPosition.location = location
    }

    private func _locationForMouseTracking(_ mouseLocation: UIPoint) -> UIPoint {
        let mouseOffset: UIVector = .init(x: 12, y: 5)
        let mousePosition = mouseLocation + mouseOffset

        return mousePosition
    }

    /// Removes the custom tooltip state if its lifetime has expired.
    private func _cullCustomTooltipState() {
        guard let state = _customTooltipState else {
            return
        }

        if !state.isActive {
            _customTooltipState = nil
        }
    }

    private enum DisplayPosition: Equatable {
        case none
        case relative(View, UIPoint)
        case rightOf(View)
        case leftOf(View)
        case above(View)
        case under(View)
        case inPlace(View, UIPoint)
        case nextToMouse
        case followingMouse
    }

    @ImagineActor
    private struct CustomTooltipState {
        weak var handler: CustomTooltipHandler?
        weak var lifetimeObject: AnyObject?

        var isActive: Bool {
            handler?.isActive == true && lifetimeObject != nil
        }

        class LifetimeObject {
            init() {

            }
        }
    }
}

/// Used to handle custom tooltip lifetimes.
@ImagineActor
fileprivate final class CustomTooltipHandler: CustomTooltipHandlerType {
    /// A lifetime object associated with this tooltip handler that is
    var lifetimeToken: AnyObject

    /// The tooltip manager associated with this tooltip lifetime handler.
    weak var manager: ImagineUITooltipsManager?

    var isActive: Bool = true

    init(lifetimeToken: AnyObject, manager: ImagineUITooltipsManager) {
        self.lifetimeToken = lifetimeToken
        self.manager = manager
    }

    /// Requests that a tooltip be shown at a specified location relative to a
    /// specified view.
    public func showTooltip(
        _ tooltip: Tooltip,
        view: View,
        location: PreferredTooltipLocation
    ) {
        guard isActive else { return }

        manager?.internalShowTooltip(tooltip, view: view, location: location)
    }

    /// Requests that a tooltip for a given tooltip provider be shown, optionally
    /// specifying a custom tooltip location.
    public func showTooltip(
        for tooltipProvider: TooltipProvider,
        location: PreferredTooltipLocation? = nil
    ) {
        guard isActive else { return }
        guard let tooltip = tooltipProvider.tooltip else {
            return
        }

        showTooltip(
            tooltip,
            view: tooltipProvider.viewForTooltip,
            location: location ?? tooltipProvider.preferredTooltipLocation
        )
    }

    /// Updates the contents of the currently displayed tooltip.
    /// Does nothing, if
    public func updateTooltip(_ tooltip: Tooltip) {
        guard isActive else { return }

        manager?.internalUpdateTooltip(tooltip)
    }

    /// Hides a tooltip that was previously shown with `showTooltip`
    public func hideTooltip() {
        guard isActive else { return }

        manager?.internalHideTooltip()
    }

    /// Explicitly requests that the custom lifetime of this tooltip handler be
    /// ended and tooltip management return to the default behaviour.
    public func endTooltipLifetime() {
        guard isActive else { return }

        manager?.endCustomTooltipLifetime(self)

        isActive = false
    }
}
