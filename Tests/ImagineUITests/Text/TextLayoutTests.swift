import XCTest
import ImagineUI
import SwiftBlend2D
import TestUtils

class TextLayoutTests: SnapshotTestCase {
    override var snapshotPath: String {
        return pathToSnapshots()
    }
    
    override var snapshotFailuresPath: String {
        return pathToSnapshotFailures()
    }
    
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
    
    func testRenderInitWithAttributedText() {
        var attributedText = AttributedText()
        attributedText.append("small", attributes: [.font: makeFont(size: 10)])
        attributedText.append("\nmedium", attributes: [.font: makeFont(size: 20)])
        attributedText.append("\nlarge", attributes: [.font: makeFont(size: 30)])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.size.x),
                          height: Int(sut.size.y),
                          format: .prgb32)
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        ctx.setFillStyle(BLRgba32.black)
        
        sut.fillText(in: ctx, location: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderInitWithAttributedTextFontChangeDuringSentence() {
        var attributedText = AttributedText()
        attributedText.append("small", attributes: [.font: makeFont(size: 10)])
        attributedText.append("medium", attributes: [.font: makeFont(size: 20)])
        attributedText.append("large", attributes: [.font: makeFont(size: 30)])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.size.x),
                          height: Int(sut.size.y),
                          format: .prgb32)
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        ctx.setFillStyle(BLRgba32.black)
        
        sut.fillText(in: ctx, location: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderAttributedTextBackgroundColor() {
        var attributedText = AttributedText()
        attributedText.append("small", attributes: [
            .font: makeFont(size: 10),
            .backgroundColor: BLRgba32.red
        ])
        attributedText.append("medium", attributes: [
            .font: makeFont(size: 20),
            .backgroundColor: BLRgba32.blue
        ])
        attributedText.append("large", attributes: [
            .font: makeFont(size: 30),
            .backgroundColor: BLRgba32.green,
            .foregroundColor: BLRgba64.gray,
            .cornerRadius: Vector2(x: 4, y: 4)
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.size.x),
                          height: Int(sut.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        ctx.setFillStyle(BLRgba32.black)
        
        sut.renderText(in: ctx, location: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderBaselineBackgroundBounds() {
        var attributedText = AttributedText()
        attributedText.append("small", attributes: [
            .font: makeFont(size: 10),
            .backgroundColor: BLRgba32.red,
            .backgroundColorBounds: TextBackgroundBoundsAttribute.largestBaselineBounds
        ])
        attributedText.append("medium", attributes: [
            .font: makeFont(size: 20),
            .backgroundColor: BLRgba32.blue,
            .backgroundColorBounds: TextBackgroundBoundsAttribute.largestBaselineBounds
        ])
        attributedText.append("large", attributes: [
            .font: makeFont(size: 30),
            .backgroundColor: BLRgba32.green,
            .foregroundColor: BLRgba64.gray,
            .cornerRadius: Vector2(x: 4, y: 4),
            .backgroundColorBounds: TextBackgroundBoundsAttribute.largestBaselineBounds
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.size.x),
                          height: Int(sut.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        ctx.setFillStyle(BLRgba32.black)
        
        sut.renderText(in: ctx, location: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderStrokeColor() {
        var attributedText = AttributedText()
        attributedText.append("Test text", attributes: [
            .foregroundColor: BLRgba32.white,
            .strokeColor: BLRgba32.black,
            .strokeWidth: 1.0
        ])
        attributedText.append(" with stroke", attributes: [
            .strokeColor: BLRgba32.red,
            .strokeWidth: 2.0
        ])
        attributedText.append(" color", attributes: [
            .strokeColor: BLRgba32.blue,
            .strokeWidth: 5.0
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.size.x),
                          height: Int(sut.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        
        sut.renderText(in: ctx, location: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func makeSut(text: String) -> TextLayout {
        let font = makeFont(size: 20)
        
        return TextLayout(font: font, text: text)
    }
    
    func makeSut(attributedText: AttributedText) -> TextLayout {
        let font = makeFont(size: 20)
        
        return TextLayout(font: font, attributedText: attributedText)
    }
    
    func makeFont(size: Float) -> BLFont {
        let face = try! BLFontFace(fromFile: "\(pathToResources())/NotoSans-Regular.ttf")
        return BLFont(fromFace: face, size: size)
    }
}
