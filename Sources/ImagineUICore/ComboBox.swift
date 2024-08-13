import Geometry
import Rendering

open class ComboBox: ControlView {
    private static let comboBoxStrokeColor = Color.white
    private static let comboBoxBackgroundColor = Color(red: 37, green: 37, blue: 38)

    private var _backColor = StatedValueStore<Color>()
    private var _visibleList: ListView?
    private let _accessoryView = AccessoryView()

    /// Gets the view that forms the label of this combo box.
    public let label = Label(textColor: .white)

    /// The insets of the label outline relative to the bounds of this button.
    open var contentInset: UIEdgeInsets = UIEdgeInsets(left: 10, top: 4, right: 10, bottom: 4) {
        didSet {
            updateLabelConstraints()
        }
    }

    /// The background color for the button.
    ///
    /// Background color is automatically handled by a button, and if customization
    /// is required, `setBackgroundColor(_:forState:)` should be used to configure
    /// the colors for each state.
    open override var backColor: Color {
        get {
            return _backColor.getValue(controlState, defaultValue: Self.comboBoxBackgroundColor)
        }
        set {
            super.backColor = newValue
        }
    }

    /// The main data source for fetching items for this combo box.
    public weak var dataSource: DataSource? {
        didSet { reloadData() }
    }

    /// Called to notify listeners that the selection on this combo box will be
    /// changed, allowing listeners to cancel the change.
    @CancellableActionEventWithSender<ComboBox, Int>
    public var willSelect

    /// Called to notify listeners that the selection on this combo box has been
    /// changed.
    @EventWithSender<ComboBox, Int>
    public var didSelect

    /// Called to notify listeners that the combo box list view has been opened.
    @EventWithSender<ComboBox, Void>
    public var didOpen

    /// Called to notify listeners that the combo box list view has closed.
    @EventWithSender<ComboBox, Void>
    public var didClose

    /// Gets the index of the item displayed on this combo box.
    ///
    /// Is `nil` if no data source is available to fill the items on this combo
    /// box.
    private(set) public var selectedIndex: Int?

    /// Initializes a standard button control with a given initial title label.
    public override init() {
        super.init()

        strokeColor = Self.comboBoxStrokeColor
        strokeWidth = 1
        initStyle()
    }

    private func initStyle() {
        _backColor.setValue(Self.comboBoxBackgroundColor, forState: .normal)
        _backColor.setValue(Self.comboBoxBackgroundColor.faded(towards: .white, factor: 0.1), forState: .highlighted)
        _backColor.setValue(Self.comboBoxBackgroundColor.faded(towards: .black, factor: 0.1), forState: .selected)
    }

    open override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        invalidate()
    }

    open override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(label)
        addSubview(_accessoryView)
    }

    open override func setupConstraints() {
        super.setupConstraints()

        // Label constraints
        label.setContentCompressionResistance(.horizontal, .high)
        label.layout.makeConstraints { make in
            (make.top == self + contentInset.top) | .high
            (make.left == self + contentInset.left) | .high
            (make.bottom == self - contentInset.bottom) | .high
            (make.right == _accessoryView.layout.left - contentInset.right) | .medium
        }
        _accessoryView.layout.makeConstraints { make in
            make.width == 25
            (make.top, make.right, make.bottom) == self
            (make.left == self.layout.right) | .low
        }
    }

    open override func onMouseClick(_ event: MouseEventArgs) {
        super.onMouseClick(event)

        _open()
    }

    public override func boundsForFillOrStroke() -> UIRectangle {
        return bounds.insetBy(x: strokeWidth, y: strokeWidth)
    }

    /// Reloads the displayed data on this combo box.
    public func reloadData() {
        _populateSelection()

        if let listView = _visibleList {
            listView.reloadItems(_generateItems())
        }
    }

    private func _populateSelection() {
        guard let dataSource else {
            selectedIndex = nil
            return
        }

        let index = dataSource.comboBoxSelectedItemIndex(self)
        let item = dataSource.comboBox(self, itemAt: index)

        let text: AttributedText
        switch item {
        case .item(let item):
            text = item.title

        case .separator:
            text = "-"
        }

        self.selectedIndex = index
        self.label.attributedText = text
    }

    private func _generateItems() -> [View] {
        guard let dataSource else {
            return []
        }

        let count = dataSource.comboBoxItemCount(self)

        var views: [View] = []
        for index in 0..<count {
            let entry = dataSource.comboBox(self, itemAt: index)

            switch entry {
            case .item(let item):
                let view = ComboBoxItemView(item: item)
                view.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
                    guard let self = self else { return }

                    // TODO: Add ghost view of selected item like in Windows comboboxes
                    self._handleItemSelect(index: index)
                    self._close()
                }

                if selectedIndex == index {
                    view.isSelected = true
                }

                views.append(view)

            case .separator:
                let view = SeparatorItem()
                views.append(view)
            }
        }

        return views
    }

    private func _close() {
        guard let listView = _visibleList else {
            return
        }

        listView.dismiss()
        _visibleList = nil
    }

    private func _open() {
        guard let controlSystem else {
            return
        }

        let listView = ListView(items: _generateItems())
        listView.onClose.addWeakListener(self) { (self, e) in
            self._didClose(sender: self)
        }

        _visibleList = listView

        let didShow = controlSystem.openDialog(
            listView,
            location: .topLeft(bounds.bottomLeft, relativeTo: self)
        )
        let location = convert(point: bounds.bottomLeft, to: nil)

        if didShow {
            if let listSuperview = listView.superview {
                listView.layout.makeConstraints { make in
                    (make.left == location.x) | .medium
                    (make.top == location.y) | .medium
                    (make.width >= self.bounds.width) | .medium
                    make.left >= listSuperview
                    make.top >= listSuperview
                    make.right <= listSuperview
                    make.bottom <= listSuperview
                }
            }

            _didOpen(sender: self)
        }
    }

    private func _handleItemSelect(index: Int) {
        guard !_willSelect(sender: self, value: index) else {
            return
        }

        _didSelect(sender: self, index)

        _populateSelection()
    }

    func updateLabelConstraints() {
        // Label constraints
        label.layout.updateConstraints { make in
            (make.top == self + contentInset.top) | .medium
            (make.left == self + contentInset.left) | .medium
            (make.bottom == self - contentInset.bottom) | .medium
            (make.right == _accessoryView.layout.left - contentInset.right) | .medium
        }
    }

    /// Sets the appropriate background color while this button is in a given
    /// state.
    ///
    /// The color is automatically used to paint the button's background on
    /// subsequent `renderBackground(renderer:screenRegion:)` calls.
    func setBackgroundColor(_ color: Color, forState state: ControlViewState) {
        _backColor.setValue(color, forState: state)

        if state == controlState {
            invalidate()
        }
    }

    open override func viewForFirstBaseline() -> View? {
        return label
    }

    /// A data source for combo box view contents.
    public protocol DataSource: AnyObject {
        /// Requests the number of items for this combo box.
        func comboBoxItemCount(
            _ comboBox: ComboBox
        ) -> Int

        /// Requests the combo box item for the given index.
        func comboBox(
            _ comboBox: ComboBox,
            itemAt index: Int
        ) -> ComboBoxItemEntry

        /// Requests an index to use as a selected item to present on this combo
        /// box.
        func comboBoxSelectedItemIndex(
            _ comboBox: ComboBox
        ) -> Int
    }

    /// A small view that sits at the end of the combo box, with a downwards-pointing
    /// chevron icon.
    private class AccessoryView: View {
        var strokeColor: Color = ComboBox.comboBoxStrokeColor
        var backColor: Color = ComboBox.comboBoxBackgroundColor

        override func render(in context: any Renderer, screenRegion: any ClipRegionType) {
            super.render(in: context, screenRegion: screenRegion)

            let color = Color(red: 68, green: 68, blue: 74)

            let line =
                UILine(
                    start: .init(x: 1, y: 0),
                    end: .init(x: 1, y: 13)
                )
                .withCenter(on: .init(x: 1, y: size.height / 2))

            let strokePoints: UIPolygon =
                UIPolygon(vertices: [
                    UIVector(x: 0, y: 0),
                    UIVector(x: 5, y: 5),
                    UIVector(x: 0, y: 10),
                ])
                .withCenter(on: bounds.center)
                .rotatedAroundCenter(by: .pi / 2)

            context.setFill(backColor)
            context.fill(bounds.insetBy(2))

            context.setStroke(color)
            context.stroke(line)

            context.setFill(color)
            context.fill(strokePoints)
        }
    }

    private class ComboBoxItemView: ControlView {
        private static let defaultColor: Color = .transparentBlack
        private static let selectedColor: Color = Color(red: 9, green: 71, blue: 113)
        private static let highlightedColor: Color = Color(red: 12, green: 100, blue: 160)
        private static let strokeColor: Color = .cornflowerBlue

        private let _label: Label = Label(textColor: .white)
        private let _contentInset: UIEdgeInsets = UIEdgeInsets(left: 14, top: 2, right: 14, bottom: 2)
        private let item: ComboBoxItem

        override var tooltipCondition: TooltipDisplayCondition {
            .viewPartiallyOccluded
        }
        override var preferredTooltipLocation: PreferredTooltipLocation {
            .inPlace
        }
        override var viewForTooltip: View {
            _label
        }

        init(item: ComboBoxItem) {
            self.item = item

            super.init()

            _label.attributedText = item.title
            _label.font = Fonts.defaultFont(size: 12)
            mouseOverHighlight = true

            tooltip = .init(text: _label.attributedText)
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_label)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _label.setContentCompressionResistance(.vertical, .required)
            _label.setContentCompressionResistance(.horizontal, .required)
            _label.layout.makeConstraints { make in
                make.left == self + _contentInset.left
                make.top == self + _contentInset.top
                make.right <= self - _contentInset.right
                make.bottom == self - _contentInset.bottom
            }
        }

        override func onMouseClick(_ event: MouseEventArgs) {
            super.onMouseClick(event)
        }

        override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
            super.onStateChanged(event)

            switch controlState {
            case .selected:
                backColor = Self.selectedColor

            case .highlighted:
                backColor = Self.highlightedColor

            default:
                backColor = Self.defaultColor
            }
        }

        override func renderBackground(in renderer: any Renderer, screenRegion: any ClipRegionType) {
            super.renderBackground(in: renderer, screenRegion: screenRegion)

            switch controlState {
            case .selected:
                renderer.setStroke(Self.strokeColor)
                renderer.setStrokeWidth(1)

                renderer.stroke(bounds.topLine)
                renderer.stroke(bounds.bottomLine)

            default:
                break
            }
        }

        override func onMouseEnter() {
            super.onMouseEnter()

            item.mouseEnteredItem?()
        }

        override func onMouseLeave() {
            super.onMouseLeave()

            item.mouseExitedItem?()
        }
    }

    private class SeparatorItem: View {
        override var intrinsicSize: IntrinsicSize {
            .height(16)
        }

        var color: Color = .gray {
            didSet {
                invalidate()
            }
        }

        override init() {
            super.init()
        }

        override func render(in renderer: Renderer, screenRegion: ClipRegionType) {
            let inset: Double = 8
            let line = UILine(
                start: UIPoint(x: inset, y: bounds.height / 2),
                end: UIPoint(x: bounds.right - inset, y: bounds.height / 2)
            )

            renderer.setStroke(color)
            renderer.setStrokeWidth(1)
            renderer.stroke(line)
        }
    }

    fileprivate class ListView: ControlView {
        let scrollView: ScrollView = .init(scrollBarsMode: .vertical)
        let stackView: StackView = .init(orientation: .vertical)
        var items: [View]

        weak var dialogDelegate: UIDialogDelegate?

        @EventWithSender<ListView, Void>
        var onClose

        init(items: [View]) {
            self.items = items

            super.init()

            scrollView.scrollBarsAlwaysVisible = false
            backColor = ComboBox.comboBoxBackgroundColor
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(scrollView)
            scrollView.addSubview(stackView)
            stackView.addArrangedSubviews(items)
        }

        override func setupConstraints() {
            super.setupConstraints()

            scrollView.layout.makeConstraints { make in
                make.edges == self
            }
            stackView.alignment = .fill
            stackView.layout.makeConstraints { make in
                make.edges == scrollView.contentView
            }
            self.layout.makeConstraints { make in
                (make.width >= scrollView.contentView) | .high
                (make.height >= scrollView.contentView) | .high

                (make.width == 0) | .lowest
                (make.height == 0) | .lowest
            }
        }

        func reloadItems(_ items: [View]) {
            self.withSuspendedLayout(setNeedsLayout: true) {
                for item in self.items {
                    item.removeFromSuperview()
                }

                self.items = items

                stackView.addArrangedSubviews(items)
            }
        }
    }
}

public enum ComboBoxItemEntry {
    /// An item with display information.
    case item(ComboBoxItem)

    /// A vertical separator.
    case separator
}

public struct ComboBoxItem {
    public let title: AttributedText

    /// Event invoked when the user enters with the mouse pointer over a this
    /// item.
    var mouseEnteredItem: (() -> Void)?

    /// Event invoked when the user exits with the mouse pointer out of this
    /// item.
    var mouseExitedItem: (() -> Void)?

    public init(
        title: AttributedText,
        mouseEnteredItem: (() -> Void)? = nil,
        mouseExitedItem: (() -> Void)? = nil
    ) {
        self.title = title
        self.mouseEnteredItem = mouseEnteredItem
        self.mouseExitedItem = mouseExitedItem
    }

    public func mouseEnter(_ closure: @escaping () -> Void) -> Self {
        var copy = self
        copy.mouseEnteredItem = closure
        return copy
    }

    public func mouseExit(_ closure: @escaping () -> Void) -> Self {
        var copy = self
        copy.mouseExitedItem = closure
        return copy
    }
}

extension ComboBox.ListView: UIDialog {
   func customBackdrop() -> View? {
        let view = BackdropControl()
        view.wantsToDismiss.addListener(weakOwner: self) { [weak self] in
            guard let self = self else { return }

            self.dismiss()
        }

        return view
    }

    func dismiss() {
        dialogDelegate?.dialogWantsToClose(self)
    }

    func didOpen() {

    }

    func didClose() {
        _onClose(sender: self)
    }

    private class BackdropControl: ControlView {
        @Event<Void>
        var wantsToDismiss

        override func onMouseDown(_ event: MouseEventArgs) {
            super.onMouseDown(event)

            _wantsToDismiss()
        }

        override func canHandle(_ eventRequest: EventRequest) -> Bool {
            guard let mouseEvent = eventRequest as? MouseEventRequest else {
                return super.canHandle(eventRequest)
            }
            guard mouseEvent.eventType == MouseEventType.mouseDown, mouseEvent.buttons == .left else {
                return super.canHandle(eventRequest)
            }

            _wantsToDismiss()
            return false
        }
    }
}
