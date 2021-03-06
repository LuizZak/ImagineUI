#if !canImport(ObjectiveC)
import XCTest

extension AttributedTextTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AttributedTextTests = [
        ("testAppend", testAppend),
        ("testAppendAttributedText", testAppendAttributedText),
        ("testAppendSequential", testAppendSequential),
        ("testAppendWithAttribute", testAppendWithAttribute),
        ("testAppendWithAttributes", testAppendWithAttributes),
        ("testInitialState", testInitialState),
        ("testInsert", testInsert),
        ("testInsertAtBeginning", testInsertAtBeginning),
        ("testInsertAtEnd", testInsertAtEnd),
        ("testInsertAttributedText", testInsertAttributedText),
        ("testRemoveAllAttributes", testRemoveAllAttributes),
        ("testRemoveAttributes", testRemoveAttributes),
        ("testSetAttributes", testSetAttributes),
        ("testSetAttributesRangeMiddle", testSetAttributesRangeMiddle),
        ("testSetAttributesRangeMiddleDoubleApplication", testSetAttributesRangeMiddleDoubleApplication),
        ("testSetText", testSetText),
    ]
}

extension TextLayoutTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TextLayoutTests = [
        ("testBoundsForCharacters", testBoundsForCharacters),
        ("testHitTestPoint", testHitTestPoint),
        ("testHitTestPointMultiline", testHitTestPointMultiline),
        ("testHitTestPointOutsideBoxBelow", testHitTestPointOutsideBoxBelow),
        ("testHitTestPointOutsideBoxRight", testHitTestPointOutsideBoxRight),
        ("testHitTestPointTrailing", testHitTestPointTrailing),
        ("testLocationOfCharacter", testLocationOfCharacter),
        ("testLocationOfCharacterOffBounds", testLocationOfCharacterOffBounds),
        ("testRenderAttributedText", testRenderAttributedText),
        ("testRenderInitWithAttributedText", testRenderInitWithAttributedText),
        ("testRenderInitWithAttributedTextFontChangeDuringSentence", testRenderInitWithAttributedTextFontChangeDuringSentence),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AttributedTextTests.__allTests__AttributedTextTests),
        testCase(TextLayoutTests.__allTests__TextLayoutTests),
    ]
}
#endif
