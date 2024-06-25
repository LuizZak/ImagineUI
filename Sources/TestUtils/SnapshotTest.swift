import XCTest
import blend2d
import SwiftBlend2D

#if canImport(LibPNG)

import CLibPNG
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

    public func recordImage(
        _ image: BLImage,
        _ testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

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

    public func assertImageMatch(
        _ image: BLImage,
        _ testName: String = #function,
        record: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

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
            XCTFail(
                "Path to save snapshots to '\(snapshotPath)' exists but is a file, not a folder.",
                file: file,
                line: line
            )
            return
        }

        let actualData = pngFileFromImage(image)

        if !FileManager.default.fileExists(atPath: recordPath) {
            try writePngFile(file: actualData, filename: failurePath)

            XCTFail(
                """
                Could not find recorded snapshot to compare against at expected path \(recordPath)
                Consider recording an expected image with 'recordImage()' prior to using assertImageMatch().
                Actual file available at: \(failurePath)
                """,
                file: file,
                line: line
            )
            return
        }

        let recordedData = try readPngFile(recordPath)

        if recordedData != actualData {
            XCTFail(
                "Snapshot \(formattedTestName) did not match recorded data. Please inspect image at \(failurePath) for further information.",
                file: file,
                line: line
            )

            try createDirectory(atPath: failureFolderPath)

            try copyFile(source: recordPath, dest: expectedPath)
            try writePngFile(file: actualData, filename: failurePath)

            attach(imageFile: expectedPath, keepFile: false)
            attach(imageFile: failurePath, keepFile: false)

            if let (diffData, stats) = produceDiffImage(recordedData, actualData) {
                try writePngFile(file: diffData, filename: diffPath)

                XCTFail("Snapshot \(testName) did not match recorded data. Please inspect image at \(diffPath) for further information.\n\(stats.description)", line: line)
            } else {
                XCTFail("Snapshot \(testName) did not match recorded data. Please inspect image at \(failurePath) for further information.", line: line)
            }
        }
    }

    func produceDiffImage(_ image1: PNGFile, _ image2: PNGFile) -> (PNGFile, ImageDiffStatistics)? {
        guard image1.width == image2.width && image1.height == image2.height else {
            return nil
        }
        guard image1.bitDepth == image2.bitDepth && image1.colorType == image2.colorType else {
            return nil
        }

        var diffImage = image1
        var statistics = ImageDiffStatistics(
            changed: 0,
            total: image1.width * image2.width,
            largestDifference: 0
        )

        // Loop through all pixels, applying a white overlay
        for y in 0..<diffImage.rows.count {
            diffImage.rows[y].withUnsafeMutableBufferPointer { pointer -> Void in
                for x in stride(from: 0, to: diffImage.rowLength, by: 4) {
                    // Color pixel red if two images differ here
                    if
                        image1.rows[y][x] != image2.rows[y][x]
                        || image1.rows[y][x + 1] != image2.rows[y][x + 1]
                        || image1.rows[y][x + 2] != image2.rows[y][x + 2]
                        || image1.rows[y][x + 3] != image2.rows[y][x + 3]
                    {
                        statistics.changed += 1
                        let dist = colorDistance(image1.rows[y][x...(x+3)], image2.rows[y][x...(x+3)])
                        statistics.largestDifference = max(dist, statistics.largestDifference)

                        pointer[x] = 255
                        pointer[x + 1] = 0
                        pointer[x + 2] = 0
                        pointer[x + 3] = 255
                    } else {
                        let factor: UInt8 = 3
                        let base = 255 - 255 / factor

                        pointer[x] = base + pointer[x] / factor
                        pointer[x + 1] = base + pointer[x + 1] / factor
                        pointer[x + 2] = base + pointer[x + 2] / factor
                    }
                }
            }
        }

        return (diffImage, statistics)
    }

    struct ImageDiffStatistics {
        /// The number of pixels that differed between expected/actual images.
        var changed: Int

        /// Total number of pixels that where tested.
        var total: Int

        /// The ratio of changed/total pixels in the image.
        var changeRatio: Double {
            Double(changed) / Double(total)
        }

        /// The largest difference in color between the expected and actual images,
        /// as the magnitude of the difference of the two colors interpreted as
        /// two 4-dimensional vectors.
        var largestDifference: Int

        var description: String {
            """
            Changed: \(changed) of \(total) (\(String(format: "%.2f %%", changeRatio * 100)))
            Largest single-pixel color difference: \(largestDifference) (out of possible \(colorDistance([0, 0, 0, 0], [255, 255, 255, 255])))
            """
        }
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

/// Gets four bytes from each sequence, returning the absolute magnitude of
/// the difference between each grouping of four bytes interpreted as a vector.
func colorDistance<S1: Sequence, S2: Sequence>(_ p1: S1, _ p2: S2) -> Int where S1.Element == png_byte, S2.Element == png_byte {
    let c1 = Array(p1.prefix(4))
    let c2 = Array(p2.prefix(4))

    let diff = zip(c1, c2).map({ Int($0) - Int($1) })
    let mag = diff.map({ $0 * $0 }).reduce(0, +)

    return Int(Double(mag).squareRoot())
}

func pngFileFromImage(_ image: BLImage) -> PNGFile {
    // Attempt codec conversion first
    do {
        let codec = BLImageCodec(builtInCodec: .png)
        let data = try image.toData(codec: codec)

        return try readPngFromData(data)
    } catch {
        let data = image.getImageData()

        assert(data.format == BLFormat.prgb32.rawValue)

        let bytes = UnsafeBufferPointer<UInt32>(
            start: data.pixelData.assumingMemoryBound(to: UInt32.self),
            count: data.stride * Int(data.size.h)
        )

        return PNGFile.fromArgb(bytes, width: image.width, height: image.height)
    }
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
    try FileManager.default.createDirectory(
        at: URL(fileURLWithPath: path),
        withIntermediateDirectories: true,
        attributes: nil
    )
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

    public func recordImage(
        _ image: BLImage,
        _ testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        throw SnapshotError.platformNotSupported
    }

    public func assertImageMatch(
        _ image: BLImage,
        _ testName: String = #function,
        record: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

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
