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

    func testStrokeRectangles() throws {
        let (img, sut) = makeSut(size: .init(width: 500, height: 100))

        sut.clear(.white)

        sut.setStroke(.black)

        let rectangles: [UIRectangle] = [
            .init(left: 1.046719124858879, top: -19.972590695091476, right: 41.04671912485888, bottom: -19.951281005196485),
            .init(left: -1.3951294748825116, top: -19.951281005196485, right: 41.04671912485888, bottom: -19.696155060244163),
            .init(left: -1.3951294748825116, top: -19.696155060244163, right: 43.4729635533386, bottom: -19.63254366895328),
            .init(left: -3.816179907530892, top: -19.63254366895328, right: 43.4729635533386, bottom: -19.126095119260707),
            .init(left: -3.816179907530892, top: -19.126095119260707, right: 45.847434094454734, bottom: -19.02113032590307),
            .init(left: -6.180339887498951, top: -19.02113032590307, right: 45.847434094454734, bottom: -18.27090915285202),
            .init(left: -6.180339887498951, top: -18.27090915285202, right: 48.134732861516, bottom: -18.126155740733),
            .init(left: -8.452365234813984, top: -18.126155740733, right: 48.134732861516, bottom: -17.143346014042248),
            .init(left: -8.452365234813984, top: -17.143346014042248, right: 50.300761498201084, bottom: -16.96096192312852),
            .init(left: -10.5983852846641, top: -16.96096192312852, right: 50.300761498201084, bottom: -15.760215072134436),
            .init(left: -10.5983852846641, top: -15.760215072134436, right: 52.31322950651317, bottom: -15.542919229139411),
            .init(left: -12.586407820996756, top: -15.542919229139411, right: 52.31322950651317, bottom: -14.142135623730955),
            .init(left: -12.586407820996756, top: -14.142135623730955, right: 54.14213562373095, bottom: -13.893167409179947),
            .init(left: -14.386796006773022, top: -13.893167409179947, right: 54.14213562373095, bottom: -12.313229506513164),
            .init(left: -14.386796006773022, top: -12.313229506513164, right: 55.76021507213444, bottom: -12.036300463040968),
            .init(left: -15.972710200945857, top: -12.036300463040968, right: 55.76021507213444, bottom: -10.30076149820109),
            .init(left: -15.972710200945857, top: -10.30076149820109, right: 57.14334601404225, bottom: -10.000000000000002),
            .init(left: -17.32050807568877, top: -10.000000000000002, right: 57.143346014042244, bottom: -8.134732861516003),
            .init(left: -17.32050807568877, top: -8.134732861516003, right: 58.27090915285202, bottom: -7.814622569785471),
            .init(left: -18.410097069048806, top: -7.814622569785471, right: 58.27090915285203, bottom: -5.847434094454743),
            .init(left: -18.410097069048806, top: -5.847434094454743, right: 59.12609511926071, bottom: -5.51274711633998),
            .init(left: 62.31322950651317, top: -4.696155060244163, right: 63.4729635533386, bottom: -4.142135623730955),
            .init(left: -19.225233918766378, top: -5.51274711633998, right: 59.12609511926071, bottom: -3.472963553338608),
            .init(left: 64.14213562373095, top: -4.126095119260707, right: 65.84743409445474, bottom: -3.2709091528520204),
            .init(left: -19.225233918766378, top: -3.472963553338608, right: 59.696155060244166, bottom: -3.1286893008046146),
            .init(left: 64.14213562373095, top: -3.2709091528520204, right: 68.134732861516, bottom: -2.3132295065131636),
            .init(left: 65.76021507213444, top: -2.3132295065131636, right: 68.134732861516, bottom: -2.1433460140422476),
            .init(left: -19.753766811902757, top: -3.1286893008046146, right: 59.69615506024416, bottom: -1.0467191248588872),
            .init(left: 65.76021507213444, top: -2.1433460140422476, right: 70.3007614982011, bottom: -0.7602150721344358),
            .init(left: -19.753766811902757, top: -1.0467191248588874, right: 59.972590695091476, bottom: -0.697989934050018),
            .init(left: 65.76021507213444, top: -0.7602150721344358, right: 72.31322950651318, bottom: -0.697989934050018),
            .init(left: 65.76021507213444, top: -0.697989934050018, right: 72.31322950651317, bottom: -0.30076149820109066),
            .init(left: 67.14334601404224, top: -0.30076149820109066, right: 72.31322950651317, bottom: 0.8578643762690454),
            .init(left: 67.14334601404224, top: 0.8578643762690454, right: 74.14213562373095, bottom: 1.865267138483997),
        ]

        let total = UIRectangle.union(rectangles)
        let offset = -total.location
        let scale = total.size.width > total.size.height
            ? Double(img.width) / total.size.width
            : Double(img.height) / total.size.height
        
        let m: UIMatrix = .translation(offset * 0.9) * .scaling(scale: scale * 0.9)

        for rect in rectangles {
            sut.stroke(rect.transformedBounds(m))
        }

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
