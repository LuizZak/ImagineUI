import XCTest

@testable import Geometry

class UIAngleSweepTests: XCTestCase {
    func testContains() {
        let sut = makeSut(.pi / 4, .pi / 2)

        XCTAssertTrue(sut.contains(sut.start))
        XCTAssertTrue(sut.contains(sut.stop))
        XCTAssertTrue(sut.contains(UIAngle.pi / 3))
        XCTAssertFalse(sut.contains(UIAngle.pi * (3 / 2)))
    }

    func testContains_wrapAround() {
        let sut = makeSut(.init(radians: .pi * 1.75), .pi * 0.33)

        XCTAssertTrue(sut.contains(0.0))
        XCTAssertTrue(sut.contains(sut.start))
        XCTAssertTrue(sut.contains(sut.stop))
        XCTAssertFalse(sut.contains(UIAngle.pi / 2))
    }

    func testContains_wrapAround_largeSweep() {
        let sut = makeSut(.init(radians: .pi * 1.55), .pi * 1.5)

        XCTAssertTrue(sut.contains(0.0))
        XCTAssertTrue(sut.contains(sut.start))
        XCTAssertTrue(sut.contains(sut.stop))
        XCTAssertTrue(sut.contains(UIAngle.pi / 2))
        XCTAssertFalse(sut.contains(.pi * 1.51))
        XCTAssertFalse(sut.contains(.pi * 1.49))
    }

    func testContains_negativeSweep_wrapAround() {
        let sut = makeSut(.pi / 4, -.pi)

        XCTAssertTrue(sut.contains(.pi * 0.1))
        XCTAssertTrue(sut.contains(.pi * 1.55))
        XCTAssertTrue(sut.contains(sut.start))
        XCTAssertTrue(sut.contains(sut.stop))
        XCTAssertFalse(sut.contains(.pi * 1.15))
        XCTAssertFalse(sut.contains(.pi * 0.75))
    }

    func testContains_negativeSweep() {
        let sut = makeSut(.pi * 1.5, -.pi)

        XCTAssertTrue(sut.contains(.pi * 1.45))
        XCTAssertTrue(sut.contains(sut.start))
        XCTAssertTrue(sut.contains(sut.stop))
        XCTAssertTrue(sut.contains(.pi * 1.15))
        XCTAssertTrue(sut.contains(.pi * 0.75))
        XCTAssertFalse(sut.contains(.pi * 1.9))
        XCTAssertFalse(sut.contains(.pi * 0.1))
    }

    func testRelativeToStart() {
        let sut = makeSut(.pi * 0.25, .pi * 0.5)

        XCTAssertEqual(sut.relativeToStart(.pi * 0.25), 0.0)
        XCTAssertEqual(sut.relativeToStart(.pi * 0.5), .pi * 0.25)
        XCTAssertEqual(sut.relativeToStart(.pi * 0.15), -.pi * 0.1)
    }

    func testRelativeToStart_wrapAround_startValue() {
        let sut = makeSut(.pi * 1.9, .pi * 0.5)

        XCTAssertEqual(sut.relativeToStart(.pi * 1.95), .pi * 0.05)
        XCTAssertEqual(sut.relativeToStart(0), .pi * 0.1)
        XCTAssertEqual(sut.relativeToStart(.pi * 0.5), .pi * 0.6)
        XCTAssertEqual(sut.relativeToStart(.pi * 1.1), -.pi * 0.80, accuracy: 1e-10)
    }

    func testRelativeToStart_wrapAround_searchValue() {
        let sut = makeSut(.pi * 0.1, .pi * 0.5)

        XCTAssertEqual(sut.relativeToStart(.pi * 1.95), -.pi * 0.15)
        XCTAssertEqual(sut.relativeToStart(0), -.pi * 0.1)
        XCTAssertEqual(sut.relativeToStart(.pi * 0.5), .pi * 0.4)
        XCTAssertEqual(sut.relativeToStart(.pi * 1.1), -.pi, accuracy: 1e-10)
    }

    func testClamped() {
        let sut = makeSut(.pi * 0.25, .pi * 0.5)

        XCTAssertEqual(sut.clamped(0), .pi * 0.25)
        XCTAssertEqual(sut.clamped(.pi * 0.5), .pi * 0.5)
        XCTAssertEqual(sut.clamped(.pi * 1.4), .pi * 0.75)
    }

    func testClamped_wrapAround() {
        let sut = makeSut(.pi * 1.5, .pi)

        XCTAssertEqual(sut.clamped(0), 0)
        XCTAssertEqual(sut.clamped(.pi * 0.25), .pi * 0.25)
        XCTAssertEqual(sut.clamped(.pi * 1.75), .pi * 1.75)
        XCTAssertEqual(sut.clamped(.pi * 0.85), .pi * 0.5)
        XCTAssertEqual(sut.clamped(.pi * 0.5), .pi * 0.5)
        XCTAssertEqual(sut.clamped(.pi * 1.5), .pi * 1.5)
    }

    func testClamped_negativeSweep() {
        let sut = makeSut(.pi * 0.75, -.pi * 0.5)

        XCTAssertEqual(sut.clamped(0), .pi * 0.25)
        XCTAssertEqual(sut.clamped(.pi * 0.5), .pi * 0.5)
        XCTAssertEqual(sut.clamped(.pi * 1.4), .pi * 0.75)
    }

    func testClamped_negativeSweep_wrapAround() {
        let sut = makeSut(.pi * 0.5, -.pi)

        XCTAssertEqual(sut.clamped(0), 0)
        XCTAssertEqual(sut.clamped(.pi * 0.25), .pi * 0.25)
        XCTAssertEqual(sut.clamped(.pi * 1.75), .pi * 1.75)
        XCTAssertEqual(sut.clamped(.pi * 0.85), .pi * 0.5)
        XCTAssertEqual(sut.clamped(.pi * 0.5), .pi * 0.5)
        XCTAssertEqual(sut.clamped(.pi * 1.5), .pi * 1.5)
    }
}

// MARK: - Test internals

private func makeSut(_ start: UIAngle, _ sweep: Double) -> UIAngleSweep {
    .init(start: start, sweep: sweep)
}
