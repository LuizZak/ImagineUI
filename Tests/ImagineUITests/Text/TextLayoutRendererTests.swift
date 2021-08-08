import XCTest
import Geometry
import SwiftBlend2D
import TestUtils

@testable import ImagineUI

class TextLayoutRendererTests: SnapshotTestCase {
    override var snapshotPath: String {
        return pathToSnapshots()
    }
    
    override var snapshotFailuresPath: String {
        return pathToSnapshotFailures()
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
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        ctx.setFillStyle(BLRgba32.black)
        
        sut.render(to: ctx, origin: .zero)
        
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
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        ctx.setFillStyle(BLRgba32.black)
        
        sut.render(to: ctx, origin: .zero)
        
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
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        
        sut.render(to: ctx, origin: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderUnderlinedText() {
        var attributedText = AttributedText()
        attributedText.append("Test text")
        attributedText.append(" with underlined", attributes: [
            .underlineStyle: UnderlineStyleTextAttribute.single
        ])
        attributedText.append(" text", attributes: [
            .underlineStyle: UnderlineStyleTextAttribute.single,
            .underlineColor: BLRgba32.red
        ])
        attributedText.addAttributes(attributedText.textRange, [
            .foregroundColor: BLRgba32.black
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        
        sut.render(to: ctx, origin: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderUnderlinedTextWithDifferentFonts() {
        var attributedText = AttributedText()
        attributedText.append("Test text with", attributes: [
            .font: makeFont(size: 20),
            .underlineStyle: UnderlineStyleTextAttribute.single
        ])
        attributedText.append(" underlined text of", attributes: [
            .font: makeFont(size: 40),
            .underlineStyle: UnderlineStyleTextAttribute.single
        ])
        attributedText.append(" different font sizes", attributes: [
            .font: makeFont(size: 60),
            .underlineStyle: UnderlineStyleTextAttribute.single
        ])
        attributedText.addAttributes(attributedText.textRange, [
            .foregroundColor: BLRgba32.black
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        
        sut.render(to: ctx, origin: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderStrikethroughText() {
        var attributedText = AttributedText()
        attributedText.append("Test text")
        attributedText.append(" with strikethrough", attributes: [
            .strikethroughStyle: StrikethroughStyleTextAttribute.single
        ])
        attributedText.append(" text", attributes: [
            .strikethroughStyle: StrikethroughStyleTextAttribute.single,
            .strikethroughColor: BLRgba32.red
        ])
        attributedText.addAttributes(attributedText.textRange, [
            .foregroundColor: BLRgba32.black
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        
        sut.render(to: ctx, origin: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func testRenderStrikethroughTextWithDifferentFonts() {
        var attributedText = AttributedText()
        attributedText.append("Test text with", attributes: [
            .font: makeFont(size: 20),
            .strikethroughStyle: StrikethroughStyleTextAttribute.single
        ])
        attributedText.append(" strikethrough text of", attributes: [
            .font: makeFont(size: 40),
            .strikethroughStyle: StrikethroughStyleTextAttribute.single
        ])
        attributedText.append(" different font sizes", attributes: [
            .font: makeFont(size: 60),
            .strikethroughStyle: StrikethroughStyleTextAttribute.single
        ])
        attributedText.addAttributes(attributedText.textRange, [
            .foregroundColor: BLRgba32.black
        ])
        let sut = makeSut(attributedText: attributedText)
        let img = BLImage(width: Int(sut.textLayout.size.x),
                          height: Int(sut.textLayout.size.y),
                          format: .prgb32)
        
        let ctx = BLContext(image: img)!
        ctx.compOp = .sourceCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .sourceOver
        
        sut.render(to: ctx, origin: .zero)
        
        ctx.end()
        assertImageMatch(img)
    }
    
    func makeSut(text: String) -> TextLayoutRenderer {
        let font = makeFont(size: 20)
        
        let layout = TextLayout(font: font, text: text)
        
        return TextLayoutRenderer(textLayout: layout)
    }
    
    func makeSut(attributedText: AttributedText) -> TextLayoutRenderer {
        let font = makeFont(size: 20)
        
        let layout = TextLayout(font: font, attributedText: attributedText)
        
        return TextLayoutRenderer(textLayout: layout)
    }
    
    func makeFont(size: Float) -> BLFont {
        let face = try! BLFontFace(fromFile: "\(pathToResources())/NotoSans-Regular.ttf")
        return BLFont(fromFace: face, size: size)
    }
}
