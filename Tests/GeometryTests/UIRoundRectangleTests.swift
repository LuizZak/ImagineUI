import XCTest

@testable import Geometry

class UIRoundRectangleTests: XCTestCase {
    func testContains_equalRadiusXRadiusY() {
        let sut = makeSut(
            .zero, .init(width: 10, height: 12),
            radius: .init(repeating: 2)
        )

        XCTAssertTrue(sut.contains(sut.center))
        XCTAssertTrue(sut.contains(sut.leftLeft))
        XCTAssertTrue(sut.contains(sut.topTop))
        XCTAssertTrue(sut.contains(sut.rightRight))
        XCTAssertTrue(sut.contains(sut.bottomBottom))
        XCTAssertFalse(sut.contains(sut.topLeft))
        XCTAssertFalse(sut.contains(sut.topRight))
        XCTAssertFalse(sut.contains(sut.bottomRight))
        XCTAssertFalse(sut.contains(sut.bottomLeft))
    }

    func testContains_unequalRadiusXRadiusY() {
        let sut = makeSut(
            .zero, .init(width: 10, height: 12),
            radius: .init(x: 2, y: 4)
        )

        XCTAssertTrue(sut.contains(sut.center))
        XCTAssertTrue(sut.contains(sut.leftLeft))
        XCTAssertTrue(sut.contains(sut.topTop))
        XCTAssertTrue(sut.contains(sut.rightRight))
        XCTAssertTrue(sut.contains(sut.bottomBottom))
        XCTAssertFalse(sut.contains(sut.topLeft))
        XCTAssertFalse(sut.contains(sut.topRight))
        XCTAssertFalse(sut.contains(sut.bottomRight))
        XCTAssertFalse(sut.contains(sut.bottomLeft))
    }
}

// MARK: - Test internals

private func makeSut(_ location: UIPoint, _ size: UISize, radius: UIVector) -> UIRoundRectangle {
    UIRoundRectangle(location: location, size: size, radiusX: radius.x, radiusY: radius.y)
}

private extension UIRoundRectangle {
    var topTop: UIPoint {
        UIPoint(x: centerX, y: top)
    }

    var leftLeft: UIPoint {
        UIPoint(x: left, y: centerY)
    }

    var rightRight: UIPoint {
        UIPoint(x: right, y: centerY)
    }

    var bottomBottom: UIPoint {
        UIPoint(x: centerX, y: bottom)
    }
}
