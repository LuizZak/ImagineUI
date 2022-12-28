import XCTest
import Blend2DRenderer
import TestUtils

@testable import ImagineUICore

class LabelTests: SnapshotTestCase {
    override var snapshotPath: String {
        return TestPaths.pathToSnapshots(testTarget: "ImagineUICoreTests")
    }
    
    override var snapshotFailuresPath: String {
        return TestPaths.pathToSnapshotFailures(testTarget: "ImagineUICoreTests")
    }
    
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
    
    func testSnapshot() throws {
        let label = Label(textColor: .white)
        label.areaIntoConstraintsMask = [.location]
        label.text = "A Label"
        label.performLayout()
        
        try matchSnapshot(label)
    }
}
