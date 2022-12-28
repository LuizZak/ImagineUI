import XCTest
import Blend2DRenderer
import TestUtils

@testable import ImagineUICore

class UISettingsTests: XCTestCase {
    func testInitialize() throws {
        let config = UISettings.Configuration(
            fontManager: Blend2DFontManager(),
            defaultFontPath: TestPaths.pathToTestFontFace(),
            timeInSecondsFunction: { 42.0 }
        )
        
        try UISettings.initialize(config)
        
        XCTAssertEqual(Fonts.fontFilePath, TestPaths.pathToTestFontFace())
        XCTAssertEqual(UISettings.timeInSeconds(), 42.0)
    }
}
