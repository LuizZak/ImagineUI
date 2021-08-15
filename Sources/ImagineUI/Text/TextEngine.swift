import Foundation
import Text

/// A text + caret engine that handles manipulation of strings by insertion/removal
/// of strings at locations that can be specified via a caret position.
///
/// Base text input engine backing for `TextField`'s.
class TextEngine: TextEngineType {
    /// Whenever sequential characters are input into the text engine via `InsertText`,
    /// this undo run is incremented so the undo operation for these operations
    /// occur as one single undo for multiple characters.
    private var _currentInputUndoRun: TextInsertUndo?
    
    /// When undoing/redoing work with `_undoSystem`, this flag is temporarily
    /// set to true so no undo tasks are accidentally registered while another
    /// undo task performs changes to this text engine.
    private var _isPerformingUndoRedo: Bool = false
    
    private let _undoSystem: UndoSystem

    /// Event fired whenever the current `caret` value is changed.
    @Event public var caretChanged: ValueChangeEvent<TextEngine, Caret>
    
    /// Gets the internal undo system that this text engine records undo and
    /// redo operations in
    public var undoSystem: UndoSystemType { _undoSystem }
    
    /// The text buffer that receives instructions to add/remove/replace text
    /// based on caret inputs handled by this text engine.
    public let textBuffer: TextEngineTextualBuffer
    
    /// Gets the text clipboard for this text engine to use during Copy/Cut/Paste
    /// operations.
    ///
    /// Defaults to an operating system-based clipboard handler, but can be
    /// replaced at any time with any other implementation.
    public var textClipboard: TextClipboard = GlobalTextClipboard()

    /// Gets the caret range.
    ///
    /// To change the caret range, use one of the `SetCaret` methods.
    public private(set) var caret = Caret(range: TextRange(start: 0, length: 0),
                                          position: .start)
    
    public init(textBuffer: TextEngineTextualBuffer) {
        self.textBuffer = textBuffer
        
        _undoSystem = UndoSystem()
        _undoSystem.maximumTaskCount = 30

        _undoSystem.willPerformUndo.addListener(owner: self) { [weak self] _ in
            self?._isPerformingUndoRedo = true
        }
        _undoSystem.willPerformRedo.addListener(owner: self) { [weak self] _ in
            self?._isPerformingUndoRedo = true
        }

        _undoSystem.undoPerformed.addListener(owner: self) { [weak self] _ in
            self?._isPerformingUndoRedo = false
        }
        _undoSystem.redoPerformed.addListener(owner: self) { [weak self] _ in
            self?._isPerformingUndoRedo = false
        }
    }
    
    /// Requests that this text engine reload its caret after a change to a text
    /// buffer's contents or length
    public func updateCaretFromTextBuffer() {
        if caret.start > textBuffer.textLength {
            setCaret(caret)
        }
    }
    
    private func registerUndo(_ task: UndoTask) {
        if _isPerformingUndoRedo {
            return
        }
        
        _undoSystem.registerUndo(task)
    }

    /// If any text insert undo is currently present under `_currentInputUndoRun`,
    /// this method flushes it into `_undoSystem` and resets the text undo run
    /// so new undo runs are started fresh.
    private func flushTextInsertUndo() {
        if _isPerformingUndoRedo {
            return
        }
        
        _undoSystem.finishGroupUndo()
        _currentInputUndoRun = nil
    }

    /// Updates `_currentInputUndoRun` with a new character at a specified offset.
    /// If the offset is not exactly at the end of the current undo run, a new
    /// undo run is started and the current undo run is flushed (via `FlushTextInsertUndo`).
    private func updateTextInsertUndo(_ replacing: String, _ text: String, _ caret: Caret) {
        if _isPerformingUndoRedo {
            return
        }
        
        if let current = _currentInputUndoRun {
            if !replacing.isEmpty || current.caret.start + current.after.count != caret.start || current.caret.position != .start {
                flushTextInsertUndo()
                
                _undoSystem.startGroupUndo(description: "Insert text")
            }
        } else {
            _undoSystem.startGroupUndo(description: "Insert text")
        }
        
        let undo = TextInsertUndo(textEngine: self, caret: caret,
                                  before: replacing, after: text)
        registerUndo(undo)
        _currentInputUndoRun = undo
    }

    /// Returns all text currently under selection of the caret.
    ///
    /// Returns an empty string, if no ranged selection is present.
    public func selectedText() -> Substring {
        return textBuffer.textInRange(caret.textRange)
    }

    /// Moves the caret to the right
    public func moveRight() {
        if caret.start == textBuffer.textLength {
            return
        }
        
        if caret.length > 0 {
            setCaret(TextRange(start: caret.end, length: 0))
        } else {
            setCaret(TextRange(start: caret.location + 1, length: 0))
        }
    }

    /// Moves the caret to the left
    public func moveLeft() {
        if caret.end == 0 {
            return
        }
        
        if caret.length > 0 {
            setCaret(TextRange(start: caret.start, length: 0))
        } else {
            setCaret(TextRange(start: caret.location - 1, length: 0))
        }
    }

    /// Moves the caret to the start of the text
    public func moveToStart() {
        if caret.end == 0 {
            return
        }
        
        setCaret(TextRange(start: 0, length: 0))
    }

    /// Moves the caret to just after the end of the text
    public func moveToEnd() {
        if caret.start == textBuffer.textLength {
            return
        }
        
        setCaret(TextRange(start: textBuffer.textLength, length: 0))
    }

    /// Moves right until the caret hits a word break.
    ///
    /// From the current caret location, moves to the beginning of the next
    /// word.
    /// If the caret is on top of a word, move to the end of that word.
    public func moveRightWord() {
        if caret.location == textBuffer.textLength {
            return
        }
        
        let offset = offsetForRightWord()
        setCaret(offset)
    }

    /// Moves left until the caret hits a word break.
    ///
    /// From the current caret location, moves to the beginning of the previous
    /// word.
    /// If the caret is on top of a word, move to the beginning of that word.
    public func moveLeftWord() {
        if caret.location == 0 {
            return
        }
        
        let offset = offsetForLeftWord()
        setCaret(offset)
    }

    /// Performs a selection to the right of the caret.
    ///
    /// If the caret's position is Start, the caret selects one character to the
    /// left, otherwise, it moves to the left and subtracts the character it
    /// moved over from the selection area.
    public func selectRight() {
        if caret.location == textBuffer.textLength {
            return
        }
        
        moveCaretSelecting(caret.location + 1)
    }

    /// Performs a selection to the left of the caret.
    ///
    /// If the caret's position is End, the caret selects one character to the
    /// left, otherwise, it moves to the left and subtracts the character it
    /// moved over from the selection area.
    public func selectLeft() {
        if caret.location == 0 {
            return
        }
        
        moveCaretSelecting(caret.location - 1)
    }

    /// Moves the caret to the beginning of the text range, selecting
    /// any characters it moves over.
    public func selectToStart() {
        if caret.location == 0 {
            return
        }
        
        moveCaretSelecting(0)
    }

    /// Moves the caret to the end of the text range, selecting
    /// any characters it moves over.
    public func selectToEnd() {
        if caret.location == textBuffer.textLength {
            return
        }
        
        moveCaretSelecting(textBuffer.textLength)
    }

    /// Selects right until the caret hits a word break.
    ///
    /// From the current caret location, selects up to the beginning of the next
    /// word.
    /// If the caret is on top of a word, selects up to the end of that word.
    public func selectRightWord() {
        if caret.location == textBuffer.textLength {
            return
        }
        
        let offset = offsetForRightWord()
        moveCaretSelecting(offset)
    }

    /// Selects to the left until the caret hits a word break.
    ///
    /// From the current caret location, selects up to the beginning of the previous
    /// word.
    /// If the caret is on top of a word, selects up to the beginning of that word.
    public func selectLeftWord() {
        if caret.location == 0 {
            return
        }
        
        let offset = offsetForLeftWord()
        moveCaretSelecting(offset)
    }

    /// Selects the entire text buffer available.
    public func selectAll() {
        setCaret(Caret(range: TextRange(start: 0, length: textBuffer.textLength),
                       position: .end))
    }

    /// Moves the caret position to a given location, while maintaining a pivot
    /// over the other end of the selection.
    ///
    /// If the caret's position is towards the End of its range, this method
    /// maintains its Start location the same, otherwise, it keeps the End
    /// location the same, instead.
    ///
    /// - Parameter offset: New offset to move caret to, pinning the current
    /// selection position.
    public func moveCaretSelecting(_ offset: Int) {
        let pivot = caret.position == .start ? caret.end : caret.start
        let newPos = offset
        
        let position = newPos > pivot ? CaretPosition.end : CaretPosition.start
        
        setCaret(Caret(range: TextRange.fromOffsets(pivot, newPos), position: position))
    }

    /// Inserts the specified text on top of the current caret position.
    ///
    /// Replaces text if caret's range is > 0.
    public func insertText(_ text: String) {
        if caret.start == textBuffer.textLength {
            textBuffer.append(text)
            updateTextInsertUndo("", text, caret)
        } else if caret.length == 0 {
            textBuffer.insert(at: caret.start, text)
            updateTextInsertUndo("", text, caret)
        } else {
            let replaced = textBuffer.textInRange(caret.textRange)
            
            textBuffer.replace(at: caret.start, length: caret.length, text)
            
            updateTextInsertUndo(String(replaced), text, caret)
        }
        
        setCaret(TextRange(start: caret.start + text.count, length: 0))
    }

    /// Deletes the text before the starting position of the caret.
    public func backspaceText() {
        if caret.location == 0 && caret.length == 0 {
            return
        }
        
        flushTextInsertUndo()
        
        if caret.length == 0 {
            let oldCaret = caret
            let removed = textBuffer.textInRange(TextRange(start: caret.start - 1, length: 1))
            
            textBuffer.delete(at: caret.start - 1, length: 1)
            setCaret(TextRange(start: caret.start - 1, length: 0))
            
            _undoSystem.registerUndo(TextDeleteUndo(textEngine: self,
                                                    beforeCaret: oldCaret,
                                                    deletedRange: oldCaret.textRange,
                                                    text: String(removed)))
        } else {
            let oldCaret = caret
            let removed = textBuffer.textInRange(caret.textRange)
            
            textBuffer.delete(at: caret.start, length: caret.length)
            setCaret(caret.start)
            
            _undoSystem.registerUndo(TextDeleteUndo(textEngine: self,
                                                    beforeCaret: oldCaret,
                                                    deletedRange: oldCaret.textRange,
                                                    text: String(removed)))
        }
    }

    /// Deletes the text exactly on top of the caret.
    public func deleteText() {
        if caret.location == textBuffer.textLength && caret.length == 0 {
            return
        }
        
        flushTextInsertUndo()
        
        if caret.length == 0 {
            let oldCaret = caret
            let removed = textBuffer.textInRange(TextRange(start: caret.start, length: 1))
            
            textBuffer.delete(at: caret.start, length: 1)
            
            registerUndo(TextDeleteUndo(textEngine: self,
                                        beforeCaret: oldCaret,
                                        deletedRange: oldCaret.textRange,
                                        text: String(removed)))
        } else {
            let oldCaret = caret
            let removed = textBuffer.textInRange(caret.textRange)
            
            textBuffer.delete(at: caret.start, length: caret.length)
            setCaret(caret.start)
            
            registerUndo(TextDeleteUndo(textEngine: self,
                                        beforeCaret: oldCaret,
                                        deletedRange: oldCaret.textRange,
                                        text: String(removed)))
        }
    }

    /// Copies the selected text content into `TextClipboard`.
    ///
    /// If no text range is selected, nothing is done.
    public func copy() {
        if caret.length == 0 {
            return
        }
        
        let text = selectedText()
        textClipboard.setText(String(text))
    }

    /// Cuts the selected text content into `TextClipboard`, by copying and
    /// subsequently deleting the text range.
    ///
    /// If no text range is selected, nothing is done.
    public func cut() {
        if caret.length == 0 {
            return
        }
        
        copy()
        deleteText()
    }

    /// Pastes any text content from `TextClipboard` into this text engine,
    /// replacing any selection range that is currently made.
    ///
    /// If no text is available in the clipboard, nothing is done.
    public func paste() {
        if !textClipboard.containsText() {
            return
        }

        if let text = textClipboard.getText() {
            flushTextInsertUndo()

            insertText(text)

            flushTextInsertUndo()
        }
    }

    /// Clears all undo/redo history for this textfield.
    public func clearUndo() {
        _undoSystem.clear()
    }

    /// Returns a text range that covers an entire word segment at a given text
    /// position.
    ///
    /// If the text under the position contains a word, the range from the
    /// beginning to the end of the word is returned, otherwise, the boundaries
    /// for the nearest word are given.
    ///
    /// If no word is under or near the position, the non-word (white space)
    ///
    /// - Parameter position: Position to get word segment under
    public func wordSegmentIn(position: Int) -> Text.TextRange {
        if position >= textBuffer.textLength {
            return TextRange(start: textBuffer.textLength, length: 0)
        }
        
        var start = 0
        var end = 0
        
        if TextEngine.isWord(textBuffer.character(at: position)) {
            start = position
            end = position
            
            while start > 0 && TextEngine.isWord(textBuffer.character(at: start)) {
                start -= 1
            }
            
            if start > 0 {
                start += 1
            }
            
            while end < textBuffer.textLength && TextEngine.isWord(textBuffer.character(at: end)) {
                end += 1
            }
            
            return TextRange.fromOffsets(start, end)
        }
        if position > 0 && TextEngine.isWord(textBuffer.character(at: position - 1)) {
            start = position - 1
            
            while start > 0 && TextEngine.isWord(textBuffer.character(at: start)) {
                start -= 1
            }
            
            if start > 0 {
                start += 1
            }
            
            return TextRange.fromOffsets(start, position)
        }
        
        start = position
        end = position
        
        while start > 0 && !TextEngine.isWord(textBuffer.character(at: start)) {
            start -= 1
        }
        
        if start > 0 {
            start += 1
        }
        
        while end < textBuffer.textLength && !TextEngine.isWord(textBuffer.character(at: end)) {
            end += 1
        }
        
        return TextRange.fromOffsets(start, end)
    }

    /// Sets the caret range for the text, with no selection length associated
    /// with it.
    ///
    /// Calls to this method fire the `caretChanged` event.
    public func setCaret(_ offset: Int) {
        setCaret(Caret(location: offset))
    }

    /// Sets the caret range for the text.
    ///
    /// If `range.length > 0`, the caret is treated as a selection range.
    ///
    /// Calls to this method fire the `caretChanged` event.
    public func setCaret(_ range: Text.TextRange, position: CaretPosition = .start) {
        setCaret(Caret(range: range, position: position))
    }

    /// Sets the caret range for the text.
    ///
    /// If `caret.length > 0`, the caret is treated as a selection range.
    ///
    /// Calls to this method fire the `caretChanged` event.
    public func setCaret(_ caret: Caret) {
        let oldCaret = self.caret
        
        // Overlap to keep caret within text bounds
        let total = textBuffer.textLength
        
        let clampedRange =
            TextRange(start: 0, length: total)
                .overlap(caret.textRange) ?? (caret.start < 0 ? TextRange(start: 0, length: 0) : TextRange(start: total, length: 0))
        
        self.caret = Caret(range: clampedRange, position: caret.position)

        _caretChanged.publishChangeEvent(sender: self, old: oldCaret, new: caret)
    }
    
    private func offsetForRightWord() -> Int {
        if caret.location == textBuffer.textLength {
            return caret.location
        }
        
        if TextEngine.isWord(textBuffer.character(at: caret.location)) {
            // Move to end of current word
            var newOffset = caret.location
            while newOffset < textBuffer.textLength && TextEngine.isWord(textBuffer.character(at: newOffset)) {
                newOffset += 1
            }
            
            return newOffset
        } else {
            // Move to beginning of the next word
            var newOffset = caret.location
            while newOffset < textBuffer.textLength && !TextEngine.isWord(textBuffer.character(at: newOffset)) {
                newOffset += 1
            }
            
            return newOffset
        }
    }
    
    private func offsetForLeftWord() -> Int {
        if caret.location == 0 {
            return caret.location
        }
        
        if TextEngine.isWord(textBuffer.character(at: caret.location - 1)) {
            // Move to beginning of current word
            var newOffset = caret.location - 1
            while newOffset > 0 && TextEngine.isWord(textBuffer.character(at: newOffset)) {
                newOffset -= 1
            }
            
            // We stopped because we hit the beginning of the string
            if newOffset == 0 {
                return newOffset
            }
            
            return newOffset + 1
        } else {
            // Move to beginning of the previous word
            var newOffset = caret.location - 1
            while newOffset > 0 && !TextEngine.isWord(textBuffer.character(at: newOffset)) {
                newOffset -= 1
            }
            while newOffset > 0 && TextEngine.isWord(textBuffer.character(at: newOffset)) {
                newOffset -= 1
            }
            
            // We stopped because we hit the beginning of the string
            if newOffset == 0 {
                return newOffset
            }

            return newOffset + 1
        }
    }

    /// Returns if a given character is recognized as a word char.
    private static func isWord(_ character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(
            CharacterSet.letters.union(CharacterSet.decimalDigits).contains
        )
    }
}

/// Undo task for a text insert operation
class TextInsertUndo: UndoTask {
    /// Text engine associated with this undo task
    public let textEngine: TextEngineType

    /// Position of caret when text was input
    public let caret: Caret

    /// Text string that was replaced (if input replaced existing)
    public let before: String

    /// Text string that replaced/was inserted into the buffer
    public let after: String

    public init(textEngine: TextEngineType, caret: Caret, before: String, after: String) {
        self.textEngine = textEngine
        self.caret = caret
        self.before = before
        self.after = after
    }

    public func clear() {

    }

    public func undo() {
        textEngine.setCaret(Caret(range: TextRange(start: caret.start, length: after.count),
                                  position: .start))
        textEngine.deleteText()

        if !before.isEmpty {
            textEngine.insertText(before)
            textEngine.setCaret(caret)
        }
    }

    public func redo() {
        textEngine.setCaret(caret)
        textEngine.insertText(after)
    }

    public func getDescription() -> String {
        return "Insert text"
    }
}

/// Undo task for a text delete operation
public class TextDeleteUndo : UndoTask {
    /// Text engine associated with this undo task
    public let textEngine: TextEngineType

    /// Position of caret to place when operation is undone
    public let beforeCaret: Caret

    /// Range of text that was removed.
    ///
    /// Must always have `length > 0`.
    public let deletedRange: Text.TextRange

    /// Text string that was deleted
    public let text: String
    
    public init(textEngine: TextEngineType, beforeCaret: Caret, deletedRange: Text.TextRange, text: String) {
        self.textEngine = textEngine
        self.deletedRange = deletedRange
        self.text = text
        self.beforeCaret = beforeCaret
    }

    public func clear() {
        
    }

    public func undo() {
        textEngine.setCaret(Caret(location: deletedRange.start))
        textEngine.insertText(text)

        textEngine.setCaret(beforeCaret)
    }

    public func redo() {
        textEngine.setCaret(Caret(range: deletedRange, position: .start))
        textEngine.deleteText()
    }

    public func getDescription() -> String {
        return "Delete text"
    }
}
