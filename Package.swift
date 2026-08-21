// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-scheduler",
    platforms: [
        .macOS(.v27)
    ],
    products: [
        .library(name: "Scheduler", targets: ["Scheduler"])
    ],
    targets: [

        .target(
            name: "Scheduler",
            path: "Sources/Scheduler"
        ),

        .testTarget(
            name: "Scheduler Tests",
            dependencies: ["Scheduler"],
            path: "Tests/Scheduler Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let membrane: [SwiftSetting] = [
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("ExistentialAny"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + membrane
}
