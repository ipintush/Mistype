// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mistype",
    platforms: [.macOS(.v11)],
    targets: [
        .executableTarget(
            name: "Mistype",
            path: "Sources/Mistype"
        )
    ]
)
