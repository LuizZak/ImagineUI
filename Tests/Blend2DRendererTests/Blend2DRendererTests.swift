import XCTest
import SwiftBlend2D
import Geometry
import Text
import Rendering
import TestUtils

@testable import Blend2DRenderer

class Blend2DRendererTests: SnapshotTestCase {
    override var snapshotPath: String {
        return TestPaths.pathToSnapshots(testTarget: "Blend2DRendererTests")
    }
    
    override var snapshotFailuresPath: String {
        return TestPaths.pathToSnapshotFailures(testTarget: "Blend2DRendererTests")
    }
    
    func testFill_UIBezier() throws {
        let bezier = makeTestBezier()
        let (img, sut) = makeSut(size: .init(width: 480, height: 480))

        sut.clear(.black)
        
        sut.setFill(.white)
        sut.fill(bezier)

        sut._context.end()

        try assertImageMatch(img)
    }
    
    func testStroke_UIBezier() throws {
        let bezier = makeTestBezier()
        let (img, sut) = makeSut(size: .init(width: 480, height: 480))

        sut.clear(.black)
        
        sut.setStroke(.white)
        sut.setStrokeWidth(5)
        sut.stroke(bezier)

        sut._context.end()

        try assertImageMatch(img)
    }

    func testStroke_UIBezierBounds() throws {
        let bezier = makeTestBezier()
        let (img, sut) = makeSut(size: .init(width: 480, height: 480))

        sut.clear(.black)
        
        sut.setStroke(.white)
        sut.setStrokeWidth(2)
        sut.stroke(bezier)

        sut.setStroke(.red)
        sut.setStrokeWidth(2)
        sut.stroke(bezier.bounds())

        sut._context.end()

        try assertImageMatch(img)
    }

    // MARK: - Test internals

    func makeTestBezier() -> UIBezier {
        var bezier = UIBezier()

        bezier.move(toX: 26, y: 31)
        bezier.cubic(
            to: UIPoint(x: 25, y: 464),
            p1: UIPoint(x: 642, y: 132),
            p2: UIPoint(x: 587, y: -136)
        )
        bezier.cubic(
            to: UIPoint(x: 27, y: 31),
            p1: UIPoint(x: 882, y: 404),
            p2: UIPoint(x: 144, y: 267)
        )

        return bezier
    }
    
    func makeSut(size: UISize) -> (BLImage, Blend2DRenderer) {
        let (img, ctx) = makeImageContext(with: size)

        let renderer = Blend2DRenderer(context: ctx)
        return (img, renderer)
    }

    func makeImageContext(with size: UISize) -> (BLImage, BLContext) {
        let img = BLImage(
            width: Int(size.width),
            height: Int(size.height),
            format: .prgb32
        )
        
        return (img, BLContext(image: img)!)
    }
}
