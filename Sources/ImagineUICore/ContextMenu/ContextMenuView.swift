/// A context-menu view items presenter control.
public class ContextMenuView: ControlView {
    private let dataSource: DataSource
    private let _stackView: StackView = StackView(orientation: .vertical)

    private var _onOpen: (() -> Void)?
    private var _onClose: (() -> Void)?

    public weak var dialogDelegate: UIDialogDelegate?

    private init(dataSource: DataSource) {
        self.dataSource = dataSource

        super.init()

        initialize()
    }

    private func initialize() {
        backColor = Color(red: 37, green: 37, blue: 38)
        strokeColor = backColor.faded(towards: .white, factor: 0.1)
        strokeWidth = 1

        _populateItems()
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_stackView)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        areaIntoConstraintsMask = [.location]
        _stackView.alignment = .fill
        _stackView.layout.makeConstraints { make in
            make.top == self + 4
            make.left == self
            make.right == self
            make.bottom == self - 4
        }
    }

    public override func boundsForFillOrStroke() -> UIRectangle {
        return bounds.insetBy(x: strokeWidth, y: strokeWidth)
    }

    public func opened(_ closure: @escaping () -> Void) -> ContextMenuView {
        _onOpen = closure
        return self
    }

    public func closed(_ closure: @escaping () -> Void) -> ContextMenuView {
        _onClose = closure
        return self
    }

    private func _populateItems() {
        for entry in dataSource.items {
            switch entry {
            case .item(let item):
                let view = ContextMenuItemView(item: item)
                view.mouseClicked.addListener(weakOwner: self) { [weak self] (_, _) in
                    guard let self = self else { return }

                    self.dialogDelegate?.dialogWantsToClose(self)

                    item.selected()
                }

                _stackView.addArrangedSubview(view)

            case .separator:
                let view = SeparatorItem()

                _stackView.addArrangedSubview(view)
            }
        }
    }

    private struct DataSource {
        var items: [ContextMenuItemEntry]
    }

    private class ContextMenuItemView: ControlView {
        private let _label: Label = Label(textColor: .white)
        private let _contentInset: UIEdgeInsets = UIEdgeInsets(left: 14, top: 2, right: 14, bottom: 2)
        private let item: ContextMenuItem

        init(item: ContextMenuItem) {
            self.item = item

            super.init()

            _label.attributedText = item.title
            _label.font = Fonts.defaultFont(size: 12)
            mouseOverHighlight = true
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_label)
        }

        override func setupConstraints() {
            super.setupConstraints()

            _label.layout.makeConstraints { make in
                make.left == self + _contentInset.left
                make.top == self + _contentInset.top
                make.right <= self - _contentInset.right
                make.bottom == self - _contentInset.bottom
            }
        }

        override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) async {
            await super.onStateChanged(event)

            switch controlState {
            case .highlighted, .selected:
                backColor = Color(red: 9, green: 71, blue: 113)
            default:
                backColor = .transparentBlack
            }
        }

        override func onMouseEnter() async {
            await super.onMouseEnter()

            item.mouseEnteredItem?()
        }

        override func onMouseLeave() async {
            await super.onMouseLeave()

            item.mouseExitedItem?()
        }
    }

    private class SeparatorItem: View {
        override var intrinsicSize: UISize? {
            .init(width: 0, height: 16)
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
}

extension ContextMenuView: UIDialog {
   public func customBackdrop() -> View? {
        let view = BackdropControl()
        view.wantsToDismiss.addListener(weakOwner: self) { [weak self] in
            guard let self = self else { return }

            self.dialogDelegate?.dialogWantsToClose(self)
        }

        return view
    }

    public func didOpen() {
        _onOpen?()
    }

    public func didClose() {
        _onClose?()
    }

    private class BackdropControl: ControlView {
        @SynchronousEvent<Void>
        var wantsToDismiss

        override func onMouseDown(_ event: MouseEventArgs) async {
            await super.onMouseDown(event)

            _wantsToDismiss()
        }

        override func canHandle(_ eventRequest: EventRequest) -> Bool {
            guard let mouseEvent = eventRequest as? MouseEventRequest else {
                return super.canHandle(eventRequest)
            }
            guard mouseEvent.eventType == MouseEventType.mouseDown, mouseEvent.buttons == .right else {
                return super.canHandle(eventRequest)
            }

            _wantsToDismiss()
            return false
        }
    }
}

extension ContextMenuView {
    public static func create(@ContextMenuViewBuilder _ builder: () -> [ContextMenuItemEntry]) -> ContextMenuView {
        return create(items: builder())
    }

    public static func create(items: [ContextMenuItemEntry]) -> ContextMenuView {
        let dataSource = DataSource(items: items)

        return ContextMenuView(dataSource: dataSource)
    }

    public static func createItems(@ContextMenuViewBuilder _ builder: () -> [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        builder()
    }
}

public enum ContextMenuItemEntry {
    /// An item with display information.
    case item(ContextMenuItem)

    /// A vertical separator.
    case separator
}

public struct ContextMenuItem {
    public let icon: Image?
    public let title: AttributedText

    /// Event invoked when the user selects this context menu item.
    var selected: () -> Void

    /// Event invoked when the user enters with the mouse pointer over a this
    /// item.
    var mouseEnteredItem: (() -> Void)?

    /// Event invoked when the user exits with the mouse pointer out of this
    /// item.
    var mouseExitedItem: (() -> Void)?

    public init(
        icon: Image? = nil,
        title: AttributedText,
        selected: @escaping () -> Void,
        mouseEnteredItem: (() -> Void)? = nil,
        mouseExitedItem: (() -> Void)? = nil
    ) {

        self.icon = icon
        self.title = title
        self.selected = selected
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

public struct ContextMenuItemSeparator {

}

@resultBuilder
public struct ContextMenuViewBuilder {
    public static func buildExpression(_ expression: ContextMenuItem) -> ContextMenuItemEntry {
        .item(expression)
    }

    public static func buildExpression(_ expression: ContextMenuItemSeparator) -> ContextMenuItemEntry {
        .separator
    }

    public static func buildBlock(_ components: ContextMenuItemEntry) -> [ContextMenuItemEntry] {
        [components]
    }

    public static func buildBlock(_ components: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        components
    }

    public static func buildBlock(_ components: ContextMenuItemEntry...) -> [ContextMenuItemEntry] {
        components
    }

    public static func buildArray(_ components: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        components
    }

    public static func buildEither(first component: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        component
    }

    public static func buildEither(second component: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        component
    }

    public static func buildPartialBlock(first: ContextMenuItemEntry) -> [ContextMenuItemEntry] {
        [first]
    }

    public static func buildPartialBlock(first: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        first
    }

    public static func buildPartialBlock(accumulated: [ContextMenuItemEntry], next: ContextMenuItemEntry) -> [ContextMenuItemEntry] {
        accumulated + [next]
    }

    public static func buildPartialBlock(accumulated: [ContextMenuItemEntry], next: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        accumulated + next
    }

    public static func buildOptional(_ component: [ContextMenuItemEntry]?) -> [ContextMenuItemEntry] {
        if let component {
            return component
        } else {
            return []
        }
    }

    public static func buildLimitedAvailability(_ component: [ContextMenuItemEntry]) -> [ContextMenuItemEntry] {
        return component
    }
}
