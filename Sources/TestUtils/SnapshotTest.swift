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
    
    public func assertImageMatch(_ image: BLImage,
                                 _ testName: String = #function,
                                 record: Bool = false,
                                 line: UInt = #line) {
        
        // Prepare test name
        let formatterTestName: String
        if let index = testName.firstIndex(of: "(") {
            formatterTestName = String(testName[testName.startIndex..<index])
        } else {
            formatterTestName = testName
        }
        
        let snapshotsFolder = snapshotPath
        let failuresFolder = snapshotFailuresPath
        let recordPath = snapshotsFolder + "/\(formatterTestName).png"
        let expectedPath = failuresFolder + "/\(formatterTestName)_expected.png"
        let failurePath = failuresFolder + "/\(formatterTestName)_actual.png"
        let diffPath = failuresFolder + "/\(formatterTestName)_diff.png"

        var isDirectory: Bool = false
        if !pathExists(snapshotsFolder, isDirectory: &isDirectory) {
            do {
                try createDirectory(atPath: snapshotsFolder)
            } catch {
                XCTFail("Error attempting to create snapshots directory '\(snapshotsFolder)': \(error)", line: line)
                return
            }
        } else if !isDirectory {
            XCTFail("Path to save snapshots to '\(snapshotsFolder)' exists but is a file, not a folder.", line: line)
            return
        }

        if record {
            do {
                let pngFile = pngFileFromImage(image)
                
                try writePngFile(file: pngFile, filename: recordPath)

                XCTFail("Successfully recorded snapshot for \(formatterTestName)", line: line)
            } catch {
                XCTFail("Error attempting to save snapshot file at '\(recordPath)': \(error)", line: line)
                return
            }
        } else {
            do {
                let recordedData = try readPngFile(recordPath)
                let actualData = pngFileFromImage(image)

                if recordedData != actualData {
                    XCTFail("Snapshot \(formatterTestName) did not match recorded data. Please inspect image at \(failurePath) for further information.", line: line)
                    
                    try createDirectory(atPath: failuresFolder)
                    
                    try copyFile(source: recordPath, dest: expectedPath)
                    try writePngFile(file: actualData, filename: failurePath)
                    
                    if let diffData = produceDiffImage(recordedData, actualData) {
                        try writePngFile(file: diffData, filename: diffPath)
                    }
                }
            } catch {
                XCTFail("Error attempting to read and compare snapshot '\(formatterTestName)': \(error)", line: line)
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
