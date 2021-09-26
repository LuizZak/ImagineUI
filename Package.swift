// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/LuizZak/CassowarySwift.git", .branch("cassowary-swift")),
    .package(url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master"))
]

let testUtilsTarget: Target = .target(
name: "TestUtils",
dependencies: [
    "SwiftBlend2D",
    "Blend2DRenderer"
])

#if !os(Windows)

dependencies.append(
    .package(url: "https://github.com/LuizZak/swift-libpng.git", .branch("master"))
)

testUtilsTarget.dependencies.append("LibPNG")

#endif

let package = Package(
    name: "ImagineUI",
    products: [
        .library(
            name: "ImagineUI",
            targets: ["ImagineUI"]),
        .library(
            name: "Blend2DRenderer",
            targets: ["Blend2DRenderer"]),
    ],
    dependencies: dependencies,
    targets: [
        testUtilsTarget,
        
        .target(
            name: "Geometry"),
        .target(
            name: "Text",
            dependencies: ["Geometry"]),
        .target(
            name: "Rendering",
            dependencies: ["Geometry", "Text"]),
        .target(
            name: "ImagineUI",
            dependencies: ["Geometry", "Rendering", "Text", "CassowarySwift"]),
        .target(
            name: "Blend2DRenderer",
            dependencies: ["SwiftBlend2D", "Geometry", "Rendering", "Text"]),
        .testTarget(
            name: "TextTests",
            dependencies: ["Geometry", "Text", "SwiftBlend2D", "Blend2DRenderer", "TestUtils"]),
        .testTarget(
            name: "ImagineUITests",
            dependencies: ["Geometry", "Text", "Rendering", "Blend2DRenderer", "ImagineUI", "TestUtils"]),
        .testTarget(
            name: "Blend2DRendererTests",
            dependencies: ["Geometry", "Text", "Rendering", "SwiftBlend2D", "Blend2DRenderer", "TestUtils"]),
    ]
)
