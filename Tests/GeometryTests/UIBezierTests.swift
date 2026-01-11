import XCTest

@testable import Geometry

class UIBezierTests: XCTestCase {
    func testDrawOperations() {
        var bezier = UIBezier()
        XCTAssertTrue(bezier.drawOperations().isEmpty)

        bezier.line(toX: 10, y: 20)

        XCTAssertFalse(bezier.drawOperations().isEmpty)
    }

    func testClear() {
        var bezier = UIBezier()
        bezier.line(toX: 10, y: 20)
        XCTAssertFalse(bezier.drawOperations().isEmpty)

        bezier.clear()

        XCTAssertTrue(bezier.drawOperations().isEmpty)
    }
}
