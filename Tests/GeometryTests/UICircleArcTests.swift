import XCTest

@testable import Geometry

class UICircleArcTests: XCTestCase {
    func testContainsAsPie_positiveSweepAngle_acrossOriginQuadrant() {
        let sut = makeSut(.zero, 10, start: -.pi * 0.1, sweep: .pi * 0.5)

        XCTAssertTrue(sut.containsAsPie(.zero))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 1.1))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 1.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(-.pi * 0.3) * 0.5))
    }

    func testContainsAsPie_positiveSweepAngle_singleQuadrantSpan() {
        let sut = makeSut(.zero, 10, start: .pi * 0.1, sweep: .pi * 0.7)

        XCTAssertTrue(sut.containsAsPie(.zero))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 1.1))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 1.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(-.pi * 0.3) * 0.5))
    }

    func testContainsAsPie_positiveSweepAngle_twoQuadrantSpan() {
        let sut = makeSut(.zero, 10, start: .pi * 0.1, sweep: .pi * 1.3)

        XCTAssertTrue(sut.containsAsPie(.zero))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 0.5))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 1.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 1.1))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(-.pi * 0.3) * 0.5))
    }

    func testContainsAsPie_negativeSweepAngle_singleQuadrantSpan() {
        let sut = makeSut(.zero, 10, start: .pi * 0.8, sweep: -.pi * 0.7)

        XCTAssertTrue(sut.containsAsPie(.zero))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 1.1))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 1.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(-.pi * 0.3) * 0.5))
    }

    func testContainsAsPie_negativeSweepAngle_twoQuadrantSpan() {
        let sut = makeSut(.zero, 10, start: .pi * 0.1, sweep: .pi * 1.3)

        XCTAssertTrue(sut.containsAsPie(.zero))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 0.5))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 1.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 1.1))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(-.pi * 0.3) * 0.5))
    }

    func testContainsAsPie_positiveSweepAngle_fullCircle() {
        let sut = makeSut(.zero, 10, start: 0, sweep: .pi * 2)

        XCTAssertTrue(sut.containsAsPie(.zero))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 0.5))
        XCTAssertTrue(sut.containsAsPie(sut.pointOnAngle(.pi * 1.3) * 0.5))
        XCTAssertFalse(sut.containsAsPie(sut.pointOnAngle(.pi * 0.3) * 1.1))
    }
}

// MARK: - Test internals

private func makeSut(_ center: UIPoint, _ radius: Double, start: Double, sweep: Double) -> UICircleArc {
    UICircleArc(center: center, radius: radius, startAngle: start, sweepAngle: sweep)
}
