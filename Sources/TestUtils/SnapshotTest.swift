import XCTest
import blend2d
import LibPNG
import SwiftBlend2D

open class SnapshotTestCase: XCTestCase {
    open var snapshotPath: String {
        fatalError("Should be overriden by subclasses")
    }
    
    open var snapshotFailuresPath: String {
        fatalError("Should be overriden by subclasses")
    }
    
    func prepareTestName(_ testName: String) -> String {
        let formattedTestName: String
        if let index = testName.firstIndex(of: "(") {
           formattedTestName = String(testName[testName.startIndex..<index])
        } else {
           formattedTestName = testName
        }
        
        return formattedTestName
    }
    
    func prepareCompoundPath(_ testName: String) -> String {
        let folder = "\(type(of: self))"
        let formattedTestName = prepareTestName(testName)
        
        return "\(folder)/\(formattedTestName)"
    }
    
    public func recordImage(_ image: BLImage,
                            _ testName: String = #function,
                            file: StaticString = #file,
                            line: UInt = #line) {
        
        let formattedTestName = prepareTestName(testName)
        let path = prepareCompoundPath(testName)
        
        let recordPath = snapshotPath + "/\(path).png"
        
        do {
            let pngFile = pngFileFromImage(image)
            
            try createDirectory(atPath: snapshotPath + "/\((path as NSString).deletingLastPathComponent)")
            try writePngFile(file: pngFile, filename: recordPath)

            XCTFail("Successfully recorded snapshot for \(formattedTestName)", file: file, line: line)
        } catch {
            XCTFail("Error attempting to save snapshot file at '\(recordPath)': \(error)", file: file, line: line)
        }
    }
    
    public func assertImageMatch(_ image: BLImage,
                                 _ testName: String = #function,
                                 record: Bool = false,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
        
        // Prepare test name
        let formattedTestName = prepareTestName(testName)
        let path = prepareCompoundPath(testName)
        
        let recordPath = snapshotPath + "/\(path).png"
        let expectedPath = snapshotFailuresPath + "/\(path)_expected.png"
        let failurePath = snapshotFailuresPath + "/\(path)_actual.png"
        let diffPath = snapshotFailuresPath + "/\(path)_diff.png"

        var isDirectory: Bool = false
        if !pathExists(snapshotPath, isDirectory: &isDirectory) {
            do {
                try createDirectory(atPath: snapshotPath)
            } catch {
                XCTFail("Error attempting to create snapshots directory '\(snapshotPath)': \(error)", file: file, line: line)
                return
            }
        } else if !isDirectory {
            XCTFail("Path to save snapshots to '\(snapshotPath)' exists but is a file, not a folder.", file: file, line: line)
            return
        }

        if record {
            do {
                let pngFile = pngFileFromImage(image)
                
                try createDirectory(atPath: snapshotPath + "/\((path as NSString).deletingLastPathComponent)")
                try writePngFile(file: pngFile, filename: recordPath)

                XCTFail("Successfully recorded snapshot for \(formattedTestName)", file: file, line: line)
            } catch {
                XCTFail("Error attempting to save snapshot file at '\(recordPath)': \(error)", file: file, line: line)
                return
            }
        } else {
            do {
                let recordedData = try readPngFile(recordPath)
                let actualData = pngFileFromImage(image)

                if recordedData != actualData {
                    XCTFail("Snapshot \(formattedTestName) did not match recorded data. Please inspect image at \(failurePath) for further information.", file: file, line: line)
                    
                    try createDirectory(atPath: snapshotFailuresPath)
                    
                    try copyFile(source: recordPath, dest: expectedPath)
                    try writePngFile(file: actualData, filename: failurePath)
                    
                    if let diffData = produceDiffImage(recordedData, actualData) {
                        try writePngFile(file: diffData, filename: diffPath)
                    }
                }
            } catch {
                XCTFail("Error attempting to read and compare snapshot '\(formattedTestName)': \(error)", file: file, line: line)
            }
        }
    }
    
    public func produceDiffImage(_ image1: PNGFile, _ image2: PNGFile) -> PNGFile? {
        guard image1.width == image2.width && image1.height == image2.height else {
            return nil
        }
        guard image1.bitDepth == image2.bitDepth && image1.colorType == image2.colorType else {
            return nil
        }
        
        var diffImage = image1
        
        // Loop through all pixels, applying a white overlay
        for y in 0..<diffImage.rows.count {
            for x in stride(from: 0, to: diffImage.rowLength, by: 4) {
                diffImage.rows[y].withUnsafeMutableBufferPointer { pointer -> Void in
                    let factor: UInt8 = 3
                    let base = 255 - 255 / factor
                    
                    pointer[x] = base + pointer[x] / factor
                    pointer[x + 1] = base + pointer[x + 1] / factor
                    pointer[x + 2] = base + pointer[x + 2] / factor
                    
                    // Color pixel red if two images differ here
                    if image1.rows[y][x] != image2.rows[y][x]
                        || image1.rows[y][x + 1] != image2.rows[y][x + 1]
                        || image1.rows[y][x + 2] != image2.rows[y][x + 2]
                        || image1.rows[y][x + 3] != image2.rows[y][x + 3] {
                        
                        pointer[x] = 255
                        pointer[x + 1] = 0
                        pointer[x + 2] = 0
                        pointer[x + 3] = 255
                    }
                }
            }
        }
        
        return diffImage
    }
}

func pngFileFromImage(_ image: BLImage) -> PNGFile {
    let data = image.getImageData()
    
    assert(data.format == BLFormat.prgb32.rawValue)
    
    let bytes =
        UnsafeBufferPointer<UInt32>(start: data.pixelData.assumingMemoryBound(to: UInt32.self),
                                    count: data.stride * Int(data.size.h))
    
    return PNGFile.fromArgb(bytes, width: image.width, height: image.height)
}

// TODO: Make this path shenanigans portable to Windows

let rootPath: String = "/"
let pathSeparator: Character = "/"

func pathExists(_ path: String, isDirectory: inout Bool) -> Bool {
    var objcBool: ObjCBool = ObjCBool(false)
    defer {
        isDirectory = objcBool.boolValue
    }
    return FileManager.default.fileExists(atPath: path, isDirectory: &objcBool)
}

func createDirectory(atPath path: String) throws {
    try FileManager.default.createDirectory(at: URL(fileURLWithPath: path),
                                            withIntermediateDirectories: true,
                                            attributes: nil)
}

func copyFile(source: String, dest: String) throws {
    if FileManager.default.fileExists(atPath: dest) {
        try FileManager.default.removeItem(atPath: dest)
    }
    try FileManager.default.copyItem(atPath: source, toPath: dest)
}
