// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-orthotope",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [.library(name: "Orthotope", targets: ["Orthotope"])],
    traits: [
        .trait(name: "Boundary", description: "Boundary integration"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-vector.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-segment.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-translation.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-coordinate.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-displacement.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-affine.git", branch: "main", traits: [.trait(name: "Tagged", condition: .when(traits: ["Boundary"])), .trait(name: "Vector", condition: .when(traits: ["Boundary"]))]),
        .package(url: "https://github.com/swift-atoms/swift-boundary.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-size.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-point.git", branch: "main", traits: [.trait(name: "Affine", condition: .when(traits: ["Boundary"]))]),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
    ],
    targets: [
        .testTarget(name: "Orthotope Boundary Tests", dependencies: [
                .target(name: "Orthotope"),
                .product(name: "Size", package: "swift-size")
            ], path: "Tests/Orthotope Boundary Tests"),
        .target(name: "Orthotope", dependencies: [
                .product(name: "Vector", package: "swift-vector", condition: .when(traits: ["Boundary"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Boundary"])),
                .product(name: "Segment", package: "swift-segment", condition: .when(traits: ["Boundary"])),
                .product(name: "Translation", package: "swift-translation", condition: .when(traits: ["Boundary"])),
                .product(name: "Coordinate", package: "swift-coordinate", condition: .when(traits: ["Boundary"])),
                .product(name: "Displacement", package: "swift-displacement", condition: .when(traits: ["Boundary"])),
                .product(name: "Affine", package: "swift-affine", condition: .when(traits: ["Boundary"])),
                .product(name: "Boundary", package: "swift-boundary", condition: .when(traits: ["Boundary"])),
            .product(name: "Size", package: "swift-size"),
            .product(name: "Point", package: "swift-point"),
        ]),
        .testTarget(name: "Orthotope Tests", dependencies: [
            .target(name: "Orthotope"),
            .product(name: "Point", package: "swift-point"),
            .product(name: "Tagged", package: "swift-tagged"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
