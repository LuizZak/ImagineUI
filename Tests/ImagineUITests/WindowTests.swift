import XCTest
@testable import ImagineUI
import Blend2DRenderer
import TestUtils

class WindowTests: XCTestCase {
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

    func testPerformnLayout_triggersReLayoutAndInvalidation() {
        // MARK: Arrange
        
        let dummyDelegate = DummyDelegate()
        let sut = Window(area: .zero, title: "Test Window")
        sut.invalidationDelegate = dummyDelegate
        sut.areaIntoConstraintsMask = [.location]
        sut.setShouldCompress(true)
        sut.rootControlSystem = DefaultControlSystem()
        
        let boundsCheckbox = Checkbox(title: "View Bounds")
        let layoutCheckbox = Checkbox(title: "Layout Guides")
        let constrCheckbox = Checkbox(title: "Constraints")
        let stackView = StackView(orientation: .vertical)
        stackView.spacing = 4
        
        stackView.addArrangedSubview(boundsCheckbox)
        stackView.addArrangedSubview(layoutCheckbox)
        stackView.addArrangedSubview(constrCheckbox)
        
        sut.addSubview(stackView)
        
        stackView.layout.makeConstraints { make in
            make.left == sut.contentsLayoutArea + 12
            make.top == sut.contentsLayoutArea + 12
            make.bottom <= sut.contentsLayoutArea - 12
            make.right <= sut.contentsLayoutArea - 12
        }

        sut.performLayout()

        // Change target layout size, flag for layout, and request new layout size
        sut.targetSize = .init(width: 300, height: 300)
        sut.setNeedsLayout()
        dummyDelegate.rootViewInvalidateRectCalls.removeAll()

        // MARK: Act

        sut.performLayout()

        // MARK: Assert

        XCTAssertEqual(sut.size, .init(width: 300, height: 300))
        XCTAssertNotEqual(dummyDelegate.rootViewInvalidateRectCalls.count, 0)
        XCTAssertTrue(dummyDelegate.rootViewInvalidateRectCalls.contains { $0.1 == .init(x: -2.5, y: -2.5, width: 305.0, height: 305.0) })
    }
}

private class DummyDelegate: RootViewRedrawInvalidationDelegate {
    var rootViewInvalidateRectCalls: [(rootView: RootView, rect: UIRectangle)] = []

    func rootView(_ rootView: RootView, invalidateRect rect: UIRectangle) {
        rootViewInvalidateRectCalls.append((rootView, rect))
    }
}
