import XCTest
import blend2d
import SwiftBlend2D

#if canImport(LibPNG)

import LibPNG

open class SnapshotTestCase: XCTestCase {
    open var snapshotPath: String {
        fatalError("Should be overridden by subclasses")
    }
    
    open var snapshotFailuresPath: String {
        fatalError("Should be overridden by subclasses")
    }
    
    /// Forces all `assertImageMatch` invocations to record images instead of
    /// testing against recorded images.
    public var forceRecordMode = false
    
    func prepareTestName(_ testName: String) -> String {
        let formattedTestName: String
        if let index = testName.firstIndex(of: "(") {
           formattedTestName = String(testName[testName.startIndex..<index])
        } else {
           formattedTestName = testName
        }
        
        return formattedTestName
    }
    
    func prepareCompoundPath(folder: String, _ testName: String) -> String {
        let formattedTestName = prepareTestName(testName)
        
        return "\(folder)/\(formattedTestName)"
    }
    
    public func recordImage(_ image: BLImage,
                            _ testName: String = #function,
                            file: StaticString = #file,
                            line: UInt = #line) throws {
        
        let formattedTestName = prepareTestName(testName)
        let folderName = "\(type(of: self))"
        let snapshotFolderPath = snapshotPath + "/\(folderName)"
        let path = prepareCompoundPath(folder: folderName, testName)
        
        let recordPath = snapshotPath + "/\(path).png"
        
        let pngFile = pngFileFromImage(image)
        
        try createDirectory(atPath: snapshotFolderPath)
        try writePngFile(file: pngFile, filename: recordPath)
        
        attach(imageFile: recordPath, keepFile: true)
        
        XCTFail("Successfully recorded snapshot for \(formattedTestName)", file: file, line: line)
    }
    
    public func assertImageMatch(_ image: BLImage,
                                 _ testName: String = #function,
                                 record: Bool = false,
                                 file: StaticString = #file,
                                 line: UInt = #line) throws {
        
        if record || forceRecordMode {
            try recordImage(image, testName, file: file, line: line)
            return
        }
        
        // Prepare test name
        let formattedTestName = prepareTestName(testName)
        let folderName = "\(type(of: self))"
        let path = prepareCompoundPath(folder: folderName, testName)
        
        let recordPath = snapshotPath + "/\(path).png"
        let expectedPath = snapshotFailuresPath + "/\(path)_expected.png"
        let failurePath = snapshotFailuresPath + "/\(path)_actual.png"
        let diffPath = snapshotFailuresPath + "/\(path)_diff.png"
        let failureFolderPath = snapshotFailuresPath + "/\(folderName)"

        var isDirectory: Bool = false
        if !pathExists(snapshotPath, isDirectory: &isDirectory) {
            try createDirectory(atPath: snapshotPath)
        } else if !isDirectory {
            XCTFail("Path to save snapshots to '\(snapshotPath)' exists but is a file, not a folder.")
            return
        }

        let recordedData = try readPngFile(recordPath)
        let actualData = pngFileFromImage(image)

        if recordedData != actualData {
            XCTFail("Snapshot \(formattedTestName) did not match recorded data. Please inspect image at \(failurePath) for further information.", file: file, line: line)
            
            try createDirectory(atPath: failureFolderPath)
            
            try copyFile(source: recordPath, dest: expectedPath)
            try writePngFile(file: actualData, filename: failurePath)
            
            attach(imageFile: expectedPath, keepFile: false)
            attach(imageFile: failurePath, keepFile: false)
            
            if let diffData = produceDiffImage(recordedData, actualData) {
                try writePngFile(file: diffData, filename: diffPath)
                
                attach(imageFile: diffPath, keepFile: false)
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
    
    func attach(imageFile: String, keepFile: Bool) {
        #if os(macOS)

        guard let image = NSImage(contentsOfFile: imageFile) else {
            return
        }
        
        let attachment = XCTAttachment(image: image)
        attachment.lifetime = keepFile ? .keepAlways : .deleteOnSuccess
        attachment.name = URL(fileURLWithPath: imageFile).lastPathComponent
        
        add(attachment)

        #endif
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

#else

open class SnapshotTestCase: XCTestCase {
    open var snapshotPath: String {
        fatalError("Should be overridden by subclasses")
    }
    
    open var snapshotFailuresPath: String {
        fatalError("Should be overridden by subclasses")
    }
    
    public var forceRecordMode = false
    
    public func recordImage(_ image: BLImage,
                            _ testName: String = #function,
                            file: StaticString = #file,
                            line: UInt = #line) throws {
        
        throw SnapshotError.platformNotSupported
    }
    
    public func assertImageMatch(_ image: BLImage,
                                 _ testName: String = #function,
                                 record: Bool = false,
                                 file: StaticString = #file,
                                 line: UInt = #line) throws {
        
        throw SnapshotError.platformNotSupported
    }
}

#endif

enum SnapshotError: Error, CustomStringConvertible {
    case platformNotSupported

    var description: String {
        switch self {
        case .platformNotSupported:
            return "Platform does not support LibPNG and cannot do snapshot testing."
        }
    }
}
