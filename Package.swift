// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwitchBack",
    platforms: [.macOS(.v11)],
    targets: [
        .executableTarget(
            name: "SwitchBack",
            path: "Sources/SwitchBack"
        )
    ]
)
