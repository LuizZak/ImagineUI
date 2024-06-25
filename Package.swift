// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/LuizZak/CassowarySwift.git", .branch("cassowary-swift-optimizations")),
    .package(url: "https://github.com/LuizZak/swift-blend2d.git", .branch("master")),
    .package(url: "https://github.com/LuizZak/swift-bezier.git", .branch("main"))
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
    platforms: [
        .macOS(.v10_12)
    ],
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
            name: "Geometry",
            dependencies: ["SwiftBezier"]),
        .target(
            name: "RenderingCommon",
            dependencies: ["Geometry"]),
        .target(
            name: "Text",
            dependencies: ["RenderingCommon", "Geometry"]),
        .target(
            name: "Rendering",
            dependencies: ["RenderingCommon", "Geometry", "Text"]),
        .target(
            name: "ImagineUICore",
            dependencies: ["RenderingCommon", "Geometry", "Rendering", "Text", "CassowarySwift"]),
        .target(
            name: "ImagineUI",
            dependencies: ["ImagineUICore"]),
        .target(
            name: "Blend2DRenderer",
            dependencies: ["SwiftBlend2D", "RenderingCommon", "Geometry", "Rendering", "Text"]),
        .testTarget(
            name: "GeometryTests",
            dependencies: ["Geometry"]),
        .testTarget(
            name: "TextTests",
            dependencies: ["RenderingCommon", "Geometry", "Text", "SwiftBlend2D", "Blend2DRenderer", "TestUtils"]),
        .testTarget(
            name: "ImagineUICoreTests",
            dependencies: ["RenderingCommon", "Geometry", "Text", "Rendering", "Blend2DRenderer", "ImagineUICore", "TestUtils"]),
        .testTarget(
            name: "Blend2DRendererTests",
            dependencies: ["RenderingCommon", "Geometry", "Text", "Rendering", "SwiftBlend2D", "Blend2DRenderer", "TestUtils"]),
    ]
)
