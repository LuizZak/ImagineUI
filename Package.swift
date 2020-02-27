// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImagineUI",
    products: [
        .library(
            name: "ImagineUI",
            targets: ["ImagineUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LuizZak/CassowarySwift.git", .branch("master")),
        .package(url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "ImagineUI",
            dependencies: ["Cassowary", "SwiftBlend2D"]),
        .target(
            name: "_CLibPNG",
            linkerSettings: [
                .linkedFramework("z")
            ]),
        .target(
            name: "_LibPNG",
            dependencies: ["_CLibPNG"]),
        .target(
            name: "TestUtils",
            dependencies: ["SwiftBlend2D", "LibPNG"]),
        .testTarget(
            name: "ImagineUITests",
            dependencies: ["ImagineUI"]),
    ]
)
