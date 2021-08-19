import XCTest
import ImagineUI
import Blend2DRenderer
import TestUtils

class LabelTests: SnapshotTestCase {
    override var snapshotPath: String {
        return pathToSnapshots()
    }
    
    override var snapshotFailuresPath: String {
        return pathToSnapshotFailures()
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try UISettings.initialize(.init(fontManager: Blend2DFontManager(), defaultFontPath: "\(pathToResources())/NotoSans-Regular.ttf"))
    }
    
    func testSnapshot() {
        let label = Label()
        label.areaIntoConstraintsMask = [.location]
        label.text = "A Label"
        label.performLayout()
        
        matchSnapshot(label)
    }
}
