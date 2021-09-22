import XCTest
import ImagineUI
import Blend2DRenderer
import TestUtils

class LabelTests: SnapshotTestCase {
    override var snapshotPath: String {
        return TestPaths.pathToSnapshots(testTarget: "ImagineUITests")
    }
    
    override var snapshotFailuresPath: String {
        return TestPaths.pathToSnapshotFailures(testTarget: "ImagineUITests")
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
    
    func testSnapshot() {
        let label = Label()
        label.areaIntoConstraintsMask = [.location]
        label.text = "A Label"
        label.performLayout()
        
        matchSnapshot(label)
    }
}
