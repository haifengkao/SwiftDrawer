// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SwiftDrawer",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "SwiftDrawer",
            targets: ["SwiftDrawer"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftDrawer",
            dependencies: []
        ),
    ]
)
