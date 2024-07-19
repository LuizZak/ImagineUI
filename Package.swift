// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/LuizZak/CassowarySwift.git", branch: "cassowary-swift-optimizations"),
    .package(url: "https://github.com/LuizZak/swift-blend2d.git", branch: "master"),
    .package(url: "https://github.com/LuizZak/swift-bezier.git", branch: "main"),
]

let testUtilsTarget: Target = .target(
name: "TestUtils",
dependencies: [
    .product(name: "SwiftBlend2D", package: "swift-blend2d"),
    "Blend2DRenderer"
])

#if !os(Windows)

dependencies.append(
    .package(url: "https://github.com/LuizZak/swift-libpng.git", branch: "master")
)

testUtilsTarget.dependencies.append(.product(name: "LibPNG", package: "swift-libpng"))

#endif

let package = Package(
    name: "ImagineUI",
    products: [
        .library(
            name: "ImagineUI",
            targets: ["ImagineUI"]
        ),
        .library(
            name: "Blend2DRenderer",
            targets: ["Blend2DRenderer"]
        ),
    ],
    dependencies: dependencies,
    targets: [
        testUtilsTarget,

        .target(
            name: "Geometry",
            dependencies: [.product(name: "SwiftBezier", package: "swift-bezier")]
        ),
        .target(
            name: "RenderingCommon",
            dependencies: ["Geometry"]
        ),
        .target(
            name: "Text",
            dependencies: ["RenderingCommon", "Geometry"]
        ),
        .target(
            name: "Rendering",
            dependencies: ["RenderingCommon", "Geometry", "Text"]
        ),
        .target(
            name: "ImagineUICore",
            dependencies: ["RenderingCommon", "Geometry", "Rendering", "Text", .product(name: "CassowarySwift", package: "CassowarySwift")]
        ),
        .target(
            name: "ImagineUI",
            dependencies: ["ImagineUICore"]
        ),
        .target(
            name: "Blend2DRenderer",
            dependencies: [.product(name: "SwiftBlend2D", package: "swift-blend2d"), "RenderingCommon", "Geometry", "Rendering", "Text"]
        ),
        .testTarget(
            name: "GeometryTests",
            dependencies: ["Geometry"]
        ),
        .testTarget(
            name: "TextTests",
            dependencies: ["RenderingCommon", "Geometry", "Text", .product(name: "SwiftBlend2D", package: "swift-blend2d"), "Blend2DRenderer", "TestUtils"]
        ),
        .testTarget(
            name: "ImagineUICoreTests",
            dependencies: ["RenderingCommon", "Geometry", "Text", "Rendering", "Blend2DRenderer", "ImagineUICore", "TestUtils"],
            exclude: [
                "Snapshots",
                "SnapshotFailures",
            ]
        ),
        .testTarget(
            name: "Blend2DRendererTests",
            dependencies: ["RenderingCommon", "Geometry", "Text", "Rendering", .product(name: "SwiftBlend2D", package: "swift-blend2d"), "Blend2DRenderer", "TestUtils"],
            exclude: [
                "Snapshots",
                "SnapshotFailures",
            ]
        ),
    ]
)
