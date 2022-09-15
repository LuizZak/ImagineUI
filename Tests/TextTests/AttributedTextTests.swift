import XCTest

@testable import Text

class AttributedTextTests: XCTestCase {
    func testInitialState() {
        let sut = AttributedText()

        XCTAssertEqual(0, sut.length)
        XCTAssertEqual("", sut.string)
        XCTAssertFalse(sut.hasAttributes)
    }

    func testAppend() {
        var sut = AttributedText()

        sut.append("abc")

        XCTAssertEqual(3, sut.length)
        XCTAssertEqual("abc", sut.string)
        XCTAssertFalse(sut.hasAttributes)
        let segments = sut.textSegments
        XCTAssertEqual(1, segments.count)
        XCTAssertEqual("abc", segments[0].text)
        XCTAssertEqual(TextRange(start: 0, length: 3), segments[0].textRange)
        XCTAssert(segments[0].textAttributes.isEmpty)
    }

    func testAppendSequential() {
        var sut = AttributedText()

        sut.append("abc")
        sut.append("def")

        XCTAssertEqual(6, sut.length)
        XCTAssertEqual("abcdef", sut.string)
        XCTAssertFalse(sut.hasAttributes)
        let segments = sut.textSegments
        XCTAssertEqual(1, segments.count)
        XCTAssertEqual("abcdef", segments[0].text)
        XCTAssertEqual(TextRange(start: 0, length: 6), segments[0].textRange)
        XCTAssert(segments[0].textAttributes.isEmpty)
    }

    func testAppendWithAttribute() {
        var sut = AttributedText()

        sut.append("abc", attributes: ["test": TestAttribute()])

        XCTAssertEqual(sut.string, "abctest")
        let segments = sut.textSegments
        XCTAssertEqual(3, sut.length)
        XCTAssertEqual("abc", sut.string)
        XCTAssert(sut.hasAttributes)
        XCTAssertEqual(1, segments.count)
        XCTAssertEqual("abc", segments[0].text)
        XCTAssertEqual(TextRange(start: 0, length: 3), segments[0].textRange)
        XCTAssertEqual(1, segments[0].textAttributes.count)
        XCTAssert(segments[0].textAttributes["test"] is TestAttribute)
    }

    func testAppendWithAttributes() {
        var sut = AttributedText()

        sut.append("abc", attributes: ["test": TestAttribute(), "test2": TestAttribute2()])

        XCTAssertEqual(sut.string, "abctest")
        let segments = sut.textSegments
        XCTAssertEqual(3, sut.length)
        XCTAssertEqual("abc", sut.string)
        XCTAssert(sut.hasAttributes)
        XCTAssertEqual(1, segments.count)
        XCTAssertEqual("abc", segments[0].text)
        XCTAssertEqual(TextRange(start: 0, length: 3), segments[0].textRange)
        XCTAssertEqual(2, segments[0].textAttributes.count)
        XCTAssert(segments[0].textAttributes["test"] is TestAttribute)
        XCTAssert(segments[0].textAttributes["test2"] is TestAttribute2)
    }
    
    func testAppendAttributedText() {
        let attributed = AttributedText("def", attributes: ["test": TestAttribute()])
        var sut = AttributedText("abc")
        
        sut.append(attributed)
        
        XCTAssertEqual(sut.string, "abcdef")
        let segments = sut.textSegments
        XCTAssertEqual(segments.count, 2)
        XCTAssertEqual(segments[0].text, "abc")
        XCTAssert(segments[0].textAttributes.isEmpty)
        XCTAssertEqual(segments[0].textRange, TextRange(start: 0, length: 3))
        XCTAssertEqual(segments[1].text, "def")
        XCTAssert(segments[1].textAttributes["test"] is TestAttribute)
        XCTAssertEqual(segments[1].textRange, TextRange(start: 3, length: 3))
    }

    func testSetText() {
        var sut = AttributedText()

        sut.append("abc", attributes: ["test": TestAttribute(), "test2": TestAttribute2()])
        sut.setText("def")

        let segments = sut.textSegments

        XCTAssertEqual(3, sut.length)
        XCTAssertEqual("def", sut.string)
        XCTAssertFalse(sut.hasAttributes)

        XCTAssertEqual(1, segments.count)
        XCTAssertEqual("def", segments[0].text)
        XCTAssertEqual(TextRange(start: 0, length: 3), segments[0].textRange)
        XCTAssert(segments[0].textAttributes.isEmpty)
    }

    func testSetAttributes() {
        var sut = AttributedText()

        sut.setText("abcdef")
        sut.setAttributes(TextRange(start: 3, length: 3), ["test": TestAttribute()])
        
        let segments = sut.textSegments

        XCTAssertEqual(6, sut.length)
        XCTAssertEqual("abcdef", sut.string)
        XCTAssert(sut.hasAttributes)

        XCTAssertEqual(2, segments.count)
        XCTAssertEqual("abc", segments[0].text)
        XCTAssertEqual("def", segments[1].text)
        XCTAssertEqual(TextRange(start: 0, length: 3), segments[0].textRange)
        XCTAssertEqual(TextRange(start: 3, length: 3), segments[1].textRange)
        XCTAssert(segments[0].textAttributes.isEmpty)
        XCTAssertEqual(1, segments[1].textAttributes.count)
        XCTAssert(segments[1].textAttributes["test"] is TestAttribute)
    }

    func testSetAttributesRangeMiddle() {
        var sut = AttributedText()

        sut.setText("abcdef")
        
        // a b c d e f
        // 0 1 2 3 4 5
        //   1
        //     1 2 3
        sut.setAttributes(TextRange(start: 1, length: 3), ["test": TestAttribute()])

        let segments = sut.textSegments

        XCTAssertEqual(6, sut.length)
        XCTAssertEqual("abcdef", sut.string)
        XCTAssert(sut.hasAttributes)

        XCTAssertEqual(3, segments.count)
        XCTAssertEqual("a", segments[0].text)
        XCTAssertEqual("bcd", segments[1].text)
        XCTAssertEqual("ef", segments[2].text)
        XCTAssertEqual(TextRange(start: 0, length: 1), segments[0].textRange)
        XCTAssertEqual(TextRange(start: 1, length: 3), segments[1].textRange)
        XCTAssertEqual(TextRange(start: 4, length: 2), segments[2].textRange)
        XCTAssertEqual(0, segments[0].textAttributes.count)
        XCTAssertEqual(1, segments[1].textAttributes.count)
        XCTAssertEqual(0, segments[2].textAttributes.count)
        XCTAssert(segments[1].textAttributes["test"] is TestAttribute)
    }
    
    func testSetAttributesRangeMiddleDoubleApplication() {
        var sut = AttributedText()

        sut.setText("abcdef")
        
        // a b c d e f
        // 0 1 2 3 4 5
        //   1
        //     1 2 3
        sut.setAttributes(TextRange(start: 1, length: 3), ["test": TestAttribute()])
        sut.setAttributes(TextRange(start: 1, length: 3), ["test": TestAttribute()]) // Apply twice here

        let segments = sut.textSegments

        XCTAssertEqual(6, sut.length)
        XCTAssertEqual("abcdef", sut.string)
        XCTAssert(sut.hasAttributes)

        XCTAssertEqual(3, segments.count)
        XCTAssertEqual("a", segments[0].text)
        XCTAssertEqual("bcd", segments[1].text)
        XCTAssertEqual("ef", segments[2].text)
        XCTAssertEqual(TextRange(start: 0, length: 1), segments[0].textRange)
        XCTAssertEqual(TextRange(start: 1, length: 3), segments[1].textRange)
        XCTAssertEqual(TextRange(start: 4, length: 2), segments[2].textRange)
        XCTAssertEqual(0, segments[0].textAttributes.count)
        XCTAssertEqual(1, segments[1].textAttributes.count)
        XCTAssertEqual(0, segments[2].textAttributes.count)
        XCTAssert(segments[1].textAttributes["test"] is TestAttribute)
    }
    
    func testInsert() {
        var sut = AttributedText("abcdef")
        
        sut.insert("GHI", at: 3, attributes: ["test": TestAttribute()])
        
        XCTAssertEqual(3, sut.textSegments.count)
        XCTAssertEqual("abcGHIdef", sut.string)
        XCTAssertEqual(sut.textSegments[0].textRange, TextRange(start: 0, length: 3))
        XCTAssertEqual(sut.textSegments[1].textRange, TextRange(start: 3, length: 3))
        XCTAssertEqual(sut.textSegments[2].textRange, TextRange(start: 6, length: 3))
        XCTAssertEqual(sut.textSegments[0].text, "abc")
        XCTAssertEqual(sut.textSegments[1].text, "GHI")
        XCTAssertEqual(sut.textSegments[2].text, "def")
    }
    
    func testInsertAtEnd() {
        var sut = AttributedText("abc")
        
        sut.insert("def", at: 3, attributes: ["test": TestAttribute()])
        
        XCTAssertEqual(sut.textSegments.count, 2)
        XCTAssertEqual(sut.string, "abcdef")
        XCTAssertEqual(sut.textSegments[0].text, "abc")
        XCTAssertEqual(sut.textSegments[1].text, "def")
    }
    
    func testInsertAtBeginning() {
        var sut = AttributedText("abc")
        
        sut.insert("def", at: 0, attributes: ["test": TestAttribute()])
        
        XCTAssertEqual(sut.textSegments.count, 2)
        XCTAssertEqual(sut.string, "defabc")
        XCTAssertEqual(sut.textSegments[0].text, "def")
        XCTAssertNotNil(sut.textSegments[0].textAttributes["test"])
        XCTAssertEqual(sut.textSegments[1].text, "abc")
        XCTAssert(sut.textSegments[1].textAttributes.isEmpty)
    }
    
    func testInsertAttributedText() {
        let attributed = AttributedText("GHI", attributes: ["test": TestAttribute()])
        var sut = AttributedText("abcdef")
        
        sut.insert(attributed, at: 3)
        
        let segments = sut.textSegments
        XCTAssertEqual(segments.count, 3)
        XCTAssertEqual(segments[0].text, "abc")
        XCTAssert(segments[0].textAttributes.isEmpty)
        XCTAssertEqual(segments[0].textRange, TextRange(start: 0, length: 3))
        XCTAssertEqual(segments[1].text, "GHI")
        XCTAssert(segments[1].textAttributes["test"] is TestAttribute)
        XCTAssertEqual(segments[1].textRange, TextRange(start: 3, length: 3))
        XCTAssertEqual(segments[2].text, "def")
        XCTAssert(segments[2].textAttributes.isEmpty)
        XCTAssertEqual(segments[2].textRange, TextRange(start: 6, length: 3))
    }
    
    func testRemoveAttributes() {
        var sut = AttributedText()
        sut.append("abcdef", attributes: ["test": TestAttribute(), "test2": TestAttribute2()])
        
        sut.removeAttributes(TextRange(start: 2, length: 2), attributeKeys: ["test"])
        
        XCTAssertEqual(sut.textSegments.count, 3)
        XCTAssertEqual(sut.textSegments[0].text, "ab")
        XCTAssertNotNil(sut.textSegments[0].textAttributes["test"])
        XCTAssertEqual(sut.textSegments[1].text, "cd")
        XCTAssertNil(sut.textSegments[1].textAttributes["test"])
        XCTAssertNotNil(sut.textSegments[1].textAttributes["test2"])
        XCTAssertEqual(sut.textSegments[2].text, "ef")
        XCTAssertNotNil(sut.textSegments[2].textAttributes["test"])
    }
    
    func testRemoveAllAttributes() {
        var sut = AttributedText()
        sut.append("abcdef", attributes: ["test": TestAttribute()])
        
        sut.removeAllAttributes(TextRange(start: 2, length: 2))
        
        XCTAssertEqual(sut.textSegments.count, 3)
        XCTAssertEqual(sut.textSegments[0].text, "ab")
        XCTAssertNotNil(sut.textSegments[0].textAttributes["test"])
        XCTAssertEqual(sut.textSegments[1].text, "cd")
        XCTAssert(sut.textSegments[1].textAttributes.isEmpty)
        XCTAssertEqual(sut.textSegments[2].text, "ef")
        XCTAssertNotNil(sut.textSegments[2].textAttributes["test"])
    }
}

private class TestAttribute: TextAttributeType {
    func isEqual(to other: TextAttributeType) -> Bool {
        other as? TestAttribute === self
    }
}

private class TestAttribute2: TextAttributeType {
    func isEqual(to other: TextAttributeType) -> Bool {
        other as? TestAttribute2 === self
    }
}

extension AttributedText.AttributeName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
