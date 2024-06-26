import XCTest
import Geometry
import TestUtils
import Blend2DRenderer

@testable import ImagineUICore

extension SnapshotTestCase {
    func recordSnapshot(
        _ view: View,
        testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        let img = try produceSnapshot(view)

        try recordImage(img, testName, file: file, line: line)
    }

    func matchSnapshot(
        _ view: View,
        testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        if forceRecordMode {
            try recordSnapshot(view, testName: testName, file: file, line: line)
            return
        }

        let img = try produceSnapshot(view)

        try assertImageMatch(img, testName, file: file, line: line)
    }

    func produceSnapshot(_ view: View) throws -> BLImage {
        let bounds = view.boundsForRedraw()
        if bounds.size.width <= .zero && bounds.size.height <= .zero {
            throw SnapshotError.emptyViewBounds
        }

        let image = BLImage(
            width: Int(ceil(bounds.width)),
            height: Int(ceil(bounds.height)),
            format: .prgb32
        )

        let ctx = BLContext(image: image)!
        ctx.clearAll()

        ctx.translate(x: -bounds.x, y: -bounds.y)

        let renderer = Blend2DRenderer(context: ctx)

        let region = UIRegion(rectangle: bounds)
        view.renderRecursive(in: renderer, screenRegion: UIRegionClipRegion(region: region))

        ctx.end()

        return image
    }

    enum SnapshotError: Error {
        case emptyViewBounds
    }
}
