import Foundation

public enum TestPaths {
    
}

public extension TestPaths {

    // MARK: - URL computing for folders of interest

    static func rootProjectFolderURL() -> URL {
        let file = #filePath
        let fileUrl = URL(fileURLWithPath: file)

        return cdToParentPath(fileUrl, count: 3)
    }

    static func testFolderURL(testTarget: String) -> URL {
        cdPath(rootProjectFolderURL(), folders: ["Tests", testTarget])
    }

    static func resourcesFolderURL() -> URL {
        cdPath(rootProjectFolderURL(), folder: "Resources")
    }

    // MARK: - Path computing

    static func pathToSnapshots(testTarget: String) -> String {
        cdPath(testFolderURL(testTarget: testTarget), folder: "Snapshots").path
    }

    static func pathToSnapshotFailures(testTarget: String) -> String {
        cdPath(testFolderURL(testTarget: testTarget), folder: "SnapshotFailures").path /* This path should be kept in .gitignore */
    }

    static func pathToResources() -> String {
        let rootUrl = rootProjectFolderURL()

        return cdPath(rootUrl, folder: "Resources").path
    }

    static func pathToTestTexture() -> String {
        let resources = resourcesFolderURL()

        return fileIn(folder: resources, fileName: "texture", extension: "jpeg").path
    }

    static func pathToTestFontFace() -> String {
        let resources = resourcesFolderURL()

        return fileIn(folder: resources, fileName: "NotoSans-Regular", extension: "ttf").path
    }

    // MARK: - Path Helper Functions

    static func cdToParentPath(_ path: URL, count: Int) -> URL {
        var newPath = path
        for _ in 0..<count {
        newPath.deleteLastPathComponent()
        }

        return newPath
    }

    static func cdPath(_ path: URL, folder: String) -> URL {
        path.appendingPathComponent(folder)
    }

    static func cdPath(_ path: URL, folders: [String]) -> URL {
        folders.reduce(path, { cdPath($0, folder: $1) })
    }

    static func fileIn(folder: URL, fileName: String, extension ext: String) -> URL {
        folder.appendingPathComponent(fileName).appendingPathExtension(ext)
    }

    static func pathExists(_ path: String, isDirectory: inout Bool) -> Bool {
        var objcBool: ObjCBool = ObjCBool(false)
        defer {
            isDirectory = objcBool.boolValue
        }
        return FileManager.default.fileExists(atPath: path, isDirectory: &objcBool)
    }

    static func createDirectory(atPath path: String) throws {
        try FileManager.default.createDirectory(at: URL(fileURLWithPath: path),
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }

    static func copyFile(source: String, dest: String) throws {
        if FileManager.default.fileExists(atPath: dest) {
            try FileManager.default.removeItem(atPath: dest)
        }
        try FileManager.default.copyItem(atPath: source, toPath: dest)
    }
}