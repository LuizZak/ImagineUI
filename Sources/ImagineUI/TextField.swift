import Foundation
import QuartzCore
import Geometry
import Text
import SwiftBlend2D
import Rendering

open class TextField: ControlView {
    private let _blinker = CursorBlinker()
    private var _label: Label
    private var _labelContainer = View()
    private var _placeholderLabel = Label()
    private var _textEngine: TextEngine
    private let _statesStyles = StatedValueStore<TextFieldVisualStyleParameters>()
    private var _onFixedFrameSubscription: EventListenerKey?

    // TODO: Collapse these into an external handler or into Combine to lower
    // the state clutter here

    private var _lastMouseDown: TimeInterval = 0
    private var _lastMouseDownPoint: Vector2 = .zero
    private var _selectingWordSpan: Bool = false
    private var _wordSpanStartPosition: Int = 0
    private var _mouseDown = false
    
    /// Event fired whenever the text contents of this text field are updated.
    ///
    /// This event is not raised if a client sets this text field's `text` property
    /// directly.
    @Event public var textChanged: EventSourceWithSender<TextField, TextFieldTextChangedEventArgs>
    
    /// Event fired whenever the caret for this text field changes position or
    /// selection range
    @Event public var caretChanged: ValueChangeEvent<TextField, Caret>
    
    /// Event fired whenever the user presses down the Enter key while
    /// `acceptsEnterKey` is true
    @Event public var enterKey: EventSourceWithSender<TextField, Void>

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
    
    /// Gets or sets the text of this textfield.
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
    
    /// An optional placeholder text which is printed when the textfield's
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
    /// paceholder labels
    open var horizontalTextAlignment: HorizontalTextAlignment = .leading {
        didSet {
            _label.horizontalTextAlignment = horizontalTextAlignment
            _placeholderLabel.horizontalTextAlignment = horizontalTextAlignment
        }
    }
    
    /// Gets or sets the caret position for this textfield.
    open var caret: Caret {
        get { _textEngine.caret }
        set { _textEngine.setCaret(newValue) }
    }

    open var contentInset: EdgeInsets = EdgeInsets(4) {
        didSet {
            setNeedsLayout()
            invalidate()
        }
    }

    /// Gets the current active style for this textfield.
    public private(set) var style: TextFieldVisualStyleParameters = TextFieldVisualStyleParameters()

    open override var canBecomeFirstResponder: Bool { isEnabled }

    public override init() {
        let label = Label()
        let buffer = LabelViewTextBuffer(label: label)
        _textEngine = TextEngine(textBuffer: buffer)
        self._label = label
        
        super.init()
        
        isEnabled = true
        
        buffer.changed.addListener(owner: self) { [weak self] in
            self?.textBufferOnChanged()
        }
        
        for (state, style) in TextFieldVisualStyleParameters.defaultDarkStyle() {
            setStyle(style, forState: state)
        }
        
        initialize()
    }

    private func initialize() {
        _textEngine.caretChanged.addListener(owner: self) { [weak self] (_, event) in
            guard let self = self else { return }
            
            self.invalidateCaret(at: event.newValue.location)
            self.invalidateCaret(at: event.oldValue.location)
            self.invalidate(bounds: self.getSelectionBounds(caret: event.oldValue))
            self.invalidate(bounds: self.getSelectionBounds(caret: event.newValue))

            self._blinker.restart()

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

        _blinker.blinkInterval = 1

        addSubview(_labelContainer)
    }

    // MARK: - Events
    private func textBufferOnChanged() {
        _blinker.restart()
        
        onTextChanged()
        
        updateLabelSize()

        updatePlaceholderVisibility()
        scrollLabel()
    }
    
    /// Raises the `textChanged` event
    open func onTextChanged() {
        _textChanged.publishEvent(sender: self, TextFieldTextChangedEventArgs(text: text))
    }

    /// Raises the `caretChanged` event
    open func onCaretChanged(_ event: ValueChangedEventArgs<Caret>) {
        _caretChanged.publishEvent(sender: self, event)
    }
    
    open override func onResize(_ event: ValueChangedEventArgs<Size>) {
        super.onResize(event)
        
        updateLabelAndPlaceholder()
        scrollLabel()
    }

    open override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        let style = getStyle(forState: event.newValue)
        applyStyle(style)
    }

    internal func onFixedFrame(interval: TimeInterval) {
        if isFirstResponder && _blinker.checkBlinkerStateChange() {
            invalidateControlGraphics(bounds: getCaretBounds())
        }
    }

    // MARK: - Visual Style Settings

    /// Sets the visual style of this text field when it's under a given view
    /// state.
    open func setStyle(_ style: TextFieldVisualStyleParameters, forState state: ControlViewState) {
        _statesStyles.setValue(style, forState: state)

        if currentState == state {
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
    open func getStyle(forState state: ControlViewState) -> TextFieldVisualStyleParameters {
        return _statesStyles.getValue(state, defaultValue: TextFieldVisualStyleParameters())
    }

    private func applyStyle(_ style: TextFieldVisualStyleParameters) {
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
        _blinker.restart()

        let offset = offsetUnder(point: event.location)
        _textEngine.setCaret(offset)

        if _lastMouseDownPoint.distance(to: event.location) < 10 && CACurrentMediaTime() - _lastMouseDown < 1 {
            _wordSpanStartPosition = offset

            let segment = _textEngine.wordSegmentIn(position: _wordSpanStartPosition)
            _textEngine.setCaret(segment)

            _selectingWordSpan = true
        }
        
        _lastMouseDownPoint = event.location
        _lastMouseDown = CACurrentMediaTime()
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

        _blinker.restart()

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

        if event.modifiers.contains(.command) {
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
                if event.modifiers == (KeyboardModifier.command.union(.shift)) {
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
                _enterKey.publishEvent(sender: self)
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

    @discardableResult
    private func handleCaretMoveEvent(_ keyCode: Keys, _ modifiers: KeyboardModifier) -> Bool {
        if modifiers.contains(.shift) {
            if modifiers.contains(.option) {
                if keyCode == .left {
                    _textEngine.selectLeftWord()
                    return true
                }
                if keyCode == .right {
                    _textEngine.selectRightWord()
                    return true
                }
            } else if modifiers.contains(.command) {
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
            if modifiers.contains(.option) {
                if keyCode == .left {
                    _textEngine.moveLeftWord()
                    return true
                }
                if keyCode == .right {
                    _textEngine.moveRightWord()
                    return true
                }
            } else if modifiers.contains(.command) {
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
        let charBounds = characterBounds.reduce(characterBounds[0], Rectangle.union)
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

    private func invalidateCaret(at offset: Int) {
        invalidateControlGraphics(bounds: getCaretBounds(at: offset))
    }
    
    private func getCaretBounds() -> Rectangle {
        return getCaretBounds(at: caret.location)
    }
    
    private func getCaretBounds(at offset: Int) -> Rectangle {
        let font = _label.textLayout.font(atLocation: offset)
        var caretLocation = Rectangle(x: 0, y: 0, width: 1, height: Double(font.metrics.ascent + font.metrics.descent))

        var location = _label.textLayout.locationOfCharacter(index: offset)
        location = _label.convert(point: location, to: self)

        caretLocation = caretLocation.withLocation(location)

        return caretLocation
    }
    
    private func getSelectionBounds() -> Rectangle {
        return getSelectionBounds(caret: caret)
    }

    private func getSelectionBounds(caret: Caret) -> Rectangle {
        if caret.length == 0 {
            return getCaretBounds(at: caret.location)
        }

        let characterBounds = _label.textLayout.boundsForCharacters(in: caret.textRange)
        if characterBounds.count == 0 {
            return .zero
        }

        let charBounds = characterBounds.reduce(characterBounds[0], Rectangle.union)
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

        if firstResponder {
            _blinker.restart()
        }
        
        if let old = _onFixedFrameSubscription {
            Scheduler.instance.fixedFrameEvent.removeListener(withKey: old)
        }
        
        _onFixedFrameSubscription = Scheduler.instance.fixedFrameEvent.addListener(owner: self) { [weak self] interval in
            self?.onFixedFrame(interval: interval)
        }

        return firstResponder
    }

    open override func resignFirstResponder() {
        super.resignFirstResponder()

        invalidate()
        
        if let old = _onFixedFrameSubscription {
            Scheduler.instance.fixedFrameEvent.removeListener(withKey: old)
            _onFixedFrameSubscription = nil
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
                labelOffset = labelOffset - Vector2(x: locInContainer.x - _labelContainer.bounds.width, y: 0)
            } else {
                labelOffset = labelOffset - Vector2(x: locInContainer.x, y: 0)
            }
        }
    }

    open override func performLayout() {
        super.performLayout()

        updateLabelAndPlaceholder()
    }
    
    private func updateLabelAndPlaceholder() {
        suspendLayout()
                
        let insetBounds = contentInset.inset(rectangle: bounds)
        _labelContainer.location = insetBounds.topLeft
        _labelContainer.bounds.size = insetBounds.size
        
        // Currently, setting location.y individually causes a runtime crash
        _label.location = Vector2(x: _label.location.x, y: _labelContainer.bounds.height / 2 - _label.bounds.height / 2)
        
        _label.bounds.width = max(_label.bounds.width, _labelContainer.bounds.width)
        
        _placeholderLabel.location = _label.location
        _placeholderLabel.bounds.width = max(_placeholderLabel.bounds.width, _labelContainer.bounds.width)
        
        resumeLayout(setNeedsLayout: false)
    }
    
    private func updateLabelSize() {
        _label.autoSize()
        _label.bounds.width = max(_label.bounds.width, _labelContainer.bounds.width)
    }

    /// Selects the entire text available on this text field
    public func selectAll() {
        _textEngine.selectAll()
    }

    /// Clears all undo/redo history for this textfield.
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
    private func offsetUnder(point: Vector2) -> Int {
        let converted = _label.convert(point: point, from: self)
        
        let result = _label.textLayout.hitTestPoint(converted)
        let offset = result.textPosition + (result.isTrailing ? 1 : 0)
        
        return min(offset, _label.text.count)
    }

    /// Returns the point for a given string offset, locally on this text
    /// field's coordinates.
    private func locationForOffset(_ offset: Int) -> Vector2 {
        var position = _label.textLayout.locationOfCharacter(index: offset)
        
        position = _label.convert(point: position, to: self)
        
        return position
    }
    
    private func isValidInputCharacter(_ event: KeyEventArgs) -> Bool {
        if event.modifiers.contains(.numericPad) {
            return false
        }
        
        return true
    }
}

public struct TextFieldTextChangedEventArgs {
    public var text: String
}

/// A small class to handle cursor blinker timer
private class CursorBlinker {
    private var _blinkStart: TimeInterval

    public var lastBlinkState: Double = 0

    /// Blink interval; time going from fully opaque to transparent, right up to
    /// before the cursor goes fully opaque again.
    public var blinkInterval: TimeInterval = 1

    /// Cursor blink state, from 0 to 1.
    ///
    /// 0 is fully transparent, and 1 is fully opaque.
    public var blinkState: Double { getBlinkState() }

    public init() {
        _blinkStart = CACurrentMediaTime()
    }

    public func restart() {
        lastBlinkState = 0
        _blinkStart = CACurrentMediaTime()
    }

    /// Check that since the last time this method was invoked, that the blinker
    /// state has changed.
    public func checkBlinkerStateChange() -> Bool {
        defer { lastBlinkState = getBlinkState() }
        return lastBlinkState != getBlinkState()
    }

    private func getBlinkState() -> Double {
        let current = CACurrentMediaTime()
        let elapsed = current - _blinkStart
        let state = elapsed.truncatingRemainder(dividingBy: blinkInterval)
        
        if state < blinkInterval / 2 {
            return 1.0
        }

        return 0
    }
}

private class LabelViewTextBuffer: TextEngineTextualBuffer {
    private let label: Label

    public var textLength: Int { label.text.count }

    @Event public var changed: EventSource<Void>

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
        _changed.publishEvent()
    }

    public func insert(at index: Int, _ text: String) {
        let index = label.text.index(label.text.startIndex, offsetBy: index)

        label.text.insert(contentsOf: text, at: index)
        _changed.publishEvent()
    }

    public func append(_ text: String) {
        label.text += text
        _changed.publishEvent()
    }

    public func replace(at index: Int, length: Int, _ text: String) {
        let start = label.text.index(label.text.startIndex, offsetBy: index)
        let end = label.text.index(start, offsetBy: length)

        label.text.removeSubrange(start..<end)
        label.text.insert(contentsOf: text, at: start)

        _changed.publishEvent()
    }
}

/// Specifies the presentation style for a text field.
///
/// Used to specify separate visual styles depending on the first-responding
/// state of the textfield.
public struct TextFieldVisualStyleParameters {
    public var textColor: Color = .black
    public var placeholderTextColor: Color = .black
    public var backgroundColor: Color = .white
    public var strokeColor: Color = .black
    public var strokeWidth: Double = 0
    public var caretColor: Color = .black
    public var selectionColor: Color = .black
    
    public init(textColor: Color = .black,
                placeholderTextColor: Color = .black,
                backgroundColor: Color = .white,
                strokeColor: Color = .black,
                strokeWidth: Double = 0,
                caretColor: Color = .black,
                selectionColor: Color = .black) {
        
        self.textColor = textColor
        self.placeholderTextColor = placeholderTextColor
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.caretColor = caretColor
        self.selectionColor = selectionColor
    }

    public static func defaultDarkStyle() -> [ControlViewState: TextFieldVisualStyleParameters] {
        return [
            .disabled:
                TextFieldVisualStyleParameters(
                    textColor: .gray,
                    placeholderTextColor: .dimGray,
                    backgroundColor: Color(red: 40, green: 40, blue: 40),
                    strokeColor: .transparentBlack,
                    strokeWidth: 0,
                    caretColor: .white,
                    selectionColor: .slateGray),
            
            .normal:
                TextFieldVisualStyleParameters(
                    textColor: .white,
                    placeholderTextColor: .dimGray,
                    backgroundColor: .black,
                    strokeColor: Color(alpha: 255, red: 50, green: 50, blue: 50),
                    strokeWidth: 1,
                    caretColor: .white,
                    selectionColor: .slateGray),
            
            .focused:
                TextFieldVisualStyleParameters(
                    textColor: .white,
                    placeholderTextColor: .dimGray,
                    backgroundColor: .black,
                    strokeColor: .cornflowerBlue,
                    strokeWidth: 1,
                    caretColor: .white,
                    selectionColor: .steelBlue)
        ]
    }

    public static func defaultLightStyle() -> [ControlViewState: TextFieldVisualStyleParameters] {
        return [
            .normal:
                TextFieldVisualStyleParameters(
                    textColor: .black,
                    placeholderTextColor: .gray,
                    backgroundColor: .white /* TODO: Should be KnownColor.Control */,
                    strokeColor: .black,
                    strokeWidth: 1,
                    caretColor: .black,
                    selectionColor: .lightBlue)
        ]
    }
}
