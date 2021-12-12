import Foundation
import Geometry
import Text
import Rendering

// import QuartzCore

open class TextField: ControlView {
    private let _blinker = CursorBlinker()
    private var _label: Label
    private var _labelContainer = View()
    private var _placeholderLabel = Label(textColor: .white)
    private var _textEngine: TextEngine
    private let _statesStyles = StatedValueStore<VisualStyle>()
    private var _cursorBlinkTimer: SchedulerTimerType?

    // TODO: Collapse these into an external handler or into Combine to lower
    // TODO: the state clutter here

    private var _selectingWordSpan: Bool = false
    private var _wordSpanStartPosition: Int = 0
    private var _mouseDown = false
    // TODO: Make double clicking be handled by `DefaultControlSystem`.
    private var _lastMouseDown: TimeInterval = 0
    private var _lastMouseDownPoint: UIVector = .zero

    /// Event fired whenever the text contents of this text field are updated.
    ///
    /// This event is not raised if a client sets this text field's `text` property
    /// directly.
    @EventWithSender<TextField, TextFieldTextChangedEventArgs>
    public var textChanged

    /// Event fired whenever the caret for this text field changes position or
    /// selection range.
    @ValueChangedEventWithSender<TextField, Caret>
    public var caretChanged

    /// Event fired whenever the user presses down the Enter key while
    /// `acceptsEnterKey` is true.
    @EventWithSender<TextField, Void>
    public var enterKey

    open var textColor: Color {
        get { _label.textColor }
        set { _label.textColor = newValue }
    }

    /// If true, when the enter key is pressed an `EnterKey` event is raised for
    /// this text field.
    open var acceptsEnterKey: Bool = false

    /// Whether to allow line breaks when pressing the enter key.
    open var allowLineBreaks: Bool = false

    /// Gets or sets a value specifying whether the string contents of this
    /// `TextField` are editable.
    open var editable: Bool = true {
        didSet {
            if !editable && isFirstResponder {
                resignFirstResponder()
            }
        }
    }

    /// Gets or sets the text of this text field.
    ///
    /// As keyboard input is received, this value is updated accordingly.
    open var text: String {
        get { _label.text }
        set {
            _label.text = newValue
            updateLabelSize()
            _textEngine.updateCaretFromTextBuffer()
            updatePlaceholderVisibility()
            setNeedsLayout()
        }
    }

    /// An optional placeholder text which is printed when the text field's
    /// contents are empty.
    open var placeholderText: String? {
        get { _placeholderLabel.text.isEmpty ? nil : _placeholderLabel.text }
        set {
            _placeholderLabel.text = newValue ?? ""
            _placeholderLabel.autoSize()
            setNeedsLayout()
            invalidate()
        }
    }

    /// Gets or sets the horizontal text alignment for both the input text and
    /// placeholder labels
    open var horizontalTextAlignment: HorizontalTextAlignment = .leading {
        didSet {
            _label.horizontalTextAlignment = horizontalTextAlignment
            _placeholderLabel.horizontalTextAlignment = horizontalTextAlignment
        }
    }

    /// Gets or sets the caret position for this text field.
    open var caret: Caret {
        get { _textEngine.caret }
        set { _textEngine.setCaret(newValue) }
    }

    open var contentInset: UIEdgeInsets = UIEdgeInsets(4) {
        didSet {
            setNeedsLayout()
            invalidate()
        }
    }

    /// Gets the current active style for this text field.
    public private(set) var style: VisualStyle = VisualStyle()

    open override var canBecomeFirstResponder: Bool { isEnabled }

    public override init() {
        let label = Label(textColor: .white)
        let buffer = LabelViewTextBuffer(label: label)
        _textEngine = TextEngine(textBuffer: buffer)
        self._label = label

        super.init()

        isEnabled = true

        buffer.changed.addListener(weakOwner: self) { [weak self] in
            self?.textBufferOnChanged()
        }

        for (state, style) in VisualStyle.defaultDarkStyle() {
            setStyle(style, forState: state)
        }

        initialize()
    }

    private func initialize() {
        _textEngine.caretChanged.addListener(weakOwner: self) { [weak self] (_, event) in
            guard let self = self else { return }

            self.invalidateCaret(at: event.newValue.location)
            self.invalidateCaret(at: event.oldValue.location)
            self.invalidate(bounds: self.getSelectionBounds(caret: event.oldValue))
            self.invalidate(bounds: self.getSelectionBounds(caret: event.newValue))

            self.restartBlinkerTimer()

            self.scrollLabel()

            self.onCaretChanged(event)
        }

        _labelContainer.isInteractiveEnabled = false
        _labelContainer.addSubview(_label)
        _labelContainer.addSubview(_placeholderLabel)

        _label.font = Fonts.defaultFont(size: 11)
        _label.suspendLayout()
        _label.textColor = style.textColor
        _label.verticalTextAlignment = .center

        _placeholderLabel.font = Fonts.defaultFont(size: 11)
        _placeholderLabel.suspendLayout()
        _placeholderLabel.textColor = style.placeholderTextColor
        _placeholderLabel.verticalTextAlignment = .center

        addSubview(_labelContainer)
    }

    // MARK: - Events
    private func textBufferOnChanged() {
        restartBlinkerTimer()

        onTextChanged()

        updateLabelSize()

        updatePlaceholderVisibility()
        scrollLabel()
    }

    /// Raises the `textChanged` event
    open func onTextChanged() {
        _textChanged(sender: self, TextFieldTextChangedEventArgs(text: text))
    }

    /// Raises the `caretChanged` event
    open func onCaretChanged(_ event: ValueChangedEventArgs<Caret>) {
        _caretChanged(sender: self, event)
    }

    open override func onResize(_ event: ValueChangedEventArgs<UISize>) {
        super.onResize(event)

        updateLabelAndPlaceholder()
        scrollLabel()
    }

    open override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        let style = getStyle(forState: event.newValue)
        applyStyle(style)
    }

    // MARK: - Visual Style Settings

    /// Sets the visual style of this text field when it's under a given view
    /// state.
    open func setStyle(_ style: VisualStyle, forState state: ControlViewState) {
        _statesStyles.setValue(style, forState: state)

        if controlState == state {
            applyStyle(style)
        }
    }

    /// Removes the special style for a given control view state.
    ///
    /// Note that `ControlViewState.normal` styles are the default styles and
    /// cannot be removed.
    open func removeStyle(forState state: ControlViewState) {
        if state == .normal {
            return
        }

        _statesStyles.removeValueForState(state)
    }

    /// Gets the visual style for a given state.
    ///
    /// If no custom visual style is specified for the state, the normal state
    /// style is returned instead.
    open func getStyle(forState state: ControlViewState) -> VisualStyle {
        return _statesStyles.getValue(state, defaultValue: VisualStyle())
    }

    private func applyStyle(_ style: VisualStyle) {
        self.style = style

        foreColor = style.textColor
        strokeWidth = style.strokeWidth
        strokeColor = style.strokeColor
        backColor = style.backgroundColor

        _label.textColor = style.textColor
        _placeholderLabel.textColor = style.placeholderTextColor

        invalidate()
    }

    // MARK: - Mouse Handlers

    open override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        if !becomeFirstResponder() {
            return
        }

        _mouseDown = true
        restartBlinkerTimer()

        let offset = offsetUnder(point: event.location)
        _textEngine.setCaret(offset)

        if _lastMouseDownPoint.distance(to: event.location) < 10 && UISettings.timeInSeconds() - _lastMouseDown < 1 {
            _wordSpanStartPosition = offset

            let segment = _textEngine.wordSegmentIn(position: _wordSpanStartPosition)
            _textEngine.setCaret(segment)

            _selectingWordSpan = true
        }

        _lastMouseDownPoint = event.location
        _lastMouseDown = UISettings.timeInSeconds()
    }

    open override func onMouseEnter() {
        super.onMouseEnter()

        if canBecomeFirstResponder {
            controlSystem?.setMouseCursor(.iBeam)
        }

        invalidate()
    }

    open override func onMouseLeave() {
        super.onMouseLeave()

        if canBecomeFirstResponder {
            controlSystem?.setMouseCursor(.arrow)
        }

        invalidate()
    }

    open override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        if !_mouseDown {
            return
        }

        restartBlinkerTimer()

        let offset = offsetUnder(point: event.location)
        if _selectingWordSpan {
            let original = _textEngine.wordSegmentIn(position: _wordSpanStartPosition)
            let newSeg = _textEngine.wordSegmentIn(position: offset)

            _textEngine.setCaret(original.union(newSeg), position: offset <= _wordSpanStartPosition ? .start : .end)
        } else {
            _textEngine.moveCaretSelecting(offset)
        }
    }

    open override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        _mouseDown = false
        _selectingWordSpan = false
    }

    // MARK: - Keyboard

    open override func onKeyDown(_ event: KeyEventArgs) {
        super.onKeyDown(event)

        controlSystem?.setMouseHiddenUntilMouseMoves()

        if event.handled { return }

        if event.modifiers.contains(.osControlKey) {
            switch event.keyCode {
            case .c:
                copy()
                return

            case .x where editable:
                cut()
                return

            case .v where editable:
                paste()
                return

            case .z where editable:
                // Ctrl+Shift+Z as alternative for Ctrl+Y (redo)
                if event.modifiers == (KeyboardModifier.osControlKey.union(.shift)) {
                    redo()
                    return
                }

                undo()
                return

            case .y where editable:
                redo()
                return

            case .a:
                selectAll()
                return

            default:
                break
            }
        }

        if event.keyCode == Keys.enter {
            if acceptsEnterKey {
                _enterKey(sender: self)
            }
            return
        }

        if handleCaretMoveEvent(event.keyCode, event.modifiers) {
            return
        }

        if !editable {
            return
        }

        if event.keyCode == .back {
            _textEngine.backspaceText()
            return
        }
        if event.keyCode == .delete {
            _textEngine.deleteText()
            return
        }

        if let string = event.keyChar, isValidInputCharacter(event) {
            _textEngine.insertText(string)
        }
    }

    open override func onKeyPress(_ event: KeyPressEventArgs) {
        super.onKeyPress(event)

        controlSystem?.setMouseHiddenUntilMouseMoves()

        if event.handled { return }

        if event.modifiers.contains(.osControlKey) {
            switch event.keyChar {
            case "c", "C":
                copy()
                return

            case "x" where editable,
                 "X" where editable:
                cut()
                return

            case "v" where editable,
                 "V" where editable:
                paste()
                return

            case "z" where editable,
                 "Z" where editable:
                // Ctrl+Shift+Z as alternative for Ctrl+Y (redo)
                if event.modifiers == (KeyboardModifier.osControlKey.union(.shift)) {
                    redo()
                    return
                }

                undo()
                return

            case "y" where editable,
                 "Y" where editable:
                redo()
                return

            case "a", "A":
                selectAll()
                return

            default:
                break
            }
        }

        if !editable {
            return
        }

        if isValidInputCharacter(event) {
            _textEngine.insertText(event.keyChar.description)
        }
    }

    @discardableResult
    private func handleCaretMoveEvent(_ keyCode: Keys, _ modifiers: KeyboardModifier) -> Bool {
        // TODO: Support wrapping calls to TextEngine.move- methods to do selection
        // TODO: to allow reduction of copy-paste here.

        #if os(macOS)

        // macOS text navigation

        if modifiers.contains(KeyMap.selectModifier) {
            if modifiers.contains(KeyMap.wordMoveModifier) {
                if keyCode == .left {
                    _textEngine.selectLeftWord()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectRightWord()
                    return true
                }
            } else if modifiers.contains(.osControlKey) {
                if keyCode == .left {
                    _textEngine.selectToStart()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectToEnd()
                    return true
                }
            } else {
                if keyCode == .left {
                    _textEngine.selectLeft()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectRight()
                    return true
                }
            }
        } else {
            if modifiers.contains(KeyMap.wordMoveModifier) {
                if keyCode == .left {
                    _textEngine.moveLeftWord()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveRightWord()
                    return true
                }
            } else if modifiers.contains(.osControlKey) {
                if keyCode == .left {
                    _textEngine.moveToStart()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveToEnd()
                    return true
                }
            } else {
                if keyCode == .left {
                    _textEngine.moveLeft()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveRight()
                    return true
                }
            }
        }

        #else

        // Windows-like text navigation

        if modifiers.contains(KeyMap.selectModifier) {
            if modifiers.contains(KeyMap.wordMoveModifier) {
                if keyCode == .left {
                    _textEngine.selectLeftWord()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectRightWord()
                    return true
                }
            } else if modifiers.contains(.osControlKey) {
                if keyCode == .left {
                    _textEngine.selectToStart()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectToEnd()
                    return true
                }
            } else {
                if keyCode == .left {
                    _textEngine.selectLeft()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectRight()
                    return true
                }
            }
        } else {
            if modifiers.contains(KeyMap.wordMoveModifier) {
                if keyCode == .left {
                    _textEngine.moveLeftWord()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveRightWord()
                    return true
                }
            } else if modifiers.contains(.osControlKey) {
                if keyCode == .left {
                    _textEngine.moveToStart()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveToEnd()
                    return true
                }
            } else {
                if keyCode == .left {
                    _textEngine.moveLeft()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveRight()
                    return true
                }
            }
        }

        #endif

        return false
    }

    // MARK: - Rendering

    open override func renderBackground(in renderer: Renderer, screenRegion: ClipRegion) {
        super.renderBackground(in: renderer, screenRegion: screenRegion)

        renderSelection(in: renderer)
    }

    open override func renderForeground(in renderer: Renderer, screenRegion: ClipRegion) {
        super.renderForeground(in: renderer, screenRegion: screenRegion)

        if isFirstResponder {
            renderCaret(in: renderer)
        }
    }

    private func renderSelection(in renderer: Renderer) {
        // Draw selected region
        guard caret.length > 0 && !style.selectionColor.isTransparent else {
            return
        }

        let characterBounds = _label.textLayout.boundsForCharacters(in: caret.textRange)
        if characterBounds.count == 0 {
            return
        }

        renderer.setFill(style.selectionColor)

        // TODO: Support selection backgrounds that span different lines
        let charBounds = characterBounds.reduce(characterBounds[0], UIRectangle.union)
        let transformed = _label.convert(bounds: charBounds, to: self)

        renderer.saveState()
        renderer.clip(_labelContainer.area)
        renderer.fill(transformed)
        renderer.restoreState()
    }

    private func renderCaret(in renderer: Renderer) {
        let transparency = _blinker.blinkState

        if transparency <= 0 {
            return
        }

        let caretBounds = getCaretBounds()

        renderer.setFill(style.caretColor.withTransparency(Int(transparency * 255)))
        renderer.fill(caretBounds)
    }

    private func invalidateCaret() {
        invalidateControlGraphics(bounds: getCaretBounds().roundedToLargest())
    }

    private func invalidateCaret(at offset: Int) {
        invalidateControlGraphics(bounds: getCaretBounds(at: offset).roundedToLargest())
    }

    private func getCaretBounds() -> UIRectangle {
        return getCaretBounds(at: caret.location)
    }

    private func getCaretBounds(at offset: Int) -> UIRectangle {
        let font = _label.textLayout.font(atLocation: offset)
        var caretLocation = UIRectangle(x: 0, y: 0, width: 1, height: Double(font.metrics.ascent + font.metrics.descent))

        var location = _label.textLayout.locationOfCharacter(index: offset)
        location = _label.convert(point: location, to: self)

        caretLocation = caretLocation.withLocation(location)

        return caretLocation
    }

    private func getSelectionBounds() -> UIRectangle {
        return getSelectionBounds(caret: caret)
    }

    private func getSelectionBounds(caret: Caret) -> UIRectangle {
        if caret.length == 0 {
            return getCaretBounds(at: caret.location)
        }

        let characterBounds = _label.textLayout.boundsForCharacters(in: caret.textRange)
        if characterBounds.count == 0 {
            return .zero
        }

        let charBounds = characterBounds.reduce(characterBounds[0], UIRectangle.union)
        let transformed = _label.convert(bounds: charBounds, to: self)

        return transformed
    }

    // MARK: -

    open override func canHandle(_ eventRequest: EventRequest) -> Bool {
        if eventRequest is KeyboardEventRequest {
            return true
        }

        return super.canHandle(eventRequest)
    }

    // MARK: - First responder status

    open override func becomeFirstResponder() -> Bool {
        if isFirstResponder {
            return true
        }

        let firstResponder = super.becomeFirstResponder()
        restartBlinkerTimer()

        return firstResponder
    }

    open override func resignFirstResponder() {
        super.resignFirstResponder()

        invalidate()

        if let timer = _cursorBlinkTimer {
            timer.invalidate()
            _cursorBlinkTimer = nil
        }
    }

    private func restartBlinkerTimer() {
        _blinker.restart()
        _cursorBlinkTimer?.invalidate()

        // Store the current time before firing the blinker timer to avoid
        // immediately firing the timer in platforms with flaky RunLoop
        // implementations
        let started = UISettings.timeInSeconds()
        _cursorBlinkTimer = Scheduler.instance.scheduleTimer(interval: _blinker.blinkInterval, repeats: true) { [weak self] in
            guard let self = self else { return }
            guard UISettings.timeInSeconds() - started >= self._blinker.blinkInterval / 2 else { return }

            self._blinker.flipBlinkerState()
            self.invalidateCaret()
        }
    }

    // MARK: - Layout

    private func scrollLabel() {
        let loc = locationForOffset(caret.location)

        var labelOffset = _label.location
        defer { _label.location = labelOffset }

        if _label.bounds.width > _labelContainer.bounds.width {
            if labelOffset.x + _label.bounds.width < _labelContainer.bounds.right {
                labelOffset.x = _labelContainer.bounds.right - _label.bounds.width
            }
        } else {
            labelOffset.x = 0
        }

        var locInContainer = _labelContainer.convert(point: loc, from: self)
        locInContainer.y = 0

        if !_labelContainer.contains(point: locInContainer) {
            if locInContainer.x > _labelContainer.bounds.width {
                labelOffset = labelOffset - UIVector(x: locInContainer.x - _labelContainer.bounds.width, y: 0)
            } else {
                labelOffset = labelOffset - UIVector(x: locInContainer.x, y: 0)
            }
        }
    }

    open override func performLayout() {
        super.performLayout()

        updateLabelAndPlaceholder()
    }

    private func updateLabelAndPlaceholder() {
        withSuspendedLayout(setNeedsLayout: false) {
            let insetBounds = contentInset.inset(rectangle: bounds)
            _labelContainer.location = insetBounds.topLeft
            _labelContainer.bounds.size = insetBounds.size

            // Currently, setting location.y individually causes a runtime crash
            _label.location = UIVector(x: _label.location.x, y: _labelContainer.bounds.height / 2 - _label.bounds.height / 2)

            _label.bounds.width = max(_label.bounds.width, _labelContainer.bounds.width)

            _placeholderLabel.location = _label.location
            _placeholderLabel.bounds.width = max(_placeholderLabel.bounds.width, _labelContainer.bounds.width)
        }
    }

    private func updateLabelSize() {
        _label.autoSize()
        _label.bounds.width = max(_label.bounds.width, _labelContainer.bounds.width)
    }

    /// Selects the entire text available on this text field
    public func selectAll() {
        _textEngine.selectAll()
    }

    /// Clears all undo/redo history for this text field.
    public func clearUndo() {
        _textEngine.clearUndo()
    }

    /// Updates the text buffer to a specified string while recording an undo
    /// for the action.
    ///
    /// To the text engine, this is essentially the same as selecting all text
    /// and replacing with the given string.
    public func setTextWithUndo(_ empty: String) {
        _textEngine.selectAll()
        _textEngine.insertText(empty)
    }

    // MARK: - Copy/cut/paste + undo/redo

    private func copy() {
        _textEngine.copy()
    }

    private func cut() {
        _textEngine.cut()
    }

    private func paste() {
        _textEngine.paste()
    }

    private func undo() {
        _textEngine.undoSystem.undo()
    }

    private func redo() {
        _textEngine.undoSystem.redo()
    }

    // MARK: -
    private func updatePlaceholderVisibility() {
        _placeholderLabel.isVisible = text.isEmpty
    }

    // MARK: - Text Location

    /// Returns string offset at a given point on this text field.
    private func offsetUnder(point: UIVector) -> Int {
        let converted = _label.convert(point: point, from: self)

        let result = _label.textLayout.hitTestPoint(converted)
        let offset = result.textPosition + (result.isTrailing ? 1 : 0)

        return min(offset, _label.text.count)
    }

    /// Returns the point for a given string offset, locally on this text
    /// field's coordinates.
    private func locationForOffset(_ offset: Int) -> UIVector {
        var position = _label.textLayout.locationOfCharacter(index: offset)

        position = _label.convert(point: position, to: self)

        return position
    }

    private func isValidInputCharacter(_ event: KeyEventArgs) -> Bool {
        #if os(macOS)

        if event.modifiers.contains(.numericPad) {
            return false
        }

        #endif

        return true
    }

    private func isValidInputCharacter(_ event: KeyPressEventArgs) -> Bool {
        #if os(macOS)

        if event.modifiers.contains(.numericPad) {
            return false
        }

        #endif

        return true
    }
}

public struct TextFieldTextChangedEventArgs {
    public var text: String
}

/// A small class to handle cursor blinker timer
private class CursorBlinker {
    /// Blink interval; time going from fully opaque to transparent.
    public var blinkInterval: TimeInterval = 0.5

    /// Cursor blink state, from 0 to 1.
    ///
    /// 0 is fully transparent, and 1 is fully opaque.
    public var blinkState: Double

    public init() {
        blinkState = 1
    }

    public func restart() {
        blinkState = 1
    }

    public func flipBlinkerState() {
        if blinkState == 0 {
            blinkState = 1
        } else {
            blinkState = 0
        }
    }
}

private class LabelViewTextBuffer: TextEngineTextualBuffer {
    private let label: Label

    public var textLength: Int { label.text.count }

    @Event<Void> public var changed

    public init(label: Label) {
        self.label = label
    }

    public func textInRange(_ range: TextRange) -> Substring {
        let start = label.text.index(label.text.startIndex, offsetBy: range.start)
        let end = label.text.index(label.text.startIndex, offsetBy: range.end)

        return label.text[start..<end]
    }

    public func character(at offset: Int) -> Character {
        let offset = label.text.index(label.text.startIndex, offsetBy: offset)

        return label.text[offset]
    }

    public func delete(at index: Int, length: Int) {
        let start = label.text.index(label.text.startIndex, offsetBy: index)
        let end = label.text.index(start, offsetBy: length)

        label.text.removeSubrange(start..<end)
        _changed()
    }

    public func insert(at index: Int, _ text: String) {
        let index = label.text.index(label.text.startIndex, offsetBy: index)

        label.text.insert(contentsOf: text, at: index)
        _changed()
    }

    public func append(_ text: String) {
        label.text += text
        _changed()
    }

    public func replace(at index: Int, length: Int, _ text: String) {
        let start = label.text.index(label.text.startIndex, offsetBy: index)
        let end = label.text.index(start, offsetBy: length)

        label.text.removeSubrange(start..<end)
        label.text.insert(contentsOf: text, at: start)

        _changed()
    }
}
