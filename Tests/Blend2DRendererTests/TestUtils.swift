import Foundation

// TODO: Create a reusable target to get rid of copies of this file across test targets

// TODO: Make this path shenanigans portable to Windows

let rootPath: String = "/"
let pathSeparator: Character = "/"

func pathToSnapshots() -> String {
    let file = #file

    return rootPath + file.split(separator: pathSeparator).dropLast(1).joined(separator: String(pathSeparator)) + "\(pathSeparator)Snapshots"
}

func pathToSnapshotFailures() -> String {
    let file = #file

    return rootPath + file.split(separator: pathSeparator).dropLast(1).joined(separator: String(pathSeparator))
        + "\(pathSeparator)SnapshotFailures" /* This path should be kept in .gitignore */
}

func pathToResources() -> String {
    let file = #file
    
    return rootPath + file.split(separator: pathSeparator).dropLast(3).joined(separator: String(pathSeparator))
        + "\(pathSeparator)Resources"
}
