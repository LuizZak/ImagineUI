import XCTest
@testable import ImagineUICore
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

    func testPerformLayout_updatingLayout_triggersInvalidation() {
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
        sut.targetSize = .init(width: 150, height: 150)
        sut.performLayout()
        dummyDelegate.rootViewInvalidateRectCalls.removeAll()
        dummyDelegate.rootViewInvalidatedLayoutCalls.removeAll()
        sut.targetSize = .init(width: 300, height: 300)

        // MARK: Act

        sut.performLayout()

        // MARK: Assert
        let expected = UIRectangle(x: -1.5, y: -1.5, width: 303.0, height: 303.0)

        XCTAssertEqual(sut.size, .init(width: 300, height: 300))
        let areas = dummyDelegate.rootViewInvalidateRectCalls.map(\.rect)
        XCTAssertNotEqual(areas.count, 0)
        XCTAssertTrue(areas.contains(expected), "\(areas)")
    }

    func testTargetSizeChange_triggersSetNeedsLayout() {
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
        sut.performLayout()
        dummyDelegate.rootViewInvalidateRectCalls.removeAll()
        dummyDelegate.rootViewInvalidatedLayoutCalls.removeAll()

        // MARK: Act

        sut.targetSize = .init(width: 400, height: 400)

        // MARK: Assert

        XCTAssertEqual(sut.size, .init(width: 300, height: 300))
        XCTAssertNotEqual(dummyDelegate.rootViewInvalidatedLayoutCalls.count, 0)
        XCTAssertTrue(dummyDelegate.rootViewInvalidatedLayoutCalls.contains { $0 === sut })
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
