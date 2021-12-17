import XCTest
@testable import ImagineUICore
import Blend2DRenderer
import TestUtils

class RootViewTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try UISettings.initialize(
            .init(
                fontManager: Blend2DFontManager(),
                defaultFontPath: TestPaths.pathToTestFontFace(),
                timeInSecondsFunction: { 0.0 }
            )
        )
    }

    func testInvalidateBounds_invokesDelegate() {
        let delegate = DummyDelegate()
        let rect = UIRectangle(x: 1, y: 2, width: 3, height: 4)
        let sut = RootView()
        sut.clipToBounds = false
        sut.invalidationDelegate = delegate

        sut.invalidate(bounds: rect)

        XCTAssertNotEqual(delegate.rootViewInvalidateRectCalls.count, 0)
        XCTAssertTrue(delegate.rootViewInvalidateRectCalls.contains { $0.0 === sut })
        XCTAssertTrue(delegate.rootViewInvalidateRectCalls.contains { $0.1 == rect })
    }

    func testSetNeedsLayout_invokesDelegate() {
        let delegate = DummyDelegate()
        let sut = RootView()
        sut.invalidationDelegate = delegate

        sut.setNeedsLayout()

        XCTAssertNotEqual(delegate.rootViewInvalidatedLayoutCalls.count, 0)
        XCTAssertTrue(delegate.rootViewInvalidatedLayoutCalls.contains { $0 === sut })
    }
}

private class DummyDelegate: RootViewRedrawInvalidationDelegate {
    var rootViewInvalidatedLayoutCalls: [RootView] = []
    var rootViewInvalidateRectCalls: [(rootView: RootView, rect: UIRectangle)] = []

    func rootViewInvalidatedLayout(_ rootView: RootView) {
        rootViewInvalidatedLayoutCalls.append(rootView)
    }

    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        rootViewInvalidateRectCalls.append((rootView, rect))
    }
}
