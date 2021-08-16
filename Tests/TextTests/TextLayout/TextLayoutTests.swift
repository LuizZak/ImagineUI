import XCTest
import Geometry

@testable import Text

class TextLayoutTests: XCTestCase {
    func testLocationOfCharacter() {
        let sut = makeSut(text: "A string")
        
        let location = sut.locationOfCharacter(index: 2)
        
        XCTAssertEqual(location, Vector2(x: 17.978515625, y: 0.0))
    }
    
    func testLocationOfCharacterOffBounds() {
        let sut = makeSut(text: "A string")
        
        let location = sut.locationOfCharacter(index: 100)
        
        XCTAssertEqual(location, sut.locationOfCharacter(index: sut.text.count))
    }
    
    func testHitTestPoint() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(Vector2(x: 3, y: 2))
        
        XCTAssert(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 0)
        XCTAssertFalse(hitTest.isTrailing)
    }
    
    func testHitTestPointTrailing() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(Vector2(x: 12, y: 2))
        
        XCTAssert(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 0)
        XCTAssert(hitTest.isTrailing)
    }
    
    func testHitTestPointOutsideBoxRight() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(Vector2(x: 200, y: 0))
        
        XCTAssertFalse(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 7)
    }
    
    func testHitTestPointOutsideBoxBelow() {
        let sut = makeSut(text: "A string")
        
        let hitTest = sut.hitTestPoint(Vector2(x: 14, y: 50))
        
        XCTAssertFalse(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 1)
    }
    
    func testHitTestPointMultiline() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let hitTest = sut.hitTestPoint(Vector2(x: 14, y: 60))
        
        XCTAssertFalse(hitTest.isInside)
        XCTAssertEqual(hitTest.textPosition, 10)
    }
    
    func testBoundsForCharacter() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacters(startIndex: 7, length: 1)
        
        XCTAssertEqual(result, [
            Rectangle(x: 60.556640625, y: 0.0, width: 12.3046875, height: 27.236328125),
        ])
    }
    
    func testBoundsForCharacter_lineBreak() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacters(startIndex: 8, length: 1)
        
        XCTAssertEqual(result, [
            Rectangle(x: 72.861328125, y: 0.0, width: 12.001953125, height: 27.236328125)
        ])
    }
    
    func testBoundsForCharacter_postLineBreak() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacters(startIndex: 9, length: 1)
        
        XCTAssertEqual(result, [
            Rectangle(x: 0.0, y: 27.236328125, width: 12.783203125, height: 27.236328125)
        ])
    }
    
    func testBoundsForCharacters() {
        let sut = makeSut(text: "A string\nAnother line")
        
        let result = sut.boundsForCharacters(startIndex: 5, length: 5)
        
        XCTAssertEqual(result, [
            Rectangle(x: 43.037109375, y: 0.0, width: 5.15625, height: 27.236328125),
            Rectangle(x: 48.193359375, y: 0.0, width: 12.36328125, height: 27.236328125),
            Rectangle(x: 60.556640625, y: 0.0, width: 12.3046875, height: 27.236328125),
            Rectangle(x: 72.861328125, y: 0.0, width: 12.001953125, height: 27.236328125),
            Rectangle(x: 0.0, y: 27.236328125, width: 12.783203125, height: 27.236328125)
        ])
    }
    
    func testBoundsForCharacters_performance() {
        let sut = makeSut(text: "A string\nAnother line")
        
        measure {
            for _ in 0..<1000 {
                _ = sut.boundsForCharacters(startIndex: 5, length: 5)
            }
        }
    }
}

extension TextLayoutTests {
    func makeSut(text: String) -> TextLayout {
        let font = makeFont(size: 20)
        
        return TextLayout(font: font, text: text)
    }
    
    func makeSut(attributedText: AttributedText) -> TextLayout {
        let font = makeFont(size: 20)
        
        return TextLayout(font: font, attributedText: attributedText)
    }
    
    func makeFont(size: Float) -> Font {
        return TestFont(size: size)
    }
}
