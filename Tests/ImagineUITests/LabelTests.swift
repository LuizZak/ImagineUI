import XCTest
import ImagineUI
import TestUtils

class LabelTests: SnapshotTestCase {
    override var snapshotPath: String {
        return pathToSnapshots()
    }
    
    override var snapshotFailuresPath: String {
        return pathToSnapshotFailures()
    }
    
    override func setUp() {
        super.setUp()
        
        Fonts.fontFilePath = "\(pathToResources())/NotoSans-Regular.ttf"
    }
    
    func testSnapshot() {
        let label = Label()
        label.areaIntoConstraintsMask = [.location]
        label.text = "A Label"
        label.performLayout()
        
        matchSnapshot(label)
    }
}
