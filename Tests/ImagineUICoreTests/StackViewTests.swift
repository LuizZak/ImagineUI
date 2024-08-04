import XCTest
import Blend2DRenderer
import TestUtils

@testable import ImagineUICore

class StackViewTests: SnapshotTestCase {
    override var snapshotPath: String {
        return TestPaths.pathToSnapshots(testTarget: "ImagineUICoreTests")
    }

    override var snapshotFailuresPath: String {
        return TestPaths.pathToSnapshotFailures(testTarget: "ImagineUICoreTests")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        ControlView.globallyCacheAsBitmap = false

        try UISettings.initialize(
            .init(
                fontManager: Blend2DFontManager(),
                defaultFontPath: TestPaths.pathToTestFontFace(),
                timeInSecondsFunction: { 0.0 }
            )
        )
    }

    func testSnapshot_horizontal_singleView() throws {
        let sut = StackView(orientation: .horizontal)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestLabel("Label 1")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_horizontal_multiView() throws {
        let sut = StackView(orientation: .horizontal)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestLabel("Label 1")
        sut.ext_addArrangedTestLabel("Label 2")
        sut.ext_addArrangedTestLabel("Label 3")
        sut.ext_addArrangedTestLabel("Label 4")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_horizontal_singleView_complex() throws {
        let sut = StackView(orientation: .horizontal)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestButton("Button 1")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_horizontal_multiView_complex() throws {
        let sut = StackView(orientation: .horizontal)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestButton("Button 1")
        sut.ext_addArrangedTestButton("Button 2")
        sut.ext_addArrangedTestButton("Button 3")
        sut.ext_addArrangedTestButton("Button 4")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_vertical_singleView() throws {
        let sut = StackView(orientation: .vertical)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestLabel("Label 1")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_vertical_multiView() throws {
        let sut = StackView(orientation: .vertical)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestLabel("Label 1")
        sut.ext_addArrangedTestLabel("Label 2")
        sut.ext_addArrangedTestLabel("Label 3")
        sut.ext_addArrangedTestLabel("Label 4")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_vertical_singleView_complex() throws {
        let sut = StackView(orientation: .vertical)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestButton("Button 1")

        sut.performLayout()

        try matchSnapshot(sut)
    }

    func testSnapshot_vertical_multiView_complex() throws {
        let sut = StackView(orientation: .vertical)
        sut.areaIntoConstraintsMask = [.location]

        sut.ext_addArrangedTestButton("Button 1")
        sut.ext_addArrangedTestButton("Button 2")
        sut.ext_addArrangedTestButton("Button 3")
        sut.ext_addArrangedTestButton("Button 4")

        sut.performLayout()

        try matchSnapshot(sut)
    }
}

// MARK: - Test internals

private extension StackView {
    func ext_addArrangedTestLabel(_ text: AttributedText) {
        let label = Label(textColor: .white)
        label.attributedText = text
        addArrangedSubview(label)
    }

    func ext_addArrangedTestButton(_ text: AttributedText) {
        let button = Button(title: "")
        button.label.attributedText = text
        addArrangedSubview(button)
    }
}
