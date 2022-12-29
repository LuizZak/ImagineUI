import XCTest

@testable import ImagineUICore

// To solve an ambiguous type lookup in macOS
typealias TextRange = ImagineUICore.TextRange

class TextEngineTests: XCTestCase {
    func testStartState() {
        let buffer = TextBuffer("Test")

        let sut = TextEngine(textBuffer: buffer)

        XCTAssertEqual(Caret(location: 0), sut.caret, "Should start with caret at beginning of text")
        XCTAssertIdentical(buffer, sut.textBuffer as AnyObject, "Should properly assign passed in text buffer")
    }

    // MARK: - Selected Text

    func testSelectedTextEmptyText() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)

        let text = sut.selectedText()

        XCTAssertEqual("", text)
    }

    func testSelectedTextEmptyRange() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)

        let text = sut.selectedText()

        XCTAssertEqual("", text)
    }

    func testSelectedTextPartialRange() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(TextRange(start: 2, length: 3))

        XCTAssertEqual("cde", sut.selectedText())
    }

    func testSelectedTextPartialRangeToEnd() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(TextRange(start: 2, length: 4))

        XCTAssertEqual("cdef", sut.selectedText())
    }

    func testSelectedTextFullRange() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(TextRange(start: 0, length: 6))

        XCTAssertEqual("Abcdef", sut.selectedText())
    }

    func testSelectedTextInvokesTextBuffer() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(TextRange(start: 2, length: 3))

        _=sut.selectedText()

        XCTAssertTrue(buffer.textInRange_calls.contains(TextRange(start: 2, length: 3)))
    }

    // MARK: - Move

    func testMoveRight() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.moveRight()

        XCTAssertEqual(Caret(location: 1), sut.caret)
    }

    func testMoveRightStopsAtEndOfText() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.moveRight()
        sut.moveRight()
        sut.moveRight()
        sut.moveRight() // Should not move right any further

        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testMoveRightWithSelectionAtEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 0, length: 2), position: .end))

        sut.moveRight()

        XCTAssertEqual(Caret(location: 2), sut.caret)
    }

    func testMoveRightWithSelectionAtStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 0, length: 2), position: .start))

        sut.moveRight()

        XCTAssertEqual(Caret(location: 2), sut.caret)
    }

    func testMoveLeft() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveLeft()

        XCTAssertEqual(Caret(location: 2), sut.caret)
    }

    func testMoveLeftStopsAtBeginningOfText() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveLeft()
        sut.moveLeft()
        sut.moveLeft()
        sut.moveLeft() // Should not move right any further

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testMoveLeftWithSelectionAtEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: .end))

        sut.moveLeft()

        XCTAssertEqual(Caret(location: 1), sut.caret)
    }

    func testMoveLeftWithSelectionAtStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: .start))

        sut.moveLeft()

        XCTAssertEqual(Caret(location: 1), sut.caret)
    }

    func testMoveLeftWithSelectionWithCaretAtStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 0, length: 2), position: .start))

        sut.moveLeft()

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testMoveToEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.moveToEnd()

        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testMoveToEndIdempotent() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.moveToEnd()
        sut.moveToEnd()

        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testMoveToStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveToStart()

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testMoveToStartIdempotent() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveToStart()
        sut.moveToStart()

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testMoveToStartWithSelectionAtStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(TextRange(start: 0, length: 2))

        sut.moveToStart()

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    // MARK: - Selection Move

    func testSelectRight() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.selectRight()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 1), position: .end), sut.caret)
    }

    func testSelectRightStopsAtEndOfText() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.selectRight()
        sut.selectRight()
        sut.selectRight()
        sut.selectRight() // Should not move right any further

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .end), sut.caret)
    }

    func testSelectRightWithSelection() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 0, length: 2), position: .start))

        sut.selectRight()

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 1), position: .start), sut.caret)
    }

    func testSelectLeft() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.selectLeft()

        XCTAssertEqual(Caret(range: TextRange(start: 2, length: 1), position: .start), sut.caret)
    }

    func testSelectLeftStopsAtBeginningOfText() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.selectLeft()
        sut.selectLeft()
        sut.selectLeft()
        sut.selectLeft() // Should not move left any further

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .start), sut.caret)
    }

    func testSelectToEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.selectToEnd()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .end), sut.caret)
    }

    func testSelectToEndIdempotent() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.selectToEnd()
        sut.selectToEnd()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .end), sut.caret)
    }

    func testSelectToEndWithSelectionAtStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 0, length: 2), position: .start))

        sut.selectToEnd()

        XCTAssertEqual(Caret(range: TextRange(start: 2, length: 1), position: .end), sut.caret)
    }

    func testSelectToStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.selectToStart()
        
        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .start), sut.caret)
    }

    func testSelectToStartIdempotent() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.selectToStart()
        sut.selectToStart()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .start), sut.caret)
    }

    func testSelectToStartWithSelectionAtEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: .end))

        sut.selectToStart()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 1), position: .start), sut.caret)
    }

    func testMoveCaretSelecting() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(1)

        sut.moveCaretSelecting(2)

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 1), position: .end), sut.caret)
    }

    func testMoveCaretSelectingLeft() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(2)

        sut.moveCaretSelecting(1)

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 1), position: .start), sut.caret)
    }

    func testMoveCaretSelectingSamePosition() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(1)

        sut.moveCaretSelecting(1)

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 0), position: .start), sut.caret)
    }

    func testMoveCaretSelectingSamePositionStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 1), position: .start))

        sut.moveCaretSelecting(3)

        XCTAssertEqual(Caret(range: TextRange(start: 2, length: 1), position: .end), sut.caret)
    }

    func testMoveCaretSelectingSamePositionEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: .end))

        sut.moveCaretSelecting(0)

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 1), position: .start), sut.caret)
    }

    func testSelectLeftWithFullSelectionRangeWithCaretAtEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(TextRange(start: 0, length: 3), position: .end)

        sut.selectLeft()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 2), position: .end), sut.caret)
    }

    func testSelectAll() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: .end))

        sut.selectAll()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: .end), sut.caret)
    }

    // MARK: - Move Word

    func testMoveRightWordEndOfWord() {
        let buffer = TextBuffer("Abc Def")
        let sut = TextEngine(textBuffer: buffer)

        sut.moveRightWord()

        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testMoveRightWordBeginningOfNextWord() {
        let buffer = TextBuffer("Abc   Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveRightWord()

        XCTAssertEqual(Caret(location: 6), sut.caret)
    }

    func testMoveLeftWordBeginningOfWord() {
        let buffer = TextBuffer("Abc Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(6)

        sut.moveLeftWord()

        XCTAssertEqual(Caret(location: 4), sut.caret)
    }

    func testMoveLeftWordBeginningOfFirstWord() {
        let buffer = TextBuffer("Abc Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveLeftWord()

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testMoveLeftWordEndOfPreviousWord() {
        let buffer = TextBuffer("Abc   Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(6)

        sut.moveLeftWord()

        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testMoveLeftWordBeginningOfWordCaretAtEnd() {
        // Tests moving to the previous word when the caret is currently just after the end
        // of a word

        let buffer = TextBuffer("Abc def ghi")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(7)

        sut.moveLeftWord()

        XCTAssertEqual(Caret(range: TextRange(start: 4, length: 0), position: CaretPosition.start), sut.caret)
    }

    func testMoveLeftAtBeginningOfText() {
        // Tests moving a word to the left when at the beginning of the text stream

        let buffer = TextBuffer("Abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(0)

        sut.moveLeftWord()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 0), position: CaretPosition.start), sut.caret)
    }

    func testMoveRightAtEndOfText() {
        // Tests moving a word to the right when at the end of the text stream

        let buffer = TextBuffer("Abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.moveRightWord()

        XCTAssertEqual(Caret(range: TextRange(start: 3, length: 0), position: CaretPosition.start), sut.caret)
    }

    // MARK: - Selection Move Word

    func testSelectRightWordEndOfWord() {
        let buffer = TextBuffer("Abc Def")
        let sut = TextEngine(textBuffer: buffer)

        sut.selectRightWord()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: CaretPosition.end), sut.caret)
    }

    func testSelectRightWordBeginningOfNextWord() {
        let buffer = TextBuffer("Abc   Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.selectRightWord()

        XCTAssertEqual(Caret(range: TextRange(start: 3, length: 3), position: CaretPosition.end), sut.caret)
    }

    func testSelectLeftWordBeginningOfWord() {
        let buffer = TextBuffer("Abc Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(7)

        sut.selectLeftWord()

        XCTAssertEqual(Caret(range: TextRange(start: 4, length: 3), position: CaretPosition.start), sut.caret)
    }

    func testSelectLeftWordBeginningOfFirstWord() {
        let buffer = TextBuffer("Abc Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.selectLeftWord()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: CaretPosition.start), sut.caret)
    }

    func testSelectLeftWordBeginningOfPreviousWord() {
        let buffer = TextBuffer("Abc   Def")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(6)

        sut.selectLeftWord()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 6), position: CaretPosition.start), sut.caret)
    }

    func testSelectLeftWordBeginningOfWordCaretAtEnd() {
        // Tests selecting the previous word when the caret is currently just after the end
        // of a word

        let buffer = TextBuffer("Abc def ghi")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(7)

        sut.selectLeftWord()

        XCTAssertEqual(Caret(range: TextRange(start: 4, length: 3), position: CaretPosition.start), sut.caret)
    }

    // MARK: - Word Segment In

    func testWordSegmentIn() {
        let buffer = TextBuffer("Abc def ghi")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 5)

        XCTAssertEqual(TextRange(start: 4, length: 3), segment)
    }

    func testWordSegmentInEmptyString() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 0)

        XCTAssertEqual(TextRange(start: 0, length: 0), segment)
    }

    func testWordSegmentInAtStartOfWord() {
        let buffer = TextBuffer("Abc def ghi")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 4)

        XCTAssertEqual(TextRange(start: 4, length: 3), segment)
    }

    func testWordSegmentInAtEndOfWord() {
        let buffer = TextBuffer("Abc def ghi")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 7)

        XCTAssertEqual(TextRange(start: 4, length: 3), segment)
    }

    func testWordSegmentInOverWhitespace() {
        let buffer = TextBuffer("Abc   ghi")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 4)

        XCTAssertEqual(TextRange(start: 3, length: 3), segment)
    }

    func testWordSegmentInSingleWordText() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 3)

        XCTAssertEqual(TextRange(start: 0, length: 6), segment)
    }

    func testWordSegmentInSingleWhitespaceText() {
        let buffer = TextBuffer("      ")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 3)

        XCTAssertEqual(TextRange(start: 0, length: 6), segment)
    }

    func testWordSegmentInBeginningOfString() {
        let buffer = TextBuffer("Abcdef")
        let sut = TextEngine(textBuffer: buffer)

        let segment = sut.wordSegmentIn(position: 0)

        XCTAssertEqual(TextRange(start: 0, length: 6), segment)
    }

    // MARK: - Set Caret

    func testSetCaret() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: CaretPosition.end))

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 2), position: CaretPosition.end), sut.caret)
    }

    func testSetCaretTextRange() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(TextRange(start: 1, length: 2))

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 2), position: CaretPosition.start), sut.caret)
    }

    func testSetCaretOffset() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(TextRange(start: 2, length: 2))

        sut.setCaret(1)

        XCTAssertEqual(Caret(location: 1), sut.caret)
    }

    func testSetCaretOutOfBoundsStart() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(Caret(range: TextRange(start: -5, length: 0), position: CaretPosition.start))

        // Cap at start
        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testSetCaretOutOfBoundsEnd() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(Caret(range: TextRange(start: 10, length: 5), position: CaretPosition.start))

        // Cap at end
        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testSetCaretOutOfBounds() {
        let buffer = TextBuffer("123")
        let sut = TextEngine(textBuffer: buffer)

        sut.setCaret(Caret(range: TextRange(start: -5, length: 10), position: CaretPosition.start))

        // Cap at whole available range
        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 3), position: CaretPosition.start), sut.caret)
    }

    // MARK: - Update Caret From TextBuffer

    func testUpdateCaretFromTextBuffer() {
        let buffer = TextBuffer("123456")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 6, length: 0), position: CaretPosition.end))
        buffer.text = "123"

        sut.updateCaretFromTextBuffer()

        XCTAssertEqual(Caret(range: TextRange(start: 3, length: 0), position: CaretPosition.end), sut.caret)
    }

    func testUpdateCaretFromTextBufferWhileStillInBounds() {
        let buffer = TextBuffer("123456")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(Caret(range: TextRange(start: 1, length: 2), position: CaretPosition.end))
        buffer.text = "123"

        sut.updateCaretFromTextBuffer()

        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 2), position: CaretPosition.end), sut.caret)
    }

    // MARK: - Insert Text

    func testInsertTextCaretAtEnd() {
        let stub = TextBuffer()
        let sut = TextEngine(textBuffer: stub)
        
        sut.insertText("456")

        XCTAssertTrue(stub.append_calls.contains("456"), stub.append_calls.description)
        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testInsertTextCaretNotAtEnd() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(0)

        sut.insertText("456")
        
        XCTAssertTrue(stub.insertAt_calls.contains(tuple: (0, "456")), stub.insertAt_calls.description)
        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testInsertTextWithSelection() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(TextRange(start: 1, length: 2))

        sut.insertText("456")
        
        XCTAssertTrue(stub.replaceAtLength_calls.contains(tuple: (1, 2, "456")), stub.replaceAtLength_calls.description)
        XCTAssertEqual(Caret(location: 4), sut.caret)
    }

    // MARK: - Backspace

    func testBackspace() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(3)

        sut.backspaceText()
        
        XCTAssertTrue(stub.deleteAtLength_calls.contains(tuple: (2, 1)), stub.deleteAtLength_calls.description)
        XCTAssertEqual(Caret(location: 2), sut.caret)
    }

    func testBackspaceAtBeginningHasNoEffect() {
        let stub = TextBuffer()
        let sut = TextEngine(textBuffer: stub)

        sut.backspaceText()
        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testBackspaceWithRange() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(TextRange(start: 1, length: 2))

        sut.backspaceText()

        XCTAssertTrue(stub.deleteAtLength_calls.contains(tuple: (1, 2)), stub.deleteAtLength_calls.description)
        XCTAssertEqual(Caret(location: 1), sut.caret)
    }

    func testBackspaceAtBeginningWithRange() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(TextRange(start: 0, length: 3))

        sut.backspaceText()

        XCTAssertTrue(stub.deleteAtLength_calls.contains(tuple: (0, 3)), stub.deleteAtLength_calls.description)
        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    // MARK: - Delete

    func testDelete() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        
        sut.deleteText()

        XCTAssertTrue(stub.deleteAtLength_calls.contains(tuple: (0, 1)), stub.deleteAtLength_calls.description)
        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    func testDeleteAtEndHasNoEffect() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(3)

        sut.deleteText()
        XCTAssertEqual(Caret(location: 3), sut.caret)
    }

    func testDeleteWithRange() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(TextRange(start: 1, length: 2))

        sut.deleteText()

        XCTAssertTrue(stub.deleteAtLength_calls.contains(tuple: (1, 2)), stub.deleteAtLength_calls.description)
        XCTAssertEqual(Caret(location: 1), sut.caret)
    }

    func testDeleteAtEndWithRange() {
        let stub = TextBuffer("123")
        let sut = TextEngine(textBuffer: stub)
        sut.setCaret(Caret(range: TextRange(start: 0, length: 3), position: .end))

        sut.deleteText()

        XCTAssertTrue(stub.deleteAtLength_calls.contains(tuple: (0, 3)), stub.deleteAtLength_calls.description)
        XCTAssertEqual(Caret(location: 0), sut.caret)
    }

    // MARK: - Copy/Cut/Paste

    func testCopy() {
        let mock = TestClipboard()
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 1, length: 2))

        sut.copy()

        XCTAssertTrue(mock.setText_calls.contains("bc"))
    }

    func testCopyNotCalledWhenNoSelectionRangeAvailable() {
        let mock = TestClipboard()
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 1, length: 0))

        sut.copy()

        XCTAssertEqual(mock.getText_calls.count, 0)
    }

    func testCut() {
        let mock = TestClipboard()
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 1, length: 2))

        sut.cut()

        XCTAssertTrue(mock.setText_calls.contains("bc"))
        XCTAssertEqual(buffer.text, "a")
    }

    func testCutNotCalledWhenNoSelectionRangeAvailable() {
        let mock = TestClipboard()
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 1, length: 0))

        sut.cut()

        XCTAssertEqual(mock.getText_calls.count, 0)
        XCTAssertEqual(mock.setText_calls.count, 0)
        XCTAssertEqual(buffer.text, "abc")
    }

    func testPaste() {
        let mock = TestClipboard("def")
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 3, length: 0))

        sut.paste()

        XCTAssertEqual(mock.getText_calls.count, 1)
        XCTAssertEqual(mock.containsText_calls.count, 1)
        XCTAssertEqual(buffer.text, "abcdef")
    }

    func testPasteNotCalledWhenNoTextAvailable() {
        let mock = TestClipboard()
        mock.containsText_stub = { false }
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 3, length: 0))

        sut.paste()

        XCTAssertEqual(mock.containsText_calls.count, 1)
        XCTAssertEqual(mock.getText_calls.count, 0)
        XCTAssertEqual(buffer.text, "abc")
    }

    func testPasteReplacesSelectionRange() {
        let mock = TestClipboard("def")
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = mock
        sut.setCaret(TextRange(start: 1, length: 2))

        sut.paste()
        
        XCTAssertEqual(buffer.text, "adef")
    }

    // MARK: - Undo Operations

    /// Tests that multiple sequential 1-char long InsertText calls are properly undone
    /// as a single operation
    func testInsertTextUndo() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("a")
        sut.insertText("b")
        sut.insertText("c")

        sut.undoSystem.undo()

        XCTAssertEqual("", buffer.text)
    }

    /// Tests that combining insert text undo operations into one only occur when the insertions
    /// are located one after another sequentially.
    func testInsertTextUndoSequenceBreaksIfNotSequential() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("a")
        sut.insertText("b")
        sut.insertText("c")
        sut.setCaret(2)
        sut.insertText("d")

        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    /// Sequential insertions should be chained even if calls to SetCaret (but only SetCaret) are 
    /// made between insertions, so long as the next text inserted is right after the previous inserted
    /// string.
    func testInsertTextUndoSequenceDoesntBreakWhenCallingSetCaret() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("a")
        sut.insertText("b")
        sut.insertText("c")
        sut.setCaret(2)
        sut.setCaret(3)
        sut.insertText("d")

        sut.undoSystem.undo()

        XCTAssertEqual("", buffer.text)
    }

    /// Tests that calling `TextEngine.paste` interrupts insert undo sequences such 
    /// that it's considered a distinct input undo operation from the characters being input so
    /// far.
    func testInsertTextUndoSequenceBreaksAfterPaste() {
        let clipboard = TestClipboard("d")
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = clipboard
        sut.insertText("a")
        sut.insertText("b")
        sut.insertText("c")
        sut.paste()

        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    /// Tests that calling `TextEngine.deleteText` interrupts insert undo sequences.
    func testInsertTextUndoSequenceBreaksAfterDeleteText() {
        let buffer = TextBuffer("e")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("a")
        sut.insertText("b")
        sut.insertText("c")
        sut.deleteText()
        sut.insertText("d")

        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    /// Tests that calling `TextEngine.backspaceText` interrupts insert undo sequences.
    func testInsertTextUndoSequenceBreaksAfterBackspaceText() {
        let buffer = TextBuffer("e")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("a")
        sut.insertText("b")
        sut.insertText("c")
        sut.setCaret(4)
        sut.backspaceText()
        sut.insertText("d")

        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    func testBackspaceTextUndo() {
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(3)

        sut.backspaceText()
        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    func testBackspaceTextRangeUndo() {
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(TextRange(start: 1, length: 2), position: CaretPosition.end)

        sut.backspaceText()
        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    func testDeleteTextUndo() {
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)

        sut.deleteText()
        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    func testDeleteTextRangeUndo() {
        let buffer = TextBuffer("abc")
        let sut = TextEngine(textBuffer: buffer)
        sut.setCaret(TextRange(start: 1, length: 2), position: CaretPosition.end)

        sut.deleteText()
        sut.undoSystem.undo()

        XCTAssertEqual("abc", buffer.text)
    }

    func testBackwardsInsertionPlusDeleteUndo() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("c")
        sut.setCaret(0)
        sut.insertText("b")
        sut.setCaret(0)
        sut.insertText("a")
        sut.setCaret(0)
        sut.undoSystem.undo()
        sut.insertText("a")
        sut.setCaret(0)

        sut.undoSystem.undo()
        sut.undoSystem.undo()
        sut.undoSystem.undo()

        XCTAssertEqual("", buffer.text)
    }

    func testPasteUndoRespectsSelectedRegion() {
        let paste = TestClipboard("test")
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = paste
        sut.insertText("T")
        sut.insertText("e")
        sut.selectToStart()
        sut.paste()
        
        sut.undoSystem.undo()

        XCTAssertEqual(Caret(range: TextRange(start: 0, length: 2), position: CaretPosition.start), sut.caret)
    }

    func testReplacingPasteUndoAndRedo() {
        let paste = TestClipboard("test")
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = paste
        sut.insertText("T")
        sut.insertText("e")
        sut.selectToStart()
        sut.paste()

        sut.undoSystem.undo()
        sut.undoSystem.undo()
        sut.undoSystem.redo()
        sut.undoSystem.redo()

        XCTAssertEqual("test", buffer.text)
    }

    func testPasteBreaksTextInsertUndoChain() {
        let paste = TestClipboard("est")
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.textClipboard = paste
        sut.insertText("t")
        sut.paste()
        sut.insertText("t")

        sut.undoSystem.undo()

        XCTAssertEqual("test", buffer.text)
    }

    func testClearUndo() {
        let buffer = TextBuffer("")
        let sut = TextEngine(textBuffer: buffer)
        sut.insertText("Abc")

        sut.clearUndo()

        XCTAssertEqual("Abc", buffer.text)
    }

    // MARK: - Text Insert Undo Task

    func testTextInsertUndo() {
        let text = "abc"
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let mock = MockTextEngine(textBuffer: TextBuffer())
        let sut = TextInsertUndo(textEngine: mock, caret: caret, before: "", after: text)

        sut.undo()

        XCTAssertTrue(mock.setCaret_calls.contains(caret), mock.setCaret_calls.description)
        XCTAssertTrue(mock.deleteText_calls.count > 0)
    }

    func testTextInsertRedo() {
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let text = "abc"
        let mock = MockTextEngine(textBuffer: TextBuffer())
        let sut = TextInsertUndo(textEngine: mock, caret: caret, before: "", after: text)

        sut.redo()

        XCTAssertTrue(mock.setCaret_calls.contains(caret), mock.setCaret_calls.description)
        XCTAssertTrue(mock.insertText_calls.contains(text), mock.insertText_calls.description)
    }

    func testTextInsertUndoExpectedText() {
        let beforeText = "abcdef"
        let afterText = "agef"
        let replacedText = "bcd"
        let newText = "g"
        let buffer = TextBuffer(afterText)
        let engine = TextEngine(textBuffer: buffer)
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let sut = TextInsertUndo(textEngine: engine, caret: caret, before: replacedText, after: newText)

        sut.undo()

        XCTAssertEqual(beforeText, buffer.text)
        XCTAssertEqual(caret, sut.caret)
    }

    func testTextInsertRedoExpectedText() {
        let beforeText = "abcdef"
        let afterText = "agef"
        let replacedText = "bcd"
        let newText = "g"
        let buffer = TextBuffer(beforeText)
        let engine = TextEngine(textBuffer: buffer)
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.end)
        let sut = TextInsertUndo(textEngine: engine, caret: caret, before: replacedText, after: newText)

        sut.redo()

        XCTAssertEqual(afterText, buffer.text)
        XCTAssertEqual(Caret(range: TextRange(start: 2, length: 0), position: CaretPosition.start), engine.caret)
    }

    // MARK: - Text Delete Undo Task

    func testTextDeleteUndo() {
        let text = "abc"
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let mock = MockTextEngine(textBuffer: TextBuffer())
        let sut = TextDeleteUndo(textEngine: mock, beforeCaret: caret, deletedRange: caret.textRange, text: text)

        sut.undo()

        XCTAssertTrue(mock.setCaret_calls.contains(Caret(location: caret.location)), mock.setCaret_calls.description)
        XCTAssertTrue(mock.insertText_calls.contains(text), mock.insertText_calls.description)
        XCTAssertTrue(mock.setCaret_calls.contains(caret), mock.setCaret_calls.description)
    }

    func testTextRedoUndo() {
        let text = "abc"
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let mock = MockTextEngine(textBuffer: TextBuffer())
        let sut = TextDeleteUndo(textEngine: mock, beforeCaret: caret, deletedRange: caret.textRange, text: text)

        sut.redo()

        XCTAssertTrue(mock.setCaret_calls.contains(caret), mock.setCaret_calls.description)
        XCTAssertTrue(mock.deleteText_calls.count > 0)
    }

    func testTextDeleteUndoExpectedTextCaretAtStart() {
        let beforeText = "abcdef"
        let afterText = "aef"
        let deletedText = "bcd"
        let buffer = TextBuffer(afterText)
        let engine = TextEngine(textBuffer: buffer)
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let sut = TextDeleteUndo(textEngine: engine, beforeCaret: caret, deletedRange: caret.textRange, text: deletedText)

        sut.undo()

        XCTAssertEqual(beforeText, buffer.text)
        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start), engine.caret)
    }

    func testTextDeleteUndoExpectedTextCaretAtEnd() {
        let beforeText = "abcdef"
        let afterText = "aef"
        let deletedText = "bcd"
        let buffer = TextBuffer(afterText)
        let engine = TextEngine(textBuffer: buffer)
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.end)
        let sut = TextDeleteUndo(textEngine: engine, beforeCaret: caret, deletedRange: caret.textRange, text: deletedText)

        sut.undo()

        XCTAssertEqual(beforeText, buffer.text)
        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.end), engine.caret)
    }

    func testTextDeleteRedoExpectedTextCaretAtStart() {
        let beforeText = "abcdef"
        let afterText = "aef"
        let deletedText = "bcd"
        let buffer = TextBuffer(beforeText)
        let engine = TextEngine(textBuffer: buffer)
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.start)
        let sut = TextDeleteUndo(textEngine: engine, beforeCaret: caret, deletedRange: caret.textRange, text: deletedText)

        sut.redo()

        XCTAssertEqual(afterText, buffer.text)
        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 0), position: CaretPosition.start), engine.caret)
    }

    func testTextDeleteRedoExpectedTextCaretAtEnd() {
        let beforeText = "abcdef"
        let afterText = "aef"
        let deletedText = "bcd"
        let buffer = TextBuffer(beforeText)
        let engine = TextEngine(textBuffer: buffer)
        let caret = Caret(range: TextRange(start: 1, length: 3), position: CaretPosition.end)
        let sut = TextDeleteUndo(textEngine: engine, beforeCaret: caret, deletedRange: caret.textRange, text: deletedText)

        sut.redo()

        XCTAssertEqual(afterText, buffer.text)
        XCTAssertEqual(Caret(range: TextRange(start: 1, length: 0), position: CaretPosition.start), engine.caret)
    }

    func testTextDeleteUndoRespectsUndoCaretLocation() {
        let beforeText = "abcdef"
        let afterText = "abcde"
        let deletedText = "f"
        let buffer = TextBuffer(afterText)
        let engine = TextEngine(textBuffer: buffer)
        let caretBefore = Caret(range: TextRange(start: 6, length: 0), position: CaretPosition.start)
        let rangeRemoved = TextRange(start: 5, length: 1)
        let sut = TextDeleteUndo(textEngine: engine, beforeCaret: caretBefore, deletedRange: rangeRemoved, text: deletedText)

        sut.undo()

        XCTAssertEqual(beforeText, buffer.text)
        XCTAssertEqual(caretBefore, engine.caret)
    }

    class TestClipboard: TextClipboard {
        public var value: String?
        
        init(_ value: String? = nil) {
            self.value = value
        }

        var getText_calls: [()] = []
        var getText_stub: (() -> String?)? = nil
        func getText() -> String? {
            getText_calls.append(())

            return getText_stub?() ?? value
        }

        var setText_calls: [String] = []
        func setText(_ text: String) {
            setText_calls.append(text)

            self.value = text
        }

        var containsText_calls: [()] = []
        var containsText_stub: (() -> Bool)? = nil
        func containsText() -> Bool {
            containsText_calls.append(())

            return containsText_stub?() ?? true
        }
    }

    class TextBuffer: TextEngineTextualBuffer {
        private var _text: String

        var textLength: Int { _text.count }
        var text: String { get { _text } set { _text = newValue } }

        init(_ text: String = "") {
            self._text = text
        }

        var textInRange_calls: [(TextRange)] = []
        func textInRange(_ range: TextRange) -> Substring {
            textInRange_calls.append(range)

            let start = _text.index(_text.startIndex, offsetBy: range.start)
            let end = _text.index(_text.startIndex, offsetBy: range.end)

            return _text[start..<end]
        }

        var characterAt_calls: [Int] = []
        func character(at offset: Int) -> Character {
            characterAt_calls.append(offset)
            let offset = _text.index(_text.startIndex, offsetBy: offset)

            return _text[offset]
        }

        var deleteAtLength_calls: [(Int, Int)] = []
        func delete(at index: Int, length: Int) {
            deleteAtLength_calls.append((index, length))

            let start = _text.index(_text.startIndex, offsetBy: index)
            let end = _text.index(start, offsetBy: length)

            _text.removeSubrange(start..<end)
        }

        var insertAt_calls: [(Int, String)] = []
        func insert(at index: Int, _ text: String) {
            insertAt_calls.append((index, text))
            let index = _text.index(_text.startIndex, offsetBy: index)

            _text.insert(contentsOf: text, at: index)
        }

        var append_calls: [String] = []
        func append(_ text: String) {
            append_calls.append(text)

            _text += text
        }

        var replaceAtLength_calls: [(Int, Int, String)] = []
        func replace(at index: Int, length: Int, _ text: String) {
            replaceAtLength_calls.append((index, length, text))

            let start = _text.index(_text.startIndex, offsetBy: index)
            let end = _text.index(start, offsetBy: length)

            _text.removeSubrange(start..<end)
            _text.insert(contentsOf: text, at: start)
        }
    }

    class MockTextEngine: TextEngine {
        var setCaret_calls: [Caret] = []
        override func setCaret(_ caret: Caret) {
            setCaret_calls.append(caret)

            super.setCaret(caret)
        }

        var deleteText_calls: [()] = []
        override func deleteText() {
            deleteText_calls.append(())

            super.deleteText()
        }

        var insertText_calls: [String] = []
        override func insertText(_ text: String) {
            insertText_calls.append(text)

            super.insertText(text)
        }
    }
}

private extension Sequence {
    func contains<T0, T1>(tuple element: (T0, T1)) -> Bool where Element == (T0, T1), T0: Equatable, T1: Equatable {
        return contains(where: { $0 == element })
    }
    func contains<T0, T1, T2>(tuple element: (T0, T1, T2)) -> Bool where Element == (T0, T1, T2), T0: Equatable, T1: Equatable, T2: Equatable {
        return contains(where: { $0 == element })
    }
    func contains<T0, T1, T2, T3>(tuple element: (T0, T1, T2, T3)) -> Bool where Element == (T0, T1, T2, T3), T0: Equatable, T1: Equatable, T2: Equatable, T3: Equatable {
        return contains(where: { $0 == element })
    }
}
