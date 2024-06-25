import XCTest
import SwiftBlend2D
import Geometry
import Text
import Rendering
import TestUtils

@testable import Blend2DRenderer

class TextLayoutRendererTests: SnapshotTestCase {
    override var snapshotPath: String {
        return TestPaths.pathToSnapshots(testTarget: "Blend2DRendererTests")
    }

    override var snapshotFailuresPath: String {
        return TestPaths.pathToSnapshotFailures(testTarget: "Blend2DRendererTests")
    }

    override func setUp() {
        // forceRecordMode = true
    }

    func testRenderAttributedTextBackgroundColor() throws {
        var attributedText = AttributedText()
        attributedText.append("small", attributes: [
            .font: makeFont(size: 10),
            .backgroundColor: Color.red
        ])
        attributedText.append("medium", attributes: [
            .font: makeFont(size: 20),
            .backgroundColor: Color.blue
        ])
        attributedText.append("large", attributes: [
            .font: makeFont(size: 30),
            .backgroundColor: Color.green,
            .foregroundColor: Color.gray,
            .cornerRadius: UIVector(x: 4, y: 4)
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver
        ctx.setFillStyle(BLRgba32.black)

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderBaselineBackgroundBounds() throws {
        var attributedText = AttributedText()
        attributedText.append("small", attributes: [
            .font: makeFont(size: 10),
            .backgroundColor: Color.red,
            .backgroundColorBounds: TextBackgroundBoundsAttribute.largestBaselineBounds
        ])
        attributedText.append("medium", attributes: [
            .font: makeFont(size: 20),
            .backgroundColor: Color.blue,
            .backgroundColorBounds: TextBackgroundBoundsAttribute.largestBaselineBounds
        ])
        attributedText.append("large", attributes: [
            .font: makeFont(size: 30),
            .backgroundColor: Color.green,
            .foregroundColor: Color.gray,
            .cornerRadius: UIVector(x: 4, y: 4),
            .backgroundColorBounds: TextBackgroundBoundsAttribute.largestBaselineBounds
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver
        ctx.setFillStyle(BLRgba32.black)

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderStrokeColor() throws {
        var attributedText = AttributedText()
        attributedText.append("Test text", attributes: [
            .foregroundColor: Color.white,
            .strokeColor: Color.black,
            .strokeWidth: 1.0
        ])
        attributedText.append(" with stroke", attributes: [
            .strokeColor: Color.red,
            .strokeWidth: 2.0
        ])
        attributedText.append(" color", attributes: [
            .strokeColor: Color.blue,
            .strokeWidth: 5.0
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderUnderlinedText() throws {
        var attributedText = AttributedText()
        attributedText.append("Test text")
        attributedText.append(" with underlined", attributes: [
            .underlineStyle: UnderlineStyleTextAttribute.single
        ])
        attributedText.append(" text", attributes: [
            .underlineStyle: UnderlineStyleTextAttribute.single,
            .underlineColor: Color.red
        ])
        attributedText.addAttributes(attributedText.textRange, [
            .foregroundColor: Color.black
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderUnderlinedTextWithDifferentFonts() throws {
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
            .foregroundColor: Color.black
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderStrikethroughText() throws {
        var attributedText = AttributedText()
        attributedText.append("Test text")
        attributedText.append(" with strikethrough", attributes: [
            .strikethroughStyle: StrikethroughStyleTextAttribute.single
        ])
        attributedText.append(" text", attributes: [
            .strikethroughStyle: StrikethroughStyleTextAttribute.single,
            .strikethroughColor: Color.red
        ])
        attributedText.addAttributes(attributedText.textRange, [
            .foregroundColor: Color.black
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderStrikethroughTextWithDifferentFonts() throws {
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
            .foregroundColor: Color.black
        ])
        let sut = makeSut(attributedText: attributedText)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img)
    }

    func testRenderImageAttribute() throws {
        try runImageAttributeTest(alignment: nil)
    }

    func testRenderImageAttribute_verticalAlignment_baseline() throws {
        try runImageAttributeTest(alignment: .baseline)
    }

    func testRenderImageAttribute_verticalAlignment_underline() throws {
        try runImageAttributeTest(alignment: .underline)
    }

    func testRenderImageAttribute_verticalAlignment_capHeight() throws {
        try runImageAttributeTest(alignment: .capHeight)
    }

    func testRenderImageAttribute_verticalAlignment_ascent() throws {
        try runImageAttributeTest(alignment: .ascent)
    }

    func testRenderImageAttribute_verticalAlignment_centralized() throws {
        try runImageAttributeTest(alignment: .centralized)
    }

    // MARK: - Test internals

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

    func makeFont(size: Float) -> Font {
        let face = try! BLFontFace(fromFile: TestPaths.pathToTestFontFace())
        return Blend2DFont(font: BLFont(fromFace: face, size: size))
    }

    func makeImageContext(for textLayout: TextLayoutType) -> (BLImage, BLContext) {
        makeImageContext(with: textLayout.size)
    }

    func makeImageContext(with size: UISize) -> (BLImage, BLContext) {
        let img = BLImage(
            width: Int(size.width),
            height: Int(size.height),
            format: .prgb32
        )

        return (img, BLContext(image: img)!)
    }

    func runImageAttributeTest(
        alignment: ImageVerticalAlignmentAttribute?,
        record: Bool = false,
        function: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let imageSize = UIIntSize(width: 20, height: 30)
        let image = Blend2DImageRenderContext(size: imageSize).withRenderer { renderer in
            let topLeft: UIPoint = .zero
            let topRight: UIPoint = .init(x: Double(imageSize.width), y: 0)
            let bottomRight: UIPoint = .init(imageSize)
            let bottomLeft: UIPoint = .init(x: 0, y: Double(imageSize.height))

            renderer.clear(.white)
            renderer.setStroke(.red)
            renderer.strokeLine(start: topLeft, end: bottomRight)
            renderer.strokeLine(start: bottomLeft, end: topRight)
        }
        var attributes: AttributedText.Attributes = [
            .image: ImageAttribute(image: image)
        ]
        attributes[.imageVerticalAlignment] = alignment
        let input: AttributedText = """
        \("A", attributes: attributes)b
        """
        let sut = makeSut(attributedText: input)

        let (img, ctx) = makeImageContext(for: sut.textLayout)

        ctx.compOp = .srcCopy
        ctx.setFillStyle(BLRgba32.transparentBlack)
        ctx.fillAll()
        ctx.compOp = .srcOver
        ctx.setFillStyle(BLRgba32.black)

        sut.render(in: ctx, location: .zero)

        ctx.end()
        try assertImageMatch(img, function, record: record, file: file, line: line)
    }
}
